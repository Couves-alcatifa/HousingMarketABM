# salaries_sub24 = rand(247:1500, Int64(NUMBER_OF_HOUSEHOLDS/4))
# salaries_25_34 = vcat(salaries, rand(500:2670, Int64(NUMBER_OF_HOUSEHOLDS/4)))
# salaries_35_44 = vcat(salaries, rand(500:3500, Int64(NUMBER_OF_HOUSEHOLDS/4)))
# salaries_45_54 = vcat(salaries, rand(544:3800, Int64(NUMBER_OF_HOUSEHOLDS/4)))
# salaries_55_64 = vcat(salaries, rand(480:4100, zNUMBER_OF_HOUSEHOLDS/4)))
include("logger.jl")
include("constructionSector.jl")
include("startup.jl")

function calculate_rental_market_price(house, model)
    bucket = calculateRentalBucket(model, house)
    if length(bucket) < MINIMUM_NUMBER_OF_TRANSACTIONS_IN_BUCKETS
        # println("house = $house calculate_initial_market_price(house) = $(calculate_initial_market_price(house))")
        return calculate_initial_rental_market_price(house) * INITIAL_RENTAL_MARKET_PRICE_CUT[house.location]
    end
    # println("house = $house mean(transactions) * house.area * house.maintenanceLevel = $(mean(transactions) * house.area * house.maintenanceLevel)")
    return median(bucket) * house.area * 
           map_value(house.percentile, 1, 100,
                     FIRST_QUARTILE_RENT_MAP_ADJUSTED[house.location] / MEDIAN_RENT_MAP_ADJUSTED[house.location],
                     THIRD_QUARTILE_RENT_MAP_ADJUSTED[house.location] / MEDIAN_RENT_MAP_ADJUSTED[house.location])
end

function calculate_market_price(model, house)
    bucket = calculateBucket(model, house)
    if length(bucket) < MINIMUM_NUMBER_OF_TRANSACTIONS_IN_BUCKETS
        # println("house = $house calculate_initial_market_price(house) = $(calculate_initial_market_price(house))")
        return calculate_initial_market_price(house) * INITIAL_MARKET_PRICE_CUT[house.location]
    end
    # println("house = $house mean(transactions) * house.area * house.maintenanceLevel = $(mean(transactions) * house.area * house.maintenanceLevel)")
    return mean(bucket) * house.area * 
           map_value((house.percentile - 1) % 25, 0, 24, 0.90, 1.10)
end

function calculate_initial_rental_market_price(house)
    ## TODO: houses should have a quality (maybe replace maintenanceLevel ?)
    ## this quality should influence the price per m2 according to the firstQuartileHousePricesPerRegion
    ## stop using only first quartile
    if house.percentile <= 25
        firstQuartile = FIRST_QUARTILE_RENT_MAP_ADJUSTED[house.location]
        base = firstQuartile / 1.25
        range = firstQuartile - base
        return house.area * (base + range * (house.percentile/100) * 4)
    elseif house.percentile <= 50
        base = FIRST_QUARTILE_RENT_MAP_ADJUSTED[house.location]
        range = MEDIAN_RENT_MAP_ADJUSTED[house.location] - base
        return house.area * (base + range * (house.percentile/100 - 0.25) * 4)
    elseif house.percentile <= 75
        base = MEDIAN_RENT_MAP_ADJUSTED[house.location]
        range = THIRD_QUARTILE_RENT_MAP_ADJUSTED[house.location] - base
        return house.area * (base + range * (house.percentile/100 - 0.50) * 4)
    else
        base = THIRD_QUARTILE_RENT_MAP_ADJUSTED[house.location]
        range = base * 0.20
        return house.area * (base + range * (house.percentile/100 - 0.75) * 4)
    end
end

function calculate_initial_market_price(house)
    ## TODO: houses should have a quality (maybe replace maintenanceLevel ?)
    ## this quality should influence the price per m2 according to the firstQuartileHousePricesPerRegion
    ## stop using only first quartile
    if house.percentile <= 25
        firstQuartile = FIRST_QUARTILE_SALES_MAP_ADJUSTED[house.location]
        base = firstQuartile / 1.25
        range = firstQuartile - base
        return house.area * (base + range * (house.percentile/100) * 4)
    elseif house.percentile <= 50
        base = FIRST_QUARTILE_SALES_MAP_ADJUSTED[house.location]
        range = MEDIAN_SALES_MAP_ADJUSTED[house.location] - base
        return house.area * (base + range * (house.percentile/100 - 0.25) * 4)
    elseif house.percentile <= 75
        base = MEDIAN_SALES_MAP_ADJUSTED[house.location]
        range = THIRD_QUARTILE_SALES_MAP_ADJUSTED[house.location] - base
        return house.area * (base + range * (house.percentile/100 - 0.50) * 4)
    else
        base = THIRD_QUARTILE_SALES_MAP_ADJUSTED[house.location]
        range = base * 0.20
        return house.area * (base + range * (house.percentile/100 - 0.75) * 4)
    end
end

function updateMortgage(mortgage, spread)
    monthly_spread = spread / 12
    interests_paid = mortgage.valueInDebt * monthly_spread
    mortgage.valueInDebt -= calculateMortgagePayment(mortgage, spread) - interests_paid
    mortgage.maturity += 1
end

function calculateMortgageDuration(value, age)
    return -1 * round(map_value(age, 20, 65, -40, -10)) * 12
end

# 100000 * (0.015/12) / (1 - (1 + 0.015/12)^(-360))
function calculateMortgagePayment(mortgage, spread)
    # WARNING: don't change this without changing maxMortgageValue, the math is related
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
    if (demandValue >= askPrice * consumerSurplusMultiplier + calculateTransactionTaxes(askPrice * consumerSurplusMultiplier))
        return askPrice * consumerSurplusMultiplier
    else
        return demandValue - calculateTransactionTaxes(demandValue)
    end
    
end

function calculateRentalBid(household, model, askPrice, consumerSurplus)
    # multiplier = map_value(household.homelessTime, 0, 24, 0.75, 1.25)
    # multiplier = multiplier <= 1.25 ? multiplier : 1.25
    multiplier = 1
    maxEffort = MAX_EFFORT_FOR_RENT * multiplier
    demandValue = calculateLiquidSalary(household, model) * maxEffort
    consumerSurplusMultiplier = calculateConsumerSurplusAddedValueForRent(consumerSurplus)
    if (demandValue >= askPrice * consumerSurplusMultiplier)
        return askPrice * consumerSurplusMultiplier
    else
        return demandValue
    end
    
