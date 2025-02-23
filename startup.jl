function initiateHouseholds(model, households_initial_ages)
    for location in HOUSE_LOCATION_INSTANCES
        for size in [1, 2, 3, 4, 5]
            number_of_households = HOUSEHOLDS_SIZES_MAP[size][location]
            for i in 1:number_of_households
                if length(households_initial_ages) == 0
                    # this means we would have slightly more households due to round()
                    # doesn't really matter, lets just ignore the remaining...
                    # maybe change to floor?
                    return
                end
                initial_age = households_initial_ages[1]
                splice!(households_initial_ages, 1)
                percentile = rand(1:100)
                actualSize = get_household_size(size)
                unemployedTime = 0
                if rand() < model.unemploymentRate
                    unemployedTime = Int64(round(rand(Normal(6.0, 3.0))))
                    if unemployedTime < 1
                        unemployedTime = 1
                    end
                end
                add_household(model, generateInitialWealth(initial_age, percentile, actualSize, location), initial_age, actualSize, location, percentile=percentile, unemployedTime=unemployedTime)
            end
        end
    end
end

function assignHousesToHouseholds(model)
    houses_sizes = Dict()
    for location in HOUSE_LOCATION_INSTANCES
        houses_sizes[location] = rand(20:29, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan29][location])))
        houses_sizes[location] = vcat(houses_sizes[location], rand(30:39, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan39][location]))))
        houses_sizes[location] = vcat(houses_sizes[location], rand(40:49, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan49][location]))))
        houses_sizes[location] = vcat(houses_sizes[location], rand(50:59, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan59][location]))))
        houses_sizes[location] = vcat(houses_sizes[location], rand(60:79, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan79][location]))))
        houses_sizes[location] = vcat(houses_sizes[location], rand(80:99, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan99][location]))))
        houses_sizes[location] = vcat(houses_sizes[location], rand(100:119, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan119][location]))))
        houses_sizes[location] = vcat(houses_sizes[location], rand(120:149, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan149][location]))))
        houses_sizes[location] = vcat(houses_sizes[location], rand(150:199, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan199][location]))))
        houses_sizes[location] = vcat(houses_sizes[location], rand(200:300, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[MoreThan200][location]))))
        sort!(houses_sizes[location], lt=sortRandomly)
    end

    houses_sizes_for_rental = Dict()
    for location in HOUSE_LOCATION_INSTANCES
        houses_sizes_for_rental[location] = rand(20:29, Int64(ceil(NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP[LessThan29][location])))
        houses_sizes_for_rental[location] = vcat(houses_sizes_for_rental[location], rand(30:39, Int64(ceil(NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP[LessThan39][location]))))
        houses_sizes_for_rental[location] = vcat(houses_sizes_for_rental[location], rand(40:49, Int64(ceil(NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP[LessThan49][location]))))
        houses_sizes_for_rental[location] = vcat(houses_sizes_for_rental[location], rand(50:59, Int64(ceil(NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP[LessThan59][location]))))
        houses_sizes_for_rental[location] = vcat(houses_sizes_for_rental[location], rand(60:79, Int64(ceil(NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP[LessThan79][location]))))
        houses_sizes_for_rental[location] = vcat(houses_sizes_for_rental[location], rand(80:99, Int64(ceil(NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP[LessThan99][location]))))
        houses_sizes_for_rental[location] = vcat(houses_sizes_for_rental[location], rand(100:119, Int64(ceil(NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP[LessThan119][location]))))
        houses_sizes_for_rental[location] = vcat(houses_sizes_for_rental[location], rand(120:149, Int64(ceil(NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP[LessThan149][location]))))
        houses_sizes_for_rental[location] = vcat(houses_sizes_for_rental[location], rand(150:199, Int64(ceil(NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP[LessThan199][location]))))
        houses_sizes_for_rental[location] = vcat(houses_sizes_for_rental[location], rand(200:300, Int64(ceil(NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP[MoreThan200][location]))))
        sort!(houses_sizes_for_rental[location], lt=sortRandomly)
        
        if !CRASH_SCENARIO
            splice!(houses_sizes_for_rental[location], 1:Int64(round(LOCAL_HOUSING_MAP[location])))
        end
    end


    zones_to_n_of_home_owners = Dict()
    houses_for_rental = Dict(location => [] for location in HOUSE_LOCATION_INSTANCES) # dict location to list of tuples (house, landlord)
    number_of_houses_for_market = Dict(location => 0 for location in HOUSE_LOCATION_INSTANCES) # dict location to list of tuples (house, landlord)
    for location in HOUSE_LOCATION_INSTANCES
        zones_to_n_of_home_owners[location] = 0
    end
    for i in 1:nagents(model) # due to round() it might not be equal to NUMBER_OF_HOUSEHOLDS
        # println("assignHousesToHouseholds i = $(i)")
        household = model[i]
        target_home_owners_in_the_zone = HOME_OWNERS_MAP[household.residencyZone]
        current_home_owners_in_the_zone = zones_to_n_of_home_owners[household.residencyZone]
        if !shouldBeHomeOwner(household)
            continue
        end

        if current_home_owners_in_the_zone >= target_home_owners_in_the_zone
            LOG_INFO("All home owners were assigned in $(household.residencyZone)")
            household.homelessTime = generateHomelessTime()
            continue # no more houses to assign in this phase
        end
        if !assignHouseThatMakesSense(model, household, houses_sizes)
            # Wasn't assigned a house...
            household.homelessTime = generateHomelessTime()
            continue # also not going to get houses for rental
        end
        zones_to_n_of_home_owners[household.residencyZone] += 1
        numberOfExtraHousesToAssign = shouldAssignMultipleHouses(model, household)
        assignHousesForRental(model, household, numberOfExtraHousesToAssign, houses_sizes_for_rental, houses_for_rental, number_of_houses_for_market)
    end
    LOG_INFO("Total Number of houses_for_rental = $(sum([length(houses_for_rental[location]) for location in HOUSE_LOCATION_INSTANCES]))")
    for i in 1:nagents(model)
        household = model[i]
        if length(household.houses) == 0
            if !createContract(model, household, houses_for_rental)
                LOG_INFO("Household wasn't assigned a house for rental:\n$(print_household(household))")
            end
        end
    end

    LOG_INFO("Number of houses_for_rental that weren't assigned = $(sum([length(houses_for_rental[location]) for location in HOUSE_LOCATION_INSTANCES]))")

