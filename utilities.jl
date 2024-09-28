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
    bucket = calculateBucket(model, house)
    if length(bucket) == 0
        # println("house = $house calculate_initial_market_price(house) = $(calculate_initial_market_price(house))")
        return calculate_initial_market_price(house)
    end
    # println("house = $house mean(transactions) * house.area * house.maintenanceLevel = $(mean(transactions) * house.area * house.maintenanceLevel)")
    return mean(bucket) * house.area * house.maintenanceLevel
end

function calculate_initial_market_price(house)
    ## TODO: houses should have a quality (maybe replace maintenanceLevel ?)
    ## this quality should influence the price per m2 according to the firstQuartileHousePricesPerRegion
    ## stop using only first quartile
    if house.percentile <= 25
        firstQuartile = eval(Symbol("FIRST_QUARTILE_SALES_IN_$(string(house.location))"))
        base = firstQuartile / 1.25
        range = firstQuartile - base
        return house.area * (base + range * (house.percentile/100) * 4) * house.maintenanceLevel
    elseif house.percentile <= 50
        base = eval(Symbol("FIRST_QUARTILE_SALES_IN_$(string(house.location))"))
        range = eval(Symbol("MEDIAN_SALES_IN_$(string(house.location))")) - base
        return house.area * (base + range * (house.percentile/100 - 0.25) * 4) * house.maintenanceLevel
    elseif house.percentile <= 75
        base = eval(Symbol("MEDIAN_SALES_IN_$(string(house.location))"))
        range = eval(Symbol("THIRD_QUARTILE_SALES_IN_$(string(house.location))")) - base
        return house.area * (base + range * (house.percentile/100 - 0.50) * 4) * house.maintenanceLevel
    else
        base = eval(Symbol("THIRD_QUARTILE_SALES_IN_$(string(house.location))"))
        range = base * 0.20
        return house.area * (base + range * (house.percentile/100 - 0.75) * 4) * house.maintenanceLevel
    end
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

function calculateBid(household, house, askPrice, maxMortgageValue, consumerSurplus)
    # demandValue = household.wealth * 0.95 + maxMortgageValue
    # bidValue = askPrice * calculateConsumerSurplusAddedValue(consumerSurplus)
    # if (demandValue < bidValue)
    #     bidValue = demandValue
    # end
    # return bidValue
    demandValue = household.wealth * 0.95 + maxMortgageValue
    consumerSurplusMultiplier = calculateConsumerSurplusAddedValue(consumerSurplus)
    if (demandValue >= askPrice * consumerSurplusMultiplier)
        return askPrice * consumerSurplusMultiplier
    elseif demandValue >= askPrice
        return askPrice
    else
        return 0
    end
    
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

function generateInitialWealth(age, percentile, size)
    # value = age * INITIAL_WEALTH_PER_AGE * rand(INITIAL_WEALTH_MULTIPLICATION_BASE:INITIAL_WEALTH_MULTIPLICATION_ROOF) 
    #     + percentile * INITIAL_WEALTH_PER_PERCENTILE * rand(INITIAL_WEALTH_MULTIPLICATION_BASE:INITIAL_WEALTH_MULTIPLICATION_ROOF)
    # return value * (size > 1 ? 2 : 1)
    
    return age * INITIAL_WEALTH_PER_AGE * rand(Normal(INITIAL_WEALTH_MULTIPLICATION_AVERAGE, INITIAL_WEALTH_MULTIPLICATION_STDEV)) 
        + percentile * INITIAL_WEALTH_PER_PERCENTILE * rand(Normal(INITIAL_WEALTH_MULTIPLICATION_AVERAGE, INITIAL_WEALTH_MULTIPLICATION_STDEV))
end

