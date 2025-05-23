using Distributions
# @enum HouseLocation begin
#     Amadora = 1
#     Cascais = 2
#     Lisboa = 3
#     Loures = 4
#     Mafra = 5
#     Odivelas = 6
#     Oeiras = 7
#     Sintra = 8
#     VilaFrancaDeXira = 9
#     Alcochete = 10
#     Almada = 11
#     Barreiro = 12
#     Moita = 13
#     Montijo = 14
#     Palmela = 15
#     Seixal =  16
#     Sesimbra = 17
#     Setubal = 18
# end

# adjacentZones = Dict(
#     Amadora          => [Odivelas, Sintra, Oeiras, Lisboa],
#     Cascais          => [Sintra, Oeiras],
#     Lisboa           => [Odivelas, Amadora, Oeiras, Loures],
#     Loures           => [Odivelas, Sintra, Mafra, Lisboa, VilaFrancaDeXira],
#     Mafra            => [Sintra, Loures],
#     Odivelas         => [Odivelas, Sintra, Oeiras, Lisboa],
#     Oeiras           => [Cascais, Sintra, Amadora, Lisboa],
#     Sintra           => [Odivelas, Sintra, Oeiras, Amadora, Cascais, Mafra, Loures],
#     VilaFrancaDeXira => [Loures],
#     Alcochete        => [Montijo, Palmela],
#     Almada           => [Seixal, Sesimbra],
#     Barreiro         => [Moita, Montijo, Seixal, Setubal, Sesimbra],
#     Moita            => [Montijo, Barreiro, Palmela, Setubal],
#     Montijo          => [Palmela, Alcochete, Moita, Barreiro],
#     Palmela          => [Montijo, Alcochete, Setubal, Moita, Barreiro],
#     Seixal           => [Almada, Barreiro, Sesimbra],
#     Sesimbra         => [Setubal, Seixal, Almada, Barreiro],
#     Setubal          => [Sesimbra, Barreiro, Palmela]
# )


# CONSUMER_SURPLUS_MIN = 0.85
# CONSUMER_SURPLUS_MAX = 1.10
# CONSUMER_SURPLUS_MIN_FOR_RENT = 0.85
# CONSUMER_SURPLUS_MAX_FOR_RENT = 1.10

# function calculateConsumerSurplusAddedValue(consumerSurplus)
#     return map_value(consumerSurplus, -30.0, 39.0, CONSUMER_SURPLUS_MIN, CONSUMER_SURPLUS_MAX)
# end

# function calculateConsumerSurplusAddedValueForRent(consumerSurplus)
#     return map_value(consumerSurplus, -30.0, 39.0, CONSUMER_SURPLUS_MIN_FOR_RENT, CONSUMER_SURPLUS_MAX_FOR_RENT)
# end

function map_value(x, in_min, in_max, out_min, out_max)::Float64
    return out_min + (x - in_min) * (out_max - out_min) / (in_max - in_min)
end

# function calculateConsumerSurplus(house_percentile, house_area, household_size, homelessTime, houseLocation, householdLocation)
#     percentileFactor = map_value(house_percentile, 1.0, 100.0, 1.0, 8.0) 
#     percentileFactor *= (0.8 + rand() * 0.4)

#     areaPerPerson = (house_area /  household_size)
#     if areaPerPerson > 60
#         areaPerPerson = 60
#     end
#     sizeFactor = map_value(areaPerPerson, 2.0, 60.0, -15.0, 15.0)
#     sizeFactor *= (0.8 + rand() * 0.4) 

#     zoneFactor = -4
#     if householdLocation == houseLocation
#         zoneFactor = 4
#     elseif houseLocation in adjacentZones[householdLocation]
#         zoneFactor = 0
#     end

#     desperationFactor = homelessTime * 2 - 12

#     if desperationFactor > 24
#         desperationFactor = 24
#     end

#     println("house_percentile = $house_percentile")
#     println("house_area = $house_area")
#     println("household_size = $household_size")
#     println("homelessTime = $homelessTime")
#     println("houseLocation = $houseLocation")
#     println("householdLocation = $householdLocation")
#     println("result = $(calculateConsumerSurplusAddedValue(percentileFactor + sizeFactor + zoneFactor + desperationFactor))")
#     return 
# end

# calculateConsumerSurplus(70, 70, 2, 0, Lisboa, Oeiras)
# calculateConsumerSurplus(70, 70, 2, 10, Lisboa, Oeiras)
# calculateConsumerSurplus(70, 70, 2, 24, Lisboa, Oeiras)
# calculateConsumerSurplus(70, 70, 2, 90, Lisboa, Oeiras)
# calculateConsumerSurplus(30, 30, 2, 24, Lisboa, Oeiras)

function map_value(x, in_min, in_max, out_min, out_max)::Float64
    return out_min + (x - in_min) * (out_max - out_min) / (in_max - in_min)
end

function map_value_sqrt(x, in_min, in_max, out_min, out_max)::Float64
    return out_min + (x - in_min)^2 * (out_max - out_min) / (in_max - in_min)^2
end

const CONSUMER_SURPLUS_MIN = 0.75
const CONSUMER_SURPLUS_MAX = 1.15

function calculateConsumerSurplus(house_percentile, house_area, household_size, homelessTime)
    println("house_percentile, house_area, household_size, homelessTime = $house_percentile, $house_area, $household_size, $homelessTime")
    if homelessTime > 24
        homelessTime = 24
    end
    percentileFactor = map_value_sqrt(house_percentile, 1.0, 100.0, 1.0, 30.0) 
    # percentileFactor = rand(Normal(percentileFactor, percentileFactor * 0.1))

    areaPerPerson = (house_area /  household_size)
    if areaPerPerson > 40
        areaPerPerson = 40
    end
    sizeFactor = map_value_sqrt(areaPerPerson, 10.0, 40.0, 1.0, 30.0)
    # sizeFactor = rand(Normal(sizeFactor, sizeFactor * 0.1)) 

    desperationFactor = map_value(homelessTime + 1, 1.0, 24.0, 1.0, 30.0)
    # desperationFactor = rand(Normal(desperationFactor, desperationFactor * 0.15)) 

    consumerSurplus = ((percentileFactor^(1/3)) * (sizeFactor^(1/3)) * (desperationFactor^(1/3)))
    if consumerSurplus > 9
        consumerSurplus = 9 + (consumerSurplus - 9) ^ (1/2)
    end

    if consumerSurplus > 13
        consumerSurplus = 13
    end
    return consumerSurplus 
end

function calculateConsumerSurplusAddedValue(consumerSurplus)
    return map_value(consumerSurplus, 1.0, 13.0, CONSUMER_SURPLUS_MIN, CONSUMER_SURPLUS_MAX)
end


function test(house_percentile, house_area, household_size, homelessTime)
    return calculateConsumerSurplusAddedValue(calculateConsumerSurplus(house_percentile, house_area, household_size, homelessTime))
end

println(test(1, 70, 2, 0))
println("\n\n")
println(test(1, 70, 2, 16))
println("\n\n")
println(test(80, 70, 2, 0))
println("\n\n")
println(test(50, 40, 2, 1))
println("\n\n")
println(test(50, 40, 2, 16))

println("\n\n")
println(test(100, 100, 2, 32))
println("\n\n")
println(test(100, 100, 2, 0))
println("\n\n")
println(test(15, 50, 2, 1))
println("\n\n")
println(test(15, 80, 2, 1))