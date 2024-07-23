# salaries_sub24 = rand(247:1500, Int64(NUMBER_OF_HOUSEHOLDS/4))
# salaries_25_34 = vcat(salaries, rand(500:2670, Int64(NUMBER_OF_HOUSEHOLDS/4)))
# salaries_35_44 = vcat(salaries, rand(500:3500, Int64(NUMBER_OF_HOUSEHOLDS/4)))
# salaries_45_54 = vcat(salaries, rand(544:3800, Int64(NUMBER_OF_HOUSEHOLDS/4)))
# salaries_55_64 = vcat(salaries, rand(480:4100, zNUMBER_OF_HOUSEHOLDS/4)))
include("table.jl")
include("consts.jl")


mutable struct Mortgage
    intialValue::Float64
    valueInDebt::Float64
    maturity::Int # unused, this should be enhanced...
    duration::UInt16 # months
end

# Highly influences price, without big changes in geographical location
@enum HouseLocationType begin
    SocialNeighbourhood = 1
    NotSocialNeighbourhood = 2
end

@multiagent :opt_speed struct MyMultiAgent(NoSpaceAgent)
    @subagent struct Household
        wealth::Float64
        age::Int64
        size::Int64
        houseIds::Array{Int}
        percentile::Int64
        mortgages::Array{Mortgage}
        contractsIdsAsLandlord::Array{Int}
        contractIdAsTenant::Int # 0 is no contract
        wealthInHouses::Float64
        residencyZone::HouseLocation
    end
    
    @subagent struct Company
        n_of_employees::UInt16
    end
end

mutable struct Contract
    landlordId::Int
    tenantId::Int
    houseId::Int
    monthlyPayment::Float64
end

mutable struct Inheritage
    houseIds::Array{Int}
    wealth::Float64
    mortgages::Array{Mortgage}
    # characteristics of the household maybe?
    percentile::Int64
end

mutable struct House
    area::UInt16
    location::HouseLocation
    locationType::HouseLocationType
    maintenanceLevel::Float64 # 0..1
end

mutable struct Transaction
    area
    price
    location
end

mutable struct Bid
    value::Float64
    householdId::Int
end

mutable struct HouseSupply
    houseId::Int
    price::Float64
    @atomic bids::Array{Bid}
    sellerId::Int
    valid::Bool
end

mutable struct HouseDemand
    householdId::Int
    @atomic supplyMatches::Array{HouseSupply}
    size::UInt16
end

mutable struct HouseMarket
    supply::Array{HouseSupply}
    demand::Array{HouseDemand}
end

mutable struct RentalSupply
    houseId::Int
    monthlyPrice::Float64
    sellerId::Int
    valid::Bool
end

mutable struct RentalDemand
    householdId::Int
    supplyMatches::Array{RentalSupply}
    size::UInt16
end

mutable struct RentalMarket
    supply::Array{RentalSupply}
    demand::Array{RentalDemand}
end

mutable struct Government
    wealth::Float64
    irs
    irc
    vat
    subsidyRate::Float64
end

mutable struct Bank
    wealth::Float64
    interestRate::Float64
    ltv::Float64
    dsti::Float64
end

mutable struct PendingConstruction
    time::Int # time that has passed since the start of the construction
    house::House
end

mutable struct ConstructionSector
    wealth::Float64
    housesInConstruction::Array{PendingConstruction}
    constructionDelay::Int # in months
    mortgages::Array{Mortgage}
end

mutable struct HouseholdInfo #TODO: drop this
    wealth::Float64
    size
end

mutable struct HouseInfo
    area::Int
end

@enum BucketKey begin
    smaller_than_50 = 1
    smaller_than_90 = 2
    smaller_than_120 = 3
    bigger_than_120 = 4
end

function calculate_rental_market_price(house)
    return house.area * 8.20 * house.maintenanceLevel
end

function calculate_market_price(house, model)
    bucketKey = calculateBucketKey(house)
    transactions = model.buckets[bucketKey]
    if length(transactions) == 0
        return calculate_initial_market_price(house)
    end
    return mean(transactions) * house.area * house.maintenanceLevel