function calculateSalary(household, model)
    location = household.residencyZone
    percentile = household.percentile
    if percentile < 20
        base = eval(Symbol("FIRST_QUINTILE_INCOME_IN_$(string(location))")) / 2
        range = base * 2 * (1 + household.age/50)
        salary = base + range * (percentile / 100) * 5
    elseif percentile < 40
        base = eval(Symbol("FIRST_QUINTILE_INCOME_IN_$(string(location))"))
        range = (eval(Symbol("SECOND_QUINTILE_INCOME_IN_$(string(location))")) - base) * (1 + household.age/50)
        salary = base + range * (percentile / 100 - 0.2) * 5
    elseif percentile < 60
        base = eval(Symbol("SECOND_QUINTILE_INCOME_IN_$(string(location))"))
        range = (eval(Symbol("THIRD_QUINTILE_INCOME_IN_$(string(location))")) - base) * (1 + household.age/50)
        salary = base + range * (percentile / 100 - 0.4) * 5
    elseif percentile < 80
        base = eval(Symbol("THIRD_QUINTILE_INCOME_IN_$(string(location))"))
        range = (eval(Symbol("FOURTH_QUINTILE_INCOME_IN_$(string(location))")) - base) * (1 + household.age/50)
        salary = base + range * (percentile / 100 - 0.6) * 5
    else
        base = eval(Symbol("FOURTH_QUINTILE_INCOME_IN_$(string(location))"))
        range = base * 3 * (1 + household.age/50)
        salary = base + range * (percentile / 100 - 0.8) * 5
    end
    if (size == 1)
        return salary * model.salary_multiplier * INCOME_MULTIPLICATION_FACTOR 
    else
        return salary * 2 * model.salary_multiplier * INCOME_MULTIPLICATION_FACTOR
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
            household = model[demand.householdId]
            if household.wealth < 0
                continue
            end

            # TODO:
            # instead we should calculate the bid that we are willing to give 
            # and if that is below ask price -> continue
            # Alternative would be to calculate a consumerSurplus, that would be a multiplier
            # to our final bid, if that consumerSurplus is == 0 -> continue right away
            if (!has_enough_size(supply.house, household.size)
                || supply.house.location != household.residencyZone)
                continue
            end
            consumerSurplus = calculateConsumerSurplus(household, supply.house)
            maxMortgage = maxMortgageValue(model, household, model.bank, supply.house)
            demandBid = calculateBid(household, supply.house, supply.price, maxMortgage, consumerSurplus)
            if (demandBid >= supply.price * 0.95)
                lock(localLock) do
                    push!(supply.bids, Bid(demandBid, demand.householdId))
                    push!(demand.supplyMatches, SupplyMatch(supply, consumerSurplus))
                end
            end
        end
    end

    i = 1
    householdsWhoBoughtAHouse = Set()
    while i <= length(model.houseMarket.supply)
        supply = model.houseMarket.supply[i]
        sort!(supply.bids, lt=sortBids)
        if buy_house(model, supply, householdsWhoBoughtAHouse)
            splice!(model.houseMarket.supply, i)
        else
            # house wasn't purchased, but we will clear the bids just in case
            empty!(supply.bids)
            supply.price *= (1 - HOUSE_PRICE_REDUCTION_FACTOR)
            i += 1
        end
    end

    empty!(model.householdsInDemand)
    for demand in model.houseMarket.demand
        if !(demand.householdId in householdsWhoBoughtAHouse)
            push!(model.householdsInDemand, demand.householdId)
            # save the information about the demand
        end
    end
    empty!(model.houseMarket.demand)
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
    while i <= length(model.rentalMarket.supply)
        if !model.rentalMarket.supply[i].valid
            splice!(model.rentalMarket.supply, i)
        else
            model.rentalMarket.supply[i].monthlyPrice *= 0.99 # reduce price
            i += 1
        end
    end
end

