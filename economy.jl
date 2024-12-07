# using Pkg ; Pkg.add("Agents") ; 
# Pkg.add("Distributions") ; Pkg.add("Random") ; 
# Pkg.add("CairoMakie") ; Pkg.add("CSV") ; Pkg.add("Statistics")

using Agents
using Distributions, Random
using CairoMakie
using CSV
using Statistics
using Base.Threads
using Dates

include("consts.jl")
output_folder = "all_runs/NHH_$(NUMBER_OF_HOUSEHOLDS)_NSTEPS_$(NUMBER_OF_STEPS)_$(Dates.format(now(), "yyyy_mm_dd_THH_MM"))"
include("utilities.jl")
include("metrics.jl")
include("plots.jl")
include("tables.jl")
include("demography.jl")
# include("marketsLogic.jl")
# Set the seed for reproducibility
Random.seed!(1234)

mkdir(output_folder)
mkdir("$output_folder/transactions_logs")
content = ""

file = open("calibrationTable.jl", "r")
content = read(file)

open("$output_folder/calibrationTable.jl", "w") do file
    write(file, content)
end

function calculate_non_housing_consumption(household, income)
    wealth = household.wealth
    size = household.size
    # return 500 + income * 0.6 + log(income) + rand(100:300)
    # expenses = EXPENSES_MINIMUM_VALUE * size * (1 + EXPENSES_EXTRA_MINIMUM + rand() * EXPENSES_EXTRA_OFFSET)
    expenses = EXPENSES_MINIMUM_VALUE * size * rand(Normal(1.0, 0.2))

    if expenses > income
        return expenses / (1.5 + rand() * 0.5)
    end

    if income / size > EXPENSES_MINIMUM_VALUE
        expenses += (income / size - EXPENSES_MINIMUM_VALUE)  * size * (EXPENSES_EXTRA_MINIMUM + rand() * EXPENSES_EXTRA_OFFSET)
    end
    if is_home_owner(household) && wealth > 50000
        expenses += sqrt(wealth) * 10
    end
    if is_home_owner(household) && wealth > 1000000
        expenses += sqrt(wealth) * 20
    end
    if is_home_owner(household) && wealth > 5000000
        expenses += cbrt(wealth) * cbrt(wealth) * 20
    end
    return expenses
    # if (income * 0.6 > 500)
    #     return rand(500:Int64(round(income * 0.7)))
    # else
    #     return 500
    # end
end