end

function calculate_initial_market_price(house)
    ## TODO: houses should have a quality (maybe replace maintenanceLevel ?)
    ## this quality should influence the price per m2 according to the firstQuartileHousePricesPerRegion
    ## stop using only first quartile
    return house.area * firstQuartileHousePricesPerRegion[house.location] * house.maintenanceLevel
end

function updateMortgage(mortgage, spread)
    monthly_spread = spread / 12
    interests_paid = mortgage.valueInDebt * monthly_spread
    mortgage.valueInDebt -= calculateMortgagePayment(mortgage, spread) - interests_paid
    mortgage.maturity += 1
end

function calculateMortgageDuration(value, age)
    return 360 # TODO: hardcoded, age of the household also relevant to calculate max mortgageValue
end

# 100000 * (0.015/12) / (1 - (1 + 0.015/12)^(-360))
function calculateMortgagePayment(mortgage, spread)
    monthly_spread = spread / 12
    return (mortgage.intialValue * monthly_spread) / (1 - (1 + monthly_spread)^(-1 * mortgage.duration)) 
end

# lets just skip this and use maxMortgageValue for now...
function calculateReservationPrice(household, house)
    
end

function shouldBid(household, house, askPrice)
    
end

function calculateBid(household, house, askPrice, maxMortgageValue)
    demandValue = household.wealth * 0.95 + maxMortgageValue
    if (demandValue < askPrice)
        return 0
    end
    return demandValue * 0.5 + askPrice * 0.5
end

# few options here, we can have a maxMortgageValue that the bank is
# willing to provide or we can have the maxValue for the conditions established by the household
# so the behaviour should be something like:
# - maxMortgageValue(h, b, house) -> max value the bank is willing to lend
# - maxMortgageValue(h, b, house, maxSpread = x | maxMonthlyPayment = y) -> maxValue with certain conditions
function maxMortgageValue(model, household, bank, house; maxSpread=0, maxMonthlyPayment=0)
    salary = calculateLiquidSalary(household, model)
    if salary < 0
        return 0
    end
    startingMaxValue = household.wealth * (1 / (1 - bank.ltv))
    # startingMaxValue = calculate_market_price(house, model) * bank.ltv
    maxValue = 0
    while maxValue == 0
        duration = calculateMortgageDuration(startingMaxValue, household.age)
        payment = calculateMortgagePayment(Mortgage(startingMaxValue, startingMaxValue, 0, duration), bank.interestRate)
        if payment > salary * bank.dsti
            startingMaxValue *= 0.90
        else
            maxValue = startingMaxValue
            break
        end
    end
    if maxValue < 0
        return 0
    end
    return maxValue 
end

# Baseprice is the market price when the offer was posted
function calculateAskPrice(basePrice, monthsSincePost)
    priceReduction = 0.01
    return basePrice * (1 - priceReduction)^monthsSincePost    
end

# adding model here because the unit costs might depend on the regional salaries
# model should probably be removed
function calculateCostBasedPrice(model, size, location)
    # TODO:
end

function generateInitialWealth(age, percentile)
    return age * 200 + percentile * 50
    # return age * 20 + percentile * 5
end