end

function calculateMortgagesPayment(household, model)
    mortgagePayment = 0
    for mortgage in household.mortgages
        mortgagePayment += calculateMortgagePayment(mortgage, model.bank.interestRate)
    end
    return mortgagePayment
end

# few options here, we can have a maxMortgageValue that the bank is
# willing to provide or we can have the maxValue for the conditions established by the household
# so the behaviour should be something like:
# - maxMortgageValue(h, b, house) -> max value the bank is willing to lend
# - maxMortgageValue(h, b, house, maxSpread = x | maxMonthlyPayment = y) -> maxValue with certain conditions
function maxMortgageValue(model, household)
    # TODO: this is just experimental - remove
    # if model.steps > 50
    #     return 0
    # end
    if household.age > 75
        return 0
    end
    bank = model.bank
    salary = calculateLiquidSalary(household, model)
    
    # remove the payments from the liquid salary to avoid one household contracting too many mortgages
    salary -= calculateMortgagesPayment(household, model)
    
    if salary < 0
        return 0
    end

    valueRestrictedByLTV = household.wealth * (1 / (1 - bank.ltv))
    duration = calculateMortgageDuration(valueRestrictedByLTV, household.age)


    highestPayment = salary * bank.dsti
    monthly_spread = bank.interestRate / 12
    
    # WARNING: This math is tied to the way we calculateMortgagePayment
    maxValue = (highestPayment * (1 - (1 + monthly_spread)^(-1 * duration))) / monthly_spread
    if maxValue > valueRestrictedByLTV
        maxValue = valueRestrictedByLTV
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

function generateInitialWealth(age, percentile, size, location)
    # value = age * INITIAL_WEALTH_PER_AGE * rand(INITIAL_WEALTH_MULTIPLICATION_BASE:INITIAL_WEALTH_MULTIPLICATION_ROOF) 
    #     + percentile * INITIAL_WEALTH_PER_PERCENTILE * rand(INITIAL_WEALTH_MULTIPLICATION_BASE:INITIAL_WEALTH_MULTIPLICATION_ROOF)
    # return value * (size > 1 ? 2 : 1)
    wealth = age * INITIAL_WEALTH_PER_AGE * rand(Normal(INITIAL_WEALTH_MULTIPLICATION_AVERAGE, INITIAL_WEALTH_MULTIPLICATION_STDEV)) 
             + percentile * INITIAL_WEALTH_PER_PERCENTILE * rand(Normal(INITIAL_WEALTH_MULTIPLICATION_AVERAGE, INITIAL_WEALTH_MULTIPLICATION_STDEV))
    return wealth * WEALTH_RATIO_MULTIPLIER_MAP[location]
end

function calculateSalary(household, model)
    location = household.residencyZone
    percentile = household.percentile
    # salaryAgeMultiplier = map_value(household.age, 20, 70, 0.7, 1.5)
    unemploymentMultiplier = household.unemployedTime > 0 ? UNEMPLOYMENT_SALARY_DECREASE : 1.0
    salaryAgeMultiplier = 1.0
    if household.age > 70
        salaryAgeMultiplier = 0.75
    end
    if percentile < 20
        base = FIRST_QUINTILE_INCOME_MAP_ADJUSTED[location] / 2
        range = base * 2 * salaryAgeMultiplier
        salary = base + range * (percentile / 100) * 5
    elseif percentile < 40
        base = FIRST_QUINTILE_INCOME_MAP_ADJUSTED[location]
        range = (SECOND_QUINTILE_INCOME_MAP_ADJUSTED[location] - base) * salaryAgeMultiplier
        salary = base + range * (percentile / 100 - 0.2) * 5
    elseif percentile < 60
        base = SECOND_QUINTILE_INCOME_MAP_ADJUSTED[location]
        range = (THIRD_QUINTILE_INCOME_MAP_ADJUSTED[location] - base) * salaryAgeMultiplier
        salary = base + range * (percentile / 100 - 0.4) * 5
    elseif percentile < 80
        base = THIRD_QUINTILE_INCOME_MAP_ADJUSTED[location]
        range = (FOURTH_QUINTILE_INCOME_MAP_ADJUSTED[location] - base) * salaryAgeMultiplier
        salary = base + range * (percentile / 100 - 0.6) * 5
    else
        base = FOURTH_QUINTILE_INCOME_MAP_ADJUSTED[location]
        range = base * 1.5 * salaryAgeMultiplier
        salary = base + range * (percentile / 100 - 0.8) * 5
    end
    if (household.size == 1)
        return salary * model.salary_multiplier * INCOME_MULTIPLICATION_FACTOR * unemploymentMultiplier
    else
        return salary * 2 * model.salary_multiplier * INCOME_MULTIPLICATION_FACTOR * unemploymentMultiplier
    end
end

function calculateLiquidSalary(household, model)
    baseSalary = calculateSalary(household, model)
    return baseSalary - incomeTaxes(baseSalary)
end

function calculateIrs(income)
    thresholds = [820, 935, 1125, 1175, 1769, 2057, 2408, 3201, 5492, 20021]
    rates = [0.0, 0.13, 0.165, 0.22, 0.25, 0.32, 0.355, 0.3872, 0.4005, 0.4495, 0.4717]

    tax = 0.0
    previous_threshold = 0.0

    for i in eachindex(thresholds)
        if income <= thresholds[i]
            tax += (income - previous_threshold) * rates[i]
            return tax
        else
            tax += (thresholds[i] - previous_threshold) * rates[i]
            previous_threshold = thresholds[i]
        end
    end

    # Handle income above the last threshold
    tax += (income - previous_threshold) * rates[end]
    return tax
end

function calculateSocialSecurityTax(income)
    return income * SOCIAL_SECURITY_TAX
end