function wealth_model()

    start_time = time()

    number_of_household_in_fertile_age = Int64(round(NUMBER_OF_HOUSEHOLDS * RATIO_OF_FERTILE_WOMEN))
    number_of_households_in_not_fertile_age = NUMBER_OF_HOUSEHOLDS - number_of_household_in_fertile_age
    households_initial_ages = rand(20:44, number_of_household_in_fertile_age)
    households_initial_ages = vcat(households_initial_ages, rand(44:58, Int64(round(number_of_households_in_not_fertile_age/3))))
    households_initial_ages = vcat(households_initial_ages, rand(58:75, Int64(round(number_of_households_in_not_fertile_age/3))))
    households_initial_ages = vcat(households_initial_ages, rand(75:100, Int64(round(number_of_households_in_not_fertile_age/3))))
    sort!(households_initial_ages, lt=sortRandomly)
    
    # initiate greediness

    properties = Dict(
        :sum_wealth => 0,
        :steps => 0,
        :houseMarket => HouseMarket(HouseSupply[], HouseDemand[]),
        :rentalMarket => RentalMarket(RentalSupply[], RentalDemand[]),
        :gov_prev_wealth => STARTING_GOV_WEALTH,
        :government => Government(STARTING_GOV_WEALTH, IRS, VAT, 1.0),
        :company_prev_wealth => STARTING_COMPANY_WEALTH,
        :company_wealth => STARTING_COMPANY_WEALTH,
        :bank => Bank(STARTING_BANK_WEALTH, STARTING_INTEREST_RATE, LTV, DSTI),
        :transactions => Transaction[],
        :transactions_per_region => Dict(location => [] for location in instances(HouseLocation)),
        :rents_per_region => Dict(location => [] for location in instances(HouseLocation)),
        :inheritages => Inheritage[],
        :contracts => Contract[],
        :salary_multiplier => 1.0,
        :demand_size => Dict(location => 0 for location in instances(HouseLocation)),
        :supply_size => Dict(location => 0 for location in instances(HouseLocation)),
        :rental_demand_size => Dict(location => 0 for location in instances(HouseLocation)),
        :rental_supply_size => Dict(location => 0 for location in instances(HouseLocation)),
        :construction_sector => initiateConstructionSector(),
        :births => 0, 
        :breakups => 0,
        :deaths => 0,
        :children_leaving_home => 0,
        :subsidiesPaid => 0.0,
        :ivaCollected => 0.0,
        :irsCollected => 0.0,
        :companyServicesPaid => 0.0,
        :inheritagesFlow => 0.0,
        :constructionLabor => 0.0,
        :rawSalariesPaid => 0.0,
        :liquidSalariesReceived => 0.0,
        :expensesReceived => 0.0,
        :buckets => InitiateBuckets(), # Houses characteristics => Prices[]
        :rentalBuckets => InitiateBuckets(), # Houses characteristics => Prices[]
        :mortgagesInStep => Mortgage[],
        :householdsInDemand => Int[],
        :housesBuiltPerRegion => Dict(location => Dict(size_interval => House[] for size_interval in instances(SizeInterval)) for location in instances(HouseLocation)),
        :supplyPerBucket => Dict(location => Dict(size_interval => 0 for size_interval in instances(SizeInterval)) for location in instances(HouseLocation)),
        :demandPerBucket => Dict(location => Dict(size_interval => 0 for size_interval in instances(SizeInterval)) for location in instances(HouseLocation)),
        :housesInRentalMarket => Set(),
        :rentalPriceIndex => InitiatePriceIndex(),
        :housesInfo => Dict(),
    )

    model = StandardABM(MyMultiAgent; agent_step! = agent_step!, model_step! = model_step!, properties,scheduler = Schedulers.Randomly())

    # initiateHouses(model)
    LOG_INFO("finished initateHouses in $(time() - start_time) seconds")
    initiateHouseholds(model, households_initial_ages)
    LOG_INFO("finished initiateHouseholds in $(time() - start_time) seconds")
    assignHousesToHouseholds(model)

    # first clear to assign rental houses to household
    clearRentalMarket(model)
    # clear structures that might have been filled during the markets logic
    model.rentalBuckets = InitiateBuckets()
    empty!(model.rentalMarket.supply)
    empty!(model.rentalMarket.demand)

    LOG_INFO("finished assignHousesToHouseholds in $(time() - start_time) seconds")
    return model
end

function has_enough_size(house, household)
    areaPerPerson = house.area / household.size
    value = areaPerPerson + household.homelessTime 
    return rand() < map_value(value, 10, 30.0, 0.01, 1.0)
end

function model_step!(model)
    LOG_INFO("Model step $(model.steps + 1) started")
    start_time = time()
    measureSupplyAndDemandRegionally(model)
    model.steps += 1
    for location in instances(HouseLocation)
        push!(model.transactions_per_region[location], Transaction[])
        push!(model.rents_per_region[location], Transaction[])
        for size_interval in instances(SizeInterval)
            model.housesBuiltPerRegion[location][size_interval] = House[]
        end
    end
    println("----------------")
    println("number of households = " * string(nagents(model)))
    println("----------------")
    # model_wealth_ratio = model.bank.wealth / 40000000.0
    # if model.bank.wealth / 40000000.0 < 1
    #     model.bank.ltv = 0.8 + (1 - model_wealth_ratio) * 0.1
    #     model.bank.dsti = 0.45 + (1 - model_wealth_ratio) * 0.1
    # end
    # houses maintenanceLevel decay
    # for i in 1:length(model.houses)
    #     model.houses[i].maintenanceLevel -= 0.001
    # end

    handle_migrations(model)

    if model.steps % 5 == 0
        println("5 steps!")
    end
    model.mortgagesInStep = Mortgage[]
    clearHangingSupplies(model)
    clearHangingRentalSupplies(model)
    nonResidentsBuyHouses(model)
    clearHouseMarket(model)
    clearRentalMarket(model)
    trimBucketsIfNeeded(model)
    measureSupplyAndDemandPerBucket(model)
    if model.steps % 12 == 0
        # considering start is in 2003
        # ### CRASH SCENARIO
        # if model.steps == 12
        #     # end of 2003
        #     model.salary_multiplier *= 0.95
        #     model.bank.interestRate = 0.0383
        # elseif model.steps == 24
        #     # end of 2004
        #     model.bank.interestRate = 0.0349
        # elseif model.steps == 36
        #     # end of 2005
        #     model.salary_multiplier *= 0.95
        #     model.bank.interestRate = 0.0338
        # elseif model.steps == 48
        #     # end of 2006
        #     model.bank.interestRate = 0.0401
        # elseif model.steps == 60
        #     # end of 2007
        #     model.bank.interestRate = 0.0480
        # elseif model.steps == 72
        #     # end of 2008
        #     model.bank.interestRate = 0.0544
        # elseif model.steps == 84
        #     # end of 2009
        #     model.salary_multiplier *= 0.95
        #     model.bank.interestRate = 0.0273
        # elseif model.steps == 96
        #     # end of 2010
        #     model.salary_multiplier *= 0.95
        #     model.bank.interestRate = 0.0247
        # elseif model.steps == 108
        #     # end of 2011
        #     model.salary_multiplier *= 0.90
        #     model.bank.interestRate = 0.0377
        # elseif model.steps == 120
        #     # end of 2012
        #     model.salary_multiplier *= 0.95
        #     model.bank.interestRate = 0.0388
        # end

        adjust_interest_rates(model)
        # company_adjust_salaries(model)
        gov_adjust_taxes(model)
        
        model.company_prev_wealth = model.company_wealth
        model.gov_prev_wealth = model.government.wealth
        updateRents(model)
    end
    
    public_investment(model)
    updateConstructions(model)
    payMortgages(model, model.construction_sector)
    println("end of model_step $(string(model.steps))")
    LOG_INFO("Model step $(model.steps) took $(string(time() - start_time)) seconds")
