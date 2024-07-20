using Agents
using Distributions, Random
using CairoMakie
using CSV
using Statistics

include("utilities.jl")
include("metrics.jl")
include("plots.jl")
# include("marketsLogic.jl")
# Set the seed for reproducibility
Random.seed!(1234)


function calculate_non_housing_consumption(household, income)
    wealth = household.wealth
    size = household.size
    # return 500 + income * 0.6 + log(income) + rand(100:300)
    expenses = EXPENSES_MINIMUM_VALUE * size * (EXPENSES_EXTRA_MINIMUM + rand() * EXPENSES_EXTRA_OFFSET)
    if income / size > EXPENSES_MINIMUM_VALUE
        expenses += (income / size - EXPENSES_MINIMUM_VALUE)  * size * (EXPENSES_EXTRA_MINIMUM + rand() * EXPENSES_EXTRA_OFFSET)
    end
    if is_home_owner(household) && wealth > 50000
        expenses += sqrt(wealth)
    end
    if is_home_owner(household) && wealth > 1000000
        expenses += sqrt(wealth)
    end
    if is_home_owner(household) && wealth > 5000000
        expenses += cbrt(wealth) * cbrt(wealth)
    end
    return expenses
    # if (income * 0.6 > 500)
    #     return rand(500:Int64(round(income * 0.7)))
    # else
    #     return 500
    # end
end

function wealth_model()

        households_sizes = rand(1:4, NUMBER_OF_HOUSEHOLDS)

        houses_sizes = rand(30:60, Int64(NUMBER_OF_HOUSEHOLDS/4))
        houses_sizes = vcat(houses_sizes, rand(60:80, Int64(NUMBER_OF_HOUSEHOLDS/4)))
        houses_sizes = vcat(houses_sizes, rand(80:120, Int64(NUMBER_OF_HOUSEHOLDS/4)))
        houses_sizes = vcat(houses_sizes, rand(120:180, Int64(NUMBER_OF_HOUSEHOLDS/4)))
        
        households_initial_ages = rand(20:35, Int64(NUMBER_OF_HOUSEHOLDS/4))
        households_initial_ages = vcat(households_initial_ages, rand(36:45, Int64(NUMBER_OF_HOUSEHOLDS/4)))
        households_initial_ages = vcat(households_initial_ages, rand(46:64, Int64(NUMBER_OF_HOUSEHOLDS/4)))
        households_initial_ages = vcat(households_initial_ages, rand(65:100, Int64(NUMBER_OF_HOUSEHOLDS/4)))
        
        # per quartile
        houses_prices_per_m2 = [1300, 1800, 2500]
        
        properties = Dict(
            :sum_wealth => 0,
            :steps => 0,
            :houses => House[],
            :houseMarket => HouseMarket(HouseSupply[], HouseDemand[]),
            :rentalMarket => RentalMarket(RentalSupply[], RentalDemand[]),
            :gov_prev_wealth => STARTING_GOV_WEALTH,
            :government => Government(STARTING_GOV_WEALTH, IRS, IRC, VAT, 1.0),
            :company_prev_wealth => STARTING_COMPANY_WEALTH,
            :company_wealth => STARTING_COMPANY_WEALTH,
            :bank => Bank(STARTING_BANK_WEALTH, INTEREST_RATE, LTV, DSTI),
            :transactions => Transaction[],
            :inheritages => Inheritage[],
            :contracts => Contract[],
            :salary_multiplier => 1.0,
            :demand_size => 0,
            :supply_size => 0,
            :construction_sector => ConstructionSector(STARTING_CONSTRUCTION_SECTOR_WEALTH, PendingConstruction[], 16, Mortgage[]),
            :births => 0, 
            :breakups => 0,
            :deaths => 0,
            :children_leaving_home => 0,
            :subsidiesPaid => 0.0,
            :ircCollected => 0.0,
            :ivaCollected => 0.0,
            :irsCollected => 0.0,
            :companyServicesPaid => 0.0,
            :inheritagesFlow => 0.0,
            :constructionLabor => 0.0,
            :rawSalariesPaid => 0.0,
            :liquidSalariesReceived => 0.0,
            :expensesReceived => 0.0,
            :buckets => InitiateBuckets(), # Houses characteristics => Transaction
        )

    model = StandardABM(MyMultiAgent; agent_step! = agent_step!, model_step! = model_step!, properties,scheduler = Schedulers.Randomly())
    initiateHouses(model)
    nextHouseIdToAssign = 1
    for i in 1:NUMBER_OF_HOUSEHOLDS
        houseIds = Int[]
        if (rand() < FRACTION_OF_HOMEOWNERS)
            # house = House(houses_sizes[i], Lisbon, NotSocialNeighbourhood, 1)
            # push!(model.houses, house)
            push!(houseIds, nextHouseIdToAssign)
            nextHouseIdToAssign += 1
            if (rand() < FRACTION_OF_DOUBLE_OWNERS)
                # house = House(houses_sizes[NUMBER_OF_HOUSEHOLDS - i], Lisbon, NotSocialNeighbourhood, 1)
                # push!(model.houses, house)
                push!(houseIds, nextHouseIdToAssign)
                nextHouseIdToAssign += 1
            end
        end
        percentile = calculate_percentile(1 - i/NUMBER_OF_HOUSEHOLDS)
        initial_age = households_initial_ages[rand(1:NUMBER_OF_HOUSEHOLDS)]
        add_agent!(Household, model, generateInitialWealth(initial_age, percentile), initial_age, households_sizes[i], houseIds, percentile, Mortgage[], Int[], 0, 0.0)
    end
    return model