function incomeTaxes(income)
    return calculateIrs(income) + calculateSocialSecurityTax(income)
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
    if household.contractAsTenant != Nothing
        contract = household.contractAsTenant
        println("landlordId = " * string(contract.landlordId))
        println("tenantId = " * string(contract.tenantId))
        landlord = model[contract.landlordId]
        push!(landlord.houses, contract.house)
        for i in 1:length(landlord.contractsAsLandlord)
            if landlord.contractsAsLandlord[i] == contract
                splice!(landlord.contractsAsLandlord, i)
                break
            end
        end
        household.contractAsTenant = Nothing
    end
end

function terminateContractsOnLandLordSide(household, model)
    while length(household.contractsAsLandlord) > 0
        contract = household.contractsAsLandlord[1]
        tenant = model[contract.tenantId]
        tenant.contractAsTenant = Nothing
        push!(household.houses, contract.house)
        splice!(household.contractsAsLandlord, 1)
    end
end

function clearHouseMarket(model)
    LOG_INFO("clearHouseMarket started")
    start_time = time()
    localLock = ReentrantLock()
    Threads.@threads for i in 1:length(model.houseMarket.supply)
        supply = model.houseMarket.supply[i]
        for j in 1:length(model.houseMarket.demand)
            demand = model.houseMarket.demand[j]
            if (rand() < HOUSE_SEARCH_OBFUSCATION_FACTOR # only view 30% of the offers
                && demand.type != NonResidentDemand)
                continue
            end
            household = Nothing
            if demand.type == NonResidentDemand
                household = model.nonResidentHousehold
            else
                if !hasid(model, demand.householdId)
                    continue
                end
                household = model[demand.householdId]
            end
            house = supply.house
            if household.wealth < 0 && demand.type != NonResidentDemand
                continue
            end

            if demand.type == ForRental
                renovatedHouse = House(house.area, house.location, house.locationType, house.maintenanceLevel, rand(95:100))

                if isHouseViableForRenting(model, renovatedHouse)
                    maxMortgage = maxMortgageValue(model, household)
                    bidValue = (rand(95:100) / 100) * supply.price
                    if maxMortgage + household.wealth > bidValue + calculateTransactionTaxes(bidValue)
                        lock(localLock) do
                            push!(supply.bids, Bid(bidValue, demand.householdId, demand.type))
                            push!(demand.supplyMatches, SupplyMatch(supply))
                        end
                    end
                end
                continue
            elseif demand.type == ForInvestment
                marketPrice = calculate_market_price(model, house)
                renovationCosts = calculateRenovationCosts(house)
                renovatedHouse = House(house.area, house.location, house.locationType, house.maintenanceLevel, rand(95:100))
                renovatedMarketPrice = calculate_market_price(model, renovatedHouse)

                totalCosts = marketPrice + calculateTransactionTaxes(marketPrice) + renovationCosts
                margin = totalCosts - renovatedMarketPrice
                margin -= calculateAddedValueTax(renovatedMarketPrice, totalCosts)

                if margin > marketPrice * EXPECTED_RENOVATION_RENTABILITY
                    maxMortgage = maxMortgageValue(model, household)
                    bidValue = (rand(95:100) / 100) * supply.price
                    if maxMortgage + household.wealth > bidValue + calculateTransactionTaxes(bidValue)
                        lock(localLock) do
                            push!(supply.bids, Bid(bidValue, demand.householdId, demand.type))
                            push!(demand.supplyMatches, SupplyMatch(supply))
                        end
                    end
                end
                continue
            elseif demand.type == NonResidentDemand
                if supply.house.percentile < 75
                    continue
                end
                lock(localLock) do
                    push!(supply.bids, Bid(supply.price * rand(Normal(1.05, 0.05)), demand.householdId, demand.type))
                    push!(demand.supplyMatches, SupplyMatch(supply))
                end
                continue
            end

            if (!has_enough_size(house, household) 
                || house.location != household.residencyZone
                || (household.houseRequirements != Nothing && (house.area <= household.houseRequirements.area || house.percentile < household.houseRequirements.percentile))
                )
                continue
            end
            consumerSurplus = calculateConsumerSurplus(household, house)
            # thresholdValue = (supply.price - household.wealth) * 0.5
            # if thresholdValue <= 0
            #     # the household has more money than the askPrice, lets establish
            #     # that it might still ask for 5% more due to the consumerSurplus
            #     thresholdValue = 0.05 * supply.price
            # end

            # maxMortgage = maxMortgageValue(model, household)
            maxMortgage = maxMortgageValue(model, household)
            demandBid = calculateBid(household, house, supply.price, maxMortgage, consumerSurplus)
            if (demandBid >= supply.price * 0.90)
                lock(localLock) do
                    push!(supply.bids, Bid(demandBid, demand.householdId, demand.type))
                    push!(demand.supplyMatches, SupplyMatch(supply))
                    if supply.maxConsumerSurplus < consumerSurplus
                        supply.maxConsumerSurplus = consumerSurplus
                    end
                end
            end
        end
    end
    LOG_INFO("clearHouseMarket - first block took $(time() - start_time)")

    start_time = time()
    i = 1
    householdsWhoBoughtAHouse = Set()
    # sort!(model.houseMarket.supply, lt=sortSupply)
    sort!(model.houseMarket.supply, lt=sortRandomly)
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
    LOG_INFO("clearHouseMarket - second block took $(time() - start_time)")
    start_time = time()

    empty!(model.householdsInDemand)
    for demand in model.houseMarket.demand
        if !(demand.householdId in householdsWhoBoughtAHouse)
            push!(model.householdsInDemand, demand.householdId)
            # save the information about the demand
        end
    end
    empty!(model.houseMarket.demand)
    LOG_INFO("clearHouseMarket - third block took $(time() - start_time)")
end