function buy_house(model, supply::HouseSupply, householdsWhoBoughtAHouse)
    seller = nothing
    if supply.sellerId == -1
        seller = model.construction_sector
    else
        seller = model[supply.sellerId]
    end

    actualBid = 0
    if length(supply.bids) == 0
        return false # no bids
    elseif length(supply.bids) == 1
        actualBid = supply.price
    else
        actualBid = supply.bids[2].value
    end

    i = 1
    highestBidder = supply.bids[1].householdId
    while i <= length(supply.bids)
        highestBidder = supply.bids[i].householdId
        if highestBidder in householdsWhoBoughtAHouse
            i += 1
        else
            break
        end
    end
    
    if i > length(supply.bids)
        return false
    end

    if i + 1 <= length(supply.bids)
        actualBid = supply.bids[i + 1].value
    elseif supply.bids[i].value > supply.price
        actualBid = supply.price
    else
        actualBid = supply.bids[i].value 
    end

    if rand() > calculateProbabilityOfAcceptingBid(actualBid, supply.price)
        return false
    end

    household = model[highestBidder]
    if (household.wealth < actualBid)
        paidWithOwnMoney = household.wealth * 0.95
        mortgageValue = actualBid - paidWithOwnMoney
        # if mortgageValue > model.bank.wealth * 0.5
        #     return false
        # end
        mortgageDuration = calculateMortgageDuration(mortgageValue, household.age)
        mortgage = Mortgage(mortgageValue, mortgageValue, 0, mortgageDuration)
        push!(household.mortgages, mortgage)
        push!(model.mortgagesInStep, mortgage)
        content = "########\n"
        content *= "mortgageValue = $mortgageValue\n"
        content *= "house.area = $(supply.house.area)\n"
        content *= "house.location = $(string(supply.house.location))\n"
        content *= "house percentile = $(supply.house.percentile)\n"
        content *= "household.wealth = $(string(household.wealth))\n"
        content *= "raw salary = $(string(calculateSalary(household, model)))\n" 
        content *= "liquid salary = $(string(calculateLiquidSalary(household, model)))\n"
        content *= "household percentile = $(household.percentile)\n"
        content *= "household id = $(household.id)\n"
        content *= "household size = $(household.size)\n"
        content *= "askPrice = $(supply.price)\n"
        content *= "sellerId = $(supply.sellerId)\n"
        content *= "actualBid = $(actualBid)\n"
        content *= "########\n"
        print(content)
        open("$output_folder/transactions_logs/step_$(model.steps).txt", "a") do file
            write(file, content)
        end
        model.bank.wealth -= mortgageValue
        household.wealth += mortgageValue
    else
        println("\n\nhouse will be paid without mortgage... unusual\n\n")
        # house will be paid without mortgage... unusual
    end
    household.wealth -= actualBid
    seller.wealth += actualBid
    push!(household.houses, supply.house)
    terminateContractsOnTentantSide(household, model)
    addTransactionToBuckets(model, supply.house, actualBid)
    push!(model.transactions, Transaction(supply.house.area, actualBid, supply.house.location))
    push!(model.transactions_per_region[supply.house.location][model.steps], Transaction(supply.house.area, actualBid, supply.house.location))
    push!(householdsWhoBoughtAHouse, highestBidder)
    return true
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
    result = Dict(location => Dict(
                    quartile => Dict( 
                        size_interval => Float64[]
                        for size_interval in instances(SizeInterval))
                    for quartile in [25, 50, 75, 100])
                  for location in instances(HouseLocation))
    return result
end

function calculateBucket(model, house)
    percentile = 100
    if house.percentile < 25
        percentile = 25
    elseif house.percentile < 50
        percentile = 50
    elseif house.percentile < 75
        percentile = 75
    end
    size_interval = getSizeInterval(house)
    return model.buckets[house.location][percentile][size_interval]
end

function addTransactionToBuckets(model, house, price)
    bucket = calculateBucket(model, house)
    push!(bucket, price / house.area)
end

function trimBucketsIfNeeded(model)
    # avoid holding to many transaction in the buckets, keep the most recent MAX_BUCKET_SIZE (initially 30)
    for location in instances(HouseLocation)
        for quartile in [25, 50, 75, 100]
            if length(model.buckets[location][quartile]) > MAX_BUCKET_SIZE
                sizeToCut = length(model.buckets[location][quartile]) - MAX_BUCKET_SIZE
                splice!(model.buckets[location][quartile], 1:sizeToCut)
            end
        end
    end
end

function sortRandomly(left, right)
    return rand() < 0.5
end

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
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Amadora, Amadora, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Cascais, Cascais, houses_sizes)
    initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Lisboa, Lisboa, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Loures, Loures, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Mafra, Mafra, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Odivelas, Odivelas, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Oeiras, Oeiras, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Sintra, Sintra, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_VilaFrancaDeXira, VilaFrancaDeXira, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Alcochete, Alcochete, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Almada, Almada, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Barreiro, Barreiro, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Moita, Moita, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Montijo, Montijo, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Palmela, Palmela, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Seixal, Seixal, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Sesimbra, Sesimbra, houses_sizes)
    # initiateHousesPerRegion(model, NUMBER_OF_HOUSES_IN_Setubal, Setubal, houses_sizes)
end