end

function adjust_interest_rates(model)
    if model.steps == 12
        # start of 2022
        model.bank.interestRate = 0.0182
    elseif model.steps == 24
        # start of 2023
        model.bank.interestRate = 0.04
    elseif model.steps == 36
        # start of 2024 and beyond...
        model.bank.interestRate = 0.035
    elseif model.steps == 48
        # beyond...
        model.bank.interestRate = 0.02
    end        
end

function company_adjust_salaries(model)
    ratio = model.company_wealth / model.company_prev_wealth
    # if ratio < 0
    #     # DOOM
    #     model.salary_multiplier = 0
    #     return
    # end
    if ratio < 0.90
        model.salary_multiplier -= 0.08
    elseif ratio < 0.95
        model.salary_multiplier -= 0.05
    elseif ratio < 1
        model.salary_multiplier -= 0.02
    elseif ratio > 1.15
        model.salary_multiplier += 0.075
    elseif ratio > 1.10
        model.salary_multiplier += 0.05
    elseif ratio > 1.05
        model.salary_multiplier += 0.03
    elseif ratio > 1
        model.salary_multiplier += 0.015
    end 
end

function company_adjust_salaries_in_crash_scenario(model)
    model.salary_multiplier *= 0.90
end

function gov_adjust_taxes(model)
    if model.gov_prev_wealth * 1.02 < model.government.wealth
        model.government.subsidyRate += 0.02
    elseif model.gov_prev_wealth * 1.05 < model.government.wealth
        model.government.subsidyRate += 0.04
    elseif model.gov_prev_wealth * 1.10 < model.government.wealth
        model.government.subsidyRate += 0.07
    elseif model.gov_prev_wealth * 1.15 < model.government.wealth
        model.government.subsidyRate += 0.10
    elseif model.gov_prev_wealth > model.government.wealth
        model.government.subsidyRate -= 0.01
    end

    ratio = model.government.wealth / model.gov_prev_wealth
    if ratio < 1
        if ratio > 0.95
            model.government.irs += 0.01
            model.government.vat += 0.01
        elseif ratio > 0.90
            model.government.irs += 0.03
            model.government.vat += 0.02
        else
            model.government.irs += 0.04
            model.government.vat += 0.02
        end
        println("irs = " * string(model.government.irs))
        println("vat = " * string(model.government.vat))
        # model.government.irs += (1 - ratio) / 2            
        # model.government.vat += 0.005
    end
    if ratio > 1.10
        model.government.irs -= 0.05
        model.government.vat -= 0.02
    elseif ratio > 1.05
        model.government.irs -= 0.03
        model.government.vat -= 0.01
    elseif ratio > 1.02
        model.government.irs -= 0.01
    end
end
function is_home_owner(household)
    return length(household.houses) > 0
end