function clearRentalMarket(model)
    LOG_INFO("clearRentalMarket started")
    start_time = time()
    localLock = ReentrantLock()
    Threads.@threads for i in 1:length(model.rentalMarket.supply)
        supply = model.rentalMarket.supply[i]
        for j in 1:length(model.rentalMarket.demand)
            if rand() < HOUSE_SEARCH_OBFUSCATION_FACTOR_FOR_RENTAL # only view 30% of the offers
                continue
            end
            demand = model.rentalMarket.demand[j]
            if !hasid(model, demand.householdId)
                continue
            end
            household = model[demand.householdId]
            if household.wealth < 0 || length(household.houses) > 0
                continue
            end

            # TODO:
            # instead we should calculate the bid that we are willing to give 
            # and if that is below ask price -> continue
            # Alternative would be to calculate a consumerSurplus, that would be a multiplier
            # to our final bid, if that consumerSurplus is == 0 -> continue right away
            if (!has_enough_size(supply.house, household) || 
                supply.house.location != household.residencyZone)
                continue
            end
            consumerSurplus = calculateConsumerSurplus(household, supply.house)
            demandBid = calculateRentalBid(household, model, supply.monthlyPrice, consumerSurplus)
            if (demandBid >= supply.monthlyPrice * 0.90)
                lock(localLock) do
                    push!(supply.bids, Bid(demandBid, demand.householdId, Regular))
                    push!(demand.supplyMatches, RentalSupplyMatch(supply))
                    if supply.maxConsumerSurplus < consumerSurplus
                        supply.maxConsumerSurplus = consumerSurplus
                    end
                end
            end
        end
    end
    LOG_INFO("clearRentalMarket - first block took $(time() - start_time)")
    start_time = time()

    i = 1
    sort!(model.rentalMarket.supply, lt=sortSupply)
    while i <= length(model.rentalMarket.supply)
        supply = model.rentalMarket.supply[i]
        sort!(supply.bids, lt=sortBids)
        if rent_house(model, supply)
            delete!(model.housesInRentalMarket, supply.house)
            splice!(model.rentalMarket.supply, i)
        else
            # house wasn't rented, but we will clear the bids just in case
            empty!(supply.bids)
            supply.monthlyPrice *= (1 - HOUSE_PRICE_REDUCTION_FACTOR)
            i += 1
        end
    end
    LOG_INFO("clearRentalMarket - second block took $(time() - start_time)")

    # empty!(model.householdsInDemand)
    # for demand in model.rentalMarket.demand
    #     if !(demand.householdId in householdsWhoBoughtAHouse)
    #         push!(model.householdsInDemand, demand.householdId)
    #         # save the information about the demand
    #     end
    # end
    empty!(model.rentalMarket.demand)
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

    winningBid = supply.bids[i]

    if i + 1 <= length(supply.bids)
        bidValue = supply.bids[i + 1].value
    elseif supply.bids[i].value > supply.price
        bidValue = supply.price
    else
        bidValue = supply.bids[i].value 
    end

    if rand() > calculateProbabilityOfAcceptingBid(bidValue, supply.price)
        return false
    end

    household = Nothing
    if highestBidder < 0
        household = model.nonResidentHousehold
    else
        household = model[highestBidder]
    end
    content = "########\n"
    transactionTaxes = calculateTransactionTaxes(bidValue)

    wealthForDisplay = household.wealth
    if (household.wealth < bidValue + transactionTaxes && typeof(household) != NonResident)
        paidWithOwnMoney = household.wealth * 0.98
        mortgageValue = bidValue + transactionTaxes - paidWithOwnMoney
        maxMortgage = maxMortgageValue(model, household)
        if maxMortgage < mortgageValue
            content = "Household failed to acquire mortgage\n"
            TRANSACTION_LOG(content, model)
            return false
        end
        # if mortgageValue > model.bank.wealth * 0.5
        #     return false
        # end
        mortgageDuration = calculateMortgageDuration(mortgageValue, household.age)
        mortgage = Mortgage(mortgageValue, mortgageValue, 0, mortgageDuration)
        push!(household.mortgages, mortgage)
        push!(model.mortgagesInStep, mortgage)
        content *= "Transaction: mortgageValue = $mortgageValue\n"
        content *= "Transaction: mortgage payment = $(calculateMortgagePayment(mortgage, model.bank.interestRate))\n"
        content *= "Transaction: mortgage duration = $(calculateMortgageDuration(mortgageValue, household.age))\n"
        model.bank.wealth -= mortgageValue
        household.wealth += mortgageValue
    else
        content *= "Transaction: house will be paid without mortgage... unusual\n"
        # house will be paid without mortgage... unusual
    end
    content *= "Transaction: house.area = $(supply.house.area)\n"
    content *= "Transaction: house.location = $(string(supply.house.location))\n"
    content *= "Transaction: house percentile = $(supply.house.percentile)\n"
    content *= "Transaction: household.wealth = $(wealthForDisplay)\n"
    content *= "Transaction: raw salary = $(string(calculateSalary(household, model)))\n" 
    content *= "Transaction: liquid salary = $(string(calculateLiquidSalary(household, model)))\n"
    content *= "Transaction: household percentile = $(household.percentile)\n"
    content *= "Transaction: household id = $(household.id)\n"
    content *= "Transaction: household size = $(household.size)\n"
    content *= "Transaction: household age = $(household.age)\n"
    content *= "Transaction: household residencyZone = $(household.residencyZone)\n"
    content *= "Transaction: household homelessTime = $(household.homelessTime)\n"
    content *= "Transaction: household unemployedTime = $(household.unemployedTime)\n"
    content *= "Transaction: area per person = $(supply.house.area / household.size)\n"
    content *= "Transaction: askPrice = $(supply.price)\n"
    content *= "Transaction: sellerId = $(supply.sellerId)\n"
    content *= "Transaction: bidValue = $(bidValue)\n"
    content *= "Transaction: consumerSurplus = $(calculateConsumerSurplusAddedValue(calculateConsumerSurplus(household, supply.house)))\n"
    content *= "Transaction: transactionTaxes = $(transactionTaxes)\n"
    content *= "Transaction: pricePerm2 = $(bidValue / supply.house.area)\n"
    content *= "Transaction: for renting = $(winningBid.type == ForRental ? "true" : "false")\n"
    content *= "Transaction: for investment = $(winningBid.type == ForInvestment ? "true" : "false")\n"
    content *= "Transaction: nonResident = $(winningBid.type == NonResidentDemand ? "true" : "false")\n"
    content *= "Transaction: contracts as landlord = $(household.contractsAsLandlord)\n"
    content *= "Transaction: contract as tenant = $(household.contractAsTenant)\n"
    content *= "Transaction: bid to ask price ratio = $(bidValue / supply.price)\n"
    if supply.sellerId != -1
        content *= "Transaction: seller contracts as landlord = $(seller.contractsAsLandlord)\n"
        content *= "Transaction: seller contract as tenant = $(seller.contractAsTenant)\n"
    end
    content *= "########\n"
    # print(content)
    TRANSACTION_LOG(content, model) 
    
    household.wealth -= bidValue
    seller.wealth += bidValue
    household.wealth -= transactionTaxes
    model.government.wealth += transactionTaxes
    push!(household.houses, supply.house)
    terminateContractsOnTentantSide(household, model)
    addTransactionToBuckets(model, supply.house, bidValue)
    push!(model.transactions, Transaction(supply.house.area, bidValue, supply.house.location))
    push!(model.transactions_per_region[supply.house.location][model.steps], Transaction(supply.house.area, bidValue, supply.house.location))
    push!(householdsWhoBoughtAHouse, highestBidder)
    
    previousPurchasePrice = getPreviousPurchasePrice(model, supply.house)

    if previousPurchasePrice != Nothing && supply.shouldPayAddedValue
        renovationCosts = getRenovationCosts(model, supply.house)
        if renovationCosts == Nothing
            renovationCosts = 0
        end
        totalCosts = previousPurchasePrice + renovationCosts 

        addedValueTax = calculateAddedValueTax(bidValue, totalCosts)
        TRANSACTION_LOG("Transaction: addedValueTax = $addedValueTax\n", model)
        seller.wealth -= addedValueTax
        model.government.wealth += addedValueTax
    end

    updateHouseTransactionInfo(model, supply.house, bidValue)
    if winningBid.type == ForRental
        # requestRenovation(model, supply.house, household, length(household.houses), ForRental)
        put_house_to_rent(household, model, supply.house)
    elseif winningBid.type == ForInvestment
        requestRenovation(model, supply.house, household, length(household.houses), ForInvestment)
    end
    return true
