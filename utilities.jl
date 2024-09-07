# salaries_sub24 = rand(247:1500, Int64(NUMBER_OF_HOUSEHOLDS/4))
# salaries_25_34 = vcat(salaries, rand(500:2670, Int64(NUMBER_OF_HOUSEHOLDS/4)))
# salaries_35_44 = vcat(salaries, rand(500:3500, Int64(NUMBER_OF_HOUSEHOLDS/4)))
# salaries_45_54 = vcat(salaries, rand(544:3800, Int64(NUMBER_OF_HOUSEHOLDS/4)))
# salaries_55_64 = vcat(salaries, rand(480:4100, zNUMBER_OF_HOUSEHOLDS/4)))
include("table.jl")
include("consts.jl")
include("logger.jl")
include("constructionSector.jl")

function calculate_rental_market_price(house)
    return house.area * 8.20 * house.maintenanceLevel
end

function calculate_market_price(house, model)
    bucketKey = calculateBucketKey(house)
    transactions = model.buckets[bucketKey]
    if length(transactions) == 0
        # println("house = $house calculate_initial_market_price(house) = $(calculate_initial_market_price(house))")
        return calculate_initial_market_price(house)
    end
    # println("house = $house mean(transactions) * house.area * house.maintenanceLevel = $(mean(transactions) * house.area * house.maintenanceLevel)")
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
    # TODO: add a random factor
    return age * INITIAL_WEALTH_PER_AGE * rand(Normal(INITIAL_WEALTH_MULTIPLICATION_AVERAGE, INITIAL_WEALTH_MULTIPLICATION_STDEV)) 
        + percentile * INITIAL_WEALTH_PER_PERCENTILE * rand(Normal(INITIAL_WEALTH_MULTIPLICATION_AVERAGE, INITIAL_WEALTH_MULTIPLICATION_STDEV))
    # return age * 20 + percentile * 5
end

function calculateSalary(household, model)
    location = household.residencyZone
    percentile = household.percentile
    if percentile < 20
        base = eval(Symbol("FIRST_QUINTILE_INCOME_IN_$(string(location))")) / 2
        range = base * 2
        salary = base + range * (percentile / 100) * 5
    elseif percentile < 40
        base = eval(Symbol("FIRST_QUINTILE_INCOME_IN_$(string(location))"))
        range = eval(Symbol("SECOND_QUINTILE_INCOME_IN_$(string(location))")) - base
        salary = base + range * (percentile / 100 - 0.2) * 5
    elseif percentile < 60
        base = eval(Symbol("SECOND_QUINTILE_INCOME_IN_$(string(location))"))
        range = eval(Symbol("THIRD_QUINTILE_INCOME_IN_$(string(location))")) - base
        salary = base + range * (percentile / 100 - 0.4) * 5
    elseif percentile < 80
        base = eval(Symbol("THIRD_QUINTILE_INCOME_IN_$(string(location))"))
        range = eval(Symbol("FOURTH_QUINTILE_INCOME_IN_$(string(location))")) - base
        salary = base + range * (percentile / 100 - 0.6) * 5
    else
        base = eval(Symbol("FOURTH_QUINTILE_INCOME_IN_$(string(location))"))
        range = base * 3
        salary = base + range * (percentile / 100 - 0.8) * 5
    end
    if (size == 1)
        return salary * model.salary_multiplier * INCOME_MULTIPLICATION_FACTOR * (1 + househod.age/50)
    else
        return salary * 2 * model.salary_multiplier * INCOME_MULTIPLICATION_FACTOR * (1 + househod.age/50)
    end
end

function calculateLiquidSalary(household, model)
    baseSalary = calculateSalary(household, model)
    irs = model.government.irs
    if baseSalary < 1200
        return baseSalary * (1 - irs / 4)
    elseif baseSalary < 1600
        return 1200 * (1 - irs / 4) + (baseSalary - 1200) * (1 - irs / 2)
    else
        return 1200 * (1 - irs / 4) + 400 * (1 - irs / 2) + (baseSalary - 1600) * (1 - irs)
    end
end

# convert a [0..1] float value to a percentile {5, 10, 20...90, 95}
function calculate_percentile(percentileInFloat::Float64)
    return rand(0:100)
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
            push!(model.inheritages, Inheritage(household.houses, household.wealth, household.mortgages, household.percentile))
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
            add_agent!(Household, model, household.wealth / 2, household.age, 1, Int[], household.percentile, Mortgage[], Int[], 0, 0.0, getChildResidencyZone(household), rand(Normal(GREEDINESS_AVERAGE, GREEDINESS_STDEV), 1)[1])
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
                household.houses = vcat(household.houses, inheritage.houses)
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
        push!(landlord.houses, contract.house)
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
        push!(household.houses, contract.house)
    end
end