function calculateSalary(household, model)
    percentile = household.percentile
    if percentile < 25
        salary = 750 + 150 * (percentile / 100) * 4
    elseif percentile < 50
        salary = 900 + 150 * ((percentile / 100) - 0.25) * 4
    elseif percentile < 75
        salary = 1000 + 400 * ((percentile / 100) - 0.50) * 4
    elseif percentile < 85
        salary = 1400 + 500 * ((percentile / 100) - 0.75) * 10
    elseif percentile < 95
        salary = 1900 + 600 * ((percentile / 100) - 0.85) * 10
    else
        salary = 2500 + 2000 * ((percentile / 100) - 0.95) * 20
    end
    # age = household.age
    size = household.size
    # salary = 0
    # if (age <= 24)
    #     lowest_salary_in_percentile = age_less_24_salary_map[percentile]
    #     salary = lowest_salary_in_percentile + rand(1:lowest_salary_in_percentile*0.10) 
    # elseif (age <= 34)
    #     lowest_salary_in_percentile = age_less_34_salary_map[percentile]
    #     salary = lowest_salary_in_percentile + rand(1:lowest_salary_in_percentile*0.10) 
    # elseif (age <= 44)
    #     lowest_salary_in_percentile = age_less_44_salary_map[percentile]
    #     salary = lowest_salary_in_percentile + rand(1:lowest_salary_in_percentile*0.10) 
    # elseif (age <= 54)
    #     lowest_salary_in_percentile = age_less_54_salary_map[percentile]
    #     salary = lowest_salary_in_percentile + rand(1:lowest_salary_in_percentile*0.10) 
    # else
    #     lowest_salary_in_percentile = age_less_64_salary_map[percentile]
    #     salary = lowest_salary_in_percentile + rand(1:lowest_salary_in_percentile*0.10) 
    # end
    if (size == 1)
        return salary * model.salary_multiplier
    else
        return salary * 2 * model.salary_multiplier
    end
end

function calculateLiquidSalary(household, model)
    baseSalary = calculateSalary(household, model)
    irs = model.government.irs
    if baseSalary < 1600
        return baseSalary * (1 - irs)
    elseif baseSalary < 2400
        taxes = 1600 * irs + (baseSalary - 1600) * irs * 1.5
        return baseSalary - taxes
    else
        taxes = 1600 * irs + (2400 - 1600) * irs * 1.5 + (baseSalary - 2400) * irs * 2
        return baseSalary - taxes
    end
end

# convert a [0..1] float value to a percentile {5, 10, 20...90, 95}
function calculate_percentile(percentileInFloat::Float64)
    if percentileInFloat < 0.10
        return 5
    elseif percentileInFloat < 0.20
        return 10
    elseif percentileInFloat < 0.25
        return 20
    elseif percentileInFloat < 0.30
        return 25
    elseif percentileInFloat < 0.40
        return 30
    elseif percentileInFloat < 0.50
        return 40
    elseif percentileInFloat < 0.60
        return 50
    elseif percentileInFloat < 0.70
        return 60
    elseif percentileInFloat < 0.75
        return 70
    elseif percentileInFloat < 0.70
        return 75
    elseif percentileInFloat < 0.90
        return 80
    elseif percentileInFloat < 0.9
        return 90
    else
        return 95
    end
end

function handle_births(household, model)
    if (household.age >= 20 && household.age < 40 && household.size >= 2)
        # probability should not be fixed
        if  (rand() < 0.055 * (7 - household.size) * (1200 / nagents(model))) # TODO: hardcoded number of agents
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
    probability_of_death = 0.001
    if (household.age > 90)
        probability_of_death += 0.05 + 0.015 * (household.age - 80) + 0.05 * (household.age - 90)
    elseif (household.age > 80)
        probability_of_death += 0.03 + 0.015 * (household.age - 80) + 0.01 * (household.age - 70)
    elseif (household.age > 70)
        probability_of_death += 0.02 + 0.01 * (household.age - 70)
    end
    if (rand() < probability_of_death)
        if household.size == 1
            push!(model.inheritages, Inheritage(household.houseIds, household.wealth, household.mortgages, household.percentile))
            # gov takes the wealth
            model.government.wealth += household.wealth
            model.inheritagesFlow += household.wealth
            #println("remove Agent! id = " * string(household.id))
            model.deaths += 1
            remove_agent!(household, model)
            return true
        else
            household.size = household.size - 1
        end
    end
    return false
end

