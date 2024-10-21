function initiateHouses(model)
    houses_sizes = rand(UInt16(30):UInt16(60), Int64(NUMBER_OF_HOUSES/4))
    houses_sizes = vcat(houses_sizes, rand(UInt16(60):UInt16(80), Int64(NUMBER_OF_HOUSES/4)))
    houses_sizes = vcat(houses_sizes, rand(UInt16(80):UInt16(120), Int64(NUMBER_OF_HOUSES/4)))
    houses_sizes = vcat(houses_sizes, rand(UInt16(120):UInt16(180), Int64(NUMBER_OF_HOUSES/4)))
    
    for location in instances(HouseLocation)
        model.houses[location] = House[]
    end
    sort!(houses_sizes, lt=sortRandomly)
    # TODO: region hack
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Amadora], Amadora, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Cascais], Cascais, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Lisboa], Lisboa, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Loures], Loures, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Mafra], Mafra, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Odivelas], Odivelas, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Oeiras], Oeiras, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Sintra], Sintra, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[VilaFrancaDeXira], VilaFrancaDeXira, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Alcochete], Alcochete, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Almada], Almada, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Barreiro], Barreiro, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Moita], Moita, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Montijo], Montijo, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Palmela], Palmela, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Seixal], Seixal, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Sesimbra], Sesimbra, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_MAP[Setubal], Setubal, houses_sizes)
end

function initiateHousesPerRegion(model, targetNumberOfHouses, location, houses_sizes)
    for i in 1:targetNumberOfHouses
        push!(model.houses[location], House(houses_sizes[1], location, NotSocialNeighbourhood, 1.0))
        splice!(houses_sizes, 1)
    end
end

# TODO: region hack
function initiateHouseholds(model, households_initial_ages, greedinesses)
    for location in [Lisboa]
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
                add_agent!(Household, model, generateInitialWealth(initial_age, percentile, actualSize), initial_age, actualSize, Int64[], percentile, Mortgage[], Int[], 0, 0.0, location, greedinesses[i])
            end
        end
    end
end

function assignHousesToHouseholds(model)
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
            continue # no more houses to assign in this phase
        end
        if !assignHouseThatMakesSense(model, household)
            # Wasn't assigned a house...
            push!(not_home_owners, household)
            continue # also not going to get houses for rental
        end
        zones_to_n_of_home_owners[household.residencyZone] += 1
        numberOfExtraHousesToAssign = shouldAssignMultipleHouses(model, household)
        assignHousesForRental(model, household, numberOfExtraHousesToAssign)
    end
end