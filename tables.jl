locationToIndex = Dict(HOUSE_LOCATION_INSTANCES[idx] => idx + 1 for idx in eachindex(HOUSE_LOCATION_INSTANCES))

function plot_simulated_results(x, simulated_y, real_y)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Quarter", ylabel = "Houses prices per m2")
    limits!(ax, (nothing, nothing), (0, max(simulated_y..., real_y...) * 1.5))
    simulated_houses_prices = scatterlines!(ax, x, simulated_y, color = :red)
    real_houses_prices = scatterlines!(ax, x, real_y, color = :blue)
    figure[1, 2] = Legend(figure, [simulated_houses_prices, real_houses_prices], ["Simulated House prices", "Real House Prices"])
    figure
end

function plot_simulated_rents(x, simulated_y, real_y)
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Semester", ylabel = "Rents per m2")
    limits!(ax, (nothing, nothing), (0, max(simulated_y..., real_y...) * 1.5))
    
    simulated_houses_prices = scatterlines!(ax, x, simulated_y, color = :red)
    real_houses_prices = scatterlines!(ax, x, real_y, color = :blue)
    figure[1, 2] = Legend(figure, [simulated_houses_prices, real_houses_prices], ["Simulated Rents", "Real Rents"])
    figure
end

# this function will generate a table with the house prices for each quarter, in each region
function generate_houses_prices_table(adf, mdf)
    # since we will organize the table in quarters, we don't need the last hanging 1 or 2 steps
    maxRelevantStep = Int(floor(NUMBER_OF_STEPS/3)) * 3

    # 
    finalTable = vcat([["-"]], [Any[string(location)] for location in HOUSE_LOCATION_INSTANCES])


    currentQuarter = 1
    currentYear = 2021
    currentQuarterTransactions = Dict(location => [] for location in HOUSE_LOCATION_INSTANCES)
    for i in 1:maxRelevantStep
        for location in HOUSE_LOCATION_INSTANCES
            for transaction in mdf.transactions_per_region[i][location]
                push!(currentQuarterTransactions[location], transaction.price / transaction.area)
            end
        end
        if i % 3 == 0
            push!(finalTable[1], "$(currentYear)Q$(currentQuarter)")
            for location in HOUSE_LOCATION_INSTANCES
                if length(currentQuarterTransactions[location]) != 0
                    push!(finalTable[locationToIndex[location]], Int64(round(median(currentQuarterTransactions[location]))))
                else
                    push!(finalTable[locationToIndex[location]], 0)
                end
                empty!(currentQuarterTransactions[location])
            end
            currentQuarter += 1
        end
        if i % 12 == 0
            currentQuarter = 1
            currentYear += 1
        end
    end

    REAL_PRICES_MAP_WITHOUT_INFLATION = Dict(string(location) => Float64[] for location in HOUSE_LOCATION_INSTANCES)
    for (location, values) in REAL_PRICES_MAP_WITHOUT_INFLATION
        for idx in eachindex(REAL_PRICES_MAP_ADJUSTED[location])
            year = CURRENT_YEAR + Int64(floor((idx - 1)/ 4))
            month = 3 + ((idx - 1) % 4) * 3
            push!(REAL_PRICES_MAP_WITHOUT_INFLATION[location], custom_adjust_value_to_inflation(REAL_PRICES_MAP_ADJUSTED[location][idx], year, month, CURRENT_YEAR, CURRENT_MONTH))
        end
    end

    for line in finalTable[2:end]
        location = line[1]
        x = [quarter for quarter in 1:length(line) - 1]
        y = Int32[]
        for value in line[2:end]
            y = vcat(y, value)
        end
        sizeToUse = min(length(y), length(REAL_PRICES_MAP_ADJUSTED[location]))
        save("simulated_prices/SimulatedPricesIn$location.png", plot_simulated_results(x[1:sizeToUse], y[1:sizeToUse], REAL_PRICES_MAP_WITHOUT_INFLATION[location][1:sizeToUse]))
        save("$output_folder/SimulatedPricesIn$location.png", plot_simulated_results(x[1:sizeToUse], y[1:sizeToUse], REAL_PRICES_MAP_WITHOUT_INFLATION[location][1:sizeToUse]))
    end

    print("Final Table: \n$(finalTable)")
    return finalTable