# returns true if household died
function handle_breakups(household, model)
    if (household.size >= 2)
        probability_of_breakup = 0.001
        if (household.age < 60)
            probability_of_breakup += 0.00005 * (60 - household.age)
        end
        if (rand() < probability_of_breakup)
            add_agent!(Household, model, household.wealth / 2, household.age, 1, Int[], household.percentile, Mortgage[], Int[], 0, 0.0, getChildResidencyZone(household))
            add_agent!(Household, model, household.wealth / 2, household.age, household.size - 1, household.houseIds, household.percentile, household.mortgages, Int[], 0, 0.0, getChildResidencyZone(household))
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
        probability_of_child_leaving = 0.1 + rand() * 0.4
        if (rand() < probability_of_child_leaving)
            expected_age = household.age - 20 # TODO: this should have a random factor
            expected_wealth = generateInitialWealth(expected_age, household.percentile) * 0.6
            if (expected_wealth > household.wealth)
                expected_wealth = household.wealth * 0.2
            end
            randomNumber = rand()
            if randomNumber < 0.45
                # a couple of young people leave their parents home
                newZone = getChildResidencyZone(household)
                add_agent!(Household, model, expected_wealth, expected_age, 2, Int[], household.percentile, Mortgage[], Int[], 0, 0.0, newZone)
                household.wealth -= expected_wealth
                household.size -= 1
                model.children_leaving_home += 2
            elseif randomNumber < 0.9
                # to simulate the other half of the couple (simplification)
                household.size -= 1
            else
                # single young person leaves their parents home
                newZone = getChildResidencyZone(household)
                add_agent!(Household, model, expected_wealth, expected_age, 1, Int[], household.percentile, Mortgage[], Int[], 0, 0.0, newZone)
                household.wealth -= expected_wealth
                household.size -= 1
                model.children_leaving_home += 1
            end
        end
    end
    return false
end

# returns true if household died
function household_evolution(household, model)
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

function getChildResidencyZone(household)
    possibleZones = adjacentZones[household.residencyZone]
    for i in 1:10
        # Virtually increase likelihood of staying in the residencyZone
        push!(possibleZones, household.residencyZone)
    end
    return possibleZones[rand(1:length(possibleZones))]
end

function receive_inheritages(household, model)
    if (rand() < 0.02)
        for i in 1:length(model.inheritages)
            inheritage = model.inheritages[i]
            if (abs(inheritage.percentile - household.percentile) <= 50) # change this percentile?
                household.houseIds = vcat(household.houseIds, inheritage.houseIds)
                household.wealth += inheritage.wealth
                model.government.wealth -= inheritage.wealth
                model.inheritagesFlow -= inheritage.wealth
                splice!(model.inheritages, i)
                break
            end
        end
    end
end

function terminateContractsOnTentantSide(household, model)
    if household.contractIdAsTenant != 0
        contract = model.contracts[household.contractIdAsTenant]
        println("landlordId = " * string(contract.landlordId))
        println("tenantId = " * string(contract.tenantId))
        landlord = model[contract.landlordId]
        push!(landlord.houseIds, contract.houseId)
        for i in 1:length(landlord.contractsIdsAsLandlord)
            if landlord.contractsIdsAsLandlord[i] == household.contractIdAsTenant
                splice!(landlord.contractsIdsAsLandlord, i)
                break
            end
        end
        household.contractIdAsTenant = 0
    end
end

function terminateContractsOnLandLordSide(household, model)
    for i in 1:length(household.contractsIdsAsLandlord)
        contractId = household.contractsIdsAsLandlord[i]
        contract = model.contracts[contractId]
        tenant = model[contract.tenantId]
        tenant.contractIdAsTenant = 0
        push!(household.houseIds, contract.houseId)
    end
end