end

function rent_house(model, supply::RentalSupply)
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
        actualBid = supply.monthlyPrice
    else
        actualBid = supply.bids[2].value
    end

    i = 1
    highestBidder = supply.bids[1].householdId
    while i <= length(supply.bids)
        highestBidder = supply.bids[i].householdId
        if model[highestBidder].contractAsTenant != Nothing
            # already renting a house... next
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
    elseif supply.bids[i].value > supply.monthlyPrice
        actualBid = supply.monthlyPrice
    else
        actualBid = supply.bids[i].value 
    end

    household = model[highestBidder]
    if rand() > calculateProbabilityOfAcceptingBid(actualBid, supply.monthlyPrice)
        return false
    end

    contract = Contract(seller.id, highestBidder, supply.house, actualBid)

    content = "Rental: house.area = $(supply.house.area)\n"
    content *= "Rental: house.location = $(string(supply.house.location))\n"
    content *= "Rental: house percentile = $(supply.house.percentile)\n"
    content *= "Rental: household.wealth = $(household.wealth)\n"
    content *= "Rental: raw salary = $(string(calculateSalary(household, model)))\n" 
    content *= "Rental: liquid salary = $(string(calculateLiquidSalary(household, model)))\n"
    content *= "Rental: household percentile = $(household.percentile)\n"
    content *= "Rental: household id = $(household.id)\n"
    content *= "Rental: household size = $(household.size)\n"
    content *= "Rental: household age = $(household.age)\n"
    content *= "Rental: household residencyZone = $(household.residencyZone)\n"
    content *= "Rental: household homelessTime = $(household.homelessTime)\n"
    content *= "Rental: household unemployedTime = $(household.unemployedTime)\n"
    content *= "Rental: area per person = $(supply.house.area / household.size)\n"
    content *= "Rental: askPrice = $(supply.monthlyPrice)\n"
    content *= "Rental: sellerId = $(supply.sellerId)\n"
    content *= "Rental: bidValue = $(actualBid)\n"
    content *= "Rental: consumerSurplus = $(calculateConsumerSurplusAddedValueForRent(calculateConsumerSurplus(household, supply.house)))\n"
    content *= "Rental: pricePerm2 = $(actualBid / supply.house.area)\n"
    content *= "Rental: contracts as landlord = $(household.contractsAsLandlord)\n"
    content *= "Rental: contract as tenant = $(household.contractAsTenant)\n"
    if supply.sellerId != -1
        content *= "Rental: seller contracts as landlord = $(seller.contractsAsLandlord)\n"
        content *= "Rental: seller contract as tenant = $(seller.contractAsTenant)\n"
    end
    content *= "########\n"
    # print(content)
    TRANSACTION_LOG(content, model) 

    updateHouseRentalInfo(model, supply.house, actualBid)
    household.contractAsTenant = contract
    push!(seller.contractsAsLandlord, contract)
    addTransactionToRentalBuckets(model, supply.house, actualBid)
    if model.steps > 0
        push!(model.rents_per_region[supply.house.location][model.steps], Transaction(supply.house.area, actualBid, supply.house.location))
    end
    return true
end

function public_investment(model)
    # gov pays company services for each household
    model.company_wealth += NUMBER_OF_HOUSEHOLDS * 2000 * model.government.subsidyRate
    model.government.wealth -= NUMBER_OF_HOUSEHOLDS * 2000 * model.government.subsidyRate
    model.companyServicesPaid += NUMBER_OF_HOUSEHOLDS * 2000 * model.government.subsidyRate
end

function InitiateBuckets()
    result = Dict(location => Dict(
                    quartile => Float64[] 
                    for quartile in [25, 50, 75, 100])
                  for location in HOUSE_LOCATION_INSTANCES)
    return result
end

function InitiateRentalBuckets()
    result = Dict(location => Float64[] for location in HOUSE_LOCATION_INSTANCES)
    return result
end

function InitiatePriceIndex()
    result = Dict(location => Dict(
                    quartile => Dict( 
                        size_interval => 0.0
                        for size_interval in instances(SizeInterval))
                    for quartile in [25, 50, 75, 100])
                  for location in HOUSE_LOCATION_INSTANCES)
    return result
end

function calculateBucket(model, house)
    percentile = 100
    if house.percentile <= 25
        percentile = 25
    elseif house.percentile <= 50
        percentile = 50
    elseif house.percentile <= 75
        percentile = 75
    end
    # size_interval = getSizeInterval(house)
    # return model.buckets[house.location][percentile][size_interval]
    # return model.buckets[house.location]
    return model.buckets[house.location][percentile]
end