end

function createContract(model, household, houses_for_rental)
    for idx in eachindex(houses_for_rental[household.residencyZone])
        house = houses_for_rental[household.residencyZone][idx][1]
        if rand() < probabilityOfHouseholdBeingAssignedToHouse(household, house)
            seller = houses_for_rental[household.residencyZone][idx][2]
            monthlyPrice = calculate_initial_rental_market_price(house) / (1 + rand() * 2)
            salary = calculateLiquidSalary(household, model)
            retry = 0
            while salary * MAX_EFFORT_FOR_RENT <= monthlyPrice && retry < 3
                monthlyPrice /= 1.5 
            end
            if salary * MAX_EFFORT_FOR_RENT <= monthlyPrice
                continue
            end
    	    contract = Contract(seller.id, household.id, house, monthlyPrice)

            household.contractAsTenant = contract
            push!(seller.contractsAsLandlord, contract)
            # LOG_INFO("####HOUSEADDED location = $(house.location)")
            splice!(houses_for_rental[household.residencyZone], idx)
            return true
        end
    end
    return false
end

function assignHouseThatMakesSense(model, household, houses_sizes)
    idx = 1
    location = household.residencyZone
    while idx <= length(houses_sizes[location])
        area = houses_sizes[location][idx]
        house = House(UInt16(area), location, NotSocialNeighbourhood, 1.0, rand(1:100))
        # println("assignHouseThatMakesSense house = $(house)")
        if has_enough_size(house, household) && rand() < probabilityOfHouseholdBeingAssignedToHouse(household, house)
            push!(household.houses, house)
            # LOG_INFO("####HOUSEADDED location = $(house.location)")
            splice!(houses_sizes[location], idx)
            return true
        end
        idx += 1
    end
    return false
end