function clearHouseMarket(model)
    # TODO: optimize this (below block is slower than all household_steps)
    localLock = ReentrantLock()
    Threads.@threads for i in 1:length(model.houseMarket.supply)
        supply = model.houseMarket.supply[i]
        for j in 1:length(model.houseMarket.demand)
            if rand() < 0.7 # only view 30% of the offers
                continue
            end
            demand = model.houseMarket.demand[j]
            if model[demand.householdId].wealth < 0
                continue
            end
            maxMortgage = maxMortgageValue(model, model[demand.householdId], model.bank, model.houses[supply.houseId])
            # println("###")
            # println("maxMortage = " * string(maxMortgage))
            # println("householdId = " * string(demand.householdId))
            # println("###")
            demandBid = calculateBid(model[demand.householdId], model.houses[supply.houseId], supply.price, maxMortgage)
            if (has_enough_size(model.houses[supply.houseId], model[demand.householdId].size) && demandBid > supply.price)
                lock(localLock) do
                    push!(supply.bids, Bid(demandBid, demand.householdId))
                    push!(demand.supplyMatches, supply)
                end
            end
        end
    end

    for i in 1:length(model.houseMarket.demand)
        demand = model.houseMarket.demand[i]
        cheapest_value = 99999999 # TODO: find const value for this
        cheapest_supply = nothing 
        for j in 1:length(demand.supplyMatches)
            supply = demand.supplyMatches[j]
            if !supply.valid
                continue
            end
            if (cheapest_value > supply.price)
                cheapest_value = supply.price
                cheapest_supply = supply
            end
        end
        if cheapest_supply !== nothing
            buy_house(model, cheapest_supply)
        end
    end
    empty!(model.houseMarket.demand)
    i = 1
    while i < length(model.houseMarket.supply)
        if !model.houseMarket.supply[i].valid
            splice!(model.houseMarket.supply, i)
        else
            model.houseMarket.supply[i].price *= 0.99 # reduce price
            empty!(model.houseMarket.supply[i].bids)
            i += 1
        end
            # println("model_step")
    end
end

function clearRentalMarket(model)
    # TODO: optimize this
    for i in 1:length(model.rentalMarket.supply)
        supply = model.rentalMarket.supply[i]
        for j in 1:length(model.rentalMarket.demand)
            if rand() < 0.7 # only view 30% of the offers
                continue
            end
            demand = model.rentalMarket.demand[j]
            household = model[demand.householdId]
            if (has_enough_size(model.houses[supply.houseId], household.size) && calculateLiquidSalary(household, model) * 0.40 > supply.monthlyPrice)
                push!(demand.supplyMatches, supply)
            end
        end
    end

    for i in 1:length(model.rentalMarket.demand)
        demand = model.rentalMarket.demand[i]
        household = model[demand.householdId]
        cheapest_value = 99999999 # TODO: find const value for this
        cheapest_supply = nothing 
        for j in 1:length(demand.supplyMatches)
            supply = demand.supplyMatches[j]
            if !supply.valid
                continue
            end
            if (cheapest_value > supply.monthlyPrice)
                cheapest_value = supply.monthlyPrice
                cheapest_supply = supply
            end
        end
        if cheapest_supply !== nothing
            rent_house(model, cheapest_supply, household)
            cheapest_supply.valid = false
        end
    end
    empty!(model.rentalMarket.demand)
    i = 1
    while i < length(model.rentalMarket.supply)
        if !model.rentalMarket.supply[i].valid
            splice!(model.rentalMarket.supply, i)
        else
            model.rentalMarket.supply[i].monthlyPrice *= 0.99 # reduce price
            i += 1
        end
    end
end

function buy_house(model, supply::HouseSupply)
    seller = nothing
    if supply.sellerId == -1
        seller = model.construction_sector
    else
        try
            seller = model[supply.sellerId]
        catch
            return # seller died, more luck next time...
        end
    end

    highestBidder = nothing
    highestBid = supply.price
    secondHighestBid = 0
    for i in 1:length(supply.bids)
        currentBidder = nothing
        try
            currentBidder = model[supply.bids[i].householdId]
        catch
            continue # this bidder died, more luck next time...
        end
        if (is_home_owner(currentBidder)) 
            # already won a bid for other houses
            # this check needs to change, a home owner might want to buy a house for rental
            continue
        end
        if (supply.bids[i].value > highestBid)
            secondHighestBid = highestBid
            highestBid = supply.bids[i].value
            highestBidder = supply.bids[i].householdId
        end
    end
    if (highestBidder === nothing)
        return
    end
    household = model[highestBidder]
    if (household.wealth < secondHighestBid)
        paidWithOwnMoney = household.wealth * 0.95
        mortgageValue = secondHighestBid - paidWithOwnMoney
        if mortgageValue > model.bank.wealth * 0.5
            return
        end
        mortgageDuration = calculateMortgageDuration(mortgageValue, household.age)
        mortgage = Mortgage(mortgageValue, mortgageValue, 0, mortgageDuration)
        push!(household.mortgages, mortgage)
        println("########")
        println("mortgageValue = " * string(mortgageValue))
        println("household.wealth = " * string(household.wealth))
        println("raw salary = " * string(calculateSalary(household, model)))
        println("liquid salary = " * string(calculateLiquidSalary(household, model)))
        println("householdId = " * string(highestBidder))
        println("########")
        model.bank.wealth -= mortgageValue
        household.wealth += mortgageValue
    else
        # house will be paid without mortgage... unusual
    end
    household.wealth -= secondHighestBid
    seller.wealth += secondHighestBid
    push!(household.houseIds, supply.houseId)
    terminateContractsOnTentantSide(household, model)
    addTransactionToBuckets(model, model.houses[supply.houseId], secondHighestBid)
    push!(model.transactions, Transaction(model.houses[supply.houseId].area, secondHighestBid, model.houses[supply.houseId].location))
    supply.valid = false
    # for i in 1:length(seller.houseIds)
    #     if (seller.houseIds[i] == supply.houseId)
    #         splice!(seller.houseIds, i)
    #         break
    #     end
    # end
