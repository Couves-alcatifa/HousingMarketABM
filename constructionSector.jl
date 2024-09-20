function updateConstructions(model)
    for location in instances(HouseLocation)
        updateConstructionsPerRegion(model, location)
    end

end

function updateConstructionsPerRegion(model, location)
    targetConstruction = calculateTargetConstructionPerRegion(model, location)
    newConstructions = targetConstruction - length(model.construction_sector.housesInConstruction[location])
    
    if rand() < 0.08
        # only generate new construction once a year to avoid overcommiting
        newConstructions = Int64(floor(newConstructions * (rand() / 3)))
        if (newConstructions > 0)
            for i in 1:newConstructions
                if (!startNewConstruction(model, location))
                    break
                end
            end
        end
    end
    i = 1
    while i <= length(model.construction_sector.housesInConstruction[location])
        pendingConstruction = model.construction_sector.housesInConstruction[location][i]
        pendingConstruction.time += 1
        laborCost = 6000
        if pendingConstruction.time > model.construction_sector.constructionDelay
            # already building
            model.government.wealth += laborCost
            model.constructionLabor += laborCost
            model.construction_sector.wealth -= laborCost
        else
            # still waiting for permit
        end
        if (pendingConstruction.time >= model.construction_sector.constructionDelay + model.construction_sector.constructionTimeMultiplier * pendingConstruction.house.area)
            put_newly_built_house_to_sale(model, pendingConstruction.house)
            splice!(model.construction_sector.housesInConstruction[location], i)
        else
            i += 1
        end
    end 
end

function calculateTargetConstructionPerRegion(model, location)
    return model.demand_size[location] - model.supply_size[location]
end

function calculateMortgageDurationForConstructionSector()
    return 100
end

function startNewConstruction(model, location)
    newHouse = generateRandomHouse(location)
    materialCost = newHouse.area * MATERIAL_COSTS
    laborCost = model.construction_sector.constructionTimeMultiplier * CONSTRUCTION_LABOR_COST * newHouse.area

    if materialCost + laborCost > model.construction_sector.wealth
        if !createConstructionLoan(model, materialCost + laborCost)
            return false
        end
    end
    model.government.wealth += materialCost
    model.constructionLabor += laborCost
    model.construction_sector.wealth -= materialCost
    push!(model.construction_sector.housesInConstruction[location], PendingConstruction(0, newHouse))
    content = "Start new Construction $(newHouse.area) $(newHouse.percentile) $(newHouse.location)\n"
    open("$output_folder/transactions_logs/step_$(model.steps).txt", "a") do file
        write(file, content)
    end
    return true
end

function createConstructionLoan(model, value)
    if model.bank.wealth * 0.5 < value 
        return false # verify bank liquidity
    end
    debt = calculate_construction_sector_debt(model)
    if debt > model.construction_sector.wealth * 2
        return false
    end

    push!(model.construction_sector.mortgages, Mortgage(value, value, 0, calculateMortgageDurationForConstructionSector()))
    model.bank.wealth -= value
    model.construction_sector.wealth += value
    return true
end

## TODO: Change this to something with logic
function generateRandomHouse(location)
    area = UInt16(floor(rand(40:150) * (rand() + 0.8)))
    return House(area, location, NotSocialNeighbourhood, 1.0)
end

function put_newly_built_house_to_sale(model, house)
    laborCost = CONSTRUCTION_LABOR_COST * model.construction_sector.constructionTimeMultiplier * house.area
    costBasedPrice = (model.construction_sector.constructionDelay * 500 + laborCost + house.area * 500)
    askPrice = calculate_market_price(house, model)
    if costBasedPrice > askPrice
        askPrice = costBasedPrice
    end
    askPrice *= CONSTRUCTION_SECTOR_MARKUP
    push!(model.houseMarket.supply, HouseSupply(house, askPrice, Bid[], -1))
    open("$output_folder/transactions_logs/step_$(model.steps).txt", "a") do file
        write(file, "askPrice = $askPrice\n")
    end
    println("askPrice = " * string(askPrice))
end

function calculate_construction_sector_debt(model)
    debt = 0
    for i in 1:length(model.construction_sector.mortgages)
        debt += model.construction_sector.mortgages[i].valueInDebt
    end
    return debt
end