function calculateRentalBucket(model, house)
    return model.rentalBuckets[house.location]
end

function addTransactionToBuckets(model, house, price)
    bucket = calculateBucket(model, house)
    push!(bucket, price / house.area)
end

function addTransactionToRentalBuckets(model, house, price)
    bucket = calculateRentalBucket(model, house)
    push!(bucket, price / house.area)
end

function trimBucketsIfNeeded(model)
    # avoid holding to many transaction in the buckets, keep the most recent MAX_BUCKET_SIZE (initially 30)
    for location in HOUSE_LOCATION_INSTANCES
        for quartile in [25, 50, 75, 100]
            if length(model.buckets[location][quartile]) > MAX_BUCKET_SIZE[location]
                sizeToCut = length(model.buckets[location][quartile]) - MAX_BUCKET_SIZE[location]
                TRANSACTION_LOG("Trimming bucket for location $location and quartile $quartile Size to cut: $sizeToCut\n", model)
                splice!(model.buckets[location][quartile], 1:sizeToCut)
            end
        end
    end

    for location in HOUSE_LOCATION_INSTANCES
        if length(model.rentalBuckets[location]) > MAX_BUCKET_SIZE[location]
            sizeToCut = length(model.rentalBuckets[location]) - MAX_BUCKET_SIZE[location]
            TRANSACTION_LOG("Trimming rental bucket for location $location Size to cut: $sizeToCut\n", model)
            splice!(model.rentalBuckets[location], 1:sizeToCut)
        end
    end
end

function sortRandomly(left, right)
    return rand() < 0.5
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

function get_household_size(size)
    if size < 5
        return size
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


function measureSupplyAndDemandRegionally(model)
    for location in HOUSE_LOCATION_INSTANCES
        model.demand_size[location] = 0
        model.supply_size[location] = 0
        model.rental_demand_size[location] = 0
        model.rental_supply_size[location] = 0
    end
    
    for demand in model.houseMarket.demand
        if !hasid(model, demand.householdId)
            continue
        end
        household = model[demand.householdId]
        model.demand_size[household.residencyZone] += 1
    end
    for supply in model.houseMarket.supply
        house = supply.house
        model.supply_size[house.location] += 1
    end

    for demand in model.rentalMarket.demand
        if !hasid(model, demand.householdId)
            continue
        end
        household = model[demand.householdId]
        model.rental_demand_size[household.residencyZone] += 1
    end
    for supply in model.rentalMarket.supply
        house = supply.house
        model.rental_supply_size[house.location] += 1
    end
end

function measureSupplyAndDemandPerBucket(model)
    for location in HOUSE_LOCATION_INSTANCES
        for size_interval in instances(SizeInterval)
            measureDemandForSizeAndRegion(model, size_interval, location)
            measureSupplyForSizeAndRegion(model, size_interval, location)
        end
    end
end

# consumerSurplus baixo:
# - area baixa + homelessTime baixo
# - percentil baixo + homelessTime baixo
# - area baixa + percentil baixo + homelessTime não gigante
# 
function calculateConsumerSurplus(household, house)
    house_percentile = house.percentile
    house_area = house.area
    household_size = household.size
    homelessTime = household.homelessTime
    if homelessTime > 24
        homelessTime = 24
    end
    percentileFactor = map_value(house_percentile, 1.0, 100.0, 1.0, 30.0) 
    # percentileFactor = rand(Normal(percentileFactor, percentileFactor * 0.1))

    areaPerPerson = (house_area /  household_size)
    if areaPerPerson > 40
        areaPerPerson = 40
    end
    sizeFactor = map_value_sqrt(areaPerPerson, 10.0, 40.0, 1.0, 30.0)
    # sizeFactor = rand(Normal(sizeFactor, sizeFactor * 0.1)) 

    desperationFactor = map_value(homelessTime + 1, 1.0, 24.0, 1.0, 25.0)
    # desperationFactor = rand(Normal(desperationFactor, desperationFactor * 0.15)) 

    regionFactor = EXTRA_CONSUMER_SURPLUS_PER_REGION[house.location]

    consumerSurplus = ((percentileFactor^(1/3)) * (sizeFactor^(1/3)) * (desperationFactor^(1/3))) + regionFactor
    if consumerSurplus > 9
        consumerSurplus = 9 + (consumerSurplus - 9) ^ (1/2)
    end

    if consumerSurplus > 13
        consumerSurplus = 13
    end
    return consumerSurplus 
end

function calculateConsumerSurplusAddedValue(consumerSurplus)
    return map_value(consumerSurplus, 1.0, 13.0, CONSUMER_SURPLUS_MIN, CONSUMER_SURPLUS_MAX)
end

function calculateConsumerSurplusAddedValueForRent(consumerSurplus)
    return map_value(consumerSurplus, 1.0, 13.0, CONSUMER_SURPLUS_MIN_FOR_RENT, CONSUMER_SURPLUS_MAX_FOR_RENT)
end

function calculateProbabilityOfAcceptingBid(bid, askPrice)
    ratio = bid / askPrice
    return map_value(ratio, 0.90, 1.0, 0.03, 1.0)
end

function map_value(x, in_min, in_max, out_min, out_max)::Float64
    return out_min + (x - in_min) * (out_max - out_min) / (in_max - in_min)
end

function map_value_sqrt(x, in_min, in_max, out_min, out_max)::Float64
    return out_min + (x - in_min)^2 * (out_max - out_min) / (in_max - in_min)^2
end

function map_value_non_linear(x, in_min, in_max, out_min, out_max)::Float64
    return out_min + (x - in_min)^3 * (out_max - out_min) / (in_max - in_min)^3
end

function sortByConsumerSurplus(l, r)
    (l.supply.price / sqrt(l.consumerSurplus)) < (r.supply.price / sqrt(r.consumerSurplus))
end

function sortBids(l, r)
    l.value > r.value
end

function sortSupply(l, r)
    l.maxConsumerSurplus > r.maxConsumerSurplus
end

function clearHangingSupplies(model)
    LOG_INFO("clearHangingSupplies started")
    start_time = time()
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
    LOG_INFO("clearHangingSupplies took $(time() - start_time)")

end

