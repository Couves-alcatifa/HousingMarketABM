function plot_houses_prices(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Houses prices per m2")
    houses_prices = lines!(ax, adf.step, mdf.calculate_houses_prices_perm2, color = :cornsilk4)
    figure[1, 2] = Legend(figure, [houses_prices], ["Houses prices"])
    figure
end

function plot_houses_prices_in_supply(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Houses prices in supply")
    houses_prices = lines!(ax, adf.step, mdf.calculate_prices_in_supply, color = :cornsilk4)
    figure[1, 2] = Legend(figure, [houses_prices], ["Houses prices"])
    figure
end

function plot_houses_owned(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Population")
    houses = lines!(ax, adf.step, adf.sum_houses_household, color = :cornsilk4)
    figure[1, 2] = Legend(figure, [houses], ["Home owners"])
    figure
end

function plot_total_wealth(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Money")
    household_wealth = lines!(ax, adf.step, adf.sum_wealth_household, color = :red)
    gov_money = lines!(ax, adf.step, mdf.gov_wealth, color = :blue)
    company_money = lines!(ax, adf.step, mdf.company_wealth, color = :green)
    bank_money = lines!(ax, adf.step, mdf.bank_wealth, color = :gray)
    construction_sector_money = lines!(ax, adf.step, mdf.construction_wealth, color = :orange)
    println(adf.sum_wealth_household .+ mdf.gov_wealth .+ mdf.company_wealth)
    total = lines!(ax, adf.step,  adf.sum_wealth_household .+ mdf.gov_wealth .+ mdf.company_wealth .+ mdf.bank_wealth .+ mdf.construction_wealth, color = :black)
    figure[1, 2] = Legend(figure, [household_wealth, gov_money, company_money, bank_money, construction_sector_money, total], ["Household", "Government", "Company", "Bank", "Construction Sector", "Total"])
    figure
end

function plot_supply_and_demand(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Volume")
    supply_volume = lines!(ax, adf.step, mdf.supply_volume, color = :blue)
    demand_volume = lines!(ax, adf.step, mdf.demand_volume, color = :red)
    figure[1, 2] = Legend(figure, [supply_volume, demand_volume], ["Supply Volume", "Demand Volume"])
    figure
end

function plot_household_status(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Status")
    total = lines!(ax, adf.step, adf.count_isHousehold, color = :black)
    home_owners = lines!(ax, adf.step, adf.count_isHouseholdHomeOwner, color = :red)
    tenants = lines!(ax, adf.step, adf.count_isHouseholdTenant, color = :blue)
    landlords = lines!(ax, adf.step, adf.count_isHouseholdLandlord, color = :green)
    Own_More_than_1_house = lines!(ax, adf.step, adf.count_isHouseholdMultipleHomeOwner, color = :pink)
    figure[1, 2] = Legend(figure, [home_owners, tenants, landlords, Own_More_than_1_house, total], ["Home Owners", "Tenants", "Landlords", "Own multiple houses", "Total"])
    figure
end

function get_quartile(vv, quartile_fun)
    res = Float32[]
    for vector in vv
        if length(vector) == 0
            push!(res, 0)
            continue
        end
        quartile = quartile_fun(vector)
        if quartile == 0
            quartile = 1 # avoid trying to access at index 0
        end
        push!(res, vector[quartile])
    end
    return res
end

function plot_households_wealth_distribution(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Wealth")
    lowest(v) = 1
    quartile_25(v) = Int64(floor(length(v)/4))
    quartile_50(v) = Int64(floor(length(v)/2))
    quartile_75(v) = Int64(floor((length(v)/4)*3))
    quartile_100(v) = length(v)
    println("get_quartile -> " * string(get_quartile(adf.wealth_distribution_household, lowest)))
    wealth_0 = lines!(ax, adf.step, get_quartile(adf.wealth_distribution_household, lowest), color = :black)
    wealth_25 = lines!(ax, adf.step, get_quartile(adf.wealth_distribution_household, quartile_25), color = :blue)
    wealth_50 = lines!(ax, adf.step, get_quartile(adf.wealth_distribution_household, quartile_50), color = :green)
    wealth_75 = lines!(ax, adf.step, get_quartile(adf.wealth_distribution_household, quartile_75), color = :yellow)
    wealth_100 = lines!(ax, adf.step, get_quartile(adf.wealth_distribution_household, quartile_100), color = :pink)
    figure[1, 2] = Legend(figure, [wealth_0, wealth_25, wealth_50, wealth_75, wealth_100], ["Lowest Wealth", "First Quartile", "Median", "Third Quartile", "Highest Wealth"])
    figure
end

function plot_households_size_distribution(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Household Size")
    lowest(v) = 1
    quartile_25(v) = Int64(floor(length(v)/4))
    quartile_50(v) = Int64(floor(length(v)/2))
    quartile_75(v) = Int64(floor((length(v)/4)*3))
    quartile_100(v) = length(v)
    wealth_0 = lines!(ax, adf.step, get_quartile(adf.size_distribution_household, lowest), color = :black)
    wealth_25 = lines!(ax, adf.step, get_quartile(adf.size_distribution_household, quartile_25), color = :blue)
    wealth_50 = lines!(ax, adf.step, get_quartile(adf.size_distribution_household, quartile_50), color = :green)
    wealth_75 = lines!(ax, adf.step, get_quartile(adf.size_distribution_household, quartile_75), color = :yellow)
    wealth_100 = lines!(ax, adf.step, get_quartile(adf.size_distribution_household, quartile_100), color = :pink)
    figure[1, 2] = Legend(figure, [wealth_0, wealth_25, wealth_50, wealth_75, wealth_100], ["Lowest Size", "First Quartile", "Median", "Third Quartile", "Highest Size"])
    figure
end

function plot_households_age_distribution(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Household Size")
    lowest(v) = 1
    quartile_25(v) = Int64(floor(length(v)/4))
    quartile_50(v) = Int64(floor(length(v)/2))
    quartile_75(v) = Int64(floor((length(v)/4)*3))
    quartile_100(v) = length(v)
    wealth_0 = lines!(ax, adf.step, get_quartile(adf.age_distribution_household, lowest), color = :black)
    wealth_25 = lines!(ax, adf.step, get_quartile(adf.age_distribution_household, quartile_25), color = :blue)
    wealth_50 = lines!(ax, adf.step, get_quartile(adf.age_distribution_household, quartile_50), color = :green)
    wealth_75 = lines!(ax, adf.step, get_quartile(adf.age_distribution_household, quartile_75), color = :yellow)
    wealth_100 = lines!(ax, adf.step, get_quartile(adf.age_distribution_household, quartile_100), color = :pink)
    figure[1, 2] = Legend(figure, [wealth_0, wealth_25, wealth_50, wealth_75, wealth_100], ["Youngest", "First Quartile", "Median", "Third Quartile", "Oldest"])
    figure
end

function plot_taxes_and_subsidy_rates(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Rates")
    subsidyRate = lines!(ax, adf.step, mdf.subsidyRate, color = :black)
    irs = lines!(ax, adf.step, mdf.irs, color = :blue)
    irc = lines!(ax, adf.step, mdf.irc, color = :green)
    vat = lines!(ax, adf.step, mdf.vat, color = :yellow)
    salaryRate = lines!(ax, adf.step, mdf.salaryRate, color = :purple)
    figure[1, 2] = Legend(figure, [subsidyRate, irs, irc, vat, salaryRate], ["Subsidy Rate", "IRS", "IRC", "IVA", "Salary Rate"])
    figure
end

function plot_demographic_events(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Volume")
    births = lines!(ax, adf.step, mdf.births, color = :red)
    deaths = lines!(ax, adf.step, mdf.deaths, color = :black)
    breakups = lines!(ax, adf.step, mdf.breakups, color = :blue)
    leaving_home = lines!(ax, adf.step, mdf.children_leaving_home, color = :yellow)
    figure[1, 2] = Legend(figure, [births, deaths, breakups, leaving_home], ["Births", "Deaths", "Divorces", "Young leaving home"])
    figure
end