end

function generate_yearly_houses_prices_table(adf, mdf)
    # since we will organize the table in quarters, we don't need the last hanging 1 or 2 steps
    maxRelevantStep = Int(floor(NUMBER_OF_STEPS/12)) * 12

    # 
    finalTable = vcat([["-"]], [Any[string(location)] for location in HOUSE_LOCATION_INSTANCES])


    currentYear = 2021
    currentYearTransactions = Dict(location => [] for location in HOUSE_LOCATION_INSTANCES)
    for i in 1:maxRelevantStep
        for location in HOUSE_LOCATION_INSTANCES
            for transaction in mdf.transactions_per_region[i][location]
                push!(currentYearTransactions[location], transaction.price / transaction.area)
            end
        end
        if i % 12 == 0
            push!(finalTable[1], "$(currentYear)")
            for location in HOUSE_LOCATION_INSTANCES
                if length(currentYearTransactions[location]) != 0
                    push!(finalTable[locationToIndex[location]], Int64(round(median(currentYearTransactions[location]))))
                else
                    push!(finalTable[locationToIndex[location]], 0)
                end
                empty!(currentYearTransactions[location])
            end
            currentYear += 1
        end
    end

    return finalTable
end

function generate_yearly_old_houses_prices_table(adf, mdf)
    # since we will organize the table in quarters, we don't need the last hanging 1 or 2 steps
    maxRelevantStep = Int(floor(NUMBER_OF_STEPS/12)) * 12

    # 
    finalTable = vcat([["-"]], [Any[string(location)] for location in HOUSE_LOCATION_INSTANCES])


    currentYear = 2021
    currentYearTransactions = Dict(location => [] for location in HOUSE_LOCATION_INSTANCES)
    for i in 1:maxRelevantStep
        for location in HOUSE_LOCATION_INSTANCES
            for transaction in mdf.transactions_per_region[i][location]
                if transaction.sellerId != -1
                    push!(currentYearTransactions[location], transaction.price / transaction.area)
                end
            end
        end
        if i % 12 == 0
            push!(finalTable[1], "$(currentYear)")
            for location in HOUSE_LOCATION_INSTANCES
                if length(currentYearTransactions[location]) != 0
                    push!(finalTable[locationToIndex[location]], Int64(round(median(currentYearTransactions[location]))))
                else
                    push!(finalTable[locationToIndex[location]], 0)
                end
                empty!(currentYearTransactions[location])
            end
            currentYear += 1
        end
    end

    return finalTable
end

function generate_yearly_recently_built_prices_table(adf, mdf)
    # since we will organize the table in quarters, we don't need the last hanging 1 or 2 steps
    maxRelevantStep = Int(floor(NUMBER_OF_STEPS/12)) * 12

    # 
    finalTable = vcat([["-"]], [Any[string(location)] for location in HOUSE_LOCATION_INSTANCES])


    currentYear = 2021
    currentYearTransactions = Dict(location => [] for location in HOUSE_LOCATION_INSTANCES)
    for i in 1:maxRelevantStep
        for location in HOUSE_LOCATION_INSTANCES
            for transaction in mdf.transactions_per_region[i][location]
                if transaction.sellerId == -1
                    push!(currentYearTransactions[location], transaction.price / transaction.area)
                end
            end
        end
        if i % 12 == 0
            push!(finalTable[1], "$(currentYear)")
            for location in HOUSE_LOCATION_INSTANCES
                if length(currentYearTransactions[location]) != 0
                    push!(finalTable[locationToIndex[location]], Int64(round(median(currentYearTransactions[location]))))
                else
                    push!(finalTable[locationToIndex[location]], 0)
                end
                empty!(currentYearTransactions[location])
            end
            currentYear += 1
        end
    end

    return finalTable