function clearHangingRentalSupplies(model)
    LOG_INFO("clearHangingRentalSupplies started")
    start_time = time()
    i = 1
    while i <= length(model.rentalMarket.supply)
        if model.rentalMarket.supply[i].sellerId == -1
            i += 1
            # construction sector -> we don't want to remove the supply
            continue
        end
        try
            model[model.rentalMarket.supply[i].sellerId]
            i += 1
        catch
            supply = model.rentalMarket.supply[i]
            push!(model.inheritages, Inheritage([supply.house], 0, Mortgage[], rand(1:100)))
            delete!(model.housesInRentalMarket, supply.house)
            splice!(model.rentalMarket.supply, i)
        end
    end
    LOG_INFO("clearHangingRentalSupplies took $(time() - start_time)")
end

function measureDemandForSizeAndRegion(model, size_interval, location)
    model.demandPerBucket[location][size_interval] = 0
    for householdId in model.householdsInDemand
        if !hasid(model, householdId)
            continue
        end
        household = model[householdId]
        if (household.residencyZone != location 
            || !isSizeIntervalAppropriate(size_interval, household)
            || !canHouseholdBuyHouse(model, household, size_interval))
            continue
        end
        model.demandPerBucket[location][size_interval] += 1
    end
end

function measureSupplyForSizeAndRegion(model, size_interval, location)
    model.supplyPerBucket[location][size_interval] = 0
    for supply in model.houseMarket.supply
        house = supply.house
        if (house.location != location
            || getSizeInterval(house) != size_interval)
            continue
        end
        model.supplyPerBucket[location][size_interval] += 1
    end
end


# 50 -> 1,2
# 75 -> 2,3
# 125 -> 3,4
# 125+ -> 4+
function isSizeIntervalAppropriate(size_interval, household)
    if household.size * 25 >= Int(size_interval)
        return false
    end

    if size_interval == LessThan50
        return household.size <= 2
    elseif size_interval == LessThan75
        return household.size in [2,3]
    elseif size_interval == LessThan125
        return household.size in [3, 4]
    elseif size_interval == More
        return household.size >= 4
    else
        println("Error: unknown sizeInterval $size_interval")
        exit(1)
    end

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

function calculateHouseAnnualRentalRentability(house, model)
    marketPrice = calculate_market_price(model, house)
    rent = calculate_rental_market_price(house, model)
    return (rent * 12)/marketPrice
end

function calculateImt(price)
    if price <= 101917.00
        return 0
    elseif price <= 139412.00
        return (price - 101917.00) * 0.02 
    elseif price <= 190086.00
        return calculateImt(139412.00) + (price - 139412.00) * 0.05
    elseif price <= 316772.00
        return calculateImt(190086.00) + (price - 190086.00) * 0.07
    elseif price <= 633453.00
        return calculateImt(316772.00) + (price - 316772.00) * 0.08
    elseif price <= 1102920.00
        return calculateImt(633453.00) + (price - 633453.00) * 0.06
    else
        return calculateImt(1102920.00) + (price - 1102920.00) * 0.075
    end
end

function calculateTaxBenefits(price)
    if price <= 101917.00
        return 0
    elseif price <= 139412.00
        return 2038.34
    elseif price <= 190086.00
        return 6220.70
    elseif price <= 316772.00
        return 10022.42
    elseif price <= 633453.00
        return 13190.14
    else
        return 0
    end
end

function calculateTransactionTaxes(price)
    taxes = calculateImt(price) + 0.008 * price - calculateTaxBenefits(price)
    if taxes < 0
        return 0
    end
    return taxes
end

# returns the probability of a household to think this house is a good fit for renting
function isHouseViableForRenting(model, house)
    # if RENTS_INCREASE_CEILLING is being used, than the rentability should be calculated in some other way
    # potentially the starting price should also be higher
    rentalGains = calculate_rental_market_price(house, model) * (1 - RENT_TAX)
    marketPrice = calculate_market_price(model, house)

    rentability = (rentalGains * 12) / marketPrice
    return rand() < map_value_sqrt(rentability, 0, 0.07, 0, 1)
end

function housesBoughtByNoNResidentsPerRegion(location)
    total = rand(Normal(HOUSES_BOUGHT_BY_NON_RESIDENTS * 0.85, HOUSES_BOUGHT_BY_NON_RESIDENTS * 0.5))
    return total * RATIO_OF_HOUSES_BOUGHT_BY_NON_RESIDENTS[location]
end

function nonResidentsBuyHouses(model)
    if CURRENT_YEAR == 2003
        if model.steps >= 72
            return
        end
    elseif CURRENT_YEAR == 2012
        if model.steps < 36
            return
        end
    end
    
    for location in HOUSE_LOCATION_INSTANCES
        housesToBuy = housesBoughtByNoNResidentsPerRegion(location)
        housesBought = 0
        sort!(model.houseMarket.supply, lt=sortRandomly)
        idx = 1
        while housesBought < housesToBuy && idx <= length(model.houseMarket.supply) 
            if length(model.houseMarket.supply) == 0
                return
            end
            supply = model.houseMarket.supply[idx]
            if supply.house.location != location
                idx += 1
                continue
            end
            seller = Nothing
            if supply.sellerId == -1
                seller = model.construction_sector
            else
                seller = model[supply.sellerId]
            end
            seller.wealth += supply.price
            content = "Sold to non resident area = $(supply.house.area)\n"
            content *= "Sold to non resident percentile = $(supply.house.percentile)\n"
            content *= "Sold to non resident location = $(supply.house.location)\n"
            content *= "Sold to non resident price = $(supply.price)\n"
            TRANSACTION_LOG(content, model)

            splice!(model.houseMarket.supply, idx)
            housesBought += 1
        end
    end
end

function handleNonResidentsDemand(model)
    if CURRENT_YEAR == 2003
        return
    elseif CURRENT_YEAR == 2012
        if model.steps < 36
            return
        end
    end
    for location in HOUSE_LOCATION_INSTANCES
        housesToBuy = housesBoughtByNoNResidentsPerRegion(location)
        housesBought = 0
        while housesBought < housesToBuy
            push!(model.houseMarket.demand, HouseDemand(getNonResidentId(model), SupplyMatch[], NonResidentDemand))
            housesBought += 1
        end
    end
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

