using CairoMakie

function scatter_plot(x, y)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Quarter", ylabel = "Houses prices per m2")
    houses_prices = scatterlines!(ax, x, y, color = :cornsilk4)
    figure[1, 2] = Legend(figure, [houses_prices], ["Houses prices"])
    figure
end

quarters = [quarter for quarter in 1:12]

prices_in_oeiras = [2440, 2467, 2550, 2644, 2721, 2822, 2929, 3001, 3093, 3145, 3177, 3158]
simulated_prices_in_oeiras = [2278,2310,2319,2363,2430,2561,2696,2872,3011,3117,3313,3399]

save("RealPricesInOeiras.png", scatter_plot(quarters, prices_in_oeiras))
save("SimulatedPricesInOeiras.png", scatter_plot(quarters, simulated_prices_in_oeiras))