end

function generate_rent_prices_table(adf, mdf)
    # since we will organize the table in quarters, we don't need the last hanging 1 or 2 steps
    maxRelevantStep = Int(floor(NUMBER_OF_STEPS/3)) * 3

    # 
    finalTable = vcat([["-"]], [Any[string(location)] for location in HOUSE_LOCATION_INSTANCES])


    currentQuarter = 1
    currentYear = 2021
    currentQuarterTransactions = Dict(location => [] for location in HOUSE_LOCATION_INSTANCES)
    for i in 1:maxRelevantStep
        for location in HOUSE_LOCATION_INSTANCES
            for transaction in mdf.rents_per_region[i][location]
                push!(currentQuarterTransactions[location], transaction.price / transaction.area)
            end
        end
        if i % 3 == 0
            push!(finalTable[1], "$(currentYear)Q$(currentQuarter)")
            for location in HOUSE_LOCATION_INSTANCES
                if length(currentQuarterTransactions[location]) != 0
                    push!(finalTable[locationToIndex[location]], median(currentQuarterTransactions[location]))
                else
                    push!(finalTable[locationToIndex[location]], 0)
                end
                empty!(currentQuarterTransactions[location])
            end
            currentQuarter += 1
        end
        if i % 12 == 0
            currentQuarter = 1
            currentYear += 1
        end
    end
    return finalTable
end

function generate_semi_annually_rent_prices_table(adf, mdf)
    # since we will organize the table in quarters, we don't need the last hanging 1 or 2 steps
    if NUMBER_OF_STEPS < 6
        println("The number of steps is too low to generate a semi-annually rent prices table")
        return
    end
    maxRelevantStep = Int(floor(NUMBER_OF_STEPS/6)) * 6

    # 
    finalTable = vcat([["-"]], [Any[string(location)] for location in HOUSE_LOCATION_INSTANCES])


    currentSemester = 1
    currentYear = 2021
    currentSemesterTransactions = Dict(location => [] for location in HOUSE_LOCATION_INSTANCES)
    for i in 1:maxRelevantStep
        for location in HOUSE_LOCATION_INSTANCES
            for transaction in mdf.rents_per_region[i][location]
                push!(currentSemesterTransactions[location], transaction.price / transaction.area)
            end
        end
        if i % 6 == 0
            push!(finalTable[1], "$(currentYear)S$(currentSemester)")
            for location in HOUSE_LOCATION_INSTANCES
                if length(currentSemesterTransactions[location]) != 0
                    push!(finalTable[locationToIndex[location]], median(currentSemesterTransactions[location]))
                else
                    push!(finalTable[locationToIndex[location]], 0)
                end
                empty!(currentSemesterTransactions[location])
            end
            currentSemester += 1
        end
        if i % 12 == 0
            currentSemester = 1
            currentYear += 1
        end
    end

    REAL_RENTS_MAP_WITHOUT_INFLATION = Dict(string(location) => Float64[] for location in HOUSE_LOCATION_INSTANCES)
    for (location, values) in REAL_RENTS_MAP_WITHOUT_INFLATION
        for idx in eachindex(REAL_RENTS_MAP_ADJUSTED[location])
            year = CURRENT_YEAR + Int(floor((idx - 1) / 2))
            month = 6 + ((idx - 1) % 2) * 6
            push!(REAL_RENTS_MAP_WITHOUT_INFLATION[location], custom_adjust_value_to_inflation(REAL_RENTS_MAP_ADJUSTED[location][idx], year, month, CURRENT_YEAR, CURRENT_MONTH))
        end
    end

    for line in finalTable[2:end]
        location = line[1]
        x = [semester for semester in 1:length(line) - 1]
        y = Int32[]
        for value in line[2:end]
            y = vcat(y, value)
        end
        sizeToUse = min(length(y), length(REAL_RENTS_MAP_WITHOUT_INFLATION[location]))
        save("simulated_rents/SimulatedRentsIn$location.png", plot_simulated_rents(x[1:sizeToUse], y[1:sizeToUse], REAL_RENTS_MAP_WITHOUT_INFLATION[location][1:sizeToUse]))
        save("$output_folder/SimulatedRentsIn$location.png", plot_simulated_rents(x[1:sizeToUse], y[1:sizeToUse], REAL_RENTS_MAP_WITHOUT_INFLATION[location][1:sizeToUse]))
    end

    return finalTable