end

function rent_house(model, supply::RentalSupply, household)
    seller = nothing
    try
        seller = model[supply.sellerId]
    catch
        return # landlord died, more luck next time...
    end

    if household.contractIdAsTenant != 0
        return # already renting
    end
    push!(model.contracts, Contract(seller.id, household.id, supply.houseId, supply.monthlyPrice))
    household.contractIdAsTenant = length(model.contracts)
    push!(seller.contractsIdsAsLandlord, length(model.contracts))
end

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
    return House(area, Lisboa, NotSocialNeighbourhood, 1)
end

function put_newly_built_house_to_sale(model, house)
    laborCost = 6000 * 12
    costBasedPrice = (model.construction_sector.constructionDelay * 500 + laborCost + house.area * 500) * 1.2 # markup
    push!(model.houses, house)
    push!(model.houseMarket.supply, HouseSupply(length(model.houses), costBasedPrice, Int[], -1, true))
    println("costBasedPrice = " * string(costBasedPrice))
end

function calculate_construction_sector_debt(model)
    debt = 0
    for i in 1:length(model.construction_sector.mortgages)
        debt += model.construction_sector.mortgages[i].valueInDebt
    end
    return debt
end

function public_investment(model)
    # gov pays company services for each household
    model.company_wealth += NUMBER_OF_HOUSEHOLDS * 1300 * model.government.subsidyRate
    model.government.wealth -= NUMBER_OF_HOUSEHOLDS * 1300 * model.government.subsidyRate
    model.companyServicesPaid += NUMBER_OF_HOUSEHOLDS * 1300 * model.government.subsidyRate
end

function InitiateBuckets()
    result = Dict([
        (Amadora, Float64[])
        (Cascais, Float64[])
        (Lisboa, Float64[])
        (Loures, Float64[])
        (Mafra, Float64[])
        (Odivelas, Float64[])
        (Oeiras, Float64[])
        (Sintra, Float64[])
        (VilaFrancaDeXira, Float64[])
        (Alcochete, Float64[])
        (Almada, Float64[])
        (Barreiro, Float64[])
        (Moita, Float64[])
        (Montijo, Float64[])
        (Palmela, Float64[])
        (Seixal, Float64[])
        (Sesimbra, Float64[])
        (Setubal, Float64[])
    ])
    return result
end

function calculateBucketKey(house)
    return house.location
#     if house.area < 50
#         return smaller_than_50
#     elseif house.area < 90
#         return smaller_than_90
#     elseif house.area < 120
#         return smaller_than_120
#     else
#         return bigger_than_120
#     end
end

function addTransactionToBuckets(model, house, price)
    bucketKey = calculateBucketKey(house)
    push!(model.buckets[bucketKey], price / house.area)
end

function trimBucketsIfNeeded(model)
    # avoid holding to many transaction in the buckets, keep the most recent MAX_BUCKET_SIZE (initially 30)
    for bucket in model.buckets
        if length(bucket[2]) > MAX_BUCKET_SIZE
            sizeToCut = length(bucket[2]) - MAX_BUCKET_SIZE
            splice!(bucket[2], 1:sizeToCut)
        end
    end