function put_house_to_rent(household::MyMultiAgent, model, house)
    askRent = calculate_rental_market_price(house, model) * rand(Normal(GREEDINESS_AVERAGE_FOR_RENTAL, GREEDINESS_STDEV_FOR_RENTAL))
    previousRent = getPreviousRent(model, house)

    # if previousRent != Nothing && askRent > previousRent * RENTS_INCREASE_CEILLING
    #     askRent = previousRent * RENTS_INCREASE_CEILLING
    # end
    push!(model.rentalMarket.supply, RentalSupply(house, askRent, household.id, Bid[]))
    push!(model.housesInRentalMarket, house)
    # # removing house from agent when putting to sale
    # splice!(agent.houseIds, index)
end

function put_house_to_rent_at_old_value(household::MyMultiAgent, model, house)
    askRent = calculate_initial_rental_market_price(house) / (1 + rand() * 2)

    # if previousRent != Nothing && askRent > previousRent * RENTS_INCREASE_CEILLING
    #     askRent = previousRent * RENTS_INCREASE_CEILLING
    # end
    push!(model.rentalMarket.supply, RentalSupply(house, askRent, household.id, Bid[]))
    # # removing house from agent when putting to sale
    # splice!(agent.houseIds, index)
end


function put_house_to_sale(household::MyMultiAgent, model, index)
    house = household.houses[index]
    push!(model.houseMarket.supply, HouseSupply(house, calculate_market_price(model, house) * rand(Normal(GREEDINESS_AVERAGE, GREEDINESS_STDEV)), Bid[], household.id))
    # removing house from agent when putting to sale
    splice!(household.houses, index)
end

# this might need some changes...
function calculate_subsidy(household, model)
    subsidy = 0
    salary = calculateLiquidSalary(household, model)
    if (salary > 700 * household.size)
        return 0
    end
    return subsidy + (700 * household.size - salary)*0.4 * model.government.subsidyRate
end

function decideToRent(household, model, house)
    if isHouseViableForRenting(model, house)
        return true
    end
    return false
end

function getContract(household, house)
    for contract in household.contractsAsLandlord
        if contract.house == house
            return contract
        end
    end
    return Nothing
end

function supply_decisions(household, model)
    houseIdx = 2
    if length(household.contractsAsLandlord) + 1 == length(household.houses)
        return
    end
    while houseIdx <= length(household.houses)
        house = household.houses[houseIdx]
        contract = getContract(household, house)
        if contract != Nothing || house in model.housesInRentalMarket
            # house is already renting
            houseIdx += 1
            continue
        # elseif house in model.housesInRentalMarket
        #     if isHouseViableForRenting(model, house)
        #         houseIdx += 1
        #         continue
        #     else
        #         for supplyIdx in eachindex(model.rentalMarket.supply)
        #             supply = model.rentalMarket.supply[supplyIdx]
        #             if supply.house == house
        #                 content = "household decided that house is no longer viable for renting $(household.id)\n"
        #                 TRANSACTION_LOG(content, model)

        #                 splice!(model.rentalMarket.supply, supplyIdx)
        #                 delete!(model.housesInRentalMarket, house)
        #                 put_house_to_sale(household, model, houseIdx)
        #                 houseIdx -= 1
        #                 break
        #             end
        #         end
        #         houseIdx += 1
        #         continue
        #     end
        end
        if decideToRent(household, model, house)
            TRANSACTION_LOG("Household decided to rent\n", model)
            put_house_to_rent(household, model, house)
        else # decides to sell...
            TRANSACTION_LOG("Household decided to sell\n", model)
            put_house_to_sale(household, model, houseIdx)
        end
        houseIdx += 1
    end
end



function not_home_owner_decisions(household, model)
    # let's say 90% of the households always try to buy a house
    # and in the meantime they rent
    if household.id % 12 < 10 # 10 & 11 only rent 
        push!(model.houseMarket.demand, HouseDemand(household.id, HouseSupply[], Regular))
    end
    if (household.contractAsTenant == Nothing)
        household.homelessTime += 1 # being here means the household does not own a house and is not renting => increment homeless time
        push!(model.rentalMarket.demand, RentalDemand(household.id, RentalSupply[]))
    else
        if household.homelessTime > 0
            household.homelessTime -= 1
        end
    end
end

