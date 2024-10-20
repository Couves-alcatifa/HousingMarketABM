percentile_color_map = Dict(
    1 => :red,
    10 => :green,
    20 => :blue,
    30 => :orange,
    40 => :purple,
    50 => :pink,
    60 => :lime,
    70 => :indigo,
    80 => :magenta,
    90 => :gray,
    100 => :black
)

average_color = :darkblue

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
    regional_supply = Dict(location => Float32[] for location in instances(HouseLocation))
    regional_demand = Dict(location => Float32[] for location in instances(HouseLocation))

    for step in 1:length(adf.step)
        supply_step_dict = mdf.supply_volume[step]
        demand_step_dict = mdf.demand_volume[step]
        for location in instances(HouseLocation)
            push!(regional_supply[location], supply_step_dict[location])
            push!(regional_demand[location], demand_step_dict[location])
        end
    end
    figures = []
    for location in instances(HouseLocation)
        figure = Figure(size = (600, 400))
        ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Volume")
        supply_lines = lines!(ax, adf.step, regional_supply[location], color = :blue)
        supply_legends = "Supply in $(string(location))"
        demand_lines = lines!(ax, adf.step, regional_demand[location], color = :red)
        demand_legends = "Demand in $(string(location))"
        figure[1, 2] = Legend(figure, [supply_lines, demand_lines], [supply_legends, demand_legends])
        push!(figures, figure)
    end
    return figures
end

function plot_supply_and_demand_per_bucket(adf, mdf)
    figures = Dict(location => Dict(size_interval => Figure() for size_interval in instances(SizeInterval)) for location in instances(HouseLocation))
    supply_per_bucket = Dict(location => Dict(size_interval => Float32[] for size_interval in instances(SizeInterval)) for location in instances(HouseLocation))
    demand_per_bucket = Dict(location => Dict(size_interval => Float32[] for size_interval in instances(SizeInterval)) for location in instances(HouseLocation))

    for step in 1:length(adf.step)
        supply_step_dict = mdf.supply_per_bucket[step]
        demand_step_dict = mdf.demand_per_bucket[step]
        for location in instances(HouseLocation)
            for size_interval in instances(SizeInterval)
                push!(supply_per_bucket[location][size_interval], supply_step_dict[location][size_interval])
                push!(demand_per_bucket[location][size_interval], demand_step_dict[location][size_interval])
            end
        end
    end
    for location in instances(HouseLocation)
        for size_interval in instances(SizeInterval)
            figure = Figure(size = (600, 400))
            ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Volume")
            supply_lines = lines!(ax, adf.step, supply_per_bucket[location][size_interval], color = :blue)
            supply_legends = "Supply in $(string(location)) for houses $(get_size_interval_legend(size_interval))"
            demand_lines = lines!(ax, adf.step, demand_per_bucket[location][size_interval], color = :red)
            demand_legends = "Demand in $(string(location)) for houses $(get_size_interval_legend(size_interval))"
            figure[1, 2] = Legend(figure, [supply_lines, demand_lines], [supply_legends, demand_legends])
            figures[location][size_interval] = figure
        end
    end
    return figures
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

function get_percentile_index(vector, percentile)
    return Int64(floor((length(vector)/100) * percentile))
end

function get_percentile_along_vv(vv, percentile)
    res = Float32[]
    for vector in vv
        if length(vector) == 0
            push!(res, 0)
            continue
        end
        percentile_index = get_percentile_index(vector, percentile)
        if percentile_index == 0
            percentile_index = 1 # avoid trying to access at index 0
        end
        push!(res, vector[percentile_index])
    end
    return res
end

function get_average_along_vv(vv)
    res = Float32[]
    for vector in vv
        if length(vector) == 0
            push!(res, 0)
            continue
        end
        push!(res, mean(vector))
    end
    return res
end