function probabilityOfHouseholdBeingAssignedToHouse(household, house)
    m2_per_person = house.area / household.size
    numberOfHousesInThatZone = NUMBER_OF_HOUSES_MAP[house.location]
    numberOfHousesWithThatRatioInThatZone = 0
    probabilityMultiplierDueToAge = map_value(household.age, 20, 90, 0.01, 4.5)
    probabilityMultiplierDueToPercentile = map_value(household.percentile, 1, 100, 0.5, 2.0)
    if m2_per_person < 10
        numberOfHousesWithThatRatioInThatZone = NUMBER_OF_HOUSES_WITH_LT_10_M2_PER_PERSON_MAP[house.location]
    elseif m2_per_person < 15
        numberOfHousesWithThatRatioInThatZone = NUMBER_OF_HOUSES_WITH_LT_15_M2_PER_PERSON_MAP[house.location]
    elseif m2_per_person < 20
        numberOfHousesWithThatRatioInThatZone = NUMBER_OF_HOUSES_WITH_LT_20_M2_PER_PERSON_MAP[house.location]
    elseif m2_per_person < 30
        numberOfHousesWithThatRatioInThatZone = NUMBER_OF_HOUSES_WITH_LT_30_M2_PER_PERSON_MAP[house.location]
    elseif m2_per_person < 40
        numberOfHousesWithThatRatioInThatZone = NUMBER_OF_HOUSES_WITH_LT_40_M2_PER_PERSON_MAP[house.location]
    elseif m2_per_person < 60
        numberOfHousesWithThatRatioInThatZone = NUMBER_OF_HOUSES_WITH_LT_60_M2_PER_PERSON_MAP[house.location]
    elseif m2_per_person < 80
        numberOfHousesWithThatRatioInThatZone = NUMBER_OF_HOUSES_WITH_LT_80_M2_PER_PERSON_MAP[house.location]
    else
        numberOfHousesWithThatRatioInThatZone = NUMBER_OF_HOUSES_WITH_MT_80_M2_PER_PERSON_MAP[house.location]
    end
    return (numberOfHousesWithThatRatioInThatZone / numberOfHousesInThatZone) * probabilityMultiplierDueToAge * probabilityMultiplierDueToPercentile
end

# function getEchelon(size)
#     for echelon in instances(HouseSizeEchelon)
#         if size <= echelon
#             return echelon
#         end
#     end
#     return MoreThan200
# end

# function probabilityOfEstablishingARentalContract(household, house)
#     echelon = getEchelon(house.area)
#     probability = NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP[echelon][house.location] / sum([NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP[size][house.location] for size in instances(HouseSizeEchelon)])
#     return probability
# end

function shouldBeHomeOwner(household)
    baseProbability = HOME_OWNERS_MAP[household.residencyZone] / NUMBER_OF_HOUSEHOLDS_MAP[household.residencyZone]

    inverseProbability = 1 - baseProbability
    inverseProbability *= 1.25
    inverseProbability = inverseProbability < 0.90 ? inverseProbability : 0.90

    baseProbability *= 1.25
    baseProbability = baseProbability < 0.90 ? baseProbability : 0.90

    ageMultiplier = map_value(household.age, 20, 75, baseProbability/4, baseProbability)
    ageMultiplier = ageMultiplier < baseProbability ? ageMultiplier : baseProbability

    percentileMultiplier = map_value(household.percentile, 1, 100, inverseProbability/3, inverseProbability)
    percentileMultiplier = percentileMultiplier < inverseProbability ? percentileMultiplier : inverseProbability
    
    return rand() < ageMultiplier + percentileMultiplier
end

function shouldAssignMultipleHouses(model, household)
    randomNumber = rand()
    if household.age < 30
        if randomNumber < 0.02
            return 1
        end
    elseif household.age < 40
        if randomNumber < 0.15
            return 1 + Int64(round(rand()))
        end
    else
        if randomNumber < 0.10
            return 1 + Int64(round(rand() * 6))
        elseif randomNumber < 0.20
            return 1 + Int64(round(rand() * 3))
        elseif randomNumber < 0.3
            return 1 + Int64(round(rand()))
        end
    end
    return 0
end

function assignHousesForRental(model, household, numberOfExtraHousesToAssign, houses_sizes_for_rental, houses_for_rental, number_of_houses_for_market)
    location = household.residencyZone
    assignedSoFar = 0
    i = 1
    if length(houses_sizes_for_rental[location]) == 0
        LOG_INFO("All houses for rental were assigned in $location")
    end
    while i <= length(houses_sizes_for_rental[location])
        if assignedSoFar == numberOfExtraHousesToAssign
            break
        end
        area = splice!(houses_sizes_for_rental[location], 1)
        house = House(UInt16(area), location, NotSocialNeighbourhood, 1.0, rand(1:100))
        # println("assignHousesForRental house = $(house)")
        # LOG_INFO("####HOUSEADDEDRENTAL location = $(house.location)")
        push!(household.houses, house)
        assignedSoFar += 1
        i += 1
        if number_of_houses_for_market[location] < NUMBER_OF_HOUSES_MAP[location] * 0.005
            number_of_houses_for_market[location] += 1
            continue
        end
        push!(houses_for_rental[house.location], tuple(house, household))
    end
end

function getProbabilityOfHouseBeingInOldContract(house)
    percentileFactor = 1 - map_value(house.percentile, 1, 100, 0.15, 0.99) # from 85% to 1%  
    areaFactor = 1 - map_value(house.area, 20, 200, 0.85, 0.99) # from 15% to 1%
    return areaFactor + percentileFactor
end

function generateHomelessTime()
    rn = rand()
    if rn < 0.7
        return rand(1:8)
    else
        return rand(1:24)
    end
        
end