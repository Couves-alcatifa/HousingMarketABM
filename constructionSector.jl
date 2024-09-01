function updateConstructions(model)
    targetConstruction = calculateTargetConstruction(model)
    newConstructions = targetConstruction - length(model.construction_sector.housesInConstruction)
    if (newConstructions > 0)
        for i in 1:newConstructions
            if (!startNewConstruction(model))
                break
            end
        end
    end
    i = 1
    while i <= length(model.construction_sector.housesInConstruction)
        pendingConstruction = model.construction_sector.housesInConstruction[i]
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
        timeItTakesToBuild = 12 # 12 months for actual construction
        if (pendingConstruction.time == model.construction_sector.constructionDelay + timeItTakesToBuild)
            put_newly_built_house_to_sale(model, pendingConstruction.house)
            splice!(model.construction_sector.housesInConstruction, i)
        else
            i += 1
        end
    end
end

function calculateTargetConstruction(model)
    return model.demand_size - model.supply_size
end

function calculateMortgageDurationForConstructionSector()
    return 100
end

function startNewConstruction(model)
    newHouse = generateRandomHouse()
    materialCost = newHouse.area * 500
    laborCost = model.construction_sector.constructionDelay * 6000

    if materialCost + laborCost > model.construction_sector.wealth
        if !createConstructionLoan(model, materialCost + laborCost)
            return false
        end
    end
    model.government.wealth += materialCost
    model.constructionLabor += laborCost
    model.construction_sector.wealth -= materialCost
    push!(model.construction_sector.housesInConstruction, PendingConstruction(0, newHouse))
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
function generateRandomHouse()
    area = rand(50:125)
    # WARNNING: House must be generated for a specific region
    # taking into consideration the supply and demand in that region
    return House(area, Lisboa, NotSocialNeighbourhood, 1)
end

function put_newly_built_house_to_sale(model, house)
    laborCost = 6000 * 12
    costBasedPrice = (model.construction_sector.constructionDelay * 500 + laborCost + house.area * 500) * 1.2 # markup
    push!(model.houses[house.location], house)
    push!(model.houseMarket.supply, HouseSupply(house, costBasedPrice, Int[], -1, true))
    println("costBasedPrice = " * string(costBasedPrice))
end

function calculate_construction_sector_debt(model)
    debt = 0
    for i in 1:length(model.construction_sector.mortgages)
        debt += model.construction_sector.mortgages[i].valueInDebt
    end
    return debt
end