end

function has_enough_size(house, household_size)
    return house.area >= household_size * 25

end

function model_step!(model)
    model.supply_size = length(model.houseMarket.supply)
    model.demand_size = length(model.houseMarket.demand)
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

    
    model.steps += 1
    if model.steps % 5 == 0
        println("5 steps!")
    end
    clearHouseMarket(model)
    clearRentalMarket(model)
    trimBucketsIfNeeded(model)
    if model.steps % 12 == 0
        if model.company_prev_wealth < model.company_wealth
            model.company_wealth -= (model.company_wealth - model.company_prev_wealth) * model.government.irc
            model.government.wealth += (model.company_wealth - model.company_prev_wealth) * model.government.irc
            model.ircCollected += (model.company_wealth - model.company_prev_wealth) * model.government.irc
        end
        company_adjust_salaries(model)
        gov_adjust_taxes(model)
        
        model.company_prev_wealth = model.company_wealth
        model.gov_prev_wealth = model.government.wealth
    end
    public_investment(model)
    updateConstructions(model)
    payMortgages(model, model.construction_sector)
    println("end of model_step!")
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
        if model.company_prev_wealth * 1.1 < model.company_wealth
            model.government.irc += 0.01
        end
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
        println("irc = " * string(model.government.irc))
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
    return length(household.houseIds) > 0
end



function put_house_to_rent(agent::MyMultiAgent, model, index)
    house = model.houses[agent.houseIds[index]]
    push!(model.rentalMarket.supply, RentalSupply(agent.houseIds[index], calculate_rental_market_price(house), agent.id, true))
    # removing house from agent when putting to sale
    splice!(agent.houseIds, index)
end

function put_house_to_sale(agent::MyMultiAgent, model, index)
    house = model.houses[agent.houseIds[index]]
    push!(model.houseMarket.supply, HouseSupply(agent.houseIds[index], calculate_market_price(house, model), Int[], agent.id, true))
    # removing house from agent when putting to sale
    splice!(agent.houseIds, index)
end

# this might need some changes...
function calculate_subsidy(household, model)
    subsidy = 0
    salary = calculateLiquidSalary(household, model)
    if (salary > 500 * household.size)
        return 0
    end
    return subsidy + (500 * household.size - salary)*0.4 * model.government.subsidyRate
end

function decideToRent(household, model, house)
    return household.percentile > 80 # TODO: something more interesting...
end

function supply_decisions(household, model)
    i = 2
    while i <= length(household.houseIds)
        if decideToRent(household, model, model.houses[household.houseIds[i]])
            put_house_to_rent(household, model, i)
        else # decides to sell...
            put_house_to_sale(household, model, i)
        end
        i += 1
    end
end

function not_home_owner_decisions(household, model)
    # let's say the household always tries to buy a house
    # and in the meantime it rents
    push!(model.houseMarket.demand, HouseDemand(household.id, HouseSupply[], household.size))
    if (household.contractIdAsTenant == 0)
        push!(model.rentalMarket.demand, RentalDemand(household.id, RentalSupply[], household.size))
    end
end

function home_owner_decisions(household, model)
    house = model.houses[household.houseIds[1]]
    if !has_enough_size(house, household.size)
        # moves out, put_house_to_sale
        # this doesnt make much sense... having a house and selling it
        # is not the same as not having one in the first place
        put_house_to_sale(household, model, 1)
        not_home_owner_decisions(household, model)
    end
end

function housing_decisions(household, model)
    if length(household.houseIds) > 1
        supply_decisions(household, model)
    elseif (!is_home_owner(household))
        not_home_owner_decisions(household, model)
    else
        home_owner_decisions(household, model)
    end
