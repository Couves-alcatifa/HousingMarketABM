FOURTH_QUINTILE_INCOME_IN_Amadora = 20882 / 12

function map_value(x, in_min, in_max, out_min, out_max)::Float64
    return out_min + (x - in_min) * (out_max - out_min) / (in_max - in_min)
end

function calculateSalary()
    percentile = 87
    salaryAgeMultiplier = map_value(57, 20, 70, 0.7, 1.5)
    println("salaryAgeMultiplier = $salaryAgeMultiplier")
    if 57 > 70
        salaryAgeMultiplier = 0.75
    end
        base = eval(Symbol("FOURTH_QUINTILE_INCOME_IN_Amadora"))
        println("base = $base")
        range = base * 1.5 * salaryAgeMultiplier
        println("range = $range")
        salary = base + range * (percentile / 100 - 0.8) * 5
        println("salary = $salary")
    if (1 == 1)
        return salary * 1.0 * 1.15 
    else
        return salary * 2 * 1.0 * 1.15
    end
end

println(calculateSalary())