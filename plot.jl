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