end

function generate_yearly_rents_table(adf, mdf)
    maxRelevantStep = Int(floor(NUMBER_OF_STEPS/12)) * 12

    finalTable = vcat([["-"]], [Any[string(location)] for location in HOUSE_LOCATION_INSTANCES])


    currentYear = 2021
    currentYearTransactions = Dict(location => [] for location in HOUSE_LOCATION_INSTANCES)
    for i in 1:maxRelevantStep
        for location in HOUSE_LOCATION_INSTANCES
            for transaction in mdf.rents_per_region[i][location]
                push!(currentYearTransactions[location], transaction.price / transaction.area)
            end
        end
        if i % 12 == 0
            push!(finalTable[1], "$(currentYear)")
            for location in HOUSE_LOCATION_INSTANCES
                if length(currentYearTransactions[location]) != 0
                    push!(finalTable[locationToIndex[location]], median(currentYearTransactions[location]))
                else
                    push!(finalTable[locationToIndex[location]], 0)
                end
                empty!(currentYearTransactions[location])
            end
            currentYear += 1
        end
    end

    return finalTable
end

function generate_quarterly_number_of_transactions(adf, mdf)
    # since we will organize the table in quarters, we don't need the last hanging 1 or 2 steps
    maxRelevantStep = Int(floor(NUMBER_OF_STEPS/3)) * 3

    # 
    finalTable = vcat([["-"]], [Any[string(location)] for location in HOUSE_LOCATION_INSTANCES])


    currentQuarter = 1
    currentYear = 2021
    currentQuarterTransactions = Dict(location => 0 for location in HOUSE_LOCATION_INSTANCES)
    for i in 1:maxRelevantStep
        for location in HOUSE_LOCATION_INSTANCES
            for transaction in mdf.transactions_per_region[i][location]
                currentQuarterTransactions[location] += 1
            end
        end
        if i % 3 == 0
            push!(finalTable[1], "$(currentYear)Q$(currentQuarter)")
            for location in HOUSE_LOCATION_INSTANCES
                push!(finalTable[locationToIndex[location]], Int64(round(currentQuarterTransactions[location] / MODEL_SCALE)))
                currentQuarterTransactions[location] = 0
            end
            currentQuarter += 1
        end
        if i % 12 == 0
            currentQuarter = 1
            currentYear += 1
        end
    end
    return finalTable
end

function generate_quarterly_number_of_new_contracts(adf, mdf)
    # since we will organize the table in quarters, we don't need the last hanging 1 or 2 steps
    maxRelevantStep = Int(floor(NUMBER_OF_STEPS/3)) * 3

    # 
    finalTable = vcat([["-"]], [Any[string(location)] for location in HOUSE_LOCATION_INSTANCES])


    currentQuarter = 1
    currentYear = 2021
    currentQuarterTransactions = Dict(location => 0 for location in HOUSE_LOCATION_INSTANCES)
    for i in 1:maxRelevantStep
        for location in HOUSE_LOCATION_INSTANCES
            for transaction in mdf.rents_per_region[i][location]
                currentQuarterTransactions[location] += 1
            end
        end
        if i % 3 == 0
            push!(finalTable[1], "$(currentYear)Q$(currentQuarter)")
            for location in HOUSE_LOCATION_INSTANCES
                push!(finalTable[locationToIndex[location]], Int64(round(currentQuarterTransactions[location] / MODEL_SCALE)))
                currentQuarterTransactions[location] = 0
            end
            currentQuarter += 1
        end
        if i % 12 == 0
            currentQuarter = 1
            currentYear += 1
        end
    end
    return finalTable