end

        
function household_step!(household::MyMultiAgent, model)
    wealthInHouses = 0.0
    for houseId in household.houseIds
        wealthInHouses += calculate_market_price(model.houses[houseId], model)
    end
    household.wealthInHouses = wealthInHouses
    if (model.steps % 12 == 0)
        household.age += 1
    end
    # 8% probability to simulate a year, but not all at the same time...
    if (rand() < 0.08 && household_evolution(household, model))
        # household died
        terminateContractsOnTentantSide(household, model)
        terminateContractsOnLandLordSide(household, model)
        return
    end

    update_houses(household, model)
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
    expenses = calculate_non_housing_consumption(household, liquid_salary + subsidy)
    household.wealth -= expenses
    model.company_wealth += expenses * (1 - model.government.vat)
    model.expensesReceived += expenses * (1 - model.government.vat)
    model.government.wealth += expenses* model.government.vat
    model.ivaCollected += expenses* model.government.vat

    payMortgages(model, household)
    payRent(model, household)
    # if (agent.wealth <= 0)
    #     agent.wealth = 0.0
        # remove_agent!(agent, model)
    # end
end

function payRent(model, household)
    if household.contractIdAsTenant != 0
        contract = model.contracts[household.contractIdAsTenant]
        landlord = model[contract.landlordId]
        landlord.wealth += contract.monthlyPayment
        # TODO: gov payment
        household.wealth -= contract.monthlyPayment
    end
end
function payMortgages(model, household)
    if (length(household.mortgages) != 0)
        for i in 1:length(household.mortgages)
            if (household.mortgages[i].valueInDebt > 0)
                payment = calculateMortgagePayment(household.mortgages[i], model.bank.interestRate)
                household.wealth -= payment
                model.bank.wealth += payment
                updateMortgage(household.mortgages[i], model.bank.interestRate)
            end
            if (household.mortgages[i].valueInDebt == 0)
                # print("Mortgage was paid! Maturity = " * string(household.mortgages[i].maturity))
            elseif (household.mortgages[i].valueInDebt < 0)
                # print("value in debt is negative! problems!! value = " * string(household.mortgages[i].valueInDebt))
            end
        end
    end
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
         bank_wealth, calculate_houses_prices_perm2, supply_volume, demand_volume, transactions,
         calculate_prices_in_supply, irs, vat, irc, subsidyRate, salaryRate, 
         births, breakups, deaths, children_leaving_home,
         ## Gov Money flow ##
         subsidiesPaid, ircCollected, ivaCollected, irsCollected, companyServicesPaid, inheritagesFlow, constructionLabor,
         ## Company Money flow ##
         rawSalariesPaid, liquidSalariesReceived, expensesReceived,
         ## Houses prices per bucket
         #bucket_1, bucket_2, bucket_3, bucket_4
         ]

N_of_steps = NUMBER_OF_STEPS
# interactive_abm(model, agent_step!, model_step!)
model = wealth_model()


agent_data, model_data = run!(model, N_of_steps; adata, mdata)
# println(data)
# println(data2)
save("1houses_prices.png", plot_houses_prices(agent_data[2:end, :], model_data[2:end, :]))
save("1houses_owned.png", plot_houses_owned(agent_data[2:end, :], model_data[2:end, :]))
save("1total_wealth.png", plot_total_wealth(agent_data[2:end, :], model_data[2:end, :]))
save("1supply_and_demand.png", plot_supply_and_demand(agent_data[2:end, :], model_data[2:end, :]))
save("1household_status.png", plot_household_status(agent_data[2:end, :], model_data[2:end, :]))
save("1house_prices_in_supply.png", plot_houses_prices_in_supply(agent_data[2:end, :], model_data[2:end, :]))
save("1taxes_and_subsidies.png", plot_taxes_and_subsidy_rates(agent_data[2:end, :], model_data[2:end, :]))
save("1household_money.png", plot_households_money_distribution(agent_data[2:end, :], model_data[2:end, :]))
save("1household_wealth.png", plot_households_wealth_distribution(agent_data[2:end, :], model_data[2:end, :]))
save("1demographic_events.png", plot_demographic_events(agent_data[2:end, :], model_data[2:end, :]))
save("1household_size_distribution.png", plot_households_size_distribution(agent_data[2:end, :], model_data[2:end, :]))
save("1household_age_distribution.png", plot_households_age_distribution(agent_data[2:end, :], model_data[2:end, :]))
save("1taxes_and_subsidies_flow.png", plot_taxes_and_subsidies_flow(agent_data[2:end, :], model_data[2:end, :]))
save("1salaries_and_expenses.png", plot_salaries_and_expenses(agent_data[2:end, :], model_data[2:end, :]))
# save("1houses_prices_per_bucket.png", plot_houses_prices_per_bucket(agent_data[2:end, :], model_data[2:end, :]))
save("1houses_prices_per_region.png", plot_houses_prices_per_region(agent_data[2:end, :], model_data[2:end, :]))

# end

CSV.write("agentData.csv", agent_data)
CSV.write("modelData.csv", model_data)


println(agent_data[(end - 5):end, :])
