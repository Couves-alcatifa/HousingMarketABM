using CairoMakie, LaTeXStrings
using CSV, DataFrames
using Statistics

function get_policy_name_from_policy(policy)
    if policy == "ConstructionVatReduction"
        return "Constr. VAT Red."
    elseif policy == "ConstructionLicensingSimplification"
        return "Constr. Licensing Simpl."
    elseif policy == "NonResidentsProhibition"
        return "Non Residents Prohib."
    elseif policy == "ReducedRentTax"
        return "Red. Rent Tax"
    elseif policy == "RentsIncreaseCeiling"
        return "Rents Increase Ceiling"
    else
        return policy
    end
end

function get_metric_name_from_metric(metric)
    if metric == "YearlyHousePrices"
        return "Yearly House Prices"
    elseif metric == "YearlyOldHousesPrices"
        return "Yearly Old Houses Prices"
    elseif metric == "YearlyRecentlyBuildPrices"
        return "Yearly Recently Build Prices"
    elseif metric == "YearlyNumberOfTransactions"
        return "Yearly Number Of Transactions"
    elseif metric == "YearlyNumberOfNewContracts"
        return "Yearly Number Of New Contracts"
    elseif metric == "YearlyRentsOfNewContracts"
        return "Yearly Rents Of New Contracts"
    else
        return metric
    end
end

function get_metric_name_from_metric_without_yearly(metric)
    if metric == "YearlyHousePrices"
        return "House Prices"
    elseif metric == "YearlyOldHousesPrices"
        return "Old Houses Prices"
    elseif metric == "YearlyRecentlyBuildPrices"
        return "Recently Build Prices"
    elseif metric == "YearlyNumberOfTransactions"
        return "Number Of Transactions"
    elseif metric == "YearlyNumberOfNewContracts"
        return "Number Of New Contracts"
    elseif metric == "YearlyRentsOfNewContracts"
        return "Rents Of New Contracts"
    else
        return metric
    end
end

function plot_bar_graph(x_data, y_data_baseline, y_data_policy;
        policyLabel = "Policy X", ylabel = "Average Price per m² (€)", title= "XPTOREPLACEHOLDER",
        x_label = "XPTOREPLACEHOLDER")
    
    # Set up figure
    fig = Figure(
        size = (800, 600),
        font = "Times New Roman",
        figure_padding = (40, 40, 40, 40)
    )
    
    ax = Axis(fig[1, 1],
        title = title,
        xlabel = x_label,
        ylabel = ylabel,
        xticks = (1:length(x_data), x_data),
        ygridvisible = true,
        ygridstyle = :dash,
        ygridcolor = (:gray, 0.3)
    )
    
    # Define bar positions and width
    bar_width = 0.35
    x_pos = 1:length(x_data)
    
    # Plot bars
    barplot!(ax, x_pos .- bar_width/2, y_data_baseline,
        width = bar_width,
        color = :navyblue,
        label = "Baseline"
    )
    
    barplot!(ax, x_pos .+ bar_width/2, y_data_policy,
        width = bar_width,
        color = :crimson,
        label = policyLabel,
    )
    
    # Add legend
    Legend(fig[1, 2], ax, framevisible = false)
    
    # Save outputs
    # save("price_comparison.png", fig, px_per_unit = 3)
    
    fig
end

function plot_deviation_bar_graph(policies, y_data_policy;
    policyLabel = "Policy X", ylabel = "Deviation from baseline (%)", title= "XPTOREPLACEHOLDER",
    x_label = "XPTOREPLACEHOLDER")

    # Set up figure
    fig = Figure(
        size = (800, 600),
        font = "Times New Roman",
        figure_padding = (40, 40, 40, 40)
    )

    ax = Axis(fig[1, 1],
        title = title,
        xlabel = x_label,
        ylabel = ylabel,
        # xticks = (1:length(policies), policies),
        ygridvisible = true,
        ygridstyle = :dash,
        ygridcolor = (:gray, 0.3)
    )

    # Define bar positions and width
    bar_width = 0.35
    x_pos = 1:length(policies)


    # Plot each bar with a different color
    colors = [:navyblue, :crimson, :orange, :green, :purple, :pink]
    for (i, policy) in enumerate(policies)
        barplot!(ax, x_pos[i], y_data_policy[i],
            width = bar_width,
            color = colors[i],
            label = get_policy_name_from_policy(policy)
        )
    end
    ylims!(ax, -15.0, 15.0)

    # Add legend
    Legend(fig[1, 2], ax, framevisible = false)

    # Save outputs
    # save("price_comparison.png", fig, px_per_unit = 3)

    fig
