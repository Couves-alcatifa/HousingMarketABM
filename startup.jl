function initiateHouses(model)
    houses_sizes = rand(UInt16(30):UInt16(60), Int64(NUMBER_OF_HOUSES/4))
    houses_sizes = vcat(houses_sizes, rand(UInt16(60):UInt16(80), Int64(NUMBER_OF_HOUSES/4)))
    houses_sizes = vcat(houses_sizes, rand(UInt16(80):UInt16(120), Int64(NUMBER_OF_HOUSES/4)))
    houses_sizes = vcat(houses_sizes, rand(UInt16(120):UInt16(180), Int64(NUMBER_OF_HOUSES/4)))
    
    for location in instances(HouseLocation)
        model.houses[location] = House[]
    end
    sort!(houses_sizes, lt=sortRandomly)
    initiateHousesPerRegion(model)
end

# TODO: region hack
function initiateHousesPerRegion(model)
    # for location in instances(HouseLocation)
    for location in instances(HouseLocation)
        houses_sizes = rand(20:29, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan29][location])))
        houses_sizes = vcat(houses_sizes, rand(30:39, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan39][location]))))
        houses_sizes = vcat(houses_sizes, rand(40:49, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan49][location]))))
        houses_sizes = vcat(houses_sizes, rand(50:59, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan59][location]))))
        houses_sizes = vcat(houses_sizes, rand(60:79, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan79][location]))))
        houses_sizes = vcat(houses_sizes, rand(80:99, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan99][location]))))
        houses_sizes = vcat(houses_sizes, rand(100:119, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan119][location]))))
        houses_sizes = vcat(houses_sizes, rand(120:149, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan149][location]))))
        houses_sizes = vcat(houses_sizes, rand(150:199, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[LessThan199][location]))))
        houses_sizes = vcat(houses_sizes, rand(200:300, Int64(ceil(NUMBER_OF_HOUSES_PER_SIZE_MAP[MoreThan200][location]))))
        sort!(houses_sizes, lt=sortRandomly)
        for i in eachindex(houses_sizes)
            if i < LOCAL_HOUSING_MAP[location]
                continue
            end
            push!(model.houses[location], House(UInt16(houses_sizes[1]), location, NotSocialNeighbourhood, 1.0))
            splice!(houses_sizes, 1)
        end
    end
end

# TODO: region hack
function initiateHouseholds(model, households_initial_ages, greedinesses)
    for location in instances(HouseLocation)
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
                percentile = rand(0:100)
                actualSize = get_household_size(size)
                add_agent!(Household, model, generateInitialWealth(initial_age, percentile, actualSize), initial_age, actualSize, Int64[], percentile, Mortgage[], Contract[], Nothing, 0.0, location, greedinesses[i])
            end
        end
    end
end

function assignHousesToHouseholds(model)
    houses_sizes_for_rental = Dict()
    for location in instances(HouseLocation)
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
    end

    zones_to_n_of_home_owners = Dict()
    for location in instances(HouseLocation)
        zones_to_n_of_home_owners[location] = 0
    end
    not_home_owners = []
    for i in 1:nagents(model) # due to round() it might not be equal to NUMBER_OF_HOUSEHOLDS
        # println("assignHousesToHouseholds i = $(i)")
        household = model[i]
        target_home_owners_in_the_zone = HOME_OWNERS_MAP[household.residencyZone]
        current_home_owners_in_the_zone = zones_to_n_of_home_owners[household.residencyZone]
        if current_home_owners_in_the_zone >= target_home_owners_in_the_zone
            LOG_INFO("All home owners were assigned in $(household.residencyZone)")
            continue # no more houses to assign in this phase
        end
        if !assignHouseThatMakesSense(model, household)
            # Wasn't assigned a house...
            push!(not_home_owners, household)
            continue # also not going to get houses for rental
        end
        zones_to_n_of_home_owners[household.residencyZone] += 1
        numberOfExtraHousesToAssign = shouldAssignMultipleHouses(model, household)
        assignHousesForRental(model, household, numberOfExtraHousesToAssign, houses_sizes_for_rental)
    end
end