function initiateHousesPerRegion(model, targetNumberOfHouses, location, houses_sizes)
    for i in 1:targetNumberOfHouses
        push!(model.houses[location], House(houses_sizes[1], location, NotSocialNeighbourhood, 1.0))
        splice!(houses_sizes, 1)
    end
end

# TODO: region hack
function initiateHouseholds(model, households_initial_ages, greedinesses)
    for zone_str in ["Lisboa"]
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
                percentile = rand(0:100)
                zone = eval(Symbol(zone_str))
                size = get_household_size(size_str)
                add_agent!(Household, model, generateInitialWealth(initial_age, percentile, size), initial_age, size, Int64[], percentile, Mortgage[], Int[], 0, 0.0, zone, greedinesses[i])
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
    for i in eachindex(model.houses[household.residencyZone])
        house = model.houses[household.residencyZone][i]
        # println("assignHouseThatMakesSense house = $(house)")
        if rand() < probabilityOfHouseholdBeingAssignedToHouse(household, house)
            push!(household.houses, house)
            splice!(model.houses[household.residencyZone], i)
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
    i = 1
    while i < length(model.houses[household.residencyZone])
        house = model.houses[household.residencyZone][i]
        # println("assignHousesForRental house = $(house)")
        if assignedSoFar == numberOfExtraHousesToAssign
            return
        end
        push!(household.houses, house)
        splice!(model.houses[household.residencyZone], i)
        # put_house_to_rent(household, model, house)
        assignedSoFar += 1
        i += 1
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

function calculateConsumerSurplus(household, house)
    house_percentile = house.percentile
    house_area = house.area
    household_size = household.size
    percentileMultiplier = map_value(house_percentile, 1.0, 100.0, 1.0, 8.0) 
    percentileMultiplier *= (0.8 + rand() * 0.4)

    areaPerPerson = (house_area /  household_size)
    if areaPerPerson > 60
        areaPerPerson = 60
    end
    sizeMultiplier = map_value(areaPerPerson, 25.0, 60.0, 5.0, 15.0)
    sizeMultiplier *= (0.8 + rand() * 0.4) 

    return percentileMultiplier + sizeMultiplier
end

function calculateConsumerSurplusAddedValue(consumerSurplus)
    return map_value(consumerSurplus, 6.0, 23.0, CONSUMER_SURPLUS_MIN, CONSUMER_SURPLUS_MAX)
end

function calculateProbabilityOfAcceptingBid(bid, askPrice)
    ratio = bid / askPrice
    return map_value(ratio, 0.95, 1.0, 0.2, 1.0)
end

function map_value(x, in_min, in_max, out_min, out_max)::Float64
    return out_min + (x - in_min) * (out_max - out_min) / (in_max - in_min)
end

function sortByConsumerSurplus(l, r)
    (l.supply.price / sqrt(l.consumerSurplus)) < (r.supply.price / sqrt(r.consumerSurplus))
end

function sortBids(l, r)
    l.value > r.value
end

function clearHangingSupplies(model)
    i = 1
    while i <= length(model.houseMarket.supply)
        if model.houseMarket.supply[i].sellerId == -1
            i += 1
            # construction sector -> we don't want to remove the supply
            continue
        end
        try
            model[model.houseMarket.supply[i].sellerId]
            i += 1
        catch
            supply = model.houseMarket.supply[i]
            push!(model.inheritages, Inheritage([supply.house], 0, Mortgage[], rand(1:100)))
            splice!(model.houseMarket.supply, i)
        end
    end
end

function measureDemandForSizeAndRegion(model, size_interval, location)
    count = 0
    for householdId in model.householdsInDemand
        household = model[householdId]
        if (household.residencyZone != location 
            || household.size * 25 >= Int(size_interval))
            continue
        end
        count += 1
    end
    return count
end

function measureSupplyForSizeAndRegion(model, size_interval, location)
    count = 0
    for supply in model.houseMarket.supply
        house = supply.house
        if (house.location != location
            || getSizeInterval(house) != size_interval)
            continue
        end
        count += 1
    end
    return count
end

function getSizeInterval(house)
    size_interval = More
    if house.area < 50
        size_interval = LessThan50
    elseif house.area < 75
        size_interval = LessThan75
    elseif house.area < 125
        size_interval = LessThan125
    end
    return size_interval
end