end

function plot_deviation_bar_graph_per_policy(metrics, y_data_policy;
    policyLabel = "Policy X", ylabel = "Deviation from baseline (%)", title= "XPTOREPLACEHOLDER",
    x_label = "XPTOREPLACEHOLDER")

    # Set up figure
    fig = Figure(
        size = (800, 600),
        font = "Times New Roman",
        figure_padding = (40, 40, 40, 40)
    )

    ax = Axis(fig[1, 1],
        title = title,
        xlabel = x_label,
        ylabel = ylabel,
        # xticks = (1:length(policies), policies),
        ygridvisible = true,
        ygridstyle = :dash,
        ygridcolor = (:gray, 0.3)
    )

    # Define bar positions and width
    bar_width = 0.35
    x_pos = 1:length(policies)


    # Plot each bar with a different color
    colors = [:navyblue, :crimson, :orange, :green, :purple, :pink]
    for (i, metric) in enumerate(metrics)
        barplot!(ax, x_pos[i], y_data_policy[i],
            width = bar_width,
            color = colors[i],
            label = get_metric_name_from_metric_without_yearly(metric)
        )
    end
    ylims!(ax, -15.0, 15.0)

    # Add legend
    Legend(fig[1, 2], ax, framevisible = false)

    # Save outputs
    # save("price_comparison.png", fig, px_per_unit = 3)

    fig
end

csvs_location = "results/csvs"
years = [string(year) for year in 2021:2030]
policies = ["ConstructionVatReduction",
    "ConstructionLicensingSimplification",
    "NonResidentsProhibition",
    "Baseline",
    "ReducedRentTax",
    "RentsIncreaseCeiling",
]

policies_without_baseline = []
for policy in policies
    if policy == "Baseline"
        continue
    end
    push!(policies_without_baseline, policy)
end

metrics = ["YearlyHousePrices",
           "YearlyNumberOfTransactions",
           "YearlyNumberOfNewContracts",
           "YearlyRentsOfNewContracts",
]

locations=["Amadora", "Cascais", "Lisboa", "Loures", "Mafra",
           "Odivelas", "Oeiras", "Sintra", "VilaFrancaDeXira",
           "Alcochete", "Almada", "Barreiro", "Moita", "Montijo",
           "Palmela", "Seixal", "Sesimbra", "Setubal"]

function load_csv_data()
    csv_data = Dict(policy => Dict(location => Dict(metric => Any[] for metric in metrics) for location in locations) for policy in policies)
    # Load CSV data
    for policy in policies
        for metric in metrics
            # read csvs
            df = CSV.read("$csvs_location/$(metric)_$policy.csv", DataFrame, header = false)
            # read line by line, ignoring 
            # the first line (header)
            for idx in 2:nrow(df)
                location = df[idx, 1]
                # Simulate data for the bar graph
                csv_data[policy][location][metric] = collect(df[idx, 2:end - 1]) # -1 to ignore the last ,
            end
        end
    end
    return csv_data
end

csv_data = load_csv_data()

output_dir = "results/bar_graphs"

for policy in policies_without_baseline
    for metric in metrics
        mkpath("$output_dir/$policy/$metric")
        for location in locations
            y_data_policy = csv_data[policy][location][metric]
            y_data_baseline = csv_data["Baseline"][location][metric]

            print("Plotting $metric for $policy in $location\n")
            # Create the bar graph
            save("$output_dir/$policy/$metric/$(location).png", plot_bar_graph(years, y_data_baseline, y_data_policy,
                policyLabel = get_policy_name_from_policy(policy),
                title = "Price Comparison with $(get_policy_name_from_policy(policy))",
                x_label = "Year"
            ))
        end
    end
end


deviations_dict = Dict(metric => Dict(location => Dict(policy => 0.0 for policy in policies_without_baseline) for location in locations) for metric in metrics)
for metric in metrics
    mkpath("results/bar_graphs/deviations/$metric")
    for location in locations
        y_data_baseline = mean(csv_data["Baseline"][location][metric])
        for policy in policies_without_baseline
            y_data_policy = mean(csv_data[policy][location][metric])
            # Calculate the deviation
            deviation = (y_data_policy - y_data_baseline) / y_data_baseline * 100
            deviations_dict[metric][location][policy] = deviation
            print("Plotting $metric for $policy in $location\n")
            # Create the bar graph
        end
        deviations = [deviation for deviation in [deviations_dict[metric][location][policy] for policy in policies_without_baseline]]
        save("$output_dir/deviations/$metric/$(location).png", plot_deviation_bar_graph(policies_without_baseline, deviations,
            policyLabel = "Deviation from baseline",
            title = "Deviation of $metric from baseline with different policies",
            x_label = "Policy"
        ))
    end
