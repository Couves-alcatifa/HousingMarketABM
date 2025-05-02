using CairoMakie, LaTeXStrings
using CSV, DataFrames
using Statistics

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
        color = :orange,
        label = "Baseline"
    )

    barplot!(ax, x_pos .+ bar_width/2, y_data_policy,
        width = bar_width,
        color = :green,
        label = policyLabel,
    )

    # Add legend
    Legend(fig[1, 2], ax, framevisible = false)

    # Save outputs
    # save("price_comparison.png", fig, px_per_unit = 3)

    fig
end
years = [string(year) for year in 2021:2030]
baseline_percentile = [62.291666666666664,63.791666666666664,66.04166666666667,69.04166666666667,73.875,74.0,71.58333333333333,69.58333333333333,77.625,77.70833333333333]
constr_lincens_simpl_percentile = [63.333333333333336,63.291666666666664,70.20833333333333,78.29166666666667,78.0,75.58333333333333,75.70833333333333,82.25,81.95833333333333,78.5]
non_res_prohibition_percentile = [60.666666666666664,62.541666666666664,64.25,67.54166666666667,68.41666666666667,70.54166666666667,66.70833333333333,66.95833333333333,68.91666666666667,71.875]
save("sold_houses_percentile_Oeiras.png", plot_bar_graph(years, baseline_percentile, constr_lincens_simpl_percentile,
                policyLabel = "Constr. Licensing Simpl.",
                title = "Percentile of houses sold Comparison with Constr. Licensing Simpl. in Oeiras",
                x_label = "Year",
                ylabel = "Percentile of Sold Houses",
            ))

save("sold_houses_percentile_non_resid_Oeiras.png", plot_bar_graph(years, baseline_percentile, non_res_prohibition_percentile,
    policyLabel = "Non Residents Prohib.",
    title = "Percentile of houses sold Comparison with Non Residents Prohib. in Oeiras",
    x_label = "Year",
    ylabel = "Percentile of Sold Houses",
))
