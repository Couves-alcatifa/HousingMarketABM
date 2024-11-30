@enum HouseLocation begin
    Amadora = 1
    Cascais = 2
    Lisboa = 3
    Loures = 4
    Mafra = 5
    Odivelas = 6
    Oeiras = 7
    Sintra = 8
    VilaFrancaDeXira = 9
    Alcochete = 10
    Almada = 11
    Barreiro = 12
    Moita = 13
    Montijo = 14
    Palmela = 15
    Seixal =  16
    Sesimbra = 17
    Setubal = 18
end

adjacentZones = Dict(
    Amadora          => [Odivelas, Sintra, Oeiras, Lisboa],
    Cascais          => [Sintra, Oeiras],
    Lisboa           => [Odivelas, Amadora, Oeiras, Loures],
    Loures           => [Odivelas, Sintra, Mafra, Lisboa, VilaFrancaDeXira],
    Mafra            => [Sintra, Loures],
    Odivelas         => [Odivelas, Sintra, Oeiras, Lisboa],
    Oeiras           => [Cascais, Sintra, Amadora, Lisboa],
    Sintra           => [Odivelas, Sintra, Oeiras, Amadora, Cascais, Mafra, Loures],
    VilaFrancaDeXira => [Loures],
    Alcochete        => [Montijo, Palmela],
    Almada           => [Seixal, Sesimbra],
    Barreiro         => [Moita, Montijo, Seixal, Setubal, Sesimbra],
    Moita            => [Montijo, Barreiro, Palmela, Setubal],
    Montijo          => [Palmela, Alcochete, Moita, Barreiro],
    Palmela          => [Montijo, Alcochete, Setubal, Moita, Barreiro],
    Seixal           => [Almada, Barreiro, Sesimbra],
    Sesimbra         => [Setubal, Seixal, Almada, Barreiro],
    Setubal          => [Sesimbra, Barreiro, Palmela]
)


CONSUMER_SURPLUS_MIN = 0.85
CONSUMER_SURPLUS_MAX = 1.10
CONSUMER_SURPLUS_MIN_FOR_RENT = 0.85
CONSUMER_SURPLUS_MAX_FOR_RENT = 1.10

function calculateConsumerSurplusAddedValue(consumerSurplus)
    return map_value(consumerSurplus, -30.0, 39.0, CONSUMER_SURPLUS_MIN, CONSUMER_SURPLUS_MAX)
end

function calculateConsumerSurplusAddedValueForRent(consumerSurplus)
    return map_value(consumerSurplus, -30.0, 39.0, CONSUMER_SURPLUS_MIN_FOR_RENT, CONSUMER_SURPLUS_MAX_FOR_RENT)
end

function map_value(x, in_min, in_max, out_min, out_max)::Float64
    return out_min + (x - in_min) * (out_max - out_min) / (in_max - in_min)
end

function calculateConsumerSurplus(house_percentile, house_area, household_size, homelessTime, houseLocation, householdLocation)
    percentileFactor = map_value(house_percentile, 1.0, 100.0, 1.0, 8.0) 
    percentileFactor *= (0.8 + rand() * 0.4)

    areaPerPerson = (house_area /  household_size)
    if areaPerPerson > 60
        areaPerPerson = 60
    end
    sizeFactor = map_value(areaPerPerson, 2.0, 60.0, -15.0, 15.0)
    sizeFactor *= (0.8 + rand() * 0.4) 

    zoneFactor = -4
    if householdLocation == houseLocation
        zoneFactor = 4
    elseif houseLocation in adjacentZones[householdLocation]
        zoneFactor = 0
    end

    desperationFactor = homelessTime - 12

    if desperationFactor > 12
        desperationFactor = 12
    end

    println("house_percentile = $house_percentile")
    println("house_area = $house_area")
    println("household_size = $household_size")
    println("homelessTime = $homelessTime")
    println("houseLocation = $houseLocation")
    println("householdLocation = $householdLocation")
    println("result = $(calculateConsumerSurplusAddedValue(percentileFactor + sizeFactor + zoneFactor + desperationFactor))")
    return 
end

calculateConsumerSurplus(70, 70, 2, 0, Lisboa, Oeiras)
calculateConsumerSurplus(70, 70, 2, 10, Lisboa, Oeiras)
calculateConsumerSurplus(70, 70, 2, 24, Lisboa, Oeiras)
calculateConsumerSurplus(70, 70, 2, 90, Lisboa, Oeiras)
calculateConsumerSurplus(30, 30, 2, 24, Lisboa, Oeiras)