function home_owner_decisions(household, model)
    if household.homelessTime > 0
        household.homelessTime -= 1
    end
    house = household.houses[1]
    if !has_enough_size(house, household)
        # moves out, put_house_to_sale
        # this doesnt make much sense... having a house and selling it
        # is not the same as not having one in the first place
        put_house_to_sale(household, model, 1)
        not_home_owner_decisions(household, model)
    else
        if household.percentile < 80 || rand() > 0.20
            # not all household think about investing
            # and it is a slow decision
            return
        end
        # lets assess the household economical situation
        # WARNING: this might be computationally expensive
        sampleHouse = House(rand(60:100), household.residencyZone, NotSocialNeighbourhood, 1.0, rand(50:100))
        marketPrice = calculate_market_price(model, sampleHouse)
        mortgage = maxMortgageValue(model, household)
        if household.wealth + mortgage > marketPrice * 3
            if decideToRent(household, model, sampleHouse)
                TRANSACTION_LOG("Household $(household.id) decided to invest in rental\n", model)
                push!(model.houseMarket.demand, HouseDemand(household.id, SupplyMatch[], ForRental))
            else
                TRANSACTION_LOG("Household $(household.id) decided to invest in renovation\n", model)
                push!(model.houseMarket.demand, HouseDemand(household.id, SupplyMatch[], ForInvestment))
            end
        end
    end
end

function housing_decisions(household, model)
    if length(household.houses) > 1
        supply_decisions(household, model)
    end
    if (!is_home_owner(household))
        not_home_owner_decisions(household, model)
    else
        home_owner_decisions(household, model)
    end
end

        
function household_step!(household::MyMultiAgent, model)
    wealthInHouses = 0.0
    for house in household.houses
        wealthInHouses += calculate_market_price(model, house)
    end
    household.wealthInHouses = wealthInHouses
    if (household.id % 12 == model.steps % 12 && household_evolution(household, model))
        # household died

        return
    end

    # update_houses(household, model)
    receive_inheritages(household, model)
    housing_decisions(household, model)
    salary = calculateSalary(household, model)
    liquid_salary = calculateLiquidSalary(household, model)
    taxes = salary - liquid_salary
    model.government.wealth += taxes
    model.irsCollected += taxes
    household.wealth += liquid_salary
    model.rawSalariesPaid += salary
    model.liquidSalariesReceived += liquid_salary
    model.company_wealth -= salary

    subsidy = calculate_subsidy(household, model)
    model.government.wealth -= subsidy
    model.subsidiesPaid += subsidy
    household.wealth += subsidy
    valuePaidInMortages = payMortgages(model, household)
    valuePaidInRent = payRent(model, household)
    incomeLeft = liquid_salary + subsidy - valuePaidInMortages - valuePaidInRent
    expenses = calculate_non_housing_consumption(household, incomeLeft)
    household.wealth -= expenses
    model.company_wealth += expenses * (1 - model.government.vat)
    model.expensesReceived += expenses * (1 - model.government.vat)
    model.government.wealth += expenses* model.government.vat
    model.ivaCollected += expenses* model.government.vat

    # if (agent.wealth <= 0)
    #     agent.wealth = 0.0
        # remove_agent!(agent, model)
    # end
end

function payRent(model, household)
    if household.contractAsTenant != Nothing
        contract = household.contractAsTenant
        landlord = model[contract.landlordId]
        landlord.wealth += contract.monthlyPayment * (1 - RENT_TAX)
        model.government.wealth += contract.monthlyPayment * RENT_TAX
        # TODO: gov payment
        household.wealth -= contract.monthlyPayment
        return contract.monthlyPayment
    end
    return 0
end

