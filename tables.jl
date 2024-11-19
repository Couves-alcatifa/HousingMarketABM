locationToIndex = Dict(location => 2 for location in instances(HouseLocation))
# this function will generate a table with the house prices for each quarter, in each region
function generate_houses_prices_table(adf, mdf)
    # since we will organize the table in quarters, we don't need the last hanging 1 or 2 steps
    maxRelevantStep = Int(floor(NUMBER_OF_STEPS/3)) * 3

    # 
    finalTable = vcat([["-"]], [Any[string(location)] for location in instances(HouseLocation)])


    currentQuarter = 1
    currentYear = 2021
    currentQuarterTransactions = Dict(location => [] for location in instances(HouseLocation))
    for i in 1:maxRelevantStep
        for location in instances(HouseLocation)
            for transaction in mdf.transactions_per_region[i][location]
                push!(currentQuarterTransactions[location], transaction.price / transaction.area)
            end
        end
        if i % 3 == 0
            push!(finalTable[1], "$(currentYear)Q$(currentQuarter)")
            for location in instances(HouseLocation)
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
    print("Final Table: \n$(finalTable)")
    return finalTable
end

function generate_rent_prices_table(adf, mdf)
    # since we will organize the table in quarters, we don't need the last hanging 1 or 2 steps
    maxRelevantStep = Int(floor(NUMBER_OF_STEPS/3)) * 3

    # 
    finalTable = vcat([["-"]], [Any[string(location)] for location in instances(HouseLocation)])


    currentQuarter = 1
    currentYear = 2021
    currentQuarterTransactions = Dict(location => [] for location in instances(HouseLocation))
    for i in 1:maxRelevantStep
        for location in instances(HouseLocation)
            for transaction in mdf.rents_per_region[i][location]
                push!(currentQuarterTransactions[location], transaction.price / transaction.area)
            end
        end
        if i % 3 == 0
            push!(finalTable[1], "$(currentYear)Q$(currentQuarter)")
            for location in instances(HouseLocation)
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