function plot_households_money_distribution(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Money")
    all_lines = []
    all_legends = []
    for percentile in [1, 10, 20, 30, 40, 50, 60, 70, 80, 90]
        push!(all_lines, lines!(ax, adf.step, get_percentile_along_vv(adf.money_distribution_household, percentile), color = percentile_color_map[percentile]))
        push!(all_legends, "Percentile $(string(percentile))")
    end
    push!(all_lines, lines!(ax, adf.step, get_average_along_vv(adf.money_distribution_household), color = average_color))
    push!(all_legends, "Average")

    figure[1, 2] = Legend(figure, all_lines, all_legends)
    figure
end

function plot_households_wealth_distribution(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Wealth")
    all_lines = []
    all_legends = []
    for percentile in [1, 10, 20, 30, 40, 50, 60, 70, 80, 90]
        push!(all_lines, lines!(ax, adf.step, get_percentile_along_vv(adf.wealth_distribution_household, percentile), color = percentile_color_map[percentile]))
        push!(all_legends, "Percentile $(string(percentile))")
    end
    push!(all_lines, lines!(ax, adf.step, get_average_along_vv(adf.wealth_distribution_household), color = average_color))
    push!(all_legends, "Average")
    figure[1, 2] = Legend(figure, all_lines, all_legends)
    figure
end


function plot_households_size_distribution(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Household Size")
    all_lines = []
    all_legends = []
    for percentile in [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        push!(all_lines, lines!(ax, adf.step, get_percentile_along_vv(adf.size_distribution_household, percentile), color = percentile_color_map[percentile]))
        push!(all_legends, "Percentile $(string(percentile))")
    end
    push!(all_lines, lines!(ax, adf.step, get_average_along_vv(adf.size_distribution_household), color = average_color))
    push!(all_legends, "Average")
    figure[1, 2] = Legend(figure, all_lines, all_legends)
    figure
end

function plot_households_age_distribution(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Household Size")
    all_lines = []
    all_legends = []
    for percentile in [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        push!(all_lines, lines!(ax, adf.step, get_percentile_along_vv(adf.age_distribution_household, percentile), color = percentile_color_map[percentile]))
        push!(all_legends, "Percentile $(string(percentile))")
    end
    push!(all_lines, lines!(ax, adf.step, get_average_along_vv(adf.age_distribution_household), color = average_color))
    push!(all_legends, "Average")
    figure[1, 2] = Legend(figure, all_lines, all_legends)
    figure
end

function plot_taxes_and_subsidy_rates(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Rates")
    subsidyRate = lines!(ax, adf.step, mdf.subsidyRate, color = :black)
    irs = lines!(ax, adf.step, mdf.irs, color = :blue)
    vat = lines!(ax, adf.step, mdf.vat, color = :yellow)
    salaryRate = lines!(ax, adf.step, mdf.salaryRate, color = :purple)
    figure[1, 2] = Legend(figure, [subsidyRate, irs, vat, salaryRate], ["Subsidy Rate", "IRS", "IVA", "Salary Rate"])
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

function plot_taxes_and_subsidies_flow(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Money")
    subsidiesPaid = lines!(ax, adf.step, mdf.subsidiesPaid, color = :red)
    ivaCollected = lines!(ax, adf.step, mdf.ivaCollected, color = :black)
    irsCollected = lines!(ax, adf.step, mdf.irsCollected, color = :blue)
    companyServicesPaid = lines!(ax, adf.step, mdf.companyServicesPaid, color = :yellow)
    figure[1, 2] = Legend(figure, [subsidiesPaid, ivaCollected, irsCollected, companyServicesPaid], ["Subsidies", "IRS", "IVA", "Public Investment"])
    figure
end

function plot_salaries_and_expenses(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Money")
    rawSalariesPaid = lines!(ax, adf.step, mdf.rawSalariesPaid, color = :red)
    liquidSalariesReceived = lines!(ax, adf.step, mdf.liquidSalariesReceived, color = :green)
    expensesReceived = lines!(ax, adf.step, mdf.expensesReceived, color = :black)
    figure[1, 2] = Legend(figure, [rawSalariesPaid, liquidSalariesReceived, expensesReceived], ["Raw Salaries Paid", "Liquid Salaries Received", "Non housing consumption"])
    figure
end

function plot_houses_prices_per_bucket(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Money")
    
    bucket_1 = lines!(ax, adf.step, mdf.bucket_1, color = :red)
    bucket_2 = lines!(ax, adf.step, mdf.bucket_2, color = :green)
    bucket_3 = lines!(ax, adf.step, mdf.bucket_3, color = :yellow)
    bucket_4 = lines!(ax, adf.step, mdf.bucket_4, color = :blue)
    figure[1, 2] = Legend(figure, [bucket_1, bucket_2, bucket_3, bucket_4], ["Bucket 1", "Bucket 2", "Bucket 3", "Bucket 4"])
    figure
end

function plot_houses_prices_per_region(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Money")
    organizedPerRegion = Dict() # this will be filled with [[MeanValueForAmadoraStep1, ..Step2, ...Step3], [MeanValueForLisboaStep1, ...]]
    for location in instances(HouseLocation)
        organizedPerRegion[location] = Float32[]
        for step in 1:NUMBER_OF_STEPS
            step_values = Float32[]
            for transaction in mdf.transactions_per_region[step][location]
                push!(step_values, transaction.price / transaction.area)
            end
            if length(step_values) != 0
                push!(organizedPerRegion[location], mean(step_values))
            else
                push!(organizedPerRegion[location], 0.0)
            end
        end
    end
    lines = []
    locations = []
    for location in instances(HouseLocation)
        println("adf.step = $(adf.step)")
        println("organizedPerRegion[location] = $(organizedPerRegion[location])")
        push!(lines, lines!(ax, adf.step, organizedPerRegion[location], color = color_map[location]))
        push!(locations, string(location))
    end

    figure[1, 2] = Legend(figure, lines, locations)
    figure
end

function plot_rents_per_region(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Money")
    organizedPerRegion = Dict() # this will be filled with [[MeanValueForAmadoraStep1, ..Step2, ...Step3], [MeanValueForLisboaStep1, ...]]
    for location in instances(HouseLocation)
        organizedPerRegion[location] = Float32[]
        for step in 1:NUMBER_OF_STEPS
            step_values = Float32[]
            for transaction in mdf.rents_per_region[step][location]
                push!(step_values, transaction.price / transaction.area)
            end
            if length(step_values) != 0
                push!(organizedPerRegion[location], mean(step_values))
            else
                push!(organizedPerRegion[location], 0.0)
            end
        end
    end
    lines = []
    locations = []
    for location in instances(HouseLocation)
        push!(lines, lines!(ax, adf.step, organizedPerRegion[location], color = color_map[location]))
        push!(locations, string(location))
    end

    figure[1, 2] = Legend(figure, lines, locations)
    figure
end

function plot_number_of_houses_per_region(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Quantity")
    lines = []
    locations = []
    for location in instances(HouseLocation)
        regional_number_of_houses = Int32[]
        for step in 1:NUMBER_OF_STEPS
            push!(regional_number_of_houses, mdf.number_of_houses_per_region[step][location]) 
        end
        push!(lines, lines!(ax, adf.step, regional_number_of_houses, color = color_map[location]))
        push!(locations, string(location))
    end

    figure[1, 2] = Legend(figure, lines, locations)
    figure
end

function plot_number_of_houses_built_per_region(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Quantity")
    lines = []
    sizes_intervals = []
    figures = Dict(location => Figure() for location in instances(HouseLocation))
    for location in instances(HouseLocation)
        for size_interval in instances(SizeInterval)
            regional_number_of_houses = Int32[]
            for step in 1:NUMBER_OF_STEPS
                push!(regional_number_of_houses, mdf.number_of_houses_built_per_region[step][location][size_interval]) 
            end
            push!(lines, lines!(ax, adf.step, regional_number_of_houses, color = sizes_color_map[size_interval]))
            push!(sizes_intervals, get_size_interval_legend(size_interval))
        end
        figure[1, 2] = Legend(figure, lines, sizes_intervals)
        figure
        figures[location] = figure
        empty!(sizes_intervals)
        empty!(lines)
    end
    return figures

end

function plot_number_of_transactions_per_region(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Quantity")
    lines = []
    locations = []
    for location in instances(HouseLocation)
        regional_number_of_transaction = Int32[]
        for step in 1:NUMBER_OF_STEPS
            push!(regional_number_of_transaction, length(mdf.transactions_per_region[step][location]))
        end
        push!(lines, lines!(ax, adf.step, regional_number_of_transaction, color = color_map[location]))
        push!(locations, string(location))
    end

    figure[1, 2] = Legend(figure, lines, locations)
    figure
end

function plot_number_of_newly_built_houses_for_sale(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Quantity")
    lines = []
    number_of_new_built_houses_for_sale_per_step = Int32[]
    for step in 1:NUMBER_OF_STEPS
        push!(number_of_new_built_houses_for_sale_per_step, length(mdf.newly_built_houses_for_sale[step]))
    end
    push!(lines, lines!(ax, adf.step, number_of_new_built_houses_for_sale_per_step, color = :black))

    figure[1, 2] = Legend(figure, lines, ["Number of newly built houses for sale"])
    figure
end

function plot_newly_built_houses_for_sale_size_distribution(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Size")
    all_lines = []
    all_legends = []
    houses_areas_vv = [[house.area for house in v] for v in mdf.newly_built_houses_for_sale]
    for v in houses_areas_vv
        sort!(v)
    end
    for percentile in [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        push!(all_lines, lines!(ax, adf.step, get_percentile_along_vv(houses_areas_vv, percentile), color = percentile_color_map[percentile]))
        push!(all_legends, "Percentile $(string(percentile))")
    end

    push!(all_lines, lines!(ax, adf.step, get_average_along_vv(adf.age_distribution_household), color = average_color))
    push!(all_legends, "Average")
    figure[1, 2] = Legend(figure, all_lines, all_legends)
    figure
end

function plot_number_of_mortgages(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Quantity")
    lines = []
    number_of_mortgages = Int32[]
    for step in 1:NUMBER_OF_STEPS
        push!(number_of_mortgages, length(mdf.mortgages_per_step[step]))
    end
    push!(lines, lines!(ax, adf.step, number_of_mortgages, color = :black))

    figure[1, 2] = Legend(figure, lines, ["Number of mortgages provided"])
    figure
end

function plot_volume_of_lent_money(adf, mdf)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Money")
    lines = []
    money_lent = Float64[]
    for step in 1:NUMBER_OF_STEPS
        push!(money_lent, sum([mortgage.intialValue for mortgage in mdf.mortgages_per_step[step]]))
    end
    push!(lines, lines!(ax, adf.step, money_lent, color = :black))

    figure[1, 2] = Legend(figure, lines, ["Money Lent"])
    figure
end

# function plot_mortgages_median_values_regionally(adf, mdf)
#     figure = Figure(size = (600, 400))
#     ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Money")
    

#     figure[1, 2] = Legend(figure, lines, locations)
#     figure
# end

# function plot_mortgages_values_distribution(adf, mdf)
#     figure = Figure(size = (600, 400))
#     ax = figure[1, 1] = Axis(figure; xlabel = "Step", ylabel = "Money")
    
#     figure[1, 2] = Legend(figure, lines, locations)
#     figure
# end