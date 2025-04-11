include("tables.jl")

# Common plotting function for creating figures with lines
function create_figure(x_data, y_data_collection, line_colors, legends; 
                      size=(600, 400), xlabel="Step", ylabel="Value")
    figure = Figure(size=size)
    ax = figure[1, 1] = Axis(figure; xlabel=xlabel, ylabel=ylabel)
    
    all_lines = []
    for (i, y_data) in enumerate(y_data_collection)
        color = i <= length(line_colors) ? line_colors[i] : :black
        push!(all_lines, scatterlines!(ax, x_data, y_data, color=color))
    end
    
    figure[1, 2] = Legend(figure, all_lines, legends)
    figure, generate_monthly_table(y_data_collection, legends)
end

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
    y_data = [mdf.calculate_houses_prices_perm2]
    colors = [:cornsilk4]
    legends = ["Houses prices"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Houses prices per m2")
end

function plot_houses_prices_in_supply(adf, mdf)
    y_data = [mdf.calculate_prices_in_supply]
    colors = [:cornsilk4]
    legends = ["Houses prices"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Houses prices in supply")
end

function plot_houses_owned(adf, mdf)
    y_data = [adf.sum_houses_household]
    colors = [:cornsilk4]
    legends = ["Home owners"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Population")
end

function plot_total_wealth(adf, mdf)
    total_wealth = adf.sum_wealth_household .+ mdf.gov_wealth .+ mdf.company_wealth .+ mdf.bank_wealth .+ mdf.construction_wealth
    println(adf.sum_wealth_household .+ mdf.gov_wealth .+ mdf.company_wealth)
    
    y_data = [
        adf.sum_wealth_household,
        mdf.gov_wealth,
        mdf.company_wealth,
        mdf.bank_wealth,
        mdf.construction_wealth, 
        total_wealth
    ]
    
    colors = [:red, :blue, :green, :gray, :orange, :black]
    legends = ["Household", "Government", "Company", "Bank", "Construction Sector", "Total"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Money")
end

function plot_supply_and_demand(adf, mdf)
    regional_supply = Dict(location => Float32[] for location in HOUSE_LOCATION_INSTANCES)
    regional_demand = Dict(location => Float32[] for location in HOUSE_LOCATION_INSTANCES)

    for step in 1:length(adf.step)
        supply_step_dict = mdf.supply_volume[step]
        demand_step_dict = mdf.demand_volume[step]
        for location in HOUSE_LOCATION_INSTANCES
            push!(regional_supply[location], supply_step_dict[location])
            push!(regional_demand[location], demand_step_dict[location])
        end
    end
    
    figures = []
    for location in HOUSE_LOCATION_INSTANCES
        y_data = [regional_supply[location], regional_demand[location]]
        colors = [:blue, :red]
        legends = ["Supply in $(string(location))", "Demand in $(string(location))"]
        
        figure = create_figure(adf.step, y_data, colors, legends; 
                              xlabel="Step", ylabel="Volume")
        push!(figures, figure)
    end
    return figures
end

function plot_rental_supply_and_demand(adf, mdf)
    regional_supply = Dict(location => Float32[] for location in HOUSE_LOCATION_INSTANCES)
    regional_demand = Dict(location => Float32[] for location in HOUSE_LOCATION_INSTANCES)

    for step in 1:length(adf.step)
        supply_step_dict = mdf.rental_supply_volume[step]
        demand_step_dict = mdf.rental_demand_volume[step]
        for location in HOUSE_LOCATION_INSTANCES
            push!(regional_supply[location], supply_step_dict[location])
            push!(regional_demand[location], demand_step_dict[location])
        end
    end
    
    figures = []
    for location in HOUSE_LOCATION_INSTANCES
        y_data = [regional_supply[location], regional_demand[location]]
        colors = [:blue, :red]
        legends = ["Supply in $(string(location))", "Demand in $(string(location))"]
        
        figure = create_figure(adf.step, y_data, colors, legends; 
                              xlabel="Step", ylabel="Volume")
        push!(figures, figure)
    end
    return figures
end

function get_percentile_index(vector, percentile)
    return Int64(floor((length(vector)/100) * percentile))
end

function get_percentile_along_vv(vv, percentile)
    res = Float32[]
    for vector in vv
        if length(vector) == 0
            push!(res, NaN)
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
            push!(res, NaN)
            continue
        end
        push!(res, mean(vector))
    end
    return res
end

function plot_households_money_distribution(adf, mdf)
    y_data = []
    colors = []
    legends = []
    
    for percentile in [1, 10, 20, 30, 40, 50, 60, 70, 80, 90]
        push!(y_data, get_percentile_along_vv(adf.money_distribution_household, percentile))
        push!(colors, percentile_color_map[percentile])
        push!(legends, "Percentile $(string(percentile))")
    end
    
    # Add average
    push!(y_data, get_average_along_vv(adf.money_distribution_household))
    push!(colors, average_color)
    push!(legends, "Average")
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Money")
end

function plot_households_wealth_distribution(adf, mdf)
    y_data = []
    colors = []
    legends = []
    
    for percentile in [1, 10, 20, 30, 40, 50, 60, 70, 80, 90]
        push!(y_data, get_percentile_along_vv(adf.wealth_distribution_household, percentile))
        push!(colors, percentile_color_map[percentile])
        push!(legends, "Percentile $(string(percentile))")
    end
    
    # Add average
    push!(y_data, get_average_along_vv(adf.wealth_distribution_household))
    push!(colors, average_color)
    push!(legends, "Average")
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Wealth")
end

function plot_households_size_distribution(adf, mdf)
    y_data = []
    colors = []
    legends = []
    
    for percentile in [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        push!(y_data, get_percentile_along_vv(adf.size_distribution_household, percentile))
        push!(colors, percentile_color_map[percentile])
        push!(legends, "Percentile $(string(percentile))")
    end
    
    # Add average
    push!(y_data, get_average_along_vv(adf.size_distribution_household))
    push!(colors, average_color)
    push!(legends, "Average")
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Household Size")
end

function plot_households_age_distribution(adf, mdf)
    y_data = []
    colors = []
    legends = []
    
    for percentile in [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        push!(y_data, get_percentile_along_vv(adf.age_distribution_household, percentile))
        push!(colors, percentile_color_map[percentile])
        push!(legends, "Percentile $(string(percentile))")
    end
    
    # Add average
    push!(y_data, get_average_along_vv(adf.age_distribution_household))
    push!(colors, average_color)
    push!(legends, "Average")
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Household Age")
end

function plot_household_status(adf, mdf)
    y_data = [
        adf.count_isHousehold,
        adf.count_isHouseholdHomeOwner,
        adf.count_isHouseholdTenant,
        adf.count_isHouseholdLandlord,
        adf.count_isHouseholdMultipleHomeOwner
    ]
    
    colors = [:black, :red, :blue, :green, :pink]
    legends = ["Total", "Home Owners", "Tenants", "Landlords", "Own multiple houses"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Status")
end

function plot_unemployment_rate(adf, mdf)
    unemployment_rates = Float64[]
    for idx in eachindex(adf.count_isHousehold)
        push!(unemployment_rates, adf.count_isHouseholdUnemployed[idx] / adf.count_isHousehold[idx])
    end
    
    y_data = [unemployment_rates]
    colors = [:red]
    legends = ["Unemployment Rate"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Rate")
end

function plot_taxes_and_subsidy_rates(adf, mdf)
    y_data = [
        mdf.subsidyRate,
        mdf.irs,
        mdf.vat,
        mdf.salaryRate
    ]
    
    colors = [:black, :blue, :yellow, :purple]
    legends = ["Subsidy Rate", "IRS", "IVA", "Salary Rate"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Rates")
end

function plot_demographic_events(adf, mdf)
    births_merged = Int32[]
    deaths_merged = Int32[]
    for step in eachindex(mdf.births)
        push!(births_merged, sum([mdf.births[step][location] for location in HOUSE_LOCATION_INSTANCES]))
        push!(deaths_merged, sum([mdf.deaths[step][location] for location in HOUSE_LOCATION_INSTANCES]))
    end
    
    y_data = [
        births_merged,
        deaths_merged,
        mdf.breakups,
        mdf.children_leaving_home
    ]
    
    colors = [:red, :black, :blue, :yellow]
    legends = ["Births", "Deaths", "Divorces", "Young leaving home"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Volume")
end

function plot_taxes_and_subsidies_flow(adf, mdf)
    y_data = [
        mdf.subsidiesPaid,
        mdf.ivaCollected,
        mdf.irsCollected,
        mdf.companyServicesPaid
    ]
    
    colors = [:red, :black, :blue, :yellow]
    legends = ["Subsidies", "IRS", "IVA", "Public Investment"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Money")
end

function plot_salaries_and_expenses(adf, mdf)
    y_data = [
        mdf.rawSalariesPaid,
        mdf.liquidSalariesReceived,
        mdf.expensesReceived
    ]
    
    colors = [:red, :green, :black]
    legends = ["Raw Salaries Paid", "Liquid Salaries Received", "Non housing consumption"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Money")
end

function plot_houses_prices_per_bucket(adf, mdf)
    y_data = [
        mdf.bucket_1,
        mdf.bucket_2,
        mdf.bucket_3,
        mdf.bucket_4
    ]
    
    colors = [:red, :green, :yellow, :blue]
    legends = ["Bucket 1", "Bucket 2", "Bucket 3", "Bucket 4"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Money")
end

function plot_houses_prices_per_region(adf, mdf)
    organizedPerRegion = Dict() # this will be filled with [[MeanValueForAmadoraStep1, ..Step2, ...Step3], [MeanValueForLisboaStep1, ...]]
    for location in HOUSE_LOCATION_INSTANCES
        organizedPerRegion[location] = Float32[]
        for step in 1:NUMBER_OF_STEPS
            step_values = Float32[]
            for transaction in mdf.transactions_per_region[step][location]
                push!(step_values, transaction.price / transaction.area)
            end
            if length(step_values) != 0
                push!(organizedPerRegion[location], mean(step_values))
            else
                push!(organizedPerRegion[location], NaN)
            end
        end
    end
    
    y_data = []
    colors = []
    legends = []
    
    for location in HOUSE_LOCATION_INSTANCES
        push!(y_data, organizedPerRegion[location])
        push!(colors, color_map[location])
        push!(legends, string(location))
    end
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Money")
end

function plot_houses_prices_per_region_yearly(adf, mdf)
    organizedPerRegion = Dict() 
    for location in HOUSE_LOCATION_INSTANCES
        organizedPerRegion[location] = Float32[]
        year_values = Float32[]
        for step in 1:NUMBER_OF_STEPS
            for transaction in mdf.transactions_per_region[step][location]
                push!(year_values, transaction.price / transaction.area)
            end
            if step % 12 == 0
                if length(year_values) != 0
                    push!(organizedPerRegion[location], mean(year_values))
                    empty!(year_values)
                else
                    push!(organizedPerRegion[location], NaN)
                end
            end
        end
    end
    
    y_data = []
    colors = []
    legends = []
    
    for location in HOUSE_LOCATION_INSTANCES
        push!(y_data, organizedPerRegion[location])
        push!(colors, color_map[location])
        push!(legends, string(location))
    end
    
    # Note: using a subset of steps for x-axis here
    create_figure(adf.step[1:length(y_data[1])], y_data, colors, legends; 
                 xlabel="Year", ylabel="Money")
end

function plot_detailed_houses_prices_per_region(adf, mdf, location)
    houses_prices_vv = [[transaction.price/transaction.area for transaction in v[location]] for v in mdf.transactions_per_region]
    for v in houses_prices_vv
        sort!(v)
    end
    
    y_data = []
    colors = []
    legends = []
    
    for percentile in [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        push!(y_data, get_percentile_along_vv(houses_prices_vv, percentile))
        push!(colors, percentile_color_map[percentile])
        push!(legends, "Percentile $(string(percentile))")
    end
    
    # Add average
    push!(y_data, get_average_along_vv(houses_prices_vv))
    push!(colors, average_color)
    push!(legends, "Average")
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Price per m2")
end

function plot_rents_of_new_contracts_per_region(adf, mdf)
    organizedPerRegion = Dict()
    for location in HOUSE_LOCATION_INSTANCES
        organizedPerRegion[location] = Float32[]
        for step in 1:NUMBER_OF_STEPS
            step_values = Float32[]
            for transaction in mdf.rents_per_region[step][location]
                push!(step_values, transaction.price / transaction.area)
            end
            if length(step_values) != 0
                push!(organizedPerRegion[location], mean(step_values))
            else
                push!(organizedPerRegion[location], NaN)
            end
        end
    end
    
    y_data = []
    colors = []
    legends = []
    
    for location in HOUSE_LOCATION_INSTANCES
        push!(y_data, organizedPerRegion[location])
        push!(colors, color_map[location])
        push!(legends, string(location))
    end
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Money")
end

function plot_number_of_new_contracts_per_region(adf, mdf)
    y_data = []
    colors = []
    legends = []
    
    for location in HOUSE_LOCATION_INSTANCES
        regional_number_of_contracts = Int32[]
        for step in 1:NUMBER_OF_STEPS
            push!(regional_number_of_contracts, length(mdf.rents_per_region[step][location]))
        end
        push!(y_data, regional_number_of_contracts)
        push!(colors, color_map[location])
        push!(legends, string(location))
    end
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Quantity")
end

function plot_number_of_new_contracts_per_region_yearly(adf, mdf)
    y_data = []
    colors = []
    legends = []
    x_steps = []
    
    for location in HOUSE_LOCATION_INSTANCES
        regional_number_of_contracts = Int32[]
        yearly_number_of_contracts = 0
        for step in 1:NUMBER_OF_STEPS
            yearly_number_of_contracts += length(mdf.rents_per_region[step][location])
            if step % 12 == 0
                push!(regional_number_of_contracts, yearly_number_of_contracts)
                yearly_number_of_contracts = 0
            end
        end
        push!(y_data, regional_number_of_contracts)
        push!(colors, color_map[location])
        push!(legends, string(location))
        
        # All locations should have the same number of yearly data points
        if isempty(x_steps)
            x_steps = 1:length(regional_number_of_contracts)
        end
    end
    
    create_figure(x_steps, y_data, colors, legends; 
                 xlabel="Step", ylabel="Quantity")
end

function plot_rents_per_region(adf, mdf)
    y_data = []
    colors = []
    legends = []
    
    for location in HOUSE_LOCATION_INSTANCES
        organizedPerRegion = Float32[]
        for step in 1:NUMBER_OF_STEPS
            push!(organizedPerRegion, mdf.contractRents[step][location])
        end
        push!(y_data, organizedPerRegion)
        push!(colors, color_map[location])
        push!(legends, string(location))
    end
    
    create_figure(1:NUMBER_OF_STEPS, y_data, colors, legends; 
                 xlabel="Step", ylabel="Money")
end

function plot_number_of_houses_built_per_region_per_bucket(adf, mdf)
    figures = Dict()
    
    for location in HOUSE_LOCATION_INSTANCES
        y_data = []
        colors = []
        legends = []
        
        for size_interval in instances(SizeInterval)
            regional_number_of_houses = Int32[]
            for step in 1:NUMBER_OF_STEPS
                push!(regional_number_of_houses, mdf.number_of_houses_built_per_region[step][location][size_interval]) 
            end
            push!(y_data, regional_number_of_houses)
            push!(colors, sizes_color_map[size_interval])
            push!(legends, get_size_interval_legend(size_interval))
        end
        
        figures[location] = create_figure(adf.step, y_data, colors, legends; 
                                         xlabel="Step", ylabel="Quantity")
    end
    
    return figures
end

function plot_number_of_houses_built_per_region(adf, mdf)
    figures = Dict()
    
    for location in HOUSE_LOCATION_INSTANCES
        regional_number_of_houses = Int32[]
        for step in 1:NUMBER_OF_STEPS
            push!(regional_number_of_houses, sum([mdf.number_of_houses_built_per_region[step][location][size_interval] for size_interval in instances(SizeInterval)])) 
        end
        
        y_data = [regional_number_of_houses]
        colors = [:red]
        legends = ["Number of houses built"]
        
        figures[location] = create_figure(adf.step, y_data, colors, legends; 
                                         xlabel="Step", ylabel="Quantity")
    end
    
    return figures
end

function plot_number_of_transactions_per_region(adf, mdf)
    y_data = []
    colors = []
    legends = []
    
    for location in HOUSE_LOCATION_INSTANCES
        regional_number_of_transaction = Int32[]
        for step in 1:NUMBER_OF_STEPS
            push!(regional_number_of_transaction, length(mdf.transactions_per_region[step][location]))
        end
        push!(y_data, regional_number_of_transaction)
        push!(colors, color_map[location])
        push!(legends, string(location))
    end
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Quantity")
end

function plot_number_of_transactions_per_region_yearly(adf, mdf)
    y_data = []
    colors = []
    legends = []
    x_steps = []
    
    for location in HOUSE_LOCATION_INSTANCES
        regional_number_of_transaction = Int32[]
        yearly_number_of_transactions = 0
        for step in 1:NUMBER_OF_STEPS
            yearly_number_of_transactions += length(mdf.transactions_per_region[step][location])
            if step % 12 == 0
                push!(regional_number_of_transaction, yearly_number_of_transactions)
                yearly_number_of_transactions = 0
            end
        end
        push!(y_data, regional_number_of_transaction)
        push!(colors, color_map[location])
        push!(legends, string(location))
        
        # All locations should have the same number of yearly data points
        if isempty(x_steps)
            x_steps = 1:length(regional_number_of_transaction)
        end
    end
    
    create_figure(x_steps, y_data, colors, legends; 
                 xlabel="Step", ylabel="Quantity")
end

function plot_number_of_newly_built_houses_for_sale(adf, mdf)
    number_of_new_built_houses_for_sale_per_step = Int32[]
    for step in 1:NUMBER_OF_STEPS
        push!(number_of_new_built_houses_for_sale_per_step, length(mdf.newly_built_houses_for_sale[step]))
    end
    
    y_data = [number_of_new_built_houses_for_sale_per_step]
    colors = [:black]
    legends = ["Number of newly built houses for sale"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Quantity")
end

function plot_newly_built_houses_for_sale_size_distribution(adf, mdf)
    houses_areas_vv = [[house.area for house in v] for v in mdf.newly_built_houses_for_sale]
    for v in houses_areas_vv
        sort!(v)
    end
    
    y_data = []
    colors = []
    legends = []
    
    for percentile in [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        push!(y_data, get_percentile_along_vv(houses_areas_vv, percentile))
        push!(colors, percentile_color_map[percentile])
        push!(legends, "Percentile $(string(percentile))")
    end
    
    # Add average
    push!(y_data, get_average_along_vv(adf.age_distribution_household))
    push!(colors, average_color)
    push!(legends, "Average")
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Size")
end

function plot_number_of_mortgages(adf, mdf)
    number_of_mortgages = Int32[]
    for step in 1:NUMBER_OF_STEPS
        push!(number_of_mortgages, length(mdf.mortgages_per_step[step]))
    end
    
    y_data = [number_of_mortgages]
    colors = [:black]
    legends = ["Number of mortgages provided"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Quantity")
end

function plot_volume_of_lent_money(adf, mdf)
    money_lent = Float64[]
    for step in 1:NUMBER_OF_STEPS
        push!(money_lent, sum([mortgage.intialValue for mortgage in mdf.mortgages_per_step[step]]))
    end
    
    y_data = [money_lent]
    colors = [:black]
    legends = ["Money Lent"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Money")
end

function plot_houses_for_sale_size_distribution(adf, mdf)
    houses_areas_vv = [[house.area for house in v] for v in mdf.houses_for_sale]
    for v in houses_areas_vv
        sort!(v)
    end
    
    y_data = []
    colors = []
    legends = []
    
    for percentile in [10, 30, 50, 70, 90, 100]
        push!(y_data, get_percentile_along_vv(houses_areas_vv, percentile))
        push!(colors, percentile_color_map[percentile])
        push!(legends, "Percentile $(string(percentile))")
    end
    
    # Add average
    push!(y_data, get_average_along_vv(adf.age_distribution_household))
    push!(colors, average_color)
    push!(legends, "Average")
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Size")
end

function plot_houses_for_sale_percentile_distribution(adf, mdf)
    houses_percentiles_vv = [[house.percentile for house in v] for v in mdf.houses_for_sale]
    for v in houses_percentiles_vv
        sort!(v)
    end
    
    # Only include average here
    y_data = [get_average_along_vv(adf.age_distribution_household)]
    colors = [average_color]
    legends = ["Average"]
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Size")
end

function plot_sold_houses_percentile(adf, mdf)
    organizedPerRegion = Dict()
    for location in HOUSE_LOCATION_INSTANCES
        organizedPerRegion[location] = Float32[]
        for step in 1:NUMBER_OF_STEPS
            step_values = Float32[]
            for transaction in mdf.transactions_per_region[step][location]
                push!(step_values, transaction.percentile)
            end
            if length(step_values) != 0
                push!(organizedPerRegion[location], median(step_values))
            else
                push!(organizedPerRegion[location], NaN)
            end
        end
    end
    
    y_data = []
    colors = []
    legends = []
    
    for location in HOUSE_LOCATION_INSTANCES
        push!(y_data, organizedPerRegion[location])
        push!(colors, color_map[location])
        push!(legends, string(location))
    end
    
    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Percentile")
end

function plot_number_of_newly_built_houses_sold(adf, mdf)
    legends = []
    y_data = []
    colors = []
    for location in HOUSE_LOCATION_INSTANCES
        regional_number_of_transaction = Int32[]
        for step in 1:NUMBER_OF_STEPS
            push!(regional_number_of_transaction, 0)
            for transaction in mdf.transactions_per_region[step][location]
                if transaction.sellerId == -1
                    regional_number_of_transaction[length(regional_number_of_transaction)] += 1
                end
            end
        end
        push!(y_data, regional_number_of_transaction)
        push!(legends, string(location))
        push!(colors, color_map[location])
    end

    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Quantity")
end

function plot_number_of_houses_sold_by_non_residents(adf, mdf)
    legends = []
    y_data = []
    colors = []
    for location in HOUSE_LOCATION_INSTANCES
        regional_number_of_transaction = Int32[]
        for step in 1:NUMBER_OF_STEPS
            push!(regional_number_of_transaction, 0)
            for transaction in mdf.transactions_per_region[step][location]
                if transaction.sellerId < -1
                    regional_number_of_transaction[length(regional_number_of_transaction)] += 1
                end
            end
        end
        push!(y_data, regional_number_of_transaction)
        push!(legends, string(location))
        push!(colors, color_map[location])
    end

    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Quantity")
end

function plot_number_of_houses_bought_by_non_residents(adf, mdf)
    legends = []
    y_data = []
    colors = []
    for location in HOUSE_LOCATION_INSTANCES
        regional_number_of_transaction = Int32[]
        for step in 1:NUMBER_OF_STEPS
            push!(regional_number_of_transaction, 0)
            for transaction in mdf.transactions_per_region[step][location]
                if transaction.demandType == NonResidentDemand
                    regional_number_of_transaction[length(regional_number_of_transaction)] += 1
                end
            end
        end
        push!(y_data, regional_number_of_transaction)
        push!(legends, string(location))
        push!(colors, color_map[location])
    end

    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Quantity")
end

function plot_houses_time_in_market_when_sold(adf, mdf)
    legends = []
    y_data = []
    colors = []
    for location in HOUSE_LOCATION_INSTANCES
        organizedPerRegion = Float32[]
        for step in 1:NUMBER_OF_STEPS
            step_values = Int64[]
            for transaction in mdf.transactions_per_region[step][location]
                push!(step_values, transaction.timeInMarket)
            end
            if length(step_values) != 0
                push!(organizedPerRegion, mean(step_values))
            else
                push!(organizedPerRegion, NaN)
            end
        end
        push!(y_data, organizedPerRegion)
        push!(legends, string(location))
        push!(colors, color_map[location])
    end

    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Average Time in Market")
end

function plot_supply_and_demand_per_bucket(adf, mdf)
    figures = Dict()
    supply_per_bucket = Dict(location => Dict(size_interval => Float32[] for size_interval in instances(SizeInterval)) for location in HOUSE_LOCATION_INSTANCES)
    demand_per_bucket = Dict(location => Dict(size_interval => Float32[] for size_interval in instances(SizeInterval)) for location in HOUSE_LOCATION_INSTANCES)

    for step in 1:length(adf.step)
        supply_step_dict = mdf.supply_per_bucket[step]
        demand_step_dict = mdf.demand_per_bucket[step]
        for location in HOUSE_LOCATION_INSTANCES
            for size_interval in instances(SizeInterval)
                push!(supply_per_bucket[location][size_interval], supply_step_dict[location][size_interval])
                push!(demand_per_bucket[location][size_interval], demand_step_dict[location][size_interval])
            end
        end
    end
    for location in HOUSE_LOCATION_INSTANCES
        figures[location] = Dict()
        for size_interval in instances(SizeInterval)
            supply_legends = "Supply in $(string(location)) for houses $(get_size_interval_legend(size_interval))"
            demand_legends = "Demand in $(string(location)) for houses $(get_size_interval_legend(size_interval))"
            figures[location][size_interval] = create_figure(adf.step, [supply_per_bucket[location][size_interval], demand_per_bucket[location][size_interval]], [:blue, :red], [supply_legends, demand_legends]; 
                                         xlabel = "Step", ylabel = "Volume")
        end
    end
    return figures
end

function plot_number_of_houses_bought_to_invest_in_rental(adf, mdf)
    legends = []
    y_data = []
    colors = []
    for location in HOUSE_LOCATION_INSTANCES
        regional_number_of_transaction = Int32[]
        for step in 1:NUMBER_OF_STEPS
            push!(regional_number_of_transaction, 0)
            for transaction in mdf.transactions_per_region[step][location]
                if transaction.demandType == ForRental
                    regional_number_of_transaction[length(regional_number_of_transaction)] += 1
                end
            end
        end
        push!(y_data, regional_number_of_transaction)
        push!(legends, string(location))
        push!(colors, color_map[location])
    end

    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Quantity")
end

function plot_number_of_houses_bought_to_invest_in_renovation(adf, mdf)
    legends = []
    y_data = []
    colors = []
    for location in HOUSE_LOCATION_INSTANCES
        regional_number_of_transaction = Int32[]
        for step in 1:NUMBER_OF_STEPS
            push!(regional_number_of_transaction, 0)
            for transaction in mdf.transactions_per_region[step][location]
                if transaction.demandType == ForInvestment
                    regional_number_of_transaction[length(regional_number_of_transaction)] += 1
                end
            end
        end
        push!(y_data, regional_number_of_transaction)
        push!(legends, string(location))
        push!(colors, color_map[location])
    end

    create_figure(adf.step, y_data, colors, legends; 
                 xlabel="Step", ylabel="Quantity")
end

function plot_and_generate_table(filename, figureAndTable)
    figure = figureAndTable[1]
    table = figureAndTable[2]
    save("$output_folder/$filename.png", figure)
    writeToCsv("$output_folder/csvs/$filename.csv", table)
end