end

function generate_annually_scalled_number_of_new_contracts(adf, mdf)
    # since we will organize the table in quarters, we don't need the last hanging 1 or 2 steps
    maxRelevantStep = Int(floor(NUMBER_OF_STEPS/12)) * 12

    # 
    finalTable = vcat([["-"]], [Any[string(location)] for location in HOUSE_LOCATION_INSTANCES])


    currentYear = 2021
    currentYearTransactions = Dict(location => 0 for location in HOUSE_LOCATION_INSTANCES)
    for i in 1:maxRelevantStep
        for location in HOUSE_LOCATION_INSTANCES
            for transaction in mdf.rents_per_region[i][location]
                currentYearTransactions[location] += 1
            end
        end
        if i % 12 == 0
            push!(finalTable[1], "$(currentYear)")
            for location in HOUSE_LOCATION_INSTANCES
                push!(finalTable[locationToIndex[location]], Int64(round(currentYearTransactions[location] / MODEL_SCALE)))
                currentYearTransactions[location] = 0
            end
            currentYear += 1
        end
    end
    return finalTable
end

function convertCommaToSemiCollon(filename)
    content = ""
    open(filename, "r") do file
        content = read(file)
    end
    content = replace(content, "," => ";")
    open(filename, "w") do file
        write(file, content)
    end
end

function convertPointToComma(filename)
    content = ""
    open(filename, "r") do file
        content = read(file)
    end
    content = replace(content, "." => ",")
    open(filename, "w") do file
        write(file, content)
    end
end

function writeToCsv(filename, data)
    open(filename, "w") do file
        write(file, exportToCsv(data))
    end
end

function exportToCsv(vv)
    result = ""
    for v in vv
        for value in v
            result *= string(value) * ","
        end
        result *= "\n"
    end
    return result
end

function generate_demographic_table(adf, mdf)

    births_merged = Int32[]
    deaths_merged = Int32[]
    for step in eachindex(mdf.births)
        push!(births_merged, sum([mdf.births[step][location] for location in HOUSE_LOCATION_INSTANCES]))
        push!(deaths_merged, sum([mdf.deaths[step][location] for location in HOUSE_LOCATION_INSTANCES]))
    end

    breakups = mdf.breakups
    n_of_households = mdf.n_of_households
    finalTable = Any[Any["Year", "Birth Rate", "Mortality Rate", "Divorces"]]
    startingYear = 2021
    currentYear = startingYear
    cummulativeBirthRate = 0
    cummulativeDeathRate = 0
    cummulativeDivorceRate = 0
    for step in 1:length(adf.step)
        cummulativeBirthRate += (births_merged[step] / n_of_households[step]) * 1000
        cummulativeDeathRate += (deaths_merged[step] / n_of_households[step]) * 1000
        cummulativeDivorceRate += (breakups[step] / n_of_households[step])* 1000
        if step % 12 == 0
            push!(finalTable, Any[])
            push!(finalTable[lastindex(finalTable)], currentYear)
            push!(finalTable[lastindex(finalTable)], cummulativeBirthRate)
            push!(finalTable[lastindex(finalTable)], cummulativeDeathRate)
            push!(finalTable[lastindex(finalTable)], cummulativeDivorceRate)
            currentYear += 1
            cummulativeBirthRate = 0
            cummulativeDeathRate = 0
            cummulativeDivorceRate = 0
        end
    end
    return finalTable
end