locationToIndex = Dict(HOUSE_LOCATION_INSTANCES[idx] => idx + 1 for idx in eachindex(HOUSE_LOCATION_INSTANCES))

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
    print("Final Table: \n$(finalTable)")
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
                push!(finalTable[locationToIndex[location]], currentQuarterTransactions[location])
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

    births = mdf.births
    deaths = mdf.deaths
    breakups = mdf.breakups
    n_of_households = mdf.n_of_households
    finalTable = Any[Any["Year", "Birth Rate", "Mortality Rate", "Divorces"]]
    startingYear = 2021
    currentYear = startingYear
    cummulativeBirthRate = 0
    cummulativeDeathRate = 0
    cummulativeDivorceRate = 0
    for step in 1:length(adf.step)
        cummulativeBirthRate += (births[step] / n_of_households[step]) * 1000
        cummulativeDeathRate += (deaths[step] / n_of_households[step]) * 1000
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