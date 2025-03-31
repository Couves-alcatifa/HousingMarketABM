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

@enum SizeInterval begin
    LessThan50 = 50
    LessThan75 = 75
    LessThan125 = 125
    More = 1000
end

function get_size_interval_legend(size_interval)
    if size_interval == LessThan50
        return "Smaller than 50m2"
    elseif size_interval == LessThan75
        return "Smaller than 75m2"
    elseif size_interval == LessThan125
        return "Smaller than 125m2"
    else
        return "Bigger than 125m2"
    end
end

# Highly influences price, without big changes in geographical location
@enum HouseLocationType begin
    SocialNeighbourhood = 1
    NotSocialNeighbourhood = 2
end
mutable struct House
    area::UInt16
    location::HouseLocation
    locationType::HouseLocationType
    maintenanceLevel::Float64 # 0..1
    percentile::Int64
end
function House(area::UInt16, location::HouseLocation, locationType::HouseLocationType, maintenanceLevel::Float64)
    return House(area, location, locationType, maintenanceLevel, rand(1:100))
end

mutable struct Mortgage
    intialValue::Float64
    valueInDebt::Float64
    maturity::Int # unused, this should be enhanced...
    duration::UInt16 # months
end

mutable struct Contract
    landlordId::Int
    tenantId::Int
    house::House
    monthlyPayment::Float64
end

@multiagent :opt_speed struct MyMultiAgent(NoSpaceAgent)
    @subagent struct Household
        wealth::Float64
        age::Int64
        size::Int64
        houses::Array{House}
        percentile::Int64
        mortgages::Array{Mortgage}
        contractsAsLandlord::Array{Contract}
        contractAsTenant #::Contract Nothing is no contract
        wealthInHouses::Float64
        residencyZone::HouseLocation
        homelessTime::Int64 # not really meant to represent homeless people, just to lower the house expectations as it struggles to find housing 
        unemployedTime::Int64
        houseRequirements
    end
    
    @subagent struct Company
        n_of_employees::UInt16
    end
end

mutable struct HouseRequirements
    area
    percentile
end

mutable struct NonResident
    id::Int64
    wealth::Float64
    age::Int64
    size::Int64
    houses::Array{House}
    percentile::Int64
    mortgages::Array{Mortgage}
    contractsAsLandlord::Array{Contract}
    contractAsTenant #::Contract Nothing is no contract
    wealthInHouses::Float64
    residencyZone::HouseLocation
    homelessTime::Int64 # not really meant to represent homeless people, just to lower the house expectations as it struggles to find housing 
    unemployedTime::Int64 # not really meant to represent homeless people, just to lower the house expectations as it struggles to find housing 
end

mutable struct Inheritage
    houses::Array{House}
    wealth::Float64
    mortgages::Array{Mortgage}
    # characteristics of the household maybe?
    percentile::Int64
end


mutable struct Transaction
    area
    price
    location
    percentile
    sellerId
    demandType
    timeInMarket
end

@enum DemandType begin
    Regular = 1
    ForRental = 2
    ForInvestment = 3
    NonResidentDemand = 4
end

mutable struct Bid
    value::Float64
    householdId::Int
    type::DemandType
end

mutable struct HouseSupply
    house::House
    price::Float64
    bids::Array{Bid}
    sellerId::Int
    maxConsumerSurplus
    shouldPayAddedValue::Bool
    timeInMarket::Int
end

function HouseSupply(house, price, bids, sellerId; shouldPayAddedValue = false, timeInMarket = 0)
    return HouseSupply(house, price, bids, sellerId, -Inf, shouldPayAddedValue, timeInMarket)
end

mutable struct SupplyMatch
    supply::HouseSupply
end



mutable struct HouseDemand
    householdId::Int
    supplyMatches::Array{SupplyMatch}
    type::DemandType
end


mutable struct HouseMarket
    supply::Array{HouseSupply}
    demand::Array{HouseDemand}
end

mutable struct RentalSupply
    house::House
    monthlyPrice::Float64
    sellerId::Int
    bids::Array{Bid}
    maxConsumerSurplus
    timeInMarket::Int
end

function RentalSupply(house, price, sellerId, bids ; timeInMarket = 0)
    return RentalSupply(house, price, sellerId, bids, -Inf, timeInMarket)
end

mutable struct RentalSupplyMatch
    supply::RentalSupply
end

mutable struct RentalDemand
    householdId::Int
    supplyMatches::Array{RentalSupplyMatch}
end


mutable struct RentalMarket
    supply::Array{RentalSupply}
    demand::Array{RentalDemand}
end

mutable struct Government
    wealth::Float64
    irs
    vat
    subsidyRate::Float64
end

mutable struct Bank
    wealth::Float64
    interestRate::Float64
    ltv::Float64
    dsti::Float64
end

mutable struct PendingConstruction
    time::Int # time that has passed since the start of the construction
    permitTime::Int # total real time that will take
    constructionTime::Int # total real time that will take
    house::House
end

mutable struct PendingRenovation
    time::Int # time that has passed since the start of the renovation
    renovationTime::Int # total real time that will take
    house::House
    household
    type
end

mutable struct ConstructionSector
    wealth::Float64
    housesInConstruction # dict of dicts with arrays of pending constructions per region/size_interval
    mortgages::Array{Mortgage}
    constructionGoals # simillar to housesInConstruction but the values are floats with the amount of houses that we want to build
    pendingRenovations::Array{PendingRenovation}
end

mutable struct HouseholdInfo #TODO: drop this
    wealth::Float64
    size
end

mutable struct HouseInfo
    lastRent
    purchasePrice
    renovationCosts
end

@enum BucketKey begin
    smaller_than_50 = 1
    smaller_than_90 = 2
    smaller_than_120 = 3
    bigger_than_120 = 4
end

@enum ForeignCountry begin
    Brasil = 1
    Ucrania = 2
    CaboVerde = 3
    Romenia = 4
    Angola = 5
    GuineBissau = 6
    ReinoUnido = 7
    Moldavia = 8
    China = 9
    SaoTomeEPrincipe = 10
end
mutable struct BucketTransaction
    area
    price
    percentile
    timeInMarket
end