function payMortgages(model, household)
    paid = 0
    for i in 1:length(household.mortgages)
        if (household.mortgages[i].valueInDebt > 0)
            payment = calculateMortgagePayment(household.mortgages[i], model.bank.interestRate)
            if typeof(household) != ConstructionSector && household.wealth < payment && length(household.houses) > 0
                content = "## Mortgage rescue: household.wealth = $(string(household.wealth))\n"
                content *= "## Mortgage rescue: raw salary = $(string(calculateSalary(household, model)))\n" 
                content *= "## Mortgage rescue: liquid salary = $(string(calculateLiquidSalary(household, model)))\n"
                content *= "## Mortgage rescue: household percentile = $(household.percentile)\n"
                content *= "## Mortgage rescue: household id = $(household.id)\n"
                content *= "## Mortgage rescue: household size = $(household.size)\n"
                content *= "## Mortgage rescue: household age = $(household.age)\n"
                content *= "## Mortgage rescue: household zone = $(household.residencyZone)\n"
                TRANSACTION_LOG(content, model)
                put_house_to_sale(household, model, 1)
            elseif typeof(household) != ConstructionSector && household.wealth < payment
                content = "## Household could not pay mortgage: household.wealth = $(string(household.wealth))\n"
                content *= "## Household could not pay mortgage: raw salary = $(string(calculateSalary(household, model)))\n" 
                content *= "## Household could not pay mortgage: liquid salary = $(string(calculateLiquidSalary(household, model)))\n"
                content *= "## Household could not pay mortgage: household percentile = $(household.percentile)\n"
                content *= "## Household could not pay mortgage: household id = $(household.id)\n"
                content *= "## Household could not pay mortgage: household size = $(household.size)\n"
                content *= "## Household could not pay mortgage: household age = $(household.age)\n"
                content *= "## Household could not pay mortgage: household zone = $(household.residencyZone)\n"
                TRANSACTION_LOG(content, model)
            else
                paid += payment
                household.wealth -= payment
                model.bank.wealth += payment
                updateMortgage(household.mortgages[i], model.bank.interestRate)
            end
        
        end
        if (household.mortgages[i].valueInDebt == 0)
            # print("Mortgage was paid! Maturity = " * string(household.mortgages[i].maturity))
        elseif (household.mortgages[i].valueInDebt < 0)
            # print("value in debt is negative! problems!! value = " * string(household.mortgages[i].valueInDebt))
        end
    end
    return paid
end

function agent_step!(agent::MyMultiAgent, model)
    kind = kindof(agent)
    if kind == :Household
        household_step!(agent, model)
    elseif kind == :Company
        # println("company step")
        return
    else
        # println("NEVER HAPPENS")
        return
    end
end




adata = [(household, sum_wealth),(household, sum_houses),
         (isHousehold, count), (isHouseholdHomeOwner, count),
         (isHouseholdTenant, count), (isHouseholdLandlord, count),
         (isHouseholdMultipleHomeOwner, count),
         (household, wealth_distribution), (household, money_distribution), (household, size_distribution), (household, age_distribution)]
mdata = [count_supply, gov_wealth, construction_wealth, company_wealth,
         bank_wealth, calculate_houses_prices_perm2, supply_volume, demand_volume,
         rental_supply_volume, rental_demand_volume,
         calculate_prices_in_supply, irs, vat, subsidyRate, salaryRate, 
         births, breakups, deaths, children_leaving_home, n_of_households,
         ## Gov Money flow ##
         subsidiesPaid, ivaCollected, irsCollected, companyServicesPaid, inheritagesFlow, constructionLabor,
         ## Company Money flow ##
         rawSalariesPaid, liquidSalariesReceived, expensesReceived, 
         transactions_per_region, rents_per_region, number_of_houses_built_per_region,
         supply_per_bucket, demand_per_bucket, newly_built_houses_for_sale, mortgages_per_step, houses_for_sale,
         contractRents, ## Houses prices per bucket
         #bucket_1, bucket_2, bucket_3, bucket_4
         ]

N_of_steps = NUMBER_OF_STEPS
# interactive_abm(model, agent_step!, model_step!)

model = wealth_model()