function clearHouseMarket(model)
    # TODO: optimize this (below block is slower than all household_steps)
    localLock = ReentrantLock()
    Threads.@threads for i in 1:length(model.houseMarket.supply)
        supply = model.houseMarket.supply[i]
        for j in 1:length(model.houseMarket.demand)
            if rand() < HOUSE_SEARCH_OBFUSCATION_FACTOR # only view 30% of the offers
                continue
            end
            demand = model.houseMarket.demand[j]
            if model[demand.householdId].wealth < 0
                continue
            end
            if (!has_enough_size(supply.house, model[demand.householdId].size) ||
                supply.house.location != model[demand.householdId].residencyZone)
                continue
            end
            maxMortgage = maxMortgageValue(model, model[demand.householdId], model.bank, supply.house)
            # println("###")
            # println("maxMortage = " * string(maxMortgage))
            # println("householdId = " * string(demand.householdId))
            # println("###")
            demandBid = calculateBid(model[demand.householdId], supply.house, supply.price, maxMortgage)
            if (demandBid > supply.price)
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
            model.houseMarket.supply[i].price *= (1 - HOUSE_PRICE_REDUCTION_FACTOR) # reduce price
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
            if rand() < HOUSE_SEARCH_OBFUSCATION_FACTOR_FOR_RENTAL # only view 30% of the offers
                continue
            end
            demand = model.rentalMarket.demand[j]
            household = model[demand.householdId]
            if (has_enough_size(supply.house, household.size) && calculateLiquidSalary(household, model) * 0.40 > supply.monthlyPrice)
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
    push!(household.houses, supply.house)
    terminateContractsOnTentantSide(household, model)
    addTransactionToBuckets(model, supply.house, secondHighestBid)
    push!(model.transactions, Transaction(supply.house.area, secondHighestBid, supply.house.location))
    push!(model.transactions_per_region[supply.house.location][model.steps], Transaction(supply.house.area, secondHighestBid, supply.house.location))
    supply.valid = false
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
    push!(model.contracts, Contract(seller.id, household.id, supply.house, supply.monthlyPrice))
    household.contractIdAsTenant = length(model.contracts)
    push!(seller.contractsIdsAsLandlord, length(model.contracts))
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
    
    for location in instances(HouseLocation)
        model.houses[location] = House[]
    end
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
end

function initiateHousesPerRegion(model, targetNumberOfHouses, location, houses_sizes)
    for i in 1:targetNumberOfHouses
        push!(model.houses[location], House(houses_sizes[1], location, NotSocialNeighbourhood, 1))
        splice!(houses_sizes, 1)
    end
end

function initiateHouseholds(model, households_initial_ages, greedinesses)
    for zone_str in ZONES_STRINGS
        for size_str in SIZES_STRINGS
            number_of_households = eval(Symbol("HOUSEHOLDS_WITH_SIZE_" * size_str * "_IN_" * zone_str))
            for i in 1:number_of_households
                if length(households_initial_ages) == 0
                    # this means we would have slightly more households due to round()
                    # doesn't really matter, lets just ignore the remaining...
                    # maybe change to floor?
                    return
                end
                initial_age = households_initial_ages[1]
                splice!(households_initial_ages, 1)
                percentile = calculate_percentile(rand())
                zone = eval(Symbol(zone_str))
                size = get_household_size(size_str)
                add_agent!(Household, model, generateInitialWealth(initial_age, percentile), initial_age, size, Int64[], percentile, Mortgage[], Int[], 0, 0.0, zone, greedinesses[i])
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
        target_home_owners_in_the_zone = eval(Symbol("HOME_OWNERS_IN_" * string(household.residencyZone)))
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
    for house in household.houses
        if rand() < 0.16 # 16 % probability to simulate twice a year, but not all at the same time
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

function assignHouseThatMakesSense(model, household)
    for house in model.houses[household.residencyZone]
        # println("assignHouseThatMakesSense house = $(house)")
        if rand() < probabilityOfHouseholdBeingAssignedToHouse(household, house)
            push!(household.houses, house)
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

function assignHousesForRental(model, household, numberOfExtraHousesToAssign)
    zones = adjacentZones[household.residencyZone]
    assignedSoFar = 0
    push!(zones, household.residencyZone)
    # for house in collect(Iterators.flatten([model.houses[zone] for zone in zones]))
    for house in model.houses[household.residencyZone]
        # println("assignHousesForRental house = $(house)")
        if assignedSoFar == numberOfExtraHousesToAssign
            return
        end
        push!(household.houses, house)
        put_house_to_rent(household, model, house)
        assignedSoFar += 1
    end
end

function measureSupplyAndDemandRegionally(model)
    for location in instances(HouseLocation)
        model.demand_size[location] = 0
        model.supply_size[location] = 0
    end
    
    for demand in model.houseMarket.demand
        household = model[demand.householdId]
        model.demand_size[household.residencyZone] += 1
    end
    for supply in model.houseMarket.supply
        house = supply.house
        model.supply_size[house.location] += 1
    end
end