end

y_data_merged_metric_policy = Dict(metric => Dict(policy => 0.0 for policy in policies) for metric in metrics)
function plot_merged_deviation_bar_graph(metric, ponderation_metric)
    y_data_merged_baseline = 0.0
    y_data_merged_policy = Dict(policy => 0.0 for policy in policies_without_baseline)
    deviations = []
    sum_ponderation_metric = Dict(policy => (ponderation_metric !== nothing
                              ? sum([sum(csv_data[policy][location][ponderation_metric]) for location in locations])
                              : 1) for policy in policies)
    for location in locations
        ponderation_metric_location_baseline = (ponderation_metric !== nothing 
                                        ? sum(csv_data["Baseline"][location][ponderation_metric])
                                        : 1)
        y_data_merged_baseline += sum(csv_data["Baseline"][location][metric]) * ponderation_metric_location_baseline
        for policy in policies_without_baseline
            ponderation_metric_location_policy = (ponderation_metric !== nothing 
                                        ? sum(csv_data[policy][location][ponderation_metric])
                                        : 1)
            y_data_merged_policy[policy] += sum(csv_data[policy][location][metric]) * ponderation_metric_location_policy 
        end
    end
    y_data_merged_baseline = y_data_merged_baseline / sum_ponderation_metric["Baseline"]
    y_data_merged_metric_policy[metric]["Baseline"] = y_data_merged_baseline
    for policy in policies_without_baseline
        y_data_merged_policy_final = y_data_merged_policy[policy] / sum_ponderation_metric[policy]
        y_data_merged_metric_policy[metric][policy] = y_data_merged_policy_final
        # Calculate the deviation
        deviation = (y_data_merged_policy_final - y_data_merged_baseline) / y_data_merged_baseline * 100
        push!(deviations, deviation)

        # Create the bar graph
    end
    save("$output_dir/deviations/$metric/merged.png", plot_deviation_bar_graph(policies_without_baseline, deviations,
        policyLabel = "Deviation from baseline",
        title = "Deviation of $(get_metric_name_from_metric_without_yearly(metric)) from baseline with different policies",
        x_label = "Policy"
    ))

end

function getPonderationMetric(metric)
    if metric == "YearlyHousePrices"
        return "YearlyNumberOfTransactions"
    elseif metric == "YearlyOldHousesPrices"
        return "YearlyNumberOfTransactions"
    elseif metric == "YearlyRecentlyBuildPrices"
        return "YearlyNumberOfTransactions"
    elseif metric == "YearlyNumberOfTransactions"
        return nothing
    elseif metric == "YearlyNumberOfNewContracts"
        return nothing
    elseif metric == "YearlyRentsOfNewContracts"
        return "YearlyNumberOfNewContracts"
    else
        return nothing
    end
end
for metric in metrics
    plot_merged_deviation_bar_graph(metric, getPonderationMetric(metric))
end

for policy in policies_without_baseline
    deviations = []
    for metric in metrics
        y_data_merged_policy_final = y_data_merged_metric_policy[metric][policy]
        y_data_merged_baseline = y_data_merged_metric_policy[metric]["Baseline"]
        # Calculate the deviation
        deviation = (y_data_merged_policy_final - y_data_merged_baseline) / y_data_merged_baseline * 100
        push!(deviations, deviation)

        # Create the bar graph
    end
    save("$output_dir/deviations/per_policy/$(policy).png", plot_deviation_bar_graph_per_policy(metrics, deviations,
        policyLabel = "Deviation from baseline",
        title = "Deviation of $(get_policy_name_from_policy(policy)) from baseline for different metrics",
        x_label = "Metric"
    ))
    for location in locations
        mkpath("$output_dir/deviations/per_location/$(location)")
        save("$output_dir/deviations/per_location/$(location)/$policy.png", plot_deviation_bar_graph_per_policy(metrics, [deviations_dict[metric][location][policy] for metric in metrics],
            policyLabel = "Deviation from baseline",
            title = "Deviation of $(get_policy_name_from_policy(policy)) from baseline in $location for different metrics",
            x_label = "Metric"
        ))
    end
end