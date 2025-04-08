#TODO: region hack
function initiateConstructionSector()
    averageTimeForPermit = (CONSTRUCTION_DELAY_MIN + CONSTRUCTION_DELAY_MAX) / 2
    averageTimeForConstruction = (CONSTRUCTION_TIME_MIN + CONSTRUCTION_TIME_MAX) / 2
    averageTotalTime = averageTimeForPermit + averageTimeForConstruction

    housesInConstruction = Dict(location => Dict(size_interval => PendingConstruction[] for size_interval in instances(SizeInterval)) for location in HOUSE_LOCATION_INSTANCES)
    for location in HOUSE_LOCATION_INSTANCES
        # divide the time by 12 because the MAX_NEW_CONSTRUCTIONS_MAP data is yearly
        # this way we calculate the expected constructions in progress based on the time it usually
        # takes for a project to complete and the amount of projects that get completed each year
        expectedConstructionInProgress = MAX_NEW_CONSTRUCTIONS_MAP[CURRENT_YEAR][location] * (averageTotalTime / 12)
        for i in 1:expectedConstructionInProgress
            # pick a random size_interval
            # TODO: could be data driven
            size_interval = instances(SizeInterval)[rand(1:length(instances(SizeInterval)))]
            permitTime = rand(CONSTRUCTION_DELAY_MIN:CONSTRUCTION_DELAY_MAX)
            constructionTime = rand(CONSTRUCTION_TIME_MIN:CONSTRUCTION_TIME_MAX)
            totalDuration = permitTime + constructionTime
            house = House(generateAreaFromSizeInterval(size_interval), location, NotSocialNeighbourhood, 1.0, rand(RECENTLY_BUILD_MINIMUM_PERCENTILE:100))
            push!(housesInConstruction[location][size_interval], PendingConstruction(rand(1:totalDuration), permitTime, constructionTime, house))
        end
    end
    return ConstructionSector(STARTING_CONSTRUCTION_SECTOR_WEALTH, 
            housesInConstruction,
            Mortgage[],
            Dict(location => 0.0 for location in HOUSE_LOCATION_INSTANCES),
            PendingRenovation[]
            )
end

mutable struct SizePriority
    size_interval::SizeInterval
    margin::Float64
end

function sortSizePriority(l, r)
    return l.margin > r.margin
end

function sortSizesBucketsByProfitability(model, location)
    res = SizePriority[]
    expectedDuration = rand(CONSTRUCTION_DELAY_MIN:CONSTRUCTION_DELAY_MAX)
    expectedDuration += rand(CONSTRUCTION_TIME_MIN:CONSTRUCTION_TIME_MAX)
    testPercentile = rand(RECENTLY_BUILD_MINIMUM_PERCENTILE:100)
    for size_interval in instances(SizeInterval)
        sampleHouse = House(generateAreaFromSizeInterval(size_interval), location, NotSocialNeighbourhood, 1.0, testPercentile)
        costs = calculate_total_construction_costs(model, sampleHouse, expectedDuration, withVat = false)
        marketPrice = calculate_market_price(model, sampleHouse)
        margin = marketPrice/costs
        # to introduce a random factor:
        margin = rand(Normal(margin, margin * 0.25))
        push!(res, SizePriority(size_interval, margin))
    end
    sort!(res, lt=sortSizePriority)
    return [sizePriority.size_interval for sizePriority in res]
end

function updateConstructions(model)
    for location in HOUSE_LOCATION_INSTANCES
        sizesOrdered = sortSizesBucketsByProfitability(model, location)
        for size_interval in sizesOrdered
            updateConstructionsPerBucket(model, location, size_interval)
        end
    end

end

function updateConstructionsPerBucket(model, location, size_interval)
    targetConstruction = calculateTargetConstructionPerBucket(model, location, size_interval)
    println("targetConstruction = $targetConstruction")
    newConstructions = targetConstruction - length(model.construction_sector.housesInConstruction[location][size_interval])
    if newConstructions < 0
        newConstructions = 0
    end
    println("newConstructions = $newConstructions")
    # if newConstructions > MAX_NEW_CONSTRUCTIONS_MAP[location] / 12
    #     newConstructions = MAX_NEW_CONSTRUCTIONS_MAP[location] / 12
    # end
    model.construction_sector.constructionGoals[location] += newConstructions / 12
    constructionGoals = copy(model.construction_sector.constructionGoals[location])
    println("constructionGoals = $constructionGoals")
    if (constructionGoals >= 1)
        # # attempt to start construction for the demand in one year (hence divide by 12) 
        # newConstructions = Int64(floor(newConstructions / 24))
        # newConstructions = rand(Normal(newConstructions, newConstructions * 0.5))
        for i in 1:constructionGoals
            if (!startNewConstruction(model, location, size_interval))
                model.construction_sector.constructionGoals[location] -= 1.0
                break
            else
                model.construction_sector.constructionGoals[location] -= 1.0
            end
        end
    end
    i = 1
    while i <= length(model.construction_sector.housesInConstruction[location][size_interval])
        pendingConstruction = model.construction_sector.housesInConstruction[location][size_interval][i]
        pendingConstruction.time += 1
        if pendingConstruction.time > pendingConstruction.permitTime
            # already building
            constructionPayment = calculate_construction_costs(model, pendingConstruction.house, false) / pendingConstruction.constructionTime
            model.government.wealth += constructionPayment
            model.constructionLabor += constructionPayment
            model.construction_sector.wealth -= constructionPayment
        else
            # still waiting for permit
            # Note: wasting money due to finnancing costs
        end
        if (pendingConstruction.time >= pendingConstruction.permitTime + pendingConstruction.constructionTime)
            put_newly_built_house_to_sale(model, pendingConstruction.house)
            splice!(model.construction_sector.housesInConstruction[location][size_interval], i)
        else
            i += 1
        end
    end
    i = 1
    while i <= length(model.construction_sector.pendingRenovations)
        pendingRenovation = model.construction_sector.pendingRenovations[i]
        if pendingRenovation.time >= pendingRenovation.renovationTime
            costs = calculateRenovationCosts(pendingRenovation.house)
            tax = costs * CONSTRUCTION_VAT
            household = pendingRenovation.household
            if costs + tax > household.wealth * 0.95
                paidWithOwnMoney = household.wealth * 0.95
                mortgageValue = costs + tax - paidWithOwnMoney
                maxMortgage = maxMortgageValue(model, household)
                if maxMortgage < mortgageValue
                    TRANSACTION_LOG("Household failed to acquire mortgage for renovation", model)
                    return false
                end
                mortgageDuration = calculateMortgageDuration(mortgageValue, household.age)
                mortgage = Mortgage(mortgageValue, mortgageValue, 0, mortgageDuration)
                push!(household.mortgages, mortgage)
                push!(model.mortgagesInStep, mortgage)
                model.bank.wealth -= mortgageValue
                household.wealth += mortgageValue
            end
            household.wealth -= costs
            model.construction_sector.wealth += costs

            household.wealth -= tax
            model.government.wealth += tax
            TRANSACTION_LOG("Charged $costs + $tax from household $(household.id) due to renovation costs and taxes", model)

            updateHouseRenovationCosts(model, pendingRenovation.house, costs + tax)
            pendingRenovation.house.percentile = calculateRenovatedPercentile(pendingRenovation.house)
            push!(household.houses, pendingRenovation.house)
            if pendingRenovation.type == ForInvestment
                put_house_to_sale(household, model, length(household.houses))
            else
                put_house_to_rent(household, model, pendingRenovation.house)
            end
            splice!(model.construction_sector.pendingRenovations, i)
        else
            pendingRenovation.time += 1
            i += 1
        end
    end
end

function calculateTargetConstructionPerBucket(model, location, size_interval)
    supplyVsDemandValue = model.demandPerBucket[location][size_interval] -
                          model.supplyPerBucket[location][size_interval]
    
    # averageTimeForPermit = (CONSTRUCTION_DELAY_MIN + CONSTRUCTION_DELAY_MAX) / 2
    # averageTimeForConstruction = (CONSTRUCTION_TIME_MIN + CONSTRUCTION_TIME_MAX) / 2
    # averageTotalTime = averageTimeForPermit + averageTimeForConstruction

    # # split the supply vs demand value among the four buckets
    # if CURRENT_YEAR != 2003
    #     # calculate the value of constructions that should be in progress to achieve the expected value
    #     # this is calculated taking into consideration the amount of time it takes to build a house
    #     # this is simillar to what is done in the initiateConstructionSector function
    #     # here we divide by the number of buckets per location (4) and multiply by 150% because it is the cap 
    #     expectedConstructionInProgress = MAX_NEW_CONSTRUCTIONS_MAP[CURRENT_YEAR][location] * (averageTotalTime / 12)
    #     capValue = expectedConstructionInProgress * 1.5
    #     capValuePerBucket = capValue / 4
    #     capValuePerBucket = rand(Normal(capValuePerBucket, capValuePerBucket * 0.25))
    #     if supplyVsDemandValue > capValuePerBucket
    #         return ceil(capValuePerBucket)
    #     end
    # end
    return supplyVsDemandValue
end

function calculateMortgageDurationForConstructionSector()
    # construction sector sells the house and finishes paying the debt
    # this should simulate that somehow
    return rand(60:120)
end

function startNewConstruction(model, location, size_interval)
    newHouse = generateHouseToBeBuilt(location, size_interval)
    if newHouse == Nothing
        # not viable...
        TRANSACTION_LOG("Failed to start new construction (not viable)\n", model)
        return false
    end
    expectedDuration = rand(CONSTRUCTION_DELAY_MIN:CONSTRUCTION_DELAY_MAX)
    expectedDuration += rand(CONSTRUCTION_TIME_MIN:CONSTRUCTION_TIME_MAX)
    constructionCost = calculate_total_construction_costs(model, newHouse, expectedDuration)

    if constructionCost > model.construction_sector.wealth
        if !createConstructionLoan(model, constructionCost)
            TRANSACTION_LOG("Failed to create construction loan\n", model)
            return false
        end
    end
    model.government.wealth += LAND_COSTS_ADJUSTED[location] * newHouse.area
    model.construction_sector.wealth -= LAND_COSTS_ADJUSTED[location] * newHouse.area
    permitTime = rand(CONSTRUCTION_DELAY_MIN:CONSTRUCTION_DELAY_MAX)
    constructionTime = rand(CONSTRUCTION_TIME_MIN:CONSTRUCTION_TIME_MAX)
    push!(model.construction_sector.housesInConstruction[location][size_interval], PendingConstruction(0, permitTime, constructionTime, newHouse))
    content = "Start new Construction $(newHouse.area) $(newHouse.percentile) $(newHouse.location)\n"
    TRANSACTION_LOG(content, model)
    return true
end

function createConstructionLoan(model, value)
    # if (model.bank.wealth * 0.5 < value)
    #     return false # verify bank liquidity
    # end

    debt = calculate_construction_sector_debt(model)
    if debt - model.construction_sector.wealth > MAX_CONSTRUCTION_SECTOR_DEBT
        return false
    end

    push!(model.construction_sector.mortgages, Mortgage(value, value, 0, calculateMortgageDurationForConstructionSector()))
    model.bank.wealth -= value
    model.construction_sector.wealth += value
    return true
end


function generateHouseToBeBuilt(location, size_interval)
    area = generateAreaFromSizeInterval(size_interval)
    bestPercentile = -1
    bestMargin = -1
    expectedDuration = rand(CONSTRUCTION_DELAY_MIN:CONSTRUCTION_DELAY_MAX)
    expectedDuration += rand(CONSTRUCTION_TIME_MIN:CONSTRUCTION_TIME_MAX)
    for testPercentile in rand(RECENTLY_BUILD_MINIMUM_PERCENTILE:100, 1)
        marketPrice = calculate_market_price(model, House(area, location, NotSocialNeighbourhood, 1.0, testPercentile))
        constructionCosts = calculate_total_construction_costs(model, House(area, location, NotSocialNeighbourhood, 1.0, testPercentile), expectedDuration)
        
        # if constructionCosts > marketPrice
        #     continue
        # end
        margin = marketPrice / constructionCosts
        if margin > bestMargin
            bestMargin = bestMargin
            bestPercentile = testPercentile
        end
    end
    if bestPercentile == -1
        # this business is not viable, 
        # return nothing to notify the caller that we won't build the house
        return Nothing
    end
    return House(area, location, NotSocialNeighbourhood, 1.0, bestPercentile)
end

function put_newly_built_house_to_sale(model, house)
    costBasedPrice = calculate_construction_costs(model, house, true) * CONSTRUCTION_SECTOR_MARKUP[house.location]
    askPrice = calculate_market_price(model, house)
    isCostBasedPrice = false
    if costBasedPrice > askPrice
        askPrice = costBasedPrice
        isCostBasedPrice = true
    end
    push!(model.houseMarket.supply, HouseSupply(house, askPrice, Bid[], -1))
    push!(model.housesBuiltPerRegion[house.location][getSizeInterval(house)], house)
    content = "Pushed house into housesBuiltPerRegion (location,size) = ($(string(house.location)), $(string(getSizeInterval(house))))\n"
    content *= "price perm2 of newly built house = $(askPrice/house.area)\n"
    content *= "Cost based price = $(isCostBasedPrice)\n"
    TRANSACTION_LOG(content, model)
    
    println(content)
end

function calculate_construction_sector_debt(model)
    debt = 0
    for i in 1:length(model.construction_sector.mortgages)
        mortgage = model.construction_sector.mortgages[i]
        if mortgage.valueInDebt > 0
            debt += calculateMortgagePayment(mortgage, model.bank.interestRate) * (mortgage.duration - mortgage.maturity)
        end
    end
    return debt
end

function calculate_total_construction_costs(model, house, expectedDuration; withVat = false)
    finnancingMultiplier = expectedDuration * (model.bank.interestRate / 12)
    landCosts = LAND_COSTS_ADJUSTED[house.location] * house.area
    constructionCosts = calculate_construction_costs(model, house, withVat)
    return (1 + finnancingMultiplier) * (landCosts + constructionCosts)
end

function calculate_construction_costs(model, house, withVat)
    constructionCosts = ((CONSTRUCTION_COSTS_MIN + CONSTRUCTION_COSTS_MAX) / 2) * house.area
    # constructionCosts = map_value(house.percentile, 1, 100, CONSTRUCTION_COSTS_MIN, CONSTRUCTION_COSTS_MAX) * house.area
    # this costs should change with the zone salaries
    constructionCosts *= THIRD_QUINTILE_INCOME_MAP[house.location] / THIRD_QUINTILE_INCOME_LMA
    if withVat
        constructionCosts *= 1 + CONSTRUCTION_VAT
    end
    # constructionCosts *= PROJECT_COST_MULTIPLIER
    return constructionCosts
end

function calculateRenovationCosts(house)
    return map_value(calculateRenovatedPercentile(house) - house.percentile, 0, 35, 400, 1300) * house.area
end

function calculateRenovatedPercentile(house)
    if house.percentile == 100
        return 100
    end
    newPercentile = Int64(round(house.percentile + map_value(house.percentile, 1, 99, -35, -1) * -1))
    return newPercentile
end

function calculateRenovationTime()
    return rand(4:6)
end

function requestRenovation(model, house, household, idx, investMentType)
    duration = calculateRenovationTime()
    push!(model.construction_sector.pendingRenovations, PendingRenovation(0, duration, house, household, investMentType))
    splice!(household.houses, idx)
end