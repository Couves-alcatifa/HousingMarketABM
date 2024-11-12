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
        greediness::Float64
    end
    
    @subagent struct Company
        n_of_employees::UInt16
    end
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
end

@enum DemandType begin
    Regular = 1
    ForRental = 2
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

mutable struct ConstructionSector
    wealth::Float64
    housesInConstruction # dict of dicts with arrays of pending constructions per region/size_interval
    mortgages::Array{Mortgage}
    constructionGoals # simillar to housesInConstruction but the values are floats with the amount of houses that we want to build
end

mutable struct HouseholdInfo #TODO: drop this
    wealth::Float64
    size
end

mutable struct HouseInfo
    lastRent
    purchasePrice
end

@enum BucketKey begin
    smaller_than_50 = 1
    smaller_than_90 = 2
    smaller_than_120 = 3
    bigger_than_120 = 4
end