end

function sortRandomly(left, right)
    return rand() < 0.5
end

function initiateHouses(model)
    houses_sizes = rand(30:60, Int64(NUMBER_OF_HOUSES/4))
    houses_sizes = vcat(houses_sizes, rand(60:80, Int64(NUMBER_OF_HOUSES/4)))
    houses_sizes = vcat(houses_sizes, rand(80:120, Int64(NUMBER_OF_HOUSES/4)))
    houses_sizes = vcat(houses_sizes, rand(120:180, Int64(NUMBER_OF_HOUSES/4)))
    
    sort!(houses_sizes, lt=sortRandomly)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Amadora, Amadora, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Cascais, Cascais, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Lisboa, Lisboa, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Loures, Loures, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Mafra, Mafra, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Odivelas, Odivelas, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Oeiras, Oeiras, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Sintra, Sintra, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_VilaFrancaDeXira, VilaFrancaDeXira, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Alcochete, Alcochete, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Almada, Almada, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Barreiro, Barreiro, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Moita, Moita, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Montijo, Montijo, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Palmela, Palmela, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Seixal, Seixal, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Sesimbra, Sesimbra, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Setubal, Setubal, houses_sizes)
    sort!(model.houses, lt=sortRandomly)
end

function initiateHousesPerRegion(model, targetNumberOfHouses, location, houses_sizes)
    for i in 1:targetNumberOfHouses
        push!(model.houses, House(houses_sizes[1], location, NotSocialNeighbourhood, 1))
        splice!(houses_sizes, 1)
    end
end

function initiateHouseholds(model, households_initial_ages)
    for zone_str in ZONES_STRINGS
        for size_str in SIZES_STRINGS
            number_of_households = eval(Symbol("HOUSEHOLDS_WITH_SIZE_" * size_str * "_IN_" * zone_str))
            for i in 1:number_of_households
                initial_age = households_initial_ages[1]
                splice!(households_initial_ages, 1)
                percentile = calculate_percentile(rand())
                zone = eval(Symbol(zone_str))
                size = get_household_size(size_str)
                add_agent!(Household, model, generateInitialWealth(initial_age, percentile), initial_age, size, Int64[], percentile, Mortgage[], Int[], 0, 0.0, zone)
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
    housePool = splice!(model.houses, 1:length(model.houses))
    for i in 1:nagents(model) # due to round() it might not be equal to NUMBER_OF_HOUSEHOLDS
        household = model[i]
        # if shouldAssignHouse(model, household, zones_to_n_of_home_owners)
        if !assignHouseThatMakesSense(model, household, housePool)
            # Wasn't assigned a house...
            push!(not_home_owners, household)
            continue # also not going to get houses for rental
        else
            zones_to_n_of_home_owners[household.residencyZone] += 1
        end
        # else
        #     push!(not_home_owners, household)
        #     continue        
        # end
        numberOfExtraHousesToAssign = shouldAssignMultipleHouses(model, household)
        assignHousesForRental(model, household, numberOfExtraHousesToAssign, housePool)
    end
end

# function shouldAssignHouse(model, household, zones_to_n_of_home_owners)
#     zone = household.residencyZone
#     zone_str = string(zone)
#     target_home_owners_in_the_zone = eval(Symbol("HOME_OWNERS_IN_" * zone_str))
#     current_home_owners_in_the_zone = zones_to_n_of_home_owners[zone]
#     if current_home_owners_in_the_zone >= target_home_owners_in_the_zone
#         return false # no more houses to assign in this phase
#     end
#     probabilityOfBeingHomeOwner = target_home_owners_in_the_zone / eval(Symbol("NUMBER_OF_HOUSES_IN_" * zone_str))
#     probabilityMultiplier = 1
#     # add probability of owning house to the bigger households, and to the older ones
#     # max 30% extra likelihood
#     if household.age > 40
#         probabilityMultiplier += 0.15
#     end