agent_data, model_data = run!(model, N_of_steps; adata, mdata)
# println(data)
# println(data2)
save("$output_folder/houses_prices.png", plot_houses_prices(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/houses_owned.png", plot_houses_owned(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/total_wealth.png", plot_total_wealth(agent_data[2:end, :], model_data[2:end, :]))

supply_and_demand_figures_regionally = plot_supply_and_demand(agent_data[2:end, :], model_data[2:end, :])
locations = instances(HouseLocation)
for i in eachindex(supply_and_demand_figures_regionally)
    save("$output_folder/supply_and_demand_in_$(string(locations[i])).png", supply_and_demand_figures_regionally[i])
end

supply_and_demand_figures_regionally = plot_rental_supply_and_demand(agent_data[2:end, :], model_data[2:end, :])
locations = instances(HouseLocation)
for i in eachindex(supply_and_demand_figures_regionally)
    save("$output_folder/rental_supply_and_demand_in_$(string(locations[i])).png", supply_and_demand_figures_regionally[i])
end

mkdir("$output_folder/supply_and_demand_per_bucket")

supply_and_demand_figures_per_bucket = plot_supply_and_demand_per_bucket(agent_data[2:end, :], model_data[2:end, :])
locations = instances(HouseLocation)
for location in instances(HouseLocation)
    for size_interval in instances(SizeInterval)
        save("$output_folder/supply_and_demand_per_bucket/supply_and_demand_in_$(string(location))_for_$(string(size_interval)).png", supply_and_demand_figures_per_bucket[location][size_interval])
    end
end

save("$output_folder/household_status.png", plot_household_status(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/house_prices_in_supply.png", plot_houses_prices_in_supply(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/taxes_and_subsidies.png", plot_taxes_and_subsidy_rates(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/household_money.png", plot_households_money_distribution(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/household_wealth.png", plot_households_wealth_distribution(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/demographic_events.png", plot_demographic_events(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/household_size_distribution.png", plot_households_size_distribution(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/household_age_distribution.png", plot_households_age_distribution(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/taxes_and_subsidies_flow.png", plot_taxes_and_subsidies_flow(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/salaries_and_expenses.png", plot_salaries_and_expenses(agent_data[2:end, :], model_data[2:end, :]))
# save("$output_folder/houses_prices_per_bucket.png", plot_houses_prices_per_bucket(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/houses_prices_per_region.png", plot_houses_prices_per_region(agent_data[2:end, :], model_data[2:end, :]))
for location in instances(HouseLocation)
    save("$output_folder/detailed_houses_prices_in_$(location).png", plot_detailed_houses_prices_per_region(agent_data[2:end, :], model_data[2:end, :], location))
end
save("$output_folder/rents_of_new_contracts_per_region.png", plot_rents_of_new_contracts_per_region(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/rents_per_region.png", plot_rents_per_region(agent_data[2:end, :], model_data[2:end, :]))

number_of_houses_built_figures = plot_number_of_houses_built_per_region(agent_data[2:end, :], model_data[2:end, :])
for location in instances(HouseLocation)
    save("$output_folder/number_of_houses_built_in_$(string(location)).png", number_of_houses_built_figures[location])
end

save("$output_folder/number_of_transactions_per_region.png", plot_number_of_transactions_per_region(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/number_of_newly_built_houses_for_sale.png", plot_number_of_newly_built_houses_for_sale(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/newly_built_houses_for_sale_size_distribution.png", plot_newly_built_houses_for_sale_size_distribution(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/number_of_mortgages.png", plot_number_of_mortgages(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/volume_of_lent_money.png", plot_volume_of_lent_money(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/houses_sizes_in_supply.png", plot_houses_for_sale_size_distribution(agent_data[2:end, :], model_data[2:end, :]))
save("$output_folder/houses_percentile_in_supply.png", plot_houses_for_sale_percentile_distribution(agent_data[2:end, :], model_data[2:end, :]))
# save("$output_folder/mortgages_median_values_regionally.png", plot_mortgages_median_values_regionally(agent_data[2:end, :], model_data[2:end, :]))
# save("$output_folder/mortgages_values_distribution.png", plot_mortgages_values_distribution(agent_data[2:end, :], model_data[2:end, :]))

# end

writeToCsv("$output_folder/QuarterLyHousePrices.csv", generate_houses_prices_table(agent_data[2:end, :], model_data[2:end, :]))
writeToCsv("$output_folder/QuarterLyRentsOfNewContracts.csv", generate_rent_prices_table(agent_data[2:end, :], model_data[2:end, :]))
writeToCsv("$output_folder/SemiAnuallyRentsOfNewContracts.csv", generate_semi_annually_rent_prices_table(agent_data[2:end, :], model_data[2:end, :]))
writeToCsv("$output_folder/QuarterlyNumberOfNewContracts.csv", generate_quarterly_number_of_new_contracts(agent_data[2:end, :], model_data[2:end, :]))
writeToCsv("$output_folder/AnnuallyScalledNumberOfNewContracts.csv", generate_annually_scalled_number_of_new_contracts(agent_data[2:end, :], model_data[2:end, :]))
writeToCsv("$output_folder/DemographicEvents.csv", generate_demographic_table(agent_data[2:end, :], model_data[2:end, :]))
# CSV.write("$output_folder/agentData.csv", agent_data, delim=';')
CSV.write("$output_folder/modelData.csv", model_data, delim=';')

Base.Filesystem.cptree("$output_folder", "latest_run", force=true)

# println(agent_data[(end - 5):end, :])
