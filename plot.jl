using CairoMakie
using LaTeXStrings

function scatter_plot(x_data, y_data;
                        xlabel = "Year",
                        ylabel = "Average Houses prices per m² (€)",
                        title = "Evolution of Average Housing Prices per m² (€)")
    scale = 5.0
    fig = Figure(
        size=(600 * scale, 400 * scale),  # in pixels
        font = "TeX Gyre Heros Makie",
        figure_padding = 40
    )
    # figure = Figure()

    # Create axis with proper labels
    ax = Axis(fig[1, 1],
        title = title,
        xlabel = xlabel,
        ylabel = ylabel,  # LaTeX formatting for m²
        xticks = x_data,
        yticks = LinearTicks(10),  # About 10 ticks on y-axis
        ygridwidth = 1 * scale,
        xgridvisible = false,
        ygridvisible = true,
        ygridstyle = :dash,
        ygridcolor = (:gray, 0.3),
        xlabelsize = 10 * scale,
        ylabelsize = 10 * scale,
        titlesize = 15 * scale,
        xticklabelsize = 6 * scale,
        yticklabelsize = 6 * scale,
    )

    # Plot main line
    lines!(ax, x_data, y_data,
        color = :navyblue,
        linewidth = 2.5 * scale
    )

    # Add markers with white fill
    scatter!(ax, x_data, y_data,
        color = :white,
        strokecolor = :navyblue,
        strokewidth = 1.5 * scale,
        markersize = 15 * scale
    )

    x_min = minimum(x_data) - 0.5
    x_max = maximum(x_data) + 0.5
    y_min = 0.9 * minimum(y_data)
    y_max = 1.1 * maximum(y_data)

    # Set proper limits
    xlims!(ax, x_min, x_max)
    ylims!(ax, y_min, y_max)

    y_width = y_max - y_min
    x_width = x_max - x_min
    # Add data labels
    for (year, price) in zip(x_data, y_data)
        text!(ax, "$(Int64(round(price)))",
            position = (year + x_width * 0.005, price + y_width * 0.06),
            align = (:center, :bottom),
            fontsize = 9 * scale,
            color = :black
        )
        previousPrice = price
    end

    fig
end

function map_value(x, in_min, in_max, out_min, out_max, exp)::Float64
    return out_min + (x - in_min)^exp * (out_max - out_min) / (in_max - in_min)^exp
end

x_values = Float64[]
y_values_1 = Float64[]
y_values_2 = Float64[]
y_values_3 = Float64[]
for i in 1:100
    push!(x_values, Float64(i))
    push!(y_values_1, map_value(i, 1, 100, 0, 100, 1))
    push!(y_values_2, map_value(i, 1, 100, 0, 100, 2))
    push!(y_values_3, map_value(i, 1, 100, 0, 100, 3))
end
save("MapValue1.png", scatter_plot(x_values, y_values_1))
save("MapValue2.png", scatter_plot(x_values, y_values_2))
save("MapValue3.png", scatter_plot(x_values, y_values_3))

quarters = [quarter for quarter in 1:12]
years = [year for year in 1:10]
# years = [year for year in 1:10]

prices_in_oeiras = [2440, 2467, 2550, 2644, 2721, 2822, 2929, 3001, 3093, 3145, 3177, 3158]
simulated_prices_in_oeiras = [2278,2310,2319,2363,2430,2561,2696,2872,3011,3117,3313,3399]
pricesFrom2003 = [81532, 96634, 111347, 121298, 124405, 125992, 115405, 118345, 100709, 95297]
pricesFrom2012 = [95297, 99869, 114701, 118072, 119184, 136059, 135968, 142183]
simulatedPricesFrom2012 = [2332.4502,2320.394,2436.2546,2479.0242,2487.1304,2536.529,2562.9905,2653.787]
simulatedPricesFrom2003 = [2054.291,2294.741,2469.5342,2439.0544,2610.4138,2584.6545,2539.4138,2649.7002,2561.6123,2373.3452]
save("PricesFrom2012.png", scatter_plot(2012:2019, pricesFrom2012, ylabel = "Average Houses prices (€)", title = "Evolution of Real Average Housing Prices (€)"))
save("PricesFrom2012Simulated.png", scatter_plot(2012:2019, simulatedPricesFrom2012, title = "Evolution of Simulated Average Housing Prices (€)"))
save("PricesFrom2003Simulated.png", scatter_plot(2003:2012, simulatedPricesFrom2003, title = "Evolution of Simulated Average Housing Prices (€)"))
save("PricesFrom2003.png", scatter_plot(2003:2012, pricesFrom2003, ylabel = "Average Houses prices (€)", title = "Evolution of Real Average Housing Prices (€)"))
# save("RealPricesInOeiras.png", scatter_plot(quarters, prices_in_oeiras))
# save("SimulatedPricesInOeiras.png", scatter_plot(quarters, simulated_prices_in_oeiras))
# save("SimulatedPricesInOeiras.png", scatter_plot(quarters, simulated_prices_in_oeiras))

# save("SamplePlot.png", scatter_plot(1:21, [sin((x % 10) / 10) for x in 1:21]))