#     if household.size > 2
#         probabilityMultiplier += 0.15
#     end
#     if rand() < probabilityOfBeingHomeOwner * probabilityMultiplier * 1.15 # increased probability, to make sure we assign all the houses
#         return true
#     end
#     return false
# end

function update_houses(household, model)
    for houseId in household.houseIds
        if rand() < 0.16 # 16 % probability to simulate twice a year, but not all at the same time
            house = model.houses[houseId]
            house.maintenanceLevel -= 0.01
        end
    end
end

function get_household_size(size_str)
    if size_str == "1"
        return 1
    elseif size_str == "2"
        return 2
    elseif size_str == "3"
        return 3
    elseif size_str == "4"
        return 4
    else
        randomNumber = rand()
        if randomNumber > 0.3
            return 5
        elseif randomNumber > 0.15
            return 6
        elseif randomNumber > 0.05
            return 7
        else
            return 8
        end
    end
end

function assignHouseThatMakesSense(model, household, housePool)
    for i in eachindex(housePool)
        house = housePool[i]
        if household.residencyZone != house.location || 
           !has_enough_size(house, household.size)
            continue
        end
        if rand() < probabilityOfHouseholdBeingAssignedToHouse(household, house)
            push!(model.houses, house)
            splice!(housePool, i)
            push!(household.houseIds, length(model.houses))
            return true
        end
    end
    return false
end

function probabilityOfHouseholdBeingAssignedToHouse(household, house)
    m2_per_person = house.area / household.size
    numberOfHousesInThatZone = eval(Symbol("NUMBER_OF_HOUSES_IN_" * string(house.location)))
    numberOfHousesWithThatRatioInThatZone = 0
    if m2_per_person < 10
        numberOfHousesWithThatRatioInThatZone = eval(Symbol("NUMBER_OF_HOUSES_WITH_LT_10_M2_PER_PERSON_IN_" * string(house.location)))
    elseif m2_per_person < 15
        numberOfHousesWithThatRatioInThatZone = eval(Symbol("NUMBER_OF_HOUSES_WITH_LT_15_M2_PER_PERSON_IN_" * string(house.location)))
    elseif m2_per_person < 20
        numberOfHousesWithThatRatioInThatZone = eval(Symbol("NUMBER_OF_HOUSES_WITH_LT_20_M2_PER_PERSON_IN_" * string(house.location)))
    elseif m2_per_person < 30
        numberOfHousesWithThatRatioInThatZone = eval(Symbol("NUMBER_OF_HOUSES_WITH_LT_30_M2_PER_PERSON_IN_" * string(house.location)))
    elseif m2_per_person < 40
        numberOfHousesWithThatRatioInThatZone = eval(Symbol("NUMBER_OF_HOUSES_WITH_LT_40_M2_PER_PERSON_IN_" * string(house.location)))
    elseif m2_per_person < 60
        numberOfHousesWithThatRatioInThatZone = eval(Symbol("NUMBER_OF_HOUSES_WITH_LT_60_M2_PER_PERSON_IN_" * string(house.location)))
    elseif m2_per_person < 80
        numberOfHousesWithThatRatioInThatZone = eval(Symbol("NUMBER_OF_HOUSES_WITH_LT_80_M2_PER_PERSON_IN_" * string(house.location)))
    else
        numberOfHousesWithThatRatioInThatZone = eval(Symbol("NUMBER_OF_HOUSES_WITH_MT_80_M2_PER_PERSON_IN_" * string(house.location)))
    end
    return numberOfHousesWithThatRatioInThatZone / numberOfHousesInThatZone
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

function assignHousesForRental(model, household, numberOfExtraHousesToAssign, housePool)
    zones = adjacentZones[household.residencyZone]
    assignedSoFar = 0
    push!(zones, household.residencyZone)
    i = 1
    while i <= length(housePool)
        if assignedSoFar == numberOfExtraHousesToAssign
            return
        end
        house = housePool[i]
        if !(house.location in zones)
            i += 1
            continue
        end
        push!(model.houses, house)
        splice!(housePool, i)
        push!(household.houseIds, length(model.houses))
        put_house_to_rent(household, model, length(household.houseIds))
        assignedSoFar += 1
    end
end