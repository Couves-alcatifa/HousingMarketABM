# salaries_sub24 = rand(247:1500, Int64(num_households/4))
# salaries_25_34 = vcat(salaries, rand(500:2670, Int64(num_households/4)))
# salaries_35_44 = vcat(salaries, rand(500:3500, Int64(num_households/4)))
# salaries_45_54 = vcat(salaries, rand(544:3800, Int64(num_households/4)))
# salaries_55_64 = vcat(salaries, rand(480:4100, znum_households/4)))
include("table.jl")

@enum HouseLocation begin
    Lisbon = 1
    Oeiras = 2
    Sintra = 3
    Almada = 4
end

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
    marketPrice::Float64 # update each model step (or several model steps ? )
end

mutable struct Transaction
    area
    price
end

mutable struct Bid
    value::Float64
    householdId::Int
end

mutable struct HouseSupply
    houseId::Int
    price::Float64
    bids::Array{Bid}
    sellerId::Int
    valid::Bool
end

mutable struct HouseDemand
    householdId::Int
    supplyMatches::Array{HouseSupply}
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

function calculate_rental_market_price(area, maintenanceLevel)
    return area * 8.20 * maintenanceLevel
end

function calculate_market_price(area, maintenanceLevel)
    return area * 1500 * maintenanceLevel
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
    startingMaxValue = house.marketPrice * bank.ltv
    maxValue = 0
    while maxValue == 0
        duration = calculateMortgageDuration(startingMaxValue, household.age)
        payment = calculateMortgagePayment(Mortgage(startingMaxValue, startingMaxValue, 0, duration), bank.interestRate)
        if payment > salary * bank.dsti
            startingMaxValue *= 0.90
        else
            maxValue = startingMaxValue
        end
    end
    return maxValue 
    # TODO: this can be more complex
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
    return age * 800
end

function calculateSalary(household, model)
    percentile = household.percentile
    if percentile < 25
        salary = 750 + rand() * 150
    elseif percentile < 50
        salary = 900 + rand() * 150
    elseif percentile < 75
        salary = 1000 + rand() * 1000
    else
        salary = 2000 + rand() * 2000
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
        if  (rand() < 0.2 * (7 - household.size))
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
    probability_of_death = 0.005
    if (household.age > 90)
        probability_of_death += 0.002 + 0.02 * (household.age - 80) + 0.05 * (household.age - 90)
    elseif (household.age > 80)
        probability_of_death += 0.002 + 0.02 * (household.age - 80)
    elseif (household.age > 70)
        probability_of_death += 0.001 + 0.001 * (household.age - 70)
    end
    if (rand() < probability_of_death)
        if household.size == 1
            push!(model.inheritages, Inheritage(household.houseIds, household.wealth, household.mortgages, household.percentile))
            # gov takes the wealth
            model.government.wealth += household.wealth
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
        probability_of_breakup = 0.005
        if (household.age < 60)
            probability_of_breakup += 0.00025 * (60 - household.age)
        end
        if (rand() < probability_of_breakup)
            add_agent!(Household, model, household.wealth / 2, household.age, 1, Int[], household.percentile, Mortgage[], Int[], 0)
            add_agent!(Household, model, household.wealth / 2, household.age, household.size - 1, household.houseIds, household.percentile, household.mortgages, Int[], 0)
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
        probability_of_child_leaving = 0.01 + 0.01 * (household.age - 38)
        if (rand() < probability_of_child_leaving)
            expected_age = household.age - 20 # TODO: this should have a random factor
            expected_wealth = generateInitialWealth(expected_age, household.percentile) * 0.6
            if (expected_wealth > household.wealth)
                expected_wealth = household.wealth * 0.2
            end
            add_agent!(Household, model, expected_wealth, expected_age, rand(1:2), Int[], household.percentile, Mortgage[], Int[], 0)
            household.wealth -= expected_wealth
            model.children_leaving_home += 1
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

function receive_inheritages(household, model)
    if (rand() < 0.02)
        for i in 1:length(model.inheritages)
            inheritage = model.inheritages[i]
            if (abs(inheritage.percentile - household.percentile) <= 50) # change this percentile?
                household.houseIds = vcat(household.houseIds, inheritage.houseIds)
                household.wealth += inheritage.wealth
                model.government.wealth -= inheritage.wealth
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
    # TODO: optimize this
    for i in 1:length(model.houseMarket.supply)
        supply = model.houseMarket.supply[i]
        for j in 1:length(model.houseMarket.demand)
            if rand() < 0.7 # only view 30% of the offers
                continue
            end
            demand = model.houseMarket.demand[j]
            maxMortgage = maxMortgageValue(model, model[demand.householdId], model.bank, model.houses[supply.houseId])
            demandBid = calculateBid(model[demand.householdId], model.houses[supply.houseId], supply.price, maxMortgage)
            if (has_enough_size(model.houses[supply.houseId], model[demand.householdId].size) && demandBid > supply.price)
                push!(supply.bids, Bid(demandBid, demand.householdId))
                push!(demand.supplyMatches, supply)
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
            cheapest_supply.valid = false
        end
    end
    empty!(model.houseMarket.demand)
    i = 1
    while i < length(model.houseMarket.supply)
        if !model.houseMarket.supply[i].valid
            splice!(model.houseMarket.supply, i)
        else
            model.houseMarket.supply[i].price *= 0.99 # reduce price
            model.houses[model.houseMarket.supply[i].houseId].marketPrice = model.houseMarket.supply[i].price
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
        mortgageDuration = calculateMortgageDuration(mortgageValue, household.age)
        mortgage = Mortgage(mortgageValue, mortgageValue, 0, mortgageDuration)
        push!(household.mortgages, mortgage)
        println("########")
        println("mortgageValue = " * string(mortgageValue))
        println("household.wealth = " * string(household.wealth))
        println("raw salary = " * string(calculateSalary(household, model)))
        println("liquid salary = " * string(calculateLiquidSalary(household, model)))
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
    push!(model.transactions, Transaction(model.houses[supply.houseId].area, secondHighestBid))
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
    randomIndex = rand(1:4)
    areas = [50, 75, 100, 125]
    area = areas[randomIndex]
    return House(area, Lisbon, NotSocialNeighbourhood, 1, calculate_market_price(area, 1))
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
    model.company_wealth += model.num_households * 1300 * model.government.subsidyRate
    model.government.wealth -= model.num_households * 1300 * model.government.subsidyRate
end