function calculateConsumerSurplus(house_percentile, house_area, household_size)
    percentileMultiplier = house_percentile / 10 # value between 0.1... 10
    percentileMultiplier *= (0.8 + rand() * 0.4) # between 0.8...1.2 

    sizeMultiplier = (house_area /  household_size) - 25
    if sizeMultiplier > 25
        sizeMultiplier = 25 # value between 0... 25
    end
    sizeMultiplier *= (0.8 + rand() * 0.4) # between 0.8...1.2  

    return percentileMultiplier + sizeMultiplier # final value between 0.1... 42
end

# convert a value from 0.7...7.5 to 0.98...1.04
function calculateConsumerSurplusAddedValue(house_percentile, house_area, household_size)
    consumerSurplus = calculateConsumerSurplus(house_percentile, house_area, household_size)
    result = consumerSurplus
    println("$house_percentile, $house_area, $household_size = $result")
    println(map_value(consumerSurplus, 0.0, 42.0, 0.94, 1.05))
end

function map_value(x::Float64, in_min::Float64, in_max::Float64, out_min::Float64, out_max::Float64)::Float64
    return out_min + (x - in_min) * (out_max - out_min) / (in_max - in_min)
end

function calculateProbabilityOfAcceptingBid(bid, askPrice)
    ratio = bid / askPrice
    return map_value(ratio, 0.95, 1.0, 0.2, 1.0)
end

calculateConsumerSurplusAddedValue(1, 200, 1)
calculateConsumerSurplusAddedValue(100, 200, 1)
calculateConsumerSurplusAddedValue(60, 75, 2)
calculateConsumerSurplusAddedValue(1, 50, 4)
calculateConsumerSurplusAddedValue(100, 50, 2)