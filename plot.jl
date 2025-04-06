using CairoMakie

function scatter_plot(x, y)
    figure = Figure(size = (600, 400))
    # figure = Figure()
    ax = figure[1, 1] = Axis(figure; xlabel = "Quarter", ylabel = "Houses prices per m2",
                            #  autolimitaspect = 1
                             )
    limits!(ax, (nothing, nothing), (0, max(y...) * 1.5))
    houses_prices = scatterlines!(ax, x, y, color = :cornsilk4)
    figure[1, 2] = Legend(figure, [houses_prices], ["Houses prices"])
    figure
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

# save("PricesFrom2012.png", scatter_plot(1:length(pricesFrom2012), pricesFrom2012))
# save("PricesFrom2003.png", scatter_plot(years, pricesFrom2003))
# save("RealPricesInOeiras.png", scatter_plot(quarters, prices_in_oeiras))
save("SimulatedPricesInOeiras.png", scatter_plot(quarters, simulated_prices_in_oeiras))
# save("SimulatedPricesInOeiras.png", scatter_plot(quarters, simulated_prices_in_oeiras))

# save("SamplePlot.png", scatter_plot(1:21, [sin((x % 10) / 10) for x in 1:21]))
