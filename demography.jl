
# returns true if household died
function household_evolution(household, model)
    household.age += 1
    handle_births(household, model)
    if (handle_deaths(household, model))
        return true
    end
    if (handle_breakups(household, model))
        return true
    end
    handle_children_leaving_home(household, model)
    return false
end

function handle_births(household, model)
    if (household.age >= 20 && household.age < 44  && household.size >= 2)
        probability = BIRTH_RATE
        ratioOfFertileWomen = eval(Symbol("RATIO_OF_FERTILE_WOMEN_IN_$(string(household.residencyZone))"))
        # probability should not be fixed
        if (rand() < (probability / ratioOfFertileWomen) * (1 + (TOTAL_HOUSEHOLDS_WITH_SIZE_1 * ratioOfFertileWomen) / NUMBER_OF_HOUSEHOLDS))
            # 5% for size == 2
            # 4% for size == 3
            # 3% for size == 4
            # 2% for size == 5
            # 1% for size == 6
            household.size += 1
            model.births += 1
            # 4 children at most
        end
    end
    return false
end

# returns true if household died
function handle_deaths(household, model)
    probability_of_death = 0.0005 + 10^(-4.2+0.032*household.age)
    # if (household.age < 60)
    #     return false
    # end
    # probability_of_death = MORTALITY_RATE / 0.40 # assuming 40% of the households have >= 60 years
    if (rand() < probability_of_death)
        model.deaths += 1
        if household.size == 1
            terminateContractsOnTentantSide(household, model)
            terminateContractsOnLandLordSide(household, model)
            push!(model.inheritages, Inheritage(household.houses, household.wealth, household.mortgages, household.percentile))
            # gov takes the wealth
            model.government.wealth += household.wealth
            model.inheritagesFlow += household.wealth
            #println("remove Agent! id = " * string(household.id))
            remove_agent!(household, model)
            return true
        else
            household.size = household.size - 1
        end
    end
    return false
end

# returns true if household died
# TODO: contracts logic should be enhanced
function handle_breakups(household, model)
    if (household.size >= 2)
        probability_of_breakup = eval(Symbol("PROBABILITY_OF_DIVORCE_IN_$(string(household.residencyZone))"))
        if (rand() < probability_of_breakup)
            terminateContractsOnTentantSide(household, model)
            terminateContractsOnLandLordSide(household, model)
            
            add_agent!(Household, model, household.wealth / 2, household.age, 1, House[], household.percentile, Mortgage[], Int[], 0, 0.0, getChildResidencyZone(household), rand(Normal(GREEDINESS_AVERAGE, GREEDINESS_STDEV), 1)[1])
            add_agent!(Household, model, household.wealth / 2, household.age, household.size - 1, household.houses, household.percentile, household.mortgages, Int[], 0, 0.0, getChildResidencyZone(household), rand(Normal(GREEDINESS_AVERAGE, GREEDINESS_STDEV), 1)[1])
            #println("remove Agent! id = " * string(household.id) * " step = " * string(model.steps))
            remove_agent!(household, model)
            model.breakups += 1
            return true
        end
    end
    return false
end

#TODO: this is too simplistic, leaving home should take in consideration
# financial situation somehow, and in most cases it should happen at 2 households at the same time
# suggest adding ChildrenLeaves to the model so that it can be handled in model_step
# returns true if household died
function handle_children_leaving_home(household, model)
    if (household.size > 2 && household.age > 38)
        probability_of_child_leaving = 0.05 + rand() * 0.05
        if (rand() < probability_of_child_leaving)
            expected_age = household.age - 20 + rand(0:8)
            expected_wealth = generateInitialWealth(expected_age, household.percentile, household.size) * 0.6
            if (expected_wealth > household.wealth)
                expected_wealth = household.wealth * 0.2
            end
            randomNumber = rand()
            if randomNumber < 0.45
                # a couple of young people leave their parents home
                newZone = getChildResidencyZone(household)
                add_agent!(Household, model, expected_wealth, expected_age, 2, Int[], household.percentile, Mortgage[], Int[], 0, 0.0, newZone, rand(Normal(GREEDINESS_AVERAGE, GREEDINESS_STDEV), 1)[1])
                household.wealth -= expected_wealth
                household.size -= 1
                model.children_leaving_home += 2
            elseif randomNumber < 0.9
                # to simulate the other half of the couple (simplification)
                household.size -= 1
            else
                # single young person leaves their parents home
                newZone = getChildResidencyZone(household)
                add_agent!(Household, model, expected_wealth, expected_age, 1, Int[], household.percentile, Mortgage[], Int[], 0, 0.0, newZone, rand(Normal(GREEDINESS_AVERAGE, GREEDINESS_STDEV), 1)[1])
                household.wealth -= expected_wealth
                household.size -= 1
                model.children_leaving_home += 1
            end
        end
    end
    return false
end

function getChildResidencyZone(household)
    # possibleZones = adjacentZones[household.residencyZone]
    # for i in 1:10
    #     # Virtually increase likelihood of staying in the residencyZone
    #     push!(possibleZones, household.residencyZone)
    # end
    # return possibleZones[rand(1:length(possibleZones))]
    return household.residencyZone
end


# TODO: region hack
function handle_migrations(model)
    for location in [Lisboa]
        expectedMigrants = migrationValueMap[location] / 12
        expectedMigrants = rand(Normal(expectedMigrants, expectedMigrants * 0.2))
        added = 0
        while added < expectedMigrants
            age = rand(20:55)
            percentile = rand(0:100)
            size = rand(1:3)
            add_agent!(Household, model, generateInitialWealth(age, percentile, size), age, size, House[], percentile, Mortgage[], Int[], 0, 0, location, rand(Normal(GREEDINESS_AVERAGE, GREEDINESS_STDEV)))
            added += size
        end
    end
end