# rough measure of the demand economic capability
function canHouseholdBuyHouse(model, household, size_interval)
    location = household.residencyZone
    house = House(generateAreaFromSizeInterval(size_interval), location, NotSocialNeighbourhood, 1.0, rand(1:100))
    marketPrice = calculate_market_price(model, house)
    if household.wealth >= marketPrice
        return true
    end
    maxMortgage = maxMortgageValue(model, household)
    return household.wealth + maxMortgage >= marketPrice * (0.50 + rand() * 0.50)
end


function updateRents(model)
    for household in allagents(model)
        if household.contractAsTenant == Nothing
            continue
        end
        contract = household.contractAsTenant
        house = contract.house
        bucket = calculateBucket(model, house)
        percentile = 100
        if house.percentile < 25
            percentile = 25
        elseif house.percentile < 50
            percentile = 50
        elseif house.percentile < 75
            percentile = 75
        end
        size_interval = getSizeInterval(house)
        
        oldValue = copy(model.rentalPriceIndex[house.location][percentile][size_interval])
        
        newValue = 0.0
        if length(bucket) != 0
            newValue = mean(bucket)
        end
        model.rentalPriceIndex[house.location][percentile][size_interval] = newValue
        if oldValue == 0.0 || newValue == 0.0
            continue
        end
        ratio = newValue / oldValue
        if ratio < 1
            # we won't reduce the existing contracts value right?...
            continue
        end
        contract.monthlyPayment *= ratio
    end
end

function updateHouseRentalInfo(model, house, rent)
    if house in keys(model.housesInfo)
        model.housesInfo[house].lastRent = rent
    else
        model.housesInfo[house] = HouseInfo(rent, Nothing, Nothing)
    end
end

function updateHouseTransactionInfo(model, house, transactionPrice)
    if house in keys(model.housesInfo)
        model.housesInfo[house].purchasePrice = transactionPrice
        # house is sold, so we should clear the renovation costs
        model.housesInfo[house].renovationCosts = Nothing
    else
        model.housesInfo[house] = HouseInfo(Nothing, transactionPrice, Nothing)
    end
end

function updateHouseRenovationCosts(model, house, renovationCosts)
    if house in keys(model.housesInfo)
        model.housesInfo[house].renovationCosts = renovationCosts
    else
        model.housesInfo[house] = HouseInfo(Nothing, Nothing, renovationCosts)
    end
end

function getPreviousRent(model, house)
    if house in keys(model.housesInfo)
        return model.housesInfo[house].lastRent
    else
        return Nothing
    end
end

function getPreviousPurchasePrice(model, house)
    if house in keys(model.housesInfo)
        return model.housesInfo[house].purchasePrice
    else
        return Nothing
    end
end

function getRenovationCosts(model, house)
    if house in keys(model.housesInfo)
        return model.housesInfo[house].renovationCosts
    else
        return Nothing
    end
end 

function calculateAddedValueTax(gains, expenses)
    taxableAddedValue = (gains - expenses) * ADDED_VALUE_TAXABLE_PERCENTAGE
    if taxableAddedValue > 0
        return calculateIrs(taxableAddedValue)
    end
    return 0
end

function getNonResidentId(model)
    model.nonResidentHousehold.id -= 1
    return model.nonResidentHousehold.id
end

function handleUnemployment(model)
    unemployedHouseholds = 0
    # measure how many households are unemployed
    for household in allagents(model)
        if household.unemployedTime > 0
            unemployedHouseholds += 1
        end
    end
    targetUnemployedHousehold = Int64(round(model.unemploymentRate * nagents(model)))
    println("targetUnemployedHousehold = $targetUnemployedHousehold")
    householdsToUnemploy = 0
    householdsToEmploy = 0
    
    # if we have more unemployed households than we should, we should employ some
    # if we have less unemployed households than we should, we should unemploy some
    if unemployedHouseholds < targetUnemployedHousehold
        householdsToUnemploy = targetUnemployedHousehold - unemployedHouseholds
    else
        householdsToEmploy = unemployedHouseholds - targetUnemployedHousehold
    end
    println("first householdsToUnemploy = $householdsToUnemploy")
    println("first householdsToEmploy = $householdsToEmploy")

    # employ / unemploy households until we reach the desired unemployment rate
    employOrUnemployHouseholds(model, householdsToEmploy, householdsToUnemploy)

    # employ / unemploy some of the households to ensure renovation
    householdsToUnemploy = nagents(model) * model.unemploymentRate * 0.05 * (0.95 + rand() * 0.1)
    householdsToEmploy = nagents(model) * model.unemploymentRate * 0.05 * (0.95 + rand() * 0.1)
    println("secound householdsToUnemploy = $householdsToUnemploy")
    println("secound householdsToEmploy = $householdsToEmploy")
    employOrUnemployHouseholds(model, householdsToEmploy, householdsToUnemploy)
end

function employOrUnemployHouseholds(model, householdsToEmploy, householdsToUnemploy)
    for householdId in shuffle(collect(allids(model)))
        if householdsToEmploy == 0 && householdsToUnemploy == 0
            break
        end
        household = model[householdId]
        if household.unemployedTime > 0
            if shouldBecomeEmployed(model, household, householdsToEmploy)
                householdsToEmploy -= 1
                household.unemployedTime = 0
            else
                household.unemployedTime += 1
            end
        else
            if shouldBecomeUnemployed(model, household, householdsToUnemploy)
                householdsToUnemploy -= 1
                household.unemployedTime += 1
            end
        end
    end
end

function shouldBecomeEmployed(model, household, householdsToEmploy)
    if householdsToEmploy <= 0
        return false
    end
    return true
end

function shouldBecomeUnemployed(model, household, householdsToUnemploy)
    if householdsToUnemploy <= 0
        return false
    end
    return true
end

function add_household(model, wealth, age, size, residencyZone; percentile = Nothing, houses = House[], mortgages = Mortgage[], contractsAsLandlord = Contract[], contractAsTenant = Nothing, wealthInHouses = 0.0, homelessTime = 0, unemployedTime = 0, houseRequirements = Nothing)
    if percentile == Nothing
        percentile = rand(1:100)
    end
    add_agent!(Household, model, wealth, age, size, houses, percentile, 
               mortgages, contractsAsLandlord, contractAsTenant, wealthInHouses,
               residencyZone, homelessTime, unemployedTime, houseRequirements)
end