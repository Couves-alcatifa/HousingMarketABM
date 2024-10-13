function initiateConstructionSector()
    averageTimeForPermit = (CONSTRUCTION_DELAY_MIN + CONSTRUCTION_DELAY_MAX) / 2
    averageTimeForConstruction = (CONSTRUCTION_TIME_MIN + CONSTRUCTION_TIME_MAX) / 2
    averageTotalTime = averageTimeForPermit + averageTimeForConstruction

    housesInConstruction = Dict(location => Dict(size_interval => PendingConstruction[] for size_interval in instances(SizeInterval)) for location in instances(HouseLocation))
    for location in instances(HouseLocation)
        # divide the time by 12 because the MAX_NEW_CONSTRUCTIONS_MAP data is yearly
        # this way we calculate the expected constructions in progress based on the time it usually
        # takes for a project to complete and the amount of projects that get completed each year
        expectedConstructionInProgress = MAX_NEW_CONSTRUCTIONS_MAP[location] * (averageTotalTime / 12)
        for i in 1:expectedConstructionInProgress
            # pick a random size_interval
            # TODO: could be data driven
            size_interval = instances(SizeInterval)[rand(1:length(instances(SizeInterval)))]
            permitTime = rand(CONSTRUCTION_DELAY_MIN:CONSTRUCTION_DELAY_MAX)
            constructionTime = rand(CONSTRUCTION_TIME_MIN:CONSTRUCTION_TIME_MAX)
            totalDuration = permitTime + constructionTime
            house = House(generateAreaFromSizeInterval(size_interval), location, NotSocialNeighbourhood, 1.0, rand(1:100))
            push!(housesInConstruction[location][size_interval], PendingConstruction(rand(1:totalDuration), permitTime, constructionTime, house))
        end
    end
    return ConstructionSector(STARTING_CONSTRUCTION_SECTOR_WEALTH, 
            housesInConstruction,
            Mortgage[],
            Dict(location => 0.0 for location in instances(HouseLocation))
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
    testPercentile = rand(1:100)
    for size_interval in instances(SizeInterval)
        sampleHouse = House(generateAreaFromSizeInterval(size_interval), location, NotSocialNeighbourhood, 1.0, testPercentile)
        costs = calculate_total_construction_costs(model, sampleHouse, expectedDuration)
        marketPrice = calculate_market_price(sampleHouse, model)
        margin = marketPrice/costs
        # to introduce a random factor:
        margin = rand(Normal(margin, margin * 0.25))
        push!(res, SizePriority(size_interval, margin))
    end
    sort!(res, lt=sortSizePriority)
    return [sizePriority.size_interval for sizePriority in res]
end

function updateConstructions(model)
    for location in instances(HouseLocation)
        sizesOrdered = sortSizesBucketsByProfitability(model, location)
        for size_interval in sizesOrdered
            updateConstructionsPerBucket(model, location, size_interval)
        end
    end

end

function updateConstructionsPerBucket(model, location, size_interval)
    targetConstruction = calculateTargetConstructionPerBucket(model, location, size_interval)
    newConstructions = targetConstruction - length(model.construction_sector.housesInConstruction[location][size_interval])
    # if newConstructions > MAX_NEW_CONSTRUCTIONS_MAP[location] / 12
    #     newConstructions = MAX_NEW_CONSTRUCTIONS_MAP[location] / 12
    # end
    model.construction_sector.constructionGoals[location] += newConstructions / 12
    constructionGoals = copy(model.construction_sector.constructionGoals[location])
    if (constructionGoals >= 1)
        # # attempt to start construction for half the demand in one year (hence divide by 12 and by 2) 
        # newConstructions = Int64(floor(newConstructions / 24))
        # newConstructions = rand(Normal(newConstructions, newConstructions * 0.5))
        for i in 1:constructionGoals
            if (!startNewConstruction(model, location, size_interval))
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
            constructionPayment = calculate_construction_costs(model, pendingConstruction.house) / pendingConstruction.constructionTime
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
end

function calculateTargetConstructionPerBucket(model, location, size_interval)
    return model.demandPerBucket[location][size_interval] -
           model.supplyPerBucket[location][size_interval]
end

function calculateMortgageDurationForConstructionSector()
    # construction sector sells the house and finishes paying the debt
    # this should simulate that somehow
    return 80
end

function startNewConstruction(model, location, size_interval)
    newHouse = generateHouseToBeBuilt(location, size_interval)
    if newHouse == Nothing
        # not viable...
        return false
    end
    expectedDuration = rand(CONSTRUCTION_DELAY_MIN:CONSTRUCTION_DELAY_MAX)
    expectedDuration += rand(CONSTRUCTION_TIME_MIN:CONSTRUCTION_TIME_MAX)
    constructionCost = calculate_total_construction_costs(model, newHouse, expectedDuration)

    if constructionCost > model.construction_sector.wealth
        if !createConstructionLoan(model, constructionCost)
            return false
        end
    end
    model.government.wealth += LAND_COSTS * newHouse.area
    model.construction_sector.wealth -= LAND_COSTS * newHouse.area
    permitTime = rand(CONSTRUCTION_DELAY_MIN:CONSTRUCTION_DELAY_MAX)
    constructionTime = rand(CONSTRUCTION_TIME_MIN:CONSTRUCTION_TIME_MAX)
    push!(model.construction_sector.housesInConstruction[location][size_interval], PendingConstruction(0, permitTime, constructionTime, newHouse))
    content = "Start new Construction $(newHouse.area) $(newHouse.percentile) $(newHouse.location)\n"
    open("$output_folder/transactions_logs/step_$(model.steps).txt", "a") do file
        write(file, content)
    end
    return true
end

function createConstructionLoan(model, value)
    if (model.bank.wealth * 0.5 < value)

        return false # verify bank liquidity
    end

    debt = calculate_construction_sector_debt(model)
    if model.construction_sector.wealth - debt < -1 * STARTING_CONSTRUCTION_SECTOR_WEALTH
        return false
    end

    push!(model.construction_sector.mortgages, Mortgage(value, value, 0, calculateMortgageDurationForConstructionSector()))
    model.bank.wealth -= value
    model.construction_sector.wealth += value
    return true
end

function generateAreaFromSizeInterval(size_interval)
    area = 0
    if size_interval == LessThan50
        area = rand(25:50)
    elseif size_interval == LessThan75
        area = rand(50:75)
    elseif size_interval == LessThan125
        area = rand(75:125)
    elseif size_interval == More
        area = Int64(round(rand(Normal(135, 10))))
        if area <  125
            area = Int64(round(125 + 10 * rand()))
        end
    else
        println("Error: unknown sizeInterval $size_interval")
        exit(1)
    end
    return area
end
function generateHouseToBeBuilt(location, size_interval)
    area = generateAreaFromSizeInterval(size_interval)
    bestPercentile = -1
    bestMargin = -1
    expectedDuration = rand(CONSTRUCTION_DELAY_MIN:CONSTRUCTION_DELAY_MAX)
    expectedDuration += rand(CONSTRUCTION_TIME_MIN:CONSTRUCTION_TIME_MAX)
    for testPercentile in rand(1:100, 5)
        marketPrice = calculate_market_price(House(area, location, NotSocialNeighbourhood, 1.0, testPercentile), model)
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
    costBasedPrice = calculate_construction_costs(model, house) * CONSTRUCTION_SECTOR_MARKUP
    askPrice = calculate_market_price(house, model)
    if costBasedPrice > askPrice
        askPrice = costBasedPrice
    end
    push!(model.houseMarket.supply, HouseSupply(house, askPrice, Bid[], -1))
    push!(model.housesBuiltPerRegion[house.location][getSizeInterval(house)], house)
    LOG_INFO("Pushed house into housesBuiltPerRegion (location,size) = ($(string(house.location)), $(string(getSizeInterval(house))))")
    open("$output_folder/transactions_logs/step_$(model.steps).txt", "a") do file
        write(file, "price of newly built house = $askPrice\n")
    end
    println("price of newly built house = " * string(askPrice))
end

function calculate_construction_sector_debt(model)
    debt = 0
    for i in 1:length(model.construction_sector.mortgages)
        debt += model.construction_sector.mortgages[i].valueInDebt
    end
    return debt
end

function calculate_total_construction_costs(model, house, expectedDuration)
    finnancingMultiplier = expectedDuration * (model.bank.interestRate / 12)
    landCosts = LAND_COSTS * house.area
    constructionCosts = calculate_construction_costs(model, house)
    return (1 + finnancingMultiplier) * (landCosts + constructionCosts)
end

function calculate_construction_costs(model, house)
    constructionCosts = map_value(house.percentile, 1, 100, CONSTRUCTION_COSTS_MIN, CONSTRUCTION_COSTS_MAX) * house.area
    constructionCosts *= 1 + CONSTRUCTION_VAT
    constructionCosts *= PROJECT_COST_MULTIPLIER
    return constructionCosts
end