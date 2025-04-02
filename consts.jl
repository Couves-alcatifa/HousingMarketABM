include("types.jl")
include("calibrationTable.jl")
include("valueConverter.jl")
include("policies.jl")

const NUMBER_OF_STEPS = 36
const ORIGINAL_YEAR = 2021
const ORIGINAL_MONTH = 1
const CURRENT_YEAR = 2021
const CURRENT_MONTH = 1
const CRASH_SCENARIO = false

const STARTING_GOV_WEALTH_PER_CAPITA = 100000.0
const STARTING_COMPANY_WEALTH_PER_CAPITA = 60000.0
const STARTING_BANK_WEALTH_PER_CAPITA = 67000.0
const STARTING_CONSTRUCTION_SECTOR_WEALTH_PER_CAPITA = 0000.0


const THEORETICAL_NUMBER_OF_HOUSES_MAP = Dict(
    Amadora => 73513,
    Cascais => 86465,
    Lisboa => 242044,
    Loures =>  81552,
    Mafra => 33152,
    Odivelas => 60119,
    Oeiras => 73013,
    Sintra => 153147,
    VilaFrancaDeXira => 55641,
    Alcochete => 7411,
    Almada => 75485,
    Barreiro => 34346,
    Moita => 27489,
    Montijo => 22104,
    Palmela => 26622,
    Seixal => 67534,
    Sesimbra => 20557,
    Setubal => 51169,
)

include("scope.jl")

# taken from Portugal's construction GDB (2374,12 milhões de euros)
# divided by the population of Portugal (10,580,000)
# https://pt.tradingeconomics.com/portugal/gdp-from-construction
const MAX_CONSTRUCTION_SECTOR_DEBT = 224.3969 * NUMBER_OF_HOUSEHOLDS

const STARTING_GOV_WEALTH = STARTING_GOV_WEALTH_PER_CAPITA * NUMBER_OF_HOUSEHOLDS
const STARTING_COMPANY_WEALTH = STARTING_COMPANY_WEALTH_PER_CAPITA * NUMBER_OF_HOUSEHOLDS
const STARTING_BANK_WEALTH = STARTING_BANK_WEALTH_PER_CAPITA * NUMBER_OF_HOUSEHOLDS
const STARTING_CONSTRUCTION_SECTOR_WEALTH = STARTING_CONSTRUCTION_SECTOR_WEALTH_PER_CAPITA * NUMBER_OF_HOUSEHOLDS

### CRASH_SCENARIO
# const STARTING_INTEREST_RATE = CURRENT_YEAR == 2003 ? 0.0504 : 0.0377
# const STARTING_UNEMPLOYMENT_RATE = CURRENT_YEAR == 2003 ? 0.062 : 0.129
# const UNEMPLOYMENT_SALARY_DECREASE = CURRENT_YEAR == 2003 ? 0.50 : 0.65
const UNEMPLOYMENT_SALARY_DECREASE = 0.65
const STARTING_INTEREST_RATE = 0.0081
const STARTING_UNEMPLOYMENT_RATE = 0.065

const LTV = 0.85
const DSTI = 0.35
const IRS = 0.2
const VAT = 0.15
const SOCIAL_SECURITY_TAX = 0.11
const MAX_EFFORT_FOR_RENT = 0.50
const CONSTRUCTION_DELAY_MIN = (ConstructionLicensingSimplification in CURRENT_POLICIES 
                                ? REDUCED_PERMIT_TIME_MIN 
                                : 24)
const CONSTRUCTION_DELAY_MAX = (ConstructionLicensingSimplification in CURRENT_POLICIES
                                ? REDUCED_PERMIT_TIME_MAX
                                : 48)
const CONSTRUCTION_VAT = ConstructionVatReduction in CURRENT_POLICIES ? REDUCED_VAT : 0.23

# based on: https://www.habitissimo.pt/orcamentos/construcao-de-casa
const CONSTRUCTION_COSTS_MIN = adjust_value_to_inflation(1200 / (1 + CONSTRUCTION_VAT)) # to be multiplied by the area of the house
const CONSTRUCTION_COSTS_MAX = adjust_value_to_inflation(1800 / (1 + CONSTRUCTION_VAT)) # to be multiplied by the area of the house

const CONSTRUCTION_TIME_MIN = 12
const CONSTRUCTION_TIME_MAX = 18

const PROJECT_COST_MULTIPLIER = 1.1
const RENT_TAX = 0.25
const RENTS_INCREASE_CEILLING = 1.02
const EXPECTED_RENOVATION_RENTABILITY = 0.2 # 20% of the investment
const ADDED_VALUE_TAXABLE_PERCENTAGE = 0.5
const RECENTLY_BUILD_MINIMUM_PERCENTILE = 90

const INITIAL_MARKET_PRICE_CUT = Dict(
    Amadora => 1.0,
    Cascais => 1.0,
    Lisboa => 1.0,
    Loures => 1.0,
    Mafra => 1.0,
    Odivelas => 1.0,
    Oeiras => 1.0,
    Sintra => 1.0,
    VilaFrancaDeXira => 1.0,
    Alcochete => 1.0,
    Almada => 1.0,
    Barreiro => 1.0,
    Moita => 1.0,
    Montijo => 1.0,
    Palmela => 1.0,
    Seixal => 1.0,
    Sesimbra => 1.0,
    Setubal => 1.0,
)

const INITIAL_RENTAL_MARKET_PRICE_CUT = Dict(
    Amadora => 1.0,
    Cascais => 1.0,
    Lisboa => 1.0,
    Loures => 1.0,
    Mafra => 1.0,
    Odivelas => 1.0,
    Oeiras => 1.0,
    Sintra => 1.0,
    VilaFrancaDeXira => 1.0,
    Alcochete => 1.0,
    Almada => 1.0,
    Barreiro => 1.0,
    Moita => 1.0,
    Montijo => 1.0,
    Palmela => 1.0,
    Seixal => 1.0,
    Sesimbra => 1.0,
    Setubal => 1.0,
)

const GREEDINESS_AVERAGE = Dict(
    Amadora => 1.0,
    Cascais => 1.0,
    Lisboa => 1.0,
    Loures => 1.0,
    Mafra => 1.0,
    Odivelas => 1.0,
    Oeiras => 1.0,
    Sintra => 1.0,
    VilaFrancaDeXira => 1.0,
    Alcochete => 1.0,
    Almada => 1.0,
    Barreiro => 1.0,
    Moita => 1.0,
    Montijo => 1.0,
    Palmela => 1.0,
    Seixal => 1.0,
    Sesimbra => 1.0,
    Setubal => 1.0,
)

const GREEDINESS_STDEV = Dict(
    Amadora => 0.015,
    Cascais => 0.015,
    Lisboa => 0.015,
    Loures => 0.015,
    Mafra => 0.015,
    Odivelas => 0.015,
    Oeiras => 0.015,
    Sintra => 0.015,
    VilaFrancaDeXira => 0.015,
    Alcochete => 0.015,
    Almada => 0.015,
    Barreiro => 0.015,
    Moita => 0.015,
    Montijo => 0.015,
    Palmela => 0.015,
    Seixal => 0.015,
    Sesimbra => 0.015,
    Setubal => 0.015,
)

const GREEDINESS_AVERAGE_FOR_RENTAL = Dict(
    Amadora => 1.00,
    Cascais => 1.00,
    Lisboa => 1.00,
    Loures => 1.00,
    Mafra => 1.00,
    Odivelas => 1.00,
    Oeiras => 1.00,
    Sintra => 1.00,
    VilaFrancaDeXira => 1.00,
    Alcochete => 1.00,
    Almada => 1.00,
    Barreiro => 1.00,
    Moita => 1.00,
    Montijo => 1.00,
    Palmela => 1.00,
    Seixal => 1.00,
    Sesimbra => 1.00,
    Setubal => 1.00,
)

const GREEDINESS_STDEV_FOR_RENTAL = Dict(
    Amadora => 0.015,
    Cascais => 0.015,
    Lisboa => 0.015,
    Loures => 0.015,
    Mafra => 0.015,
    Odivelas => 0.015,
    Oeiras => 0.015,
    Sintra => 0.015,
    VilaFrancaDeXira => 0.015,
    Alcochete => 0.015,
    Almada => 0.015,
    Barreiro => 0.015,
    Moita => 0.015,
    Montijo => 0.015,
    Palmela => 0.015,
    Seixal => 0.015,
    Sesimbra => 0.015,
    Setubal => 0.015,
)

const EXTRA_CONSUMER_SURPLUS_PER_REGION = Dict(
    Amadora => 0.0,
    Cascais => 0.0,
    Lisboa => 0.0,
    Loures => 0.0,
    Mafra => 0.0,
    Odivelas => 0.0,
    Oeiras => 0.0,
    Sintra => 0.0,
    VilaFrancaDeXira => 0.0,
    Alcochete => 0.0,
    Almada => 0.0,
    Barreiro => 0.0,
    Moita => 0.0,
    Montijo => 0.0,
    Palmela => 0.0,
    Seixal => 0.0,
    Sesimbra => 0.0,
    Setubal => 0.0,
)

const BIRTH_INCREASE_MULTIPLIER = 1.0

const CONSUMER_SURPLUS_MIN = 0.75
const CONSUMER_SURPLUS_MAX = 1.10
const CONSUMER_SURPLUS_MIN_FOR_RENT = 0.75
const CONSUMER_SURPLUS_MAX_FOR_RENT = 1.10
const SALES_PERCENTILE_MULTIPLIER = 0.85

const CONSTRUCTION_SECTOR_MARKUP = Dict(
    Amadora => 1.2,
    Cascais => 1.2,
    Lisboa => 1.2,
    Loures => 1.2,
    Mafra => 1.2,
    Odivelas => 1.2,
    Oeiras => 1.2,
    Sintra => 1.2,
    VilaFrancaDeXira => 1.2,
    Alcochete => 1.2,
    Almada => 1.2,
    Barreiro => 1.2,
    Moita => 1.2,
    Montijo => 1.2,
    Palmela => 1.2,
    Seixal => 1.2,
    Sesimbra => 1.2,
    Setubal => 1.2,
)


const TotalTheoreticalNumberOfHouses = sum([THEORETICAL_NUMBER_OF_HOUSES_MAP[location] for location in HOUSE_LOCATION_INSTANCES])

const NUMBER_OF_HOUSES=NUMBER_OF_HOUSEHOLDS

# TODO: region hack
# MODEL_SCALE = NUMBER_OF_HOUSES / TheoreticalNumberOfHousesInLisboa
const MODEL_SCALE = NUMBER_OF_HOUSES / TotalTheoreticalNumberOfHouses
# const MAX_BUCKET_SIZE = Int64(round(200 * MODEL_SCALE))
const MAX_BUCKET_SIZE = Dict(location => Int64(round(THEORETICAL_NUMBER_OF_HOUSES_MAP[location] * 0.01 * MODEL_SCALE)) for location in HOUSE_LOCATION_INSTANCES)
const N_OF_TRANS_MINIMUM = Int64(round(30 * MODEL_SCALE))
const MINIMUM_NUMBER_OF_TRANSACTIONS_IN_BUCKETS = N_OF_TRANS_MINIMUM > 5 ? N_OF_TRANS_MINIMUM : 5  

# NUMBER_OF_HOUSES_IN_GrandeLisboa = (TheoreticalNumberOfHousesInGrandeLisboa / TotalTheoreticalNumberOfHouses) * NUMBER_OF_HOUSES 
const NUMBER_OF_HOUSES_MAP = Dict(
    Amadora => THEORETICAL_NUMBER_OF_HOUSES_MAP[Amadora] * MODEL_SCALE,
    Cascais => THEORETICAL_NUMBER_OF_HOUSES_MAP[Cascais] * MODEL_SCALE,
    Lisboa => THEORETICAL_NUMBER_OF_HOUSES_MAP[Lisboa] * MODEL_SCALE,
    Loures => THEORETICAL_NUMBER_OF_HOUSES_MAP[Loures] * MODEL_SCALE,
    Mafra => THEORETICAL_NUMBER_OF_HOUSES_MAP[Mafra] * MODEL_SCALE,
    Odivelas => THEORETICAL_NUMBER_OF_HOUSES_MAP[Odivelas] * MODEL_SCALE,
    Oeiras => THEORETICAL_NUMBER_OF_HOUSES_MAP[Oeiras] * MODEL_SCALE,
    Sintra => THEORETICAL_NUMBER_OF_HOUSES_MAP[Sintra] * MODEL_SCALE,
    VilaFrancaDeXira => THEORETICAL_NUMBER_OF_HOUSES_MAP[VilaFrancaDeXira] * MODEL_SCALE,
    Alcochete => THEORETICAL_NUMBER_OF_HOUSES_MAP[Alcochete] * MODEL_SCALE,
    Almada => THEORETICAL_NUMBER_OF_HOUSES_MAP[Almada] * MODEL_SCALE,
    Barreiro => THEORETICAL_NUMBER_OF_HOUSES_MAP[Barreiro] * MODEL_SCALE,
    Moita => THEORETICAL_NUMBER_OF_HOUSES_MAP[Moita] * MODEL_SCALE,
    Montijo => THEORETICAL_NUMBER_OF_HOUSES_MAP[Montijo] * MODEL_SCALE,
    Palmela => THEORETICAL_NUMBER_OF_HOUSES_MAP[Palmela] * MODEL_SCALE,
    Seixal => THEORETICAL_NUMBER_OF_HOUSES_MAP[Seixal] * MODEL_SCALE,
    Sesimbra => THEORETICAL_NUMBER_OF_HOUSES_MAP[Sesimbra] * MODEL_SCALE,
    Setubal => THEORETICAL_NUMBER_OF_HOUSES_MAP[Setubal] * MODEL_SCALE,
)

const FIRST_QUARTILE_RENT_MAP = Dict(
    Amadora => 7.17,
    Cascais => 8.91,
    Lisboa => 9.38,
    Loures => 5.97,
    Mafra => 5.13,
    Odivelas => 6.50,
    Oeiras => 8.57,
    Sintra => 5.81,
    VilaFrancaDeXira => 5.64,
    Alcochete => 5.45,
    Almada => 7.00,
    Barreiro => 6.03,
    Moita => 5.08,
    Montijo => 5.33,
    Palmela => 5.00,
    Seixal => 5.81,
    Sesimbra => 4.97,
    Setubal => 5.40,
)
const FIRST_QUARTILE_RENT_MAP_ADJUSTED = Dict(location => adjust_value_to_inflation(value) for (location, value) in FIRST_QUARTILE_RENT_MAP)

const MEDIAN_RENT_MAP = Dict(
    Amadora => 8.76,
    Cascais => 10.56,
    Lisboa => 11.12,
    Loures => 7.78,
    Mafra => 6.80,
    Odivelas => 8.21,
    Oeiras => 9.86,
    Sintra => 7.25,
    VilaFrancaDeXira => 6.82,
    Alcochete => 6.35,
    Almada => 8.36,
    Barreiro => 6.95,
    Moita => 5.80,
    Montijo => 6.32,
    Palmela => 5.82,
    Seixal => 6.67,
    Sesimbra => 5.95,
    Setubal => 6.67,
)
const MEDIAN_RENT_MAP_ADJUSTED = Dict(location => adjust_value_to_inflation(value) for (location, value) in MEDIAN_RENT_MAP)

const THIRD_QUARTILE_RENT_MAP = Dict(
    Amadora => 10.78,
    Cascais => 13.13,
    Lisboa => 13.79,
    Loures => 9.64,
    Mafra => 8.76,
    Odivelas => 10.00,
    Oeiras => 11.99,
    Sintra => 8.89,
    VilaFrancaDeXira => 8.23,
    Alcochete => 7.61,
    Almada => 10.29,
    Barreiro => 8.29,
    Moita => 7.31,
    Montijo => 7.63,
    Palmela => 7.42,
    Seixal => 8.18,
    Sesimbra => 7.50,
    Setubal => 8.10,
)
const THIRD_QUARTILE_RENT_MAP_ADJUSTED = Dict(location => adjust_value_to_inflation(value) for (location, value) in THIRD_QUARTILE_RENT_MAP)

const FIRST_QUARTILE_SALES_MAP = Dict(
    Amadora => 1408,
    Cascais => 2133,
    Lisboa => 2523,
    Loures => 1403,
    Mafra => 1212,
    Odivelas => 1603,
    Oeiras => 1995,
    Sintra => 1157,
    VilaFrancaDeXira => 1101,
    Alcochete => 1211,
    Almada => 1466,
    Barreiro => 908,
    Moita => 733,
    Montijo => 1023,
    Palmela => 988,
    Seixal => 1117,
    Sesimbra => 1205,
    Setubal => 1014,
)
const FIRST_QUARTILE_SALES_MAP_ADJUSTED = Dict(location => adjust_value_to_inflation(value) for (location, value) in FIRST_QUARTILE_SALES_MAP)

const MEDIAN_SALES_MAP = Dict(
    Amadora => 1723,
    Cascais => 2776,
    Lisboa => 3333,
    Loures => 1820,
    Mafra => 1600,
    Odivelas => 2057,
    Oeiras => 2440,
    Sintra => 1441,
    VilaFrancaDeXira => 1383,
    Alcochete => 1525,
    Almada => 1801,
    Barreiro => 1136,
    Moita => 952,
    Montijo => 1334,
    Palmela => 1198,
    Seixal => 1380,
    Sesimbra => 1456,
    Setubal => 1307,
)
const MEDIAN_SALES_MAP_ADJUSTED = Dict(location => adjust_value_to_inflation(value) for (location, value) in MEDIAN_SALES_MAP)

const THIRD_QUARTILE_SALES_MAP = Dict(
    Amadora => 2060,
    Cascais => 3644,
    Lisboa => 4392,
    Loures => 2296,
    Mafra => 1999,
    Odivelas => 2464,
    Oeiras => 2957,
    Sintra => 1703,
    VilaFrancaDeXira => 1704,
    Alcochete => 2051,
    Almada => 2177,
    Barreiro => 1341,
    Moita => 1190,
    Montijo => 1602,
    Palmela => 1426,
    Seixal => 1667,
    Sesimbra => 1799,
    Setubal => 1610,
)
const THIRD_QUARTILE_SALES_MAP_ADJUSTED = Dict(location => adjust_value_to_inflation(value) for (location, value) in THIRD_QUARTILE_SALES_MAP)

const color_map = Dict(
    Amadora => :red,
    Cascais => :blue,
    Lisboa => :green,
    Loures => :yellow,
    Mafra => :purple,
    Odivelas => :orange,
    Oeiras => :pink,
    Sintra => :brown,
    VilaFrancaDeXira => :cyan,
    Alcochete => :magenta,
    Almada => :lime,
    Barreiro => :navy,
    Moita => :teal,
    Montijo => :olive,
    Palmela => :maroon,
    Seixal => :aqua,
    Sesimbra => :fuchsia,
    Setubal => :gold
)

const sizes_color_map = Dict(
    LessThan50 => :olive,
    LessThan75 => :cyan,
    LessThan125 => :pink,
    More => :gold
)

const Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_1 = 336274
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Alcochete = 1699
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Almada = 22459
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Amadora = 22151
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Barreiro = 10183
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Cascais = 23431
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Lisboa =  85477
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Loures =  20967
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Mafra = 7359
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Moita = 7285
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Montijo = 5440
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Odivelas = 15483
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Oeiras = 22114
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Palmela = 6195
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Seixal = 16387
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Sesimbra = 4636
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Setubal = 13899
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Sintra = 37771
const Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_VilaFrancaDeXira = 13338
const Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_2 = 392111
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Alcochete = 2289
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Almada = 25601
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Amadora = 24547
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Barreiro = 12161
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Cascais = 27793
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Lisboa =  78584
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Loures =  27299
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Mafra = 10276
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Moita = 9270
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Montijo = 7231
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Odivelas = 19776
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Oeiras = 23966
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Palmela = 8843
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Seixal = 23196
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Sesimbra = 6742
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Setubal = 17253
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Sintra = 48985
const Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_VilaFrancaDeXira = 18299
const Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_3 = 238291
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Alcochete = 1675
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Almada = 14318
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Amadora = 14246
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Barreiro = 6769
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Cascais = 17047
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Lisboa =  39037
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Loures =  17089
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Mafra = 7544
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Moita = 5879
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Montijo = 4974
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Odivelas = 12703
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Oeiras = 13479
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Palmela = 5853
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Seixal = 14841
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Sesimbra = 4644
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Setubal = 10598
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Sintra = 34425
const Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_VilaFrancaDeXira = 13170
const Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_4 = 160982
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Alcochete = 1347
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Almada = 9462
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Amadora = 8682
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Barreiro = 3881
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Cascais = 12688
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Lisboa =  26629
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Loures =  11535
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Mafra = 6060
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Moita = 3610
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Montijo = 3277
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Odivelas = 8843
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Oeiras = 9703
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Palmela = 4318
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Seixal = 9630
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Sesimbra = 3378
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Setubal = 6954
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Sintra = 22670
const Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_VilaFrancaDeXira = 8315
const Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_GT_5 = 65326
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Alcochete = 427
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Almada = 3852
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Amadora = 3913
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Barreiro = 1372
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Cascais = 5525
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Lisboa =  12844
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Loures =  4812
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Mafra = 1970
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Moita = 1462
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Montijo = 1233
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Odivelas = 3334
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Oeiras = 3764
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Palmela = 1569
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Seixal = 3615
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Sesimbra = 1164
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Setubal = 2525
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Sintra = 9371
const Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_VilaFrancaDeXira = 2574


const TOTAL_HOUSEHOLDS_WITH_SIZE_1 = Int64(round(MODEL_SCALE * Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_1))

const HOUSEHOLDS_WITH_SIZE_1_MAP = Dict(
    Alcochete => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Alcochete)),
    Almada => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Almada)),
    Amadora => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Amadora)),
    Barreiro => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Barreiro)),
    Cascais => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Cascais)),
    Lisboa => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Lisboa)),
    Loures => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Loures)),
    Mafra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Mafra)),
    Moita => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Moita)),
    Montijo => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Montijo)),
    Odivelas => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Odivelas)),
    Oeiras => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Oeiras)),
    Palmela => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Palmela)),
    Seixal => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Seixal)),
    Sesimbra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Sesimbra)),
    Setubal => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Setubal)),
    Sintra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Sintra)),
    VilaFrancaDeXira => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_VilaFrancaDeXira)),
)

const TOTAL_HOUSEHOLDS_WITH_SIZE_2 = Int64(round(MODEL_SCALE * Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_2))
const HOUSEHOLDS_WITH_SIZE_2_MAP = Dict(
    Alcochete => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Alcochete)),
    Almada => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Almada)),
    Amadora => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Amadora)),
    Barreiro => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Barreiro)),
    Cascais => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Cascais)),
    Lisboa => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Lisboa)),
    Loures => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Loures)),
    Mafra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Mafra)),
    Moita => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Moita)),
    Montijo => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Montijo)),
    Odivelas => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Odivelas)),
    Oeiras => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Oeiras)),
    Palmela => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Palmela)),
    Seixal => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Seixal)),
    Sesimbra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Sesimbra)),
    Setubal => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Setubal)),
    Sintra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Sintra)),
    VilaFrancaDeXira => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_VilaFrancaDeXira)),
)

const TOTAL_HOUSEHOLDS_WITH_SIZE_3 = Int64(round(MODEL_SCALE * Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_3))
const HOUSEHOLDS_WITH_SIZE_3_MAP = Dict(
    Alcochete => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Alcochete)),
    Almada => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Almada)),
    Amadora => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Amadora)),
    Barreiro => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Barreiro)),
    Cascais => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Cascais)),
    Lisboa => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Lisboa)),
    Loures => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Loures)),
    Mafra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Mafra)),
    Moita => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Moita)),
    Montijo => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Montijo)),
    Odivelas => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Odivelas)),
    Oeiras => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Oeiras)),
    Palmela => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Palmela)),
    Seixal => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Seixal)),
    Sesimbra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Sesimbra)),
    Setubal => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Setubal)),
    Sintra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Sintra)),
    VilaFrancaDeXira => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_VilaFrancaDeXira)),
)

const TOTAL_HOUSEHOLDS_WITH_SIZE_4 = Int64(round(MODEL_SCALE * Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_4))
const HOUSEHOLDS_WITH_SIZE_4_MAP = Dict(
    Alcochete => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Alcochete)),
    Almada => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Almada)),
    Amadora => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Amadora)),
    Barreiro => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Barreiro)),
    Cascais => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Cascais)),
    Lisboa => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Lisboa)),
    Loures => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Loures)),
    Mafra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Mafra)),
    Moita => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Moita)),
    Montijo => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Montijo)),
    Odivelas => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Odivelas)),
    Oeiras => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Oeiras)),
    Palmela => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Palmela)),
    Seixal => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Seixal)),
    Sesimbra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Sesimbra)),
    Setubal => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Setubal)),
    Sintra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Sintra)),
    VilaFrancaDeXira => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_VilaFrancaDeXira)),
)

const TOTAL_HOUSEHOLDS_WITH_SIZE_GT_5 = Int64(round(MODEL_SCALE * Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_GT_5))
const HOUSEHOLDS_WITH_SIZE_GT_5_MAP = Dict(
    Alcochete => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Alcochete)),
    Almada => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Almada)),
    Amadora => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Amadora)),
    Barreiro => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Barreiro)),
    Cascais => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Cascais)),
    Lisboa => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Lisboa)),
    Loures => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Loures)),
    Mafra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Mafra)),
    Moita => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Moita)),
    Montijo => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Montijo)),
    Odivelas => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Odivelas)),
    Oeiras => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Oeiras)),
    Palmela => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Palmela)),
    Seixal => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Seixal)),
    Sesimbra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Sesimbra)),
    Setubal => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Setubal)),
    Sintra => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Sintra)),
    VilaFrancaDeXira => Int64(round(MODEL_SCALE * Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_VilaFrancaDeXira)),
)

const HOUSEHOLDS_SIZES_MAP = Dict(
    1 => HOUSEHOLDS_WITH_SIZE_1_MAP,
    2 => HOUSEHOLDS_WITH_SIZE_2_MAP,
    3 => HOUSEHOLDS_WITH_SIZE_3_MAP,
    4 => HOUSEHOLDS_WITH_SIZE_4_MAP,
    5 => HOUSEHOLDS_WITH_SIZE_GT_5_MAP,
)

const HOME_OWNERS_MAP = Dict(
    Alcochete => Int64(round(5085  * MODEL_SCALE)),
    Almada => Int64(round(47380 * MODEL_SCALE)),
    Amadora => Int64(round(44275 * MODEL_SCALE)),
    Barreiro => Int64(round(23487 * MODEL_SCALE)),
    Cascais => Int64(round(56436 * MODEL_SCALE)),
    Lisboa  => Int64(round(121869 * MODEL_SCALE)),
    Loures  => Int64(round(49847 * MODEL_SCALE)),
    Mafra => Int64(round(23259 * MODEL_SCALE)),
    Moita => Int64(round(18879 * MODEL_SCALE)),
    Montijo => Int64(round(14555 * MODEL_SCALE)),
    Odivelas => Int64(round(39445 * MODEL_SCALE)),
    Oeiras => Int64(round(49136 * MODEL_SCALE)),
    Palmela => Int64(round(19771 * MODEL_SCALE)),
    Seixal => Int64(round(50723 * MODEL_SCALE)),
    Sesimbra => Int64(round(15421 * MODEL_SCALE)),
    Setubal => Int64(round(35109 * MODEL_SCALE)),
    Sintra => Int64(round(104302 * MODEL_SCALE)),
    VilaFrancaDeXira => Int64(round(39619 * MODEL_SCALE)),
)

const NOT_HOME_OWNERS_MAP = Dict(
    Alcochete => Int64(round(2326 * MODEL_SCALE)),
    Almada => Int64(round(28105 * MODEL_SCALE)),
    Amadora => Int64(round(29238 * MODEL_SCALE)),
    Barreiro => Int64(round(10859 * MODEL_SCALE)),
    Cascais => Int64(round(30029 * MODEL_SCALE)),
    Lisboa =>  Int64(round(120175 * MODEL_SCALE)),
    Loures =>  Int64(round(31705 * MODEL_SCALE)),
    Mafra => Int64(round(9893 * MODEL_SCALE)),
    Moita => Int64(round(8610 * MODEL_SCALE)),
    Montijo => Int64(round(7549 * MODEL_SCALE)),
    Odivelas => Int64(round(20674 * MODEL_SCALE)),
    Oeiras => Int64(round(23877 * MODEL_SCALE)),
    Palmela => Int64(round(6851 * MODEL_SCALE)),
    Seixal => Int64(round(16811 * MODEL_SCALE)),
    Sesimbra => Int64(round(5136 * MODEL_SCALE)),
    Setubal => Int64(round(16060 * MODEL_SCALE)),
    Sintra => Int64(round(48845 * MODEL_SCALE)),
    VilaFrancaDeXira => Int64(round(16022 * MODEL_SCALE)),
)

const NUMBER_OF_HOUSES_WITH_LT_10_M2_PER_PERSON_MAP = Dict(
    Alcochete => 85 * MODEL_SCALE,
    Almada => 1426 * MODEL_SCALE,
    Amadora => 1664 * MODEL_SCALE,
    Barreiro => 424 * MODEL_SCALE,
    Cascais => 1321 * MODEL_SCALE,
    Lisboa =>  4871 * MODEL_SCALE,
    Loures =>  1798 * MODEL_SCALE,
    Mafra => 358 * MODEL_SCALE,
    Moita => 491 * MODEL_SCALE,
    Montijo => 327 * MODEL_SCALE,
    Odivelas => 1060 * MODEL_SCALE,
    Oeiras => 755 * MODEL_SCALE,
    Palmela => 299 * MODEL_SCALE,
    Seixal => 855 * MODEL_SCALE,
    Sesimbra => 235 * MODEL_SCALE,
    Setubal => 677 * MODEL_SCALE,
    Sintra => 2020 * MODEL_SCALE,
    VilaFrancaDeXira => 612 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LT_15_M2_PER_PERSON_MAP = Dict(
    Alcochete => 146 * MODEL_SCALE,
    Almada => 2020 * MODEL_SCALE,
    Amadora => 2872 * MODEL_SCALE,
    Barreiro => 876 * MODEL_SCALE,
    Cascais => 1822 * MODEL_SCALE,
    Lisboa =>  5975 * MODEL_SCALE,
    Loures =>  2707 * MODEL_SCALE,
    Mafra => 612 * MODEL_SCALE,
    Moita => 902 * MODEL_SCALE,
    Montijo => 448 * MODEL_SCALE,
    Odivelas => 1827 * MODEL_SCALE,
    Oeiras => 1278 * MODEL_SCALE,
    Palmela => 497 * MODEL_SCALE,
    Seixal => 1467 * MODEL_SCALE,
    Sesimbra => 382 * MODEL_SCALE,
    Setubal => 1073 * MODEL_SCALE,
    Sintra => 4352 * MODEL_SCALE,
    VilaFrancaDeXira => 1191 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LT_20_M2_PER_PERSON_MAP = Dict(
    Alcochete => 409 * MODEL_SCALE,
    Almada => 5695 * MODEL_SCALE,
    Amadora => 6960 * MODEL_SCALE,
    Barreiro => 2403 * MODEL_SCALE,
    Cascais => 5454 * MODEL_SCALE,
    Lisboa =>  18229 * MODEL_SCALE,
    Loures =>  6972 * MODEL_SCALE,
    Mafra => 1746 * MODEL_SCALE,
    Moita => 2189 * MODEL_SCALE,
    Montijo => 1319 * MODEL_SCALE,
    Odivelas => 4663 * MODEL_SCALE,
    Oeiras => 4084 * MODEL_SCALE,
    Palmela => 1458 * MODEL_SCALE,
    Seixal => 4299 * MODEL_SCALE,
    Sesimbra => 1170 * MODEL_SCALE,
    Setubal => 3148 * MODEL_SCALE,
    Sintra => 11761 * MODEL_SCALE,
    VilaFrancaDeXira => 3590 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LT_30_M2_PER_PERSON_MAP = Dict(
    Alcochete => 939 * MODEL_SCALE,
    Almada => 11275 * MODEL_SCALE,
    Amadora => 12615 * MODEL_SCALE,
    Barreiro => 5253 * MODEL_SCALE,
    Cascais => 12159 * MODEL_SCALE,
    Lisboa =>  34396 * MODEL_SCALE,
    Loures =>  13502 * MODEL_SCALE,
    Mafra => 4129 * MODEL_SCALE,
    Moita => 4489 * MODEL_SCALE,
    Montijo => 3041 * MODEL_SCALE,
    Odivelas => 10025 * MODEL_SCALE,
    Oeiras => 10207 * MODEL_SCALE,
    Palmela => 3571 * MODEL_SCALE,
    Seixal => 9791 * MODEL_SCALE,
    Sesimbra => 3065 * MODEL_SCALE,
    Setubal => 7018 * MODEL_SCALE,
    Sintra => 25545 * MODEL_SCALE,
    VilaFrancaDeXira => 9069 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LT_40_M2_PER_PERSON_MAP = Dict(
    Alcochete => 1454 * MODEL_SCALE,
    Almada => 14728 * MODEL_SCALE,
    Amadora => 16046 * MODEL_SCALE,
    Barreiro => 7570 * MODEL_SCALE,
    Cascais => 16074 * MODEL_SCALE,
    Lisboa =>  45540 * MODEL_SCALE,
    Loures =>  16848 * MODEL_SCALE,
    Mafra => 6196 * MODEL_SCALE,
    Moita => 5948 * MODEL_SCALE,
    Montijo => 4571 * MODEL_SCALE,
    Odivelas => 13079 * MODEL_SCALE,
    Oeiras => 14441 * MODEL_SCALE,
    Palmela => 5144 * MODEL_SCALE,
    Seixal => 14352 * MODEL_SCALE,
    Sesimbra => 4196 * MODEL_SCALE,
    Setubal => 10162 * MODEL_SCALE,
    Sintra => 33444 * MODEL_SCALE,
    VilaFrancaDeXira => 12825 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LT_60_M2_PER_PERSON_MAP = Dict(
    Alcochete => 2205 * MODEL_SCALE,
    Almada => 19231 * MODEL_SCALE,
    Amadora => 16670 * MODEL_SCALE,
    Barreiro => 8327 * MODEL_SCALE,
    Cascais => 22806 * MODEL_SCALE,
    Lisboa =>  59223 * MODEL_SCALE,
    Loures =>  19980 * MODEL_SCALE,
    Mafra => 10141 * MODEL_SCALE,
    Moita => 6866 * MODEL_SCALE,
    Montijo => 6256 * MODEL_SCALE,
    Odivelas => 15167 * MODEL_SCALE,
    Oeiras => 19248 * MODEL_SCALE,
    Palmela => 7768 * MODEL_SCALE,
    Seixal => 18260 * MODEL_SCALE,
    Sesimbra => 5668 * MODEL_SCALE,
    Setubal => 14028 * MODEL_SCALE,
    Sintra => 37621 * MODEL_SCALE,
    VilaFrancaDeXira => 14769 * MODEL_SCALE,

)

const NUMBER_OF_HOUSES_WITH_LT_80_M2_PER_PERSON_MAP = Dict(
    Alcochete => 789 * MODEL_SCALE,
    Almada => 8587 * MODEL_SCALE,
    Amadora => 8076 * MODEL_SCALE,
    Barreiro => 4740 * MODEL_SCALE,
    Cascais => 9799 * MODEL_SCALE,
    Lisboa =>  30608 * MODEL_SCALE,
    Loures =>  8572 * MODEL_SCALE,
    Mafra => 3827 * MODEL_SCALE,
    Moita => 2930 * MODEL_SCALE,
    Montijo => 2302 * MODEL_SCALE,
    Odivelas => 6178 * MODEL_SCALE,
    Oeiras => 8988 * MODEL_SCALE,
    Palmela => 2952 * MODEL_SCALE,
    Seixal => 7178 * MODEL_SCALE,
    Sesimbra => 2215 * MODEL_SCALE,
    Setubal => 5606 * MODEL_SCALE,
    Sintra => 16054 * MODEL_SCALE,
    VilaFrancaDeXira => 5963 * MODEL_SCALE,

)

const NUMBER_OF_HOUSES_WITH_MT_80_M2_PER_PERSON_MAP = Dict(
    Alcochete => 1384 * MODEL_SCALE,
    Almada => 12523 * MODEL_SCALE,
    Amadora => 8610 * MODEL_SCALE,
    Barreiro => 4753 * MODEL_SCALE,
    Cascais => 17030 * MODEL_SCALE,
    Lisboa =>  43202 * MODEL_SCALE,
    Loures =>  11173 * MODEL_SCALE,
    Mafra => 6143 * MODEL_SCALE,
    Moita => 3674 * MODEL_SCALE,
    Montijo => 3840 * MODEL_SCALE,
    Odivelas => 8120 * MODEL_SCALE,
    Oeiras => 14012 * MODEL_SCALE,
    Palmela => 4933 * MODEL_SCALE,
    Seixal => 11332 * MODEL_SCALE,
    Sesimbra => 3626 * MODEL_SCALE,
    Setubal => 9457 * MODEL_SCALE,
    Sintra => 22350 * MODEL_SCALE,
    VilaFrancaDeXira => 7622 * MODEL_SCALE,
)

# NUMBER_OF_HOUSES_WITH_LT_10_M2_PER_PERSON_MAP
# NUMBER_OF_HOUSES_WITH_LT_15_M2_PER_PERSON_MAP
# NUMBER_OF_HOUSES_WITH_LT_20_M2_PER_PERSON_MAP
# NUMBER_OF_HOUSES_WITH_LT_30_M2_PER_PERSON_MAP
# NUMBER_OF_HOUSES_WITH_LT_40_M2_PER_PERSON_MAP
# NUMBER_OF_HOUSES_WITH_LT_60_M2_PER_PERSON_MAP
# NUMBER_OF_HOUSES_WITH_LT_80_M2_PER_PERSON_MAP
# NUMBER_OF_HOUSES_WITH_MT_80_M2_PER_PERSON_MAP

const adjacentZones = Dict(
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


const FIRST_QUINTILE_INCOME_MAP = Dict(
    Alcochete => 7532 / 12,
    Almada => 6937 / 12,
    Amadora => 6650 / 12,
    Barreiro => 7162 / 12,
    Cascais => 7004 / 12,
    Lisboa => 7308 / 12,
    Loures => 7006 / 12,
    Mafra => 6764 / 12,
    Moita => 6678 / 12,
    Montijo => 6691 / 12,
    Odivelas => 6793 / 12,
    Oeiras => 8424 / 12,
    Palmela => 6780 / 12,
    Seixal => 7126 / 12,
    Sesimbra => 6900 / 12,
    Setubal => 6930 / 12,
    Sintra => 6797 / 12,
    VilaFrancaDeXira => 7604 / 12,
)
const FIRST_QUINTILE_INCOME_MAP_ADJUSTED = Dict(location => adjust_value_to_inflation(income) for (location, income) in FIRST_QUINTILE_INCOME_MAP)

const SECOND_QUINTILE_INCOME_MAP = Dict(
    Alcochete => 10874 / 12,
    Almada => 10294 / 12,
    Amadora => 9713 / 12,
    Barreiro => 10140 / 12,
    Cascais => 10784 / 12,
    Lisboa => 11575 / 12,
    Loures => 9975 / 12,
    Mafra => 10077 / 12,
    Moita => 9517 / 12,
    Montijo => 9772 / 12,
    Odivelas => 9930 / 12,
    Oeiras => 12981 / 12,
    Palmela => 9996 / 12,
    Seixal => 10387 / 12,
    Sesimbra => 10159 / 12,
    Setubal => 10175 / 12,
    Sintra => 9892 / 12,
    VilaFrancaDeXira => 10648 / 12,
)
const SECOND_QUINTILE_INCOME_MAP_ADJUSTED = Dict(location => adjust_value_to_inflation(income) for (location, income) in SECOND_QUINTILE_INCOME_MAP)

const THIRD_QUINTILE_INCOME_MAP = Dict(
    Alcochete => 16169 / 12,
    Almada => 14750 / 12,
    Amadora => 13381 / 12,
    Barreiro => 13662 / 12,
    Cascais => 16480 / 12,
    Lisboa => 18918 / 12,
    Loures => 13702 / 12,
    Mafra => 14539 / 12,
    Moita => 12528 / 12,
    Montijo => 13748 / 12,
    Odivelas => 13918 / 12,
    Oeiras => 20024 / 12,
    Palmela => 14193 / 12,
    Seixal => 14328 / 12,
    Sesimbra => 14009 / 12,
    Setubal => 14297 / 12,
    VilaFrancaDeXira => 14252 / 12,
    Sintra => 13417 / 12,
)
const THIRD_QUINTILE_INCOME_MAP_ADJUSTED = Dict(location => adjust_value_to_inflation(income) for (location, income) in THIRD_QUINTILE_INCOME_MAP)

const FOURTH_QUINTILE_INCOME_MAP = Dict(
    Alcochete => 26716 / 12,
    Almada => 23502 / 12,
    Amadora => 20882 / 12,
    Barreiro => 20486 / 12,
    Cascais => 27978 / 12,
    Lisboa => 33444 / 12,
    Loures => 21271 / 12,
    Mafra => 23325 / 12,
    Moita => 17930 / 12,
    Montijo => 21880 / 12,
    Odivelas => 21633 / 12,
    Oeiras => 32601 / 12,
    Palmela => 21810 / 12,
    Seixal => 21505 / 12,
    Sesimbra => 20735 / 12,
    Setubal => 22410 / 12,
    Sintra => 20169 / 12,
    VilaFrancaDeXira => 20828 / 12, 
)
const FOURTH_QUINTILE_INCOME_MAP_ADJUSTED = Dict(location => adjust_value_to_inflation(income) for (location, income) in FOURTH_QUINTILE_INCOME_MAP)

# BIRTH_RATE = 9.8 / 1000

BIRTH_RATE_MAP = Dict(
    Alcochete => 7.9 / 1000,
    Almada => 8.8 / 1000,
    Amadora => 10.0 / 1000,
    Barreiro => 8.3 / 1000,
    Cascais => 8.0 / 1000,
    Lisboa => 9.9 / 1000,
    Loures => 10.2 / 1000,
    Mafra => 8.6 / 1000,
    Moita => 10.2 / 1000,
    Montijo => 10.2 / 1000,
    Odivelas => 11.1 / 1000,
    Oeiras => 8.3 / 1000,
    Palmela => 8.4 / 1000,
    Seixal => 8.8 / 1000,
    Sesimbra => 8.2 / 1000,
    Setubal => 8.0 / 1000,
    Sintra => 9.6 / 1000,
    VilaFrancaDeXira => 8.9 / 1000,
)

# MORTALITY_RATE = 10.9 / 1000
MORTALITY_RATE_MAP = Dict(
    Alcochete => 8.6 / 1000,
    Almada => 12.5 / 1000,
    Amadora => 11.1 / 1000,
    Barreiro => 13.7 / 1000,
    Cascais => 11.2 / 1000,
    Lisboa => 14.1 / 1000,
    Loures => 11.5 / 1000,
    Mafra => 9.1 / 1000,
    Moita => 12.9 / 1000,
    Montijo => 11.5 / 1000,
    Odivelas => 10.6 / 1000,
    Oeiras => 10.9 / 1000,
    Palmela => 13.0 / 1000,
    Seixal => 10.5 / 1000,
    Sesimbra => 10.7 / 1000,
    Setubal => 13.6 / 1000,
    Sintra => 9.1 / 1000,
    VilaFrancaDeXira => 9.8 / 1000,
)

const NUMBER_OF_HOUSEHOLDS_MAP = Dict(
    Alcochete => sum([ HOUSEHOLDS_SIZES_MAP[size][Alcochete] for size in [1, 2, 3, 4, 5]]),
    Almada => sum([ HOUSEHOLDS_SIZES_MAP[size][Almada] for size in [1, 2, 3, 4, 5]]),
    Amadora => sum([ HOUSEHOLDS_SIZES_MAP[size][Amadora] for size in [1, 2, 3, 4, 5]]),
    Barreiro => sum([ HOUSEHOLDS_SIZES_MAP[size][Barreiro] for size in [1, 2, 3, 4, 5]]),
    Cascais => sum([ HOUSEHOLDS_SIZES_MAP[size][Cascais] for size in [1, 2, 3, 4, 5]]),
    Lisboa => sum([ HOUSEHOLDS_SIZES_MAP[size][Lisboa] for size in [1, 2, 3, 4, 5]]),
    Loures => sum([ HOUSEHOLDS_SIZES_MAP[size][Loures] for size in [1, 2, 3, 4, 5]]),
    Mafra => sum([ HOUSEHOLDS_SIZES_MAP[size][Mafra] for size in [1, 2, 3, 4, 5]]),
    Moita => sum([ HOUSEHOLDS_SIZES_MAP[size][Moita] for size in [1, 2, 3, 4, 5]]),
    Montijo => sum([ HOUSEHOLDS_SIZES_MAP[size][Montijo] for size in [1, 2, 3, 4, 5]]),
    Odivelas => sum([ HOUSEHOLDS_SIZES_MAP[size][Odivelas] for size in [1, 2, 3, 4, 5]]),
    Oeiras => sum([ HOUSEHOLDS_SIZES_MAP[size][Oeiras] for size in [1, 2, 3, 4, 5]]),
    Palmela => sum([ HOUSEHOLDS_SIZES_MAP[size][Palmela] for size in [1, 2, 3, 4, 5]]),
    Seixal => sum([ HOUSEHOLDS_SIZES_MAP[size][Seixal] for size in [1, 2, 3, 4, 5]]),
    Sesimbra => sum([ HOUSEHOLDS_SIZES_MAP[size][Sesimbra] for size in [1, 2, 3, 4, 5]]),
    Setubal => sum([ HOUSEHOLDS_SIZES_MAP[size][Setubal] for size in [1, 2, 3, 4, 5]]),
    Sintra => sum([ HOUSEHOLDS_SIZES_MAP[size][Sintra] for size in [1, 2, 3, 4, 5]]),
    VilaFrancaDeXira => sum([ HOUSEHOLDS_SIZES_MAP[size][VilaFrancaDeXira] for size in [1, 2, 3, 4, 5]]),
)

# AER2022_II_01_Pessoas_e_populacao.xlsx
const migrationBalanceMap = Dict(
    Alcochete => (1.36 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Alcochete],
    Almada => (0.45 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Almada],
    Amadora => (0.74 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Amadora],
    Barreiro => (0.56 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Barreiro],
    Cascais => (0.29 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Cascais],
    Lisboa => (0.95 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Lisboa],
    Loures => (0.47 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Loures],
    Mafra => (0.80 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Mafra],
    Moita => (1.15 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Moita],
    Montijo => (1.52 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Montijo],
    Odivelas => (0.64 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Odivelas],
    Oeiras => (0.76 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Oeiras],
    Palmela => (1.89 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Palmela],
    Seixal => (1.00 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Seixal],
    Sesimbra => (1.76 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Sesimbra],
    Setubal => (-0.06 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Setubal],
    Sintra => (0.21 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[Sintra],
    VilaFrancaDeXira => (0.18 / 100) * NUMBER_OF_HOUSEHOLDS_MAP[VilaFrancaDeXira],
)

# AER2022_II_01_Pessoas_e_populacao.xlsx
const imigrationValueMap = Dict(
    Alcochete => 177 * MODEL_SCALE,
    Almada => 3810 * MODEL_SCALE,
    Amadora => 4629 * MODEL_SCALE,
    Barreiro => 1308 * MODEL_SCALE,
    Cascais => 5774 * MODEL_SCALE,
    Lisboa => 25169 * MODEL_SCALE,
    Loures => 4544 * MODEL_SCALE,
    Mafra => 1284 * MODEL_SCALE,
    Moita => 1063 * MODEL_SCALE,
    Montijo => 1164 * MODEL_SCALE,
    Odivelas => 4738 * MODEL_SCALE,
    Oeiras => 2762 * MODEL_SCALE,
    Palmela => 609 * MODEL_SCALE,
    Seixal => 2881 * MODEL_SCALE,
    Sesimbra => 543 * MODEL_SCALE,
    Setubal => 2001 * MODEL_SCALE,
    Sintra => 7733 * MODEL_SCALE,
    VilaFrancaDeXira => 1628 * MODEL_SCALE,
)

const PROBABILITY_OF_DIVORCE_MAP = Dict(
    Alcochete => 2.3 / 1000,
    Almada => 1.6 / 1000,
    Amadora => 1.6 / 1000,
    Barreiro => 1.7 / 1000,
    Cascais => 1.8 / 1000,
    Lisboa => 1.4 / 1000,
    Loures => 1.4 / 1000,
    Mafra => 1.8 / 1000,
    Moita => 1.9 / 1000,
    Montijo => 1.6 / 1000,
    Odivelas => 1.5 / 1000,
    Oeiras => 1.4 / 1000,
    Palmela => 1.9 / 1000,
    Seixal => 1.9 / 1000,
    Sesimbra => 1.7 / 1000,
    Setubal => 2.0 / 1000,
    Sintra => 1.7 / 1000,
    VilaFrancaDeXira => 1.7 / 1000,
)

const RATIO_OF_FERTILE_WOMEN = 42.1 / 100
const RATIO_OF_FERTILE_WOMEN_MAP = Dict(
    Alcochete => 44.8 / 100,
    Almada => 40.3 / 100,
    Amadora => 42.1 / 100,
    Barreiro => 40.1 / 100,
    Cascais => 39.6 / 100,
    Lisboa => 41.5 / 100,
    Loures => 41.8 / 100,
    Mafra => 45.2 / 100,
    Moita => 41.7 / 100,
    Montijo => 45.2 / 100,
    Odivelas => 43.1 / 100,
    Oeiras => 40.0 / 100,
    Palmela => 42.7 / 100,
    Seixal => 42.4 / 100,
    Sesimbra => 43.5 / 100,
    Setubal => 40.6 / 100,
    Sintra => 44.1 / 100,
    VilaFrancaDeXira => 44.4 / 100,
)

const MAX_NEW_CONSTRUCTIONS_MAP_2021 = Dict(
    Alcochete => 156 * MODEL_SCALE,
    Almada => 304 * MODEL_SCALE,
    Amadora => 315 * MODEL_SCALE,
    Barreiro => 58 * MODEL_SCALE,
    Cascais => 255 * MODEL_SCALE,
    Lisboa => 502 * MODEL_SCALE,
    Loures => 261 * MODEL_SCALE,
    Mafra => 294 * MODEL_SCALE,
    Moita => 66 * MODEL_SCALE,
    Montijo => 209 * MODEL_SCALE,
    Odivelas => 456 * MODEL_SCALE,
    Oeiras => 157 * MODEL_SCALE,
    Palmela => 226 * MODEL_SCALE,
    Seixal => 720 * MODEL_SCALE,
    Sesimbra => 106 * MODEL_SCALE,
    Setubal => 213 * MODEL_SCALE,
    Sintra => 246 * MODEL_SCALE,
    VilaFrancaDeXira => 119 * MODEL_SCALE,
)

const MAX_NEW_CONSTRUCTIONS_MAP_2003 = MAX_NEW_CONSTRUCTIONS_MAP_2021

const MAX_NEW_CONSTRUCTIONS_MAP_2012 = Dict(
    Alcochete => 20 * MODEL_SCALE,
    Almada => 110 * MODEL_SCALE,
    Amadora => 4 * MODEL_SCALE,
    Barreiro => 8 * MODEL_SCALE,
    Cascais => 67 * MODEL_SCALE,
    Lisboa => 164 * MODEL_SCALE,
    Loures => 156 * MODEL_SCALE,
    Mafra => 84 * MODEL_SCALE,
    Moita => 13 * MODEL_SCALE,
    Montijo => 32 * MODEL_SCALE,
    Odivelas => 207 * MODEL_SCALE,
    Oeiras => 54 * MODEL_SCALE,
    Palmela => 40 * MODEL_SCALE,
    Seixal => 69 * MODEL_SCALE,
    Sesimbra => 35 * MODEL_SCALE,
    Setubal => 29 * MODEL_SCALE,
    Sintra => 71 * MODEL_SCALE,
    VilaFrancaDeXira => 66 * MODEL_SCALE,
)

const MAX_NEW_CONSTRUCTIONS_MAP = Dict(
    2003 => MAX_NEW_CONSTRUCTIONS_MAP_2003,
    2012 => MAX_NEW_CONSTRUCTIONS_MAP_2012,
    2021 => MAX_NEW_CONSTRUCTIONS_MAP_2021,
)

const HOUSES_BOUGHT_BY_NON_RESIDENTS = (4047 * MODEL_SCALE) / 12

# TODO: test high value and low value
const PERCENTAGE_OF_HOUSES_SOLD_BY_NON_RESIDENTS = 0.05

const RATIO_OF_HOUSES_BOUGHT_BY_NON_RESIDENTS_BASE = Dict(
    Alcochete => THEORETICAL_NUMBER_OF_HOUSES_MAP[Alcochete],
    Almada => THEORETICAL_NUMBER_OF_HOUSES_MAP[Almada],
    Amadora => THEORETICAL_NUMBER_OF_HOUSES_MAP[Amadora],
    Barreiro => THEORETICAL_NUMBER_OF_HOUSES_MAP[Barreiro],
    Cascais => THEORETICAL_NUMBER_OF_HOUSES_MAP[Cascais],
    Lisboa => THEORETICAL_NUMBER_OF_HOUSES_MAP[Lisboa],
    Loures => THEORETICAL_NUMBER_OF_HOUSES_MAP[Loures],
    Mafra => THEORETICAL_NUMBER_OF_HOUSES_MAP[Mafra],
    Moita => THEORETICAL_NUMBER_OF_HOUSES_MAP[Moita],
    Montijo => THEORETICAL_NUMBER_OF_HOUSES_MAP[Montijo],
    Odivelas => THEORETICAL_NUMBER_OF_HOUSES_MAP[Odivelas],
    Oeiras => THEORETICAL_NUMBER_OF_HOUSES_MAP[Oeiras],
    Palmela => THEORETICAL_NUMBER_OF_HOUSES_MAP[Palmela],
    Seixal => THEORETICAL_NUMBER_OF_HOUSES_MAP[Seixal],
    Sesimbra => THEORETICAL_NUMBER_OF_HOUSES_MAP[Sesimbra],
    Setubal => THEORETICAL_NUMBER_OF_HOUSES_MAP[Setubal],
    Sintra => THEORETICAL_NUMBER_OF_HOUSES_MAP[Sintra],
    VilaFrancaDeXira => THEORETICAL_NUMBER_OF_HOUSES_MAP[VilaFrancaDeXira],
)

const RATIO_OF_HOUSES_BOUGHT_BY_NON_RESIDENTS_BASE_TOTAL = sum(values(RATIO_OF_HOUSES_BOUGHT_BY_NON_RESIDENTS_BASE))

const RATIO_OF_HOUSES_BOUGHT_BY_NON_RESIDENTS = Dict(location => RATIO_OF_HOUSES_BOUGHT_BY_NON_RESIDENTS_BASE[location] / RATIO_OF_HOUSES_BOUGHT_BY_NON_RESIDENTS_BASE_TOTAL for location in instances(HouseLocation))

@enum HouseSizeEchelon begin
    LessThan29 = 30
    LessThan39 = 39
    LessThan49 = 49 
    LessThan59 = 59 
    LessThan79 = 79 
    LessThan99 = 99 
    LessThan119 = 119 
    LessThan149 = 149 
    LessThan199 = 199 
    MoreThan200 = 200 
end



const NUMBER_OF_HOUSES_WITH_LessThan29_MAP = Dict(
    Alcochete => 24 * MODEL_SCALE,
    Almada => 293 * MODEL_SCALE,
    Amadora => 332 * MODEL_SCALE,
    Barreiro => 138 * MODEL_SCALE,
    Cascais => 223 * MODEL_SCALE,
    Lisboa => 627 * MODEL_SCALE,
    Loures => 300 * MODEL_SCALE,
    Mafra => 88 * MODEL_SCALE,
    Moita => 150 * MODEL_SCALE,
    Montijo => 70 * MODEL_SCALE,
    Odivelas => 170 * MODEL_SCALE,
    Oeiras => 185 * MODEL_SCALE,
    Palmela => 133 * MODEL_SCALE,
    Seixal => 247 * MODEL_SCALE,
    Sesimbra => 89 * MODEL_SCALE,
    Setubal => 206 * MODEL_SCALE,
    Sintra => 459 * MODEL_SCALE,
    VilaFrancaDeXira => 143 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LessThan39_MAP = Dict(
    Alcochete => 62 * MODEL_SCALE,
    Almada => 785 * MODEL_SCALE,
    Amadora => 1156 * MODEL_SCALE,
    Barreiro => 355 * MODEL_SCALE,
    Cascais => 681 * MODEL_SCALE,
    Lisboa => 1822 * MODEL_SCALE,
    Loures => 710 * MODEL_SCALE,
    Mafra => 205 * MODEL_SCALE,
    Moita => 361 * MODEL_SCALE,
    Montijo => 172 * MODEL_SCALE,
    Odivelas => 590 * MODEL_SCALE,
    Oeiras => 609 * MODEL_SCALE,
    Palmela => 283 * MODEL_SCALE,
    Seixal => 752 * MODEL_SCALE,
    Sesimbra => 190 * MODEL_SCALE,
    Setubal => 459 * MODEL_SCALE,
    Sintra => 1338 * MODEL_SCALE,
    VilaFrancaDeXira => 444 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LessThan49_MAP = Dict(
    Alcochete => 83 * MODEL_SCALE,
    Almada => 1477 * MODEL_SCALE,
    Amadora => 1954 * MODEL_SCALE,
    Barreiro => 726 * MODEL_SCALE,
    Cascais => 1258 * MODEL_SCALE,
    Lisboa => 4043 * MODEL_SCALE,
    Loures => 1416 * MODEL_SCALE,
    Mafra => 394 * MODEL_SCALE,
    Moita => 668 * MODEL_SCALE,
    Montijo => 286 * MODEL_SCALE,
    Odivelas => 1104 * MODEL_SCALE,
    Oeiras => 1180 * MODEL_SCALE,
    Palmela => 423 * MODEL_SCALE,
    Seixal => 1146 * MODEL_SCALE,
    Sesimbra => 360 * MODEL_SCALE,
    Setubal => 822 * MODEL_SCALE,
    Sintra => 2606 * MODEL_SCALE,
    VilaFrancaDeXira => 844 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LessThan59_MAP = Dict(
    Alcochete => 147 * MODEL_SCALE,
    Almada => 2556 * MODEL_SCALE,
    Amadora => 3298 * MODEL_SCALE,
    Barreiro => 1585 * MODEL_SCALE,
    Cascais => 2132 * MODEL_SCALE,
    Lisboa => 7707 * MODEL_SCALE,
    Loures => 2620 * MODEL_SCALE,
    Mafra => 641 * MODEL_SCALE,
    Moita => 1178 * MODEL_SCALE,
    Montijo => 419 * MODEL_SCALE,
    Odivelas => 1948 * MODEL_SCALE,
    Oeiras => 2055 * MODEL_SCALE,
    Palmela => 707 * MODEL_SCALE,
    Seixal => 2230 * MODEL_SCALE,
    Sesimbra => 546 * MODEL_SCALE,
    Setubal => 1325 * MODEL_SCALE,
    Sintra => 4892 * MODEL_SCALE,
    VilaFrancaDeXira => 1594 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LessThan79_MAP = Dict(
    Alcochete => 456 * MODEL_SCALE,
    Almada => 8637 * MODEL_SCALE,
    Amadora => 11228 * MODEL_SCALE,
    Barreiro => 6184 * MODEL_SCALE,
    Cascais => 7773 * MODEL_SCALE,
    Lisboa => 22623 * MODEL_SCALE,
    Loures => 9208 * MODEL_SCALE,
    Mafra => 2151 * MODEL_SCALE,
    Moita => 4151 * MODEL_SCALE,
    Montijo => 1499 * MODEL_SCALE,
    Odivelas => 7637 * MODEL_SCALE,
    Oeiras => 7619 * MODEL_SCALE,
    Palmela => 2329 * MODEL_SCALE,
    Seixal => 8711 * MODEL_SCALE,
    Sesimbra => 1877 * MODEL_SCALE,
    Setubal => 5157 * MODEL_SCALE,
    Sintra => 20353 * MODEL_SCALE,
    VilaFrancaDeXira => 7101 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LessThan99_MAP = Dict(
    Alcochete => 847 * MODEL_SCALE,
    Almada => 12586 * MODEL_SCALE,
    Amadora => 12015 * MODEL_SCALE,
    Barreiro => 5544 * MODEL_SCALE,
    Cascais => 11918 * MODEL_SCALE,
    Lisboa => 24608 * MODEL_SCALE,
    Loures => 12319 * MODEL_SCALE,
    Mafra => 3898 * MODEL_SCALE,
    Moita => 5353 * MODEL_SCALE,
    Montijo => 3329 * MODEL_SCALE,
    Odivelas => 11142 * MODEL_SCALE,
    Oeiras => 10768 * MODEL_SCALE,
    Palmela => 4280 * MODEL_SCALE,
    Seixal => 13857 * MODEL_SCALE,
    Sesimbra => 2985 * MODEL_SCALE,
    Setubal => 8776 * MODEL_SCALE,
    Sintra => 30277 * MODEL_SCALE,
    VilaFrancaDeXira => 10313 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LessThan119_MAP = Dict(
    Alcochete => 1047 * MODEL_SCALE,
    Almada => 8565 * MODEL_SCALE,
    Amadora => 7780 * MODEL_SCALE,
    Barreiro => 3884 * MODEL_SCALE,
    Cascais => 10516 * MODEL_SCALE,
    Lisboa => 20529 * MODEL_SCALE,
    Loures => 9626 * MODEL_SCALE,
    Mafra => 4417 * MODEL_SCALE,
    Moita => 3238 * MODEL_SCALE,
    Montijo => 3725 * MODEL_SCALE,
    Odivelas => 8085 * MODEL_SCALE,
    Oeiras => 9637 * MODEL_SCALE,
    Palmela => 3834 * MODEL_SCALE,
    Seixal => 9491 * MODEL_SCALE,
    Sesimbra => 3368 * MODEL_SCALE,
    Setubal => 7082 * MODEL_SCALE,
    Sintra => 19017 * MODEL_SCALE,
    VilaFrancaDeXira => 9159 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LessThan149_MAP = Dict(
    Alcochete => 994 * MODEL_SCALE,
    Almada => 5414 * MODEL_SCALE,
    Amadora => 4352 * MODEL_SCALE,
    Barreiro => 2992 * MODEL_SCALE,
    Cascais => 9013 * MODEL_SCALE,
    Lisboa => 19955 * MODEL_SCALE,
    Loures => 7403 * MODEL_SCALE,
    Mafra => 4212 * MODEL_SCALE,
    Moita => 1866 * MODEL_SCALE,
    Montijo => 2785 * MODEL_SCALE,
    Odivelas => 4841 * MODEL_SCALE,
    Oeiras => 8651 * MODEL_SCALE,
    Palmela => 3088 * MODEL_SCALE,
    Seixal => 6193 * MODEL_SCALE,
    Sesimbra => 2960 * MODEL_SCALE,
    Setubal => 5576 * MODEL_SCALE,
    Sintra => 12285 * MODEL_SCALE,
    VilaFrancaDeXira => 5938 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_LessThan199_MAP = Dict(
    Alcochete => 712 * MODEL_SCALE,
    Almada => 4201 * MODEL_SCALE,
    Amadora => 1545 * MODEL_SCALE,
    Barreiro => 1277 * MODEL_SCALE,
    Cascais => 6644 * MODEL_SCALE,
    Lisboa => 13267 * MODEL_SCALE,
    Loures => 3882 * MODEL_SCALE,
    Mafra => 3798 * MODEL_SCALE,
    Moita => 1182 * MODEL_SCALE,
    Montijo => 1358 * MODEL_SCALE,
    Odivelas => 2300 * MODEL_SCALE,
    Oeiras => 5120 * MODEL_SCALE,
    Palmela => 2405 * MODEL_SCALE,
    Seixal => 4939 * MODEL_SCALE,
    Sesimbra => 1893 * MODEL_SCALE,
    Setubal => 3555 * MODEL_SCALE,
    Sintra => 7466 * MODEL_SCALE,
    VilaFrancaDeXira => 2523 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_WITH_MoreThan200_MAP = Dict(
    Alcochete => 713 * MODEL_SCALE,
    Almada => 2866 * MODEL_SCALE,
    Amadora => 615 * MODEL_SCALE,
    Barreiro => 802 * MODEL_SCALE,
    Cascais => 6278 * MODEL_SCALE,
    Lisboa => 6688 * MODEL_SCALE,
    Loures => 2363 * MODEL_SCALE,
    Mafra => 3455 * MODEL_SCALE,
    Moita => 732 * MODEL_SCALE,
    Montijo => 912 * MODEL_SCALE,
    Odivelas => 1628 * MODEL_SCALE,
    Oeiras => 3312 * MODEL_SCALE,
    Palmela => 2289 * MODEL_SCALE,
    Seixal => 3157 * MODEL_SCALE,
    Sesimbra => 1153 * MODEL_SCALE,
    Setubal => 2151 * MODEL_SCALE,
    Sintra => 5609 * MODEL_SCALE,
    VilaFrancaDeXira => 1560 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_PER_SIZE_MAP = Dict(
    LessThan29 => NUMBER_OF_HOUSES_WITH_LessThan29_MAP,
    LessThan39 => NUMBER_OF_HOUSES_WITH_LessThan39_MAP,
    LessThan49 => NUMBER_OF_HOUSES_WITH_LessThan49_MAP, 
    LessThan59 => NUMBER_OF_HOUSES_WITH_LessThan59_MAP, 
    LessThan79 => NUMBER_OF_HOUSES_WITH_LessThan79_MAP, 
    LessThan99 => NUMBER_OF_HOUSES_WITH_LessThan99_MAP, 
    LessThan119 => NUMBER_OF_HOUSES_WITH_LessThan119_MAP, 
    LessThan149 => NUMBER_OF_HOUSES_WITH_LessThan149_MAP, 
    LessThan199 => NUMBER_OF_HOUSES_WITH_LessThan199_MAP, 
    MoreThan200 => NUMBER_OF_HOUSES_WITH_MoreThan200_MAP, 
)


#########
#########
#########
#########


const NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan29_MAP = Dict(
    Alcochete => 63 * MODEL_SCALE,
    Almada => 1006 * MODEL_SCALE,
    Amadora => 1168 * MODEL_SCALE,
    Barreiro => 298 * MODEL_SCALE,
    Cascais => 1174 * MODEL_SCALE,
    Lisboa => 4777 * MODEL_SCALE,
    Loures => 1242 * MODEL_SCALE,
    Mafra => 283 * MODEL_SCALE,
    Moita => 289 * MODEL_SCALE,
    Montijo => 244 * MODEL_SCALE,
    Odivelas => 696 * MODEL_SCALE,
    Oeiras => 679 * MODEL_SCALE,
    Palmela => 149 * MODEL_SCALE,
    Seixal => 466 * MODEL_SCALE,
    Sesimbra => 147 * MODEL_SCALE,
    Setubal => 525 * MODEL_SCALE,
    Sintra => 1225 * MODEL_SCALE,
    VilaFrancaDeXira => 466 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan39_MAP = Dict(
    Alcochete => 147 * MODEL_SCALE,
    Almada => 1994 * MODEL_SCALE,
    Amadora => 2486 * MODEL_SCALE,
    Barreiro => 552 * MODEL_SCALE,
    Cascais => 1874 * MODEL_SCALE,
    Lisboa => 8586 * MODEL_SCALE,
    Loures => 2323 * MODEL_SCALE,
    Mafra => 514 * MODEL_SCALE,
    Moita => 561 * MODEL_SCALE,
    Montijo => 412 * MODEL_SCALE,
    Odivelas => 1373 * MODEL_SCALE,
    Oeiras => 1529 * MODEL_SCALE,
    Palmela => 297 * MODEL_SCALE,
    Seixal => 956 * MODEL_SCALE,
    Sesimbra => 274 * MODEL_SCALE,
    Setubal => 952 * MODEL_SCALE,
    Sintra => 2591 * MODEL_SCALE,
    VilaFrancaDeXira => 929 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan49_MAP = Dict(
    Alcochete => 164 * MODEL_SCALE,
    Almada => 2564 * MODEL_SCALE,
    Amadora => 3315 * MODEL_SCALE,
    Barreiro => 879 * MODEL_SCALE,
    Cascais => 2227 * MODEL_SCALE,
    Lisboa => 11651 * MODEL_SCALE,
    Loures => 3188 * MODEL_SCALE,
    Mafra => 629 * MODEL_SCALE,
    Moita => 765 * MODEL_SCALE,
    Montijo => 497 * MODEL_SCALE,
    Odivelas => 1901 * MODEL_SCALE,
    Oeiras => 2079 * MODEL_SCALE,
    Palmela => 377 * MODEL_SCALE,
    Seixal => 1095 * MODEL_SCALE,
    Sesimbra => 309 * MODEL_SCALE,
    Setubal => 1180 * MODEL_SCALE,
    Sintra => 3566 * MODEL_SCALE,
    VilaFrancaDeXira => 1279 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan59_MAP = Dict(
    Alcochete => 189 * MODEL_SCALE,
    Almada => 3288 * MODEL_SCALE,
    Amadora => 4116 * MODEL_SCALE,
    Barreiro => 1381 * MODEL_SCALE,
    Cascais => 2752 * MODEL_SCALE,
    Lisboa => 14862 * MODEL_SCALE,
    Loures => 4137 * MODEL_SCALE,
    Mafra => 839 * MODEL_SCALE,
    Moita => 1055 * MODEL_SCALE,
    Montijo => 592 * MODEL_SCALE,
    Odivelas => 2543 * MODEL_SCALE,
    Oeiras => 2513 * MODEL_SCALE,
    Palmela => 552 * MODEL_SCALE,
    Seixal => 1389 * MODEL_SCALE,
    Sesimbra => 438 * MODEL_SCALE,
    Setubal => 1515 * MODEL_SCALE,
    Sintra => 5052 * MODEL_SCALE,
    VilaFrancaDeXira => 1795 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan79_MAP = Dict(
    Alcochete => 350 * MODEL_SCALE,
    Almada => 6179 * MODEL_SCALE,
    Amadora => 7315 * MODEL_SCALE,
    Barreiro => 3067 * MODEL_SCALE,
    Cascais => 5130 * MODEL_SCALE,
    Lisboa => 26070 * MODEL_SCALE,
    Loures => 6995 * MODEL_SCALE,
    Mafra => 1633 * MODEL_SCALE,
    Moita => 2016 * MODEL_SCALE,
    Montijo => 1206 * MODEL_SCALE,
    Odivelas => 4850 * MODEL_SCALE,
    Oeiras => 5102 * MODEL_SCALE,
    Palmela => 1027 * MODEL_SCALE,
    Seixal => 3189 * MODEL_SCALE,
    Sesimbra => 897 * MODEL_SCALE,
    Setubal => 3126 * MODEL_SCALE,
    Sintra => 11182 * MODEL_SCALE,
    VilaFrancaDeXira => 3798 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan99_MAP = Dict(
    Alcochete => 357 * MODEL_SCALE,
    Almada => 4366 * MODEL_SCALE,
    Amadora => 4118 * MODEL_SCALE,
    Barreiro => 1627 * MODEL_SCALE,
    Cascais => 4265 * MODEL_SCALE,
    Lisboa => 17411 * MODEL_SCALE,
    Loures => 4499 * MODEL_SCALE,
    Mafra => 1499 * MODEL_SCALE,
    Moita => 1366 * MODEL_SCALE,
    Montijo => 1335 * MODEL_SCALE,
    Odivelas => 3222 * MODEL_SCALE,
    Oeiras => 3611 * MODEL_SCALE,
    Palmela => 1029 * MODEL_SCALE,
    Seixal => 3065 * MODEL_SCALE,
    Sesimbra => 730 * MODEL_SCALE,
    Setubal => 2954 * MODEL_SCALE,
    Sintra => 8673 * MODEL_SCALE,
    VilaFrancaDeXira => 2741 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan119_MAP = Dict(
    Alcochete => 217 * MODEL_SCALE,
    Almada => 1800 * MODEL_SCALE,
    Amadora => 1460 * MODEL_SCALE,
    Barreiro => 640 * MODEL_SCALE,
    Cascais => 2605 * MODEL_SCALE,
    Lisboa => 9489 * MODEL_SCALE,
    Loures => 1888 * MODEL_SCALE,
    Mafra => 926 * MODEL_SCALE,
    Moita => 535 * MODEL_SCALE,
    Montijo => 938 * MODEL_SCALE,
    Odivelas => 1307 * MODEL_SCALE,
    Oeiras => 1782 * MODEL_SCALE,
    Palmela => 597 * MODEL_SCALE,
    Seixal => 1279 * MODEL_SCALE,
    Sesimbra => 437 * MODEL_SCALE,
    Setubal => 1357 * MODEL_SCALE,
    Sintra => 3463 * MODEL_SCALE,
    VilaFrancaDeXira => 1272 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan149_MAP = Dict(
    Alcochete => 113 * MODEL_SCALE,
    Almada => 687 * MODEL_SCALE,
    Amadora => 473 * MODEL_SCALE,
    Barreiro => 294 * MODEL_SCALE,
    Cascais => 1500 * MODEL_SCALE,
    Lisboa => 5572 * MODEL_SCALE,
    Loures => 854 * MODEL_SCALE,
    Mafra => 493 * MODEL_SCALE,
    Moita => 181 * MODEL_SCALE,
    Montijo => 455 * MODEL_SCALE,
    Odivelas => 499 * MODEL_SCALE,
    Oeiras => 945 * MODEL_SCALE,
    Palmela => 278 * MODEL_SCALE,
    Seixal => 437 * MODEL_SCALE,
    Sesimbra => 209 * MODEL_SCALE,
    Setubal => 591 * MODEL_SCALE,
    Sintra => 1452 * MODEL_SCALE,
    VilaFrancaDeXira => 477 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan199_MAP = Dict(
    Alcochete => 69 * MODEL_SCALE,
    Almada => 281 * MODEL_SCALE,
    Amadora => 179 * MODEL_SCALE,
    Barreiro => 91 * MODEL_SCALE,
    Cascais => 763 * MODEL_SCALE,
    Lisboa => 2636 * MODEL_SCALE,
    Loures => 308 * MODEL_SCALE,
    Mafra => 206 * MODEL_SCALE,
    Moita => 80 * MODEL_SCALE,
    Montijo => 122 * MODEL_SCALE,
    Odivelas => 180 * MODEL_SCALE,
    Oeiras => 377 * MODEL_SCALE,
    Palmela => 117 * MODEL_SCALE,
    Seixal => 183 * MODEL_SCALE,
    Sesimbra => 84 * MODEL_SCALE,
    Setubal => 201 * MODEL_SCALE,
    Sintra => 575 * MODEL_SCALE,
    VilaFrancaDeXira => 154 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_FOR_RENTAL_WITH_MoreThan200_MAP = Dict(
    Alcochete => 33 * MODEL_SCALE,
    Almada => 184 * MODEL_SCALE,
    Amadora => 130 * MODEL_SCALE,
    Barreiro => 45 * MODEL_SCALE,
    Cascais => 665 * MODEL_SCALE,
    Lisboa => 1257 * MODEL_SCALE,
    Loures => 162 * MODEL_SCALE,
    Mafra => 134 * MODEL_SCALE,
    Moita => 53 * MODEL_SCALE,
    Montijo => 56 * MODEL_SCALE,
    Odivelas => 104 * MODEL_SCALE,
    Oeiras => 202 * MODEL_SCALE,
    Palmela => 106 * MODEL_SCALE,
    Seixal => 135 * MODEL_SCALE,
    Sesimbra => 56 * MODEL_SCALE,
    Setubal => 117 * MODEL_SCALE,
    Sintra => 442 * MODEL_SCALE,
    VilaFrancaDeXira => 85 * MODEL_SCALE,
)

const NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP = Dict(
    LessThan29 => NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan29_MAP,
    LessThan39 => NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan39_MAP,
    LessThan49 => NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan49_MAP, 
    LessThan59 => NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan59_MAP, 
    LessThan79 => NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan79_MAP, 
    LessThan99 => NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan99_MAP, 
    LessThan119 => NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan119_MAP, 
    LessThan149 => NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan149_MAP, 
    LessThan199 => NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan199_MAP, 
    MoreThan200 => NUMBER_OF_HOUSES_FOR_RENTAL_WITH_MoreThan200_MAP, 
)

const LOCAL_HOUSING_MAP = Dict(
    Alcochete => 47 * MODEL_SCALE,
    Almada => 1709 * MODEL_SCALE,
    Amadora => 170 * MODEL_SCALE,
    Barreiro => 82 * MODEL_SCALE,
    Cascais => 2630 * MODEL_SCALE,
    Lisboa => 19124 * MODEL_SCALE,
    Loures => 208 * MODEL_SCALE,
    Mafra => 1141 * MODEL_SCALE,
    Moita => 50 * MODEL_SCALE,
    Montijo => 85 * MODEL_SCALE,
    Odivelas => 87 * MODEL_SCALE,
    Oeiras => 572 * MODEL_SCALE,
    Palmela => 202 * MODEL_SCALE,
    Seixal => 333 * MODEL_SCALE,
    Sesimbra => 760 * MODEL_SCALE,
    Setubal => 931 * MODEL_SCALE,
    Sintra => 1215 * MODEL_SCALE,
    VilaFrancaDeXira => 59 * MODEL_SCALE,
)

const LAND_COSTS = Dict(
    Amadora => 1000,
    Cascais => 1300,
    Lisboa => 1500,
    Loures => 1100,
    Mafra => 900,
    Odivelas => 1200,
    Oeiras => 1400,
    Sintra => 800,
    VilaFrancaDeXira => 700,
    Alcochete => 900,
    Almada => 1100,
    Barreiro => 600,
    Moita => 500,
    Montijo => 700,
    Palmela => 600,
    Seixal => 700,
    Sesimbra => 650,
    Setubal => 700,
)
const LAND_COSTS_ADJUSTED = Dict(location => adjust_value_to_inflation(value) for (location, value) in LAND_COSTS)

const RELATIVE_WEALTH_RATIO = Dict(
    Amadora => 1.699 / NUMBER_OF_HOUSEHOLDS_MAP[Amadora],
    Cascais => 2.500 / NUMBER_OF_HOUSEHOLDS_MAP[Cascais],
    Lisboa => 9.748 / NUMBER_OF_HOUSEHOLDS_MAP[Lisboa],
    Loures => 1.990 / NUMBER_OF_HOUSEHOLDS_MAP[Loures],
    Mafra => 0.868 / NUMBER_OF_HOUSEHOLDS_MAP[Mafra],
    Odivelas => 1.356 / NUMBER_OF_HOUSEHOLDS_MAP[Odivelas],
    Oeiras => 2.729 / NUMBER_OF_HOUSEHOLDS_MAP[Oeiras],
    Sintra => 3.636 / NUMBER_OF_HOUSEHOLDS_MAP[Sintra],
    VilaFrancaDeXira => 1.307 / NUMBER_OF_HOUSEHOLDS_MAP[VilaFrancaDeXira],
    Alcochete => 0.222 / NUMBER_OF_HOUSEHOLDS_MAP[Alcochete],
    Almada => 1.785 / NUMBER_OF_HOUSEHOLDS_MAP[Almada],
    Barreiro => 0.729 / NUMBER_OF_HOUSEHOLDS_MAP[Barreiro],
    Moita => 0.529 / NUMBER_OF_HOUSEHOLDS_MAP[Moita],
    Montijo => 0.560 / NUMBER_OF_HOUSEHOLDS_MAP[Montijo],
    Palmela => 0.659 / NUMBER_OF_HOUSEHOLDS_MAP[Palmela],
    Seixal => 1.548 / NUMBER_OF_HOUSEHOLDS_MAP[Seixal],
    Sesimbra => 0.482 / NUMBER_OF_HOUSEHOLDS_MAP[Sesimbra],
    Setubal => 1.238 / NUMBER_OF_HOUSEHOLDS_MAP[Setubal]
)
const SUM_WEALTH_RATIO = sum([RELATIVE_WEALTH_RATIO[location] for location in HOUSE_LOCATION_INSTANCES])

const NORMALIZED_WEALTH_RATIO = Dict(
    Amadora => RELATIVE_WEALTH_RATIO[Amadora] / SUM_WEALTH_RATIO,
    Cascais => RELATIVE_WEALTH_RATIO[Cascais] / SUM_WEALTH_RATIO,
    Lisboa => RELATIVE_WEALTH_RATIO[Lisboa] / SUM_WEALTH_RATIO,
    Loures => RELATIVE_WEALTH_RATIO[Loures] / SUM_WEALTH_RATIO,
    Mafra => RELATIVE_WEALTH_RATIO[Mafra] / SUM_WEALTH_RATIO,
    Odivelas => RELATIVE_WEALTH_RATIO[Odivelas] / SUM_WEALTH_RATIO,
    Oeiras => RELATIVE_WEALTH_RATIO[Oeiras] / SUM_WEALTH_RATIO,
    Sintra => RELATIVE_WEALTH_RATIO[Sintra] / SUM_WEALTH_RATIO,
    VilaFrancaDeXira => RELATIVE_WEALTH_RATIO[VilaFrancaDeXira] / SUM_WEALTH_RATIO,
    Alcochete => RELATIVE_WEALTH_RATIO[Alcochete] / SUM_WEALTH_RATIO,
    Almada => RELATIVE_WEALTH_RATIO[Almada] / SUM_WEALTH_RATIO,
    Barreiro => RELATIVE_WEALTH_RATIO[Barreiro] / SUM_WEALTH_RATIO,
    Moita => RELATIVE_WEALTH_RATIO[Moita] / SUM_WEALTH_RATIO,
    Montijo => RELATIVE_WEALTH_RATIO[Montijo] / SUM_WEALTH_RATIO,
    Palmela => RELATIVE_WEALTH_RATIO[Palmela] / SUM_WEALTH_RATIO,
    Seixal => RELATIVE_WEALTH_RATIO[Seixal] / SUM_WEALTH_RATIO,
    Sesimbra => RELATIVE_WEALTH_RATIO[Sesimbra] / SUM_WEALTH_RATIO,
    Setubal => RELATIVE_WEALTH_RATIO[Setubal] / SUM_WEALTH_RATIO
)
const MEAN_NORMALIZED_WEALTH_RATIO = mean([NORMALIZED_WEALTH_RATIO[location] for location in HOUSE_LOCATION_INSTANCES])

const WEALTH_RATIO_MULTIPLIER_MAP = Dict(
    Amadora => (NORMALIZED_WEALTH_RATIO[Amadora] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Cascais => (NORMALIZED_WEALTH_RATIO[Cascais] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Lisboa => (NORMALIZED_WEALTH_RATIO[Lisboa] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Loures => (NORMALIZED_WEALTH_RATIO[Loures] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Mafra => (NORMALIZED_WEALTH_RATIO[Mafra] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Odivelas => (NORMALIZED_WEALTH_RATIO[Odivelas] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Oeiras => (NORMALIZED_WEALTH_RATIO[Oeiras] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Sintra => (NORMALIZED_WEALTH_RATIO[Sintra] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    VilaFrancaDeXira => (NORMALIZED_WEALTH_RATIO[VilaFrancaDeXira] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Alcochete => (NORMALIZED_WEALTH_RATIO[Alcochete] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Almada => (NORMALIZED_WEALTH_RATIO[Almada] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Barreiro => (NORMALIZED_WEALTH_RATIO[Barreiro] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Moita => (NORMALIZED_WEALTH_RATIO[Moita] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Montijo => (NORMALIZED_WEALTH_RATIO[Montijo] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Palmela => (NORMALIZED_WEALTH_RATIO[Palmela] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Seixal => (NORMALIZED_WEALTH_RATIO[Seixal] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Sesimbra => (NORMALIZED_WEALTH_RATIO[Sesimbra] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2),
    Setubal => (NORMALIZED_WEALTH_RATIO[Setubal] / MEAN_NORMALIZED_WEALTH_RATIO) ^ (1/2)
)

const REAL_PRICES_MAP = Dict(
    "Amadora" => [1723, 1743, 1783, 1820, 1884, 1929, 1984, 2049, 2108, 2154, 2223, 2260],
    "Cascais" => [2776, 2851, 2946, 3046, 3184, 3276, 3371, 3473, 3574, 3667, 3831, 3976],
    "Lisboa" => [3333, 3347, 3437, 3531, 3642, 3704, 3785, 3872, 3965, 4080, 4151, 4167],
    "Loures" => [1820, 1888, 1916, 1960, 1991, 2062, 2116, 2155, 2293, 2380, 2430, 2482],
    "Mafra" => [1600, 1614, 1670, 1704, 1796, 1879, 1948, 2065, 2135, 2118, 2171, 2200],
    "Odivelas" => [2057, 2078, 2134, 2156, 2197, 2234, 2286, 2355, 2448, 2464, 2497, 2517],
    "Oeiras" => [2440, 2467, 2550, 2644, 2721, 2822, 2929, 3001, 3093, 3145, 3177, 3158],
    "Sintra" => [1441, 1473, 1508, 1548, 1612, 1688, 1751, 1816, 1868, 1913, 1957, 2014],
    "VilaFrancaDeXira" => [1383, 1429, 1486, 1525, 1560, 1626, 1681, 1750, 1798, 1833, 1886, 1897],
    "Alcochete" => [1525, 1661, 1840, 1951, 1979, 1979, 1886, 1867, 1885, 1890, 2002, 2086],
    "Almada" => [1801, 1838, 1860, 1895, 1946, 2026, 2092, 2179, 2238, 2267, 2331, 2374],
    "Barreiro" => [1136, 1162, 1189, 1226, 1287, 1349, 1426, 1512, 1556, 1595, 1634, 1687],
    "Moita" => [952, 966, 993, 1035, 1078, 1163, 1214, 1280, 1350, 1405, 1446, 1498],
    "Montijo" => [1334, 1338, 1364, 1421, 1482, 1559, 1643, 1710, 1749, 1792, 1835, 1840],
    "Palmela" => [1198, 1237, 1272, 1312, 1372, 1411, 1475, 1556, 1605, 1654, 1716, 1764],
    "Seixal" => [1380, 1410, 1458, 1510, 1569, 1627, 1700, 1761, 1821, 1878, 1924, 1992],
    "Sesimbra" => [1456, 1503, 1573, 1667, 1701, 1759, 1862, 1956, 2012, 2070, 2091, 2086],
    "Setubal" => [1307, 1325, 1335, 1384, 1447, 1516, 1583, 1648, 1709, 1758, 1811, 1835],
)
const REAL_PRICES_MAP_ADJUSTED = Dict(location => [adjust_value_to_inflation(value) for value in values] for (location, values) in REAL_PRICES_MAP)

const REAL_RENTS_MAP = Dict(
    "Amadora" => [8.76, 8.85, 9.00, 9.48, 10.14, 10.72, 11.24],
    "Cascais" => [10.56, 10.95, 11.56, 12.58, 13.56, 14.22, 14.87],
    "Lisboa" => [11.12, 11.24, 11.86, 12.88, 14.11, 15.22, 15.63],
    "Loures" => [7.78, 7.90, 8.13, 8.54, 8.95, 9.68, 10.15],
    "Mafra" => [6.80, 6.94, 7.27, 7.48, 7.95, 8.37, 8.75],
    "Odivelas" => [8.21, 8.43, 8.78, 9.00, 9.41, 10.02, 10.91],
    "Oeiras" => [9.86, 10.00, 10.50, 11.36, 12.32, 13.00, 13.46],
    "Sintra" => [7.25, 7.46, 7.64, 8.06, 8.75, 9.32, 9.70],
    "VilaFrancaDeXira" => [6.82, 7.09, 7.17, 7.46, 8.11, 8.94, 9.43],
    "Alcochete" => [6.35, 6.74, 6.98, 7.52, 7.77, 8.52, 9.00],
    "Almada" => [8.36, 8.58, 9.01, 9.49, 9.97, 10.67, 11.34],
    "Barreiro" => [6.95, 7.24, 7.48, 7.84, 8.50, 9.01, 9.45],
    "Moita" => [5.80, 6.21, 6.39, 6.90, 7.50, 8.05, 8.44],
    "Montijo" => [6.32, 6.48, 6.74, 7.41, 8.08, 8.44, 8.56],
    "Palmela" => [5.82, 6.03, 6.39, 6.72, 6.98, 7.22, 7.87],
    "Seixal" => [6.67, 7.01, 7.45, 8.07, 8.49, 8.78, 9.44],
    "Sesimbra" => [5.95, 6.07, 6.67, 7.10, 7.41, 7.97, 8.33],
    "Setubal" => [6.67, 6.85, 7.15, 7.58, 8.08, 8.95, 9.39],
)

const REAL_RENTS_MAP_ADJUSTED = Dict(location => [adjust_value_to_inflation(value) for value in values] for (location, values) in REAL_RENTS_MAP)

const FOREIGNERS_PER_COUNTRY_MAP = Dict(
    Alcochete => Dict(
        Brasil => 391,
        Ucrania => 53,
        CaboVerde => 9,
        Romenia => 277,
        Angola => 77,
        GuineBissau => 7,
        ReinoUnido => 44,
        Moldavia => 9,
        China => 32,
        SaoTomeEPrincipe => 6,
    ),

    Almada => Dict(
        Brasil => 7601,
        Ucrania => 322,
        CaboVerde => 1973,
        Romenia => 278,
        Angola => 1134,
        GuineBissau => 321,
        ReinoUnido => 324,
        Moldavia => 108,
        China => 417,
        SaoTomeEPrincipe => 650,
    ),

    Amadora => Dict(
        Brasil => 6767,
        Ucrania => 507,
        CaboVerde => 5904,
        Romenia => 579,
        Angola => 1743,
        GuineBissau => 3035,
        ReinoUnido => 319,
        Moldavia => 55,
        China => 466,
        SaoTomeEPrincipe => 1019,
    ),

    Barreiro => Dict(
        Brasil => 2459,
        Ucrania => 75,
        CaboVerde => 831,
        Romenia => 50,
        Angola => 836,
        GuineBissau => 609,
        ReinoUnido => 63,
        Moldavia => 29,
        China => 178,
        SaoTomeEPrincipe => 280,
    ),

    Cascais => Dict(
        Brasil => 11937,
        Ucrania => 894,
        CaboVerde => 896,
        Romenia => 953,
        Angola => 593,
        GuineBissau => 975,
        ReinoUnido => 2560,
        Moldavia => 325,
        China => 781,
        SaoTomeEPrincipe => 92,
    ),

    Lisboa => Dict(
        Brasil => 22077,
        Ucrania => 1393,
        CaboVerde => 2124,
        Romenia => 1664,
        Angola => 2920,
        GuineBissau => 1430,
        ReinoUnido => 4621,
        Moldavia => 133,
        China => 5447,
        SaoTomeEPrincipe => 951,
    ),

    Loures => Dict(
        Brasil => 5964,
        Ucrania => 727,
        CaboVerde => 2011,
        Romenia => 760,
        Angola => 2329,
        GuineBissau => 2143,
        ReinoUnido => 135,
        Moldavia => 120,
        China => 465,
        SaoTomeEPrincipe => 2573,
    ),

    Mafra => Dict(
        Brasil => 3381,
        Ucrania => 289,
        CaboVerde => 39,
        Romenia => 261,
        Angola => 98,
        GuineBissau => 21,
        ReinoUnido => 304,
        Moldavia => 87,
        China => 153,
        SaoTomeEPrincipe => 25,
    ),

    Moita => Dict(
        Brasil => 1396,
        Ucrania => 78,
        CaboVerde => 802,
        Romenia => 84,
        Angola => 834,
        GuineBissau => 926,
        ReinoUnido => 62,
        Moldavia => 22,
        China => 165,
        SaoTomeEPrincipe => 298,
    ),

    Montijo => Dict(
        Brasil => 2406,
        Ucrania => 155,
        CaboVerde => 64,
        Romenia => 881,
        Angola => 499,
        GuineBissau => 44,
        ReinoUnido => 60,
        Moldavia => 86,
        China => 143,
        SaoTomeEPrincipe => 48,
    ),

    Odivelas => Dict(
        Brasil => 6306,
        Ucrania => 874,
        CaboVerde => 908,
        Romenia => 544,
        Angola => 2581,
        GuineBissau => 1969,
        ReinoUnido => 274,
        Moldavia => 81,
        China => 447,
        SaoTomeEPrincipe => 643,
    ),

    Oeiras => Dict(
        Brasil => 6580,
        Ucrania => 371,
        CaboVerde => 1446,
        Romenia => 311,
        Angola => 518,
        GuineBissau => 222,
        ReinoUnido => 278,
        Moldavia => 106,
        China => 468,
        SaoTomeEPrincipe => 87,
    ),

    Palmela => Dict(
        Brasil => 1388,
        Ucrania => 157,
        CaboVerde => 86,
        Romenia => 408,
        Angola => 204,
        GuineBissau => 38,
        ReinoUnido => 127,
        Moldavia => 71,
        China => 134,
        SaoTomeEPrincipe => 20,
    ),

    Seixal => Dict(
        Brasil => 5684,
        Ucrania => 195,
        CaboVerde => 2296,
        Romenia => 230,
        Angola => 1391,
        GuineBissau => 468,
        ReinoUnido => 178,
        Moldavia => 61,
        China => 251,
        SaoTomeEPrincipe => 1436,
    ),

    Sesimbra => Dict(
        Brasil => 1561,
        Ucrania => 100,
        CaboVerde => 121,
        Romenia => 139,
        Angola => 145,
        GuineBissau => 17,
        ReinoUnido => 125,
        Moldavia => 84,
        China => 88,
        SaoTomeEPrincipe => 22,
    ),

    Setubal => Dict(
        Brasil => 5327,
        Ucrania => 322,
        CaboVerde => 499,
        Romenia => 722,
        Angola => 685,
        GuineBissau => 85,
        ReinoUnido => 229,
        Moldavia => 150,
        China => 349,
        SaoTomeEPrincipe => 45,
    ),

    Sintra => Dict(
        Brasil => 13687,
        Ucrania => 1382,
        CaboVerde => 8011,
        Romenia => 1660,
        Angola => 5226,
        GuineBissau => 6187,
        ReinoUnido => 611,
        Moldavia => 377,
        China => 846,
        SaoTomeEPrincipe => 1414,
    ),

    VilaFrancaDeXira => Dict(
        Brasil => 4440,
        Ucrania => 397,
        CaboVerde => 762,
        Romenia => 523,
        Angola => 825,
        GuineBissau => 571,
        ReinoUnido => 64,
        Moldavia => 116,
        China => 258,
        SaoTomeEPrincipe => 254,
    ),
)

FOREIGNERS_POOL = Dict(location => ForeignCountry[] for location in HOUSE_LOCATION_INSTANCES)

for (location, foreigners) in FOREIGNERS_PER_COUNTRY_MAP
    if !(location in HOUSE_LOCATION_INSTANCES)
        continue
    end
    for (country, count) in foreigners
        for _ in 1:round(count * (200 / sum([foreigners[foreignCountry] for foreignCountry in keys(foreigners)])))
            push!(FOREIGNERS_POOL[location], country)
        end
    end
end

const LISBON_GROSS_DISPOSABLE_INCOME = adjust_value_to_inflation(17241) # 2021 value

const LISBON_GDP_PER_CAPITA = adjust_value_to_inflation(26588)
const THIRD_QUINTILE_INCOME_LMA = adjust_value_to_inflation(14990)

const GDP_PER_CAPITA_MAP = Dict(
    Brasil => adjust_value_to_inflation(9673),
    Ucrania => adjust_value_to_inflation(4825),
    CaboVerde => adjust_value_to_inflation(4043),
    Romenia => adjust_value_to_inflation(16094),
    Angola => adjust_value_to_inflation(3437),
    GuineBissau => adjust_value_to_inflation(820),
    ReinoUnido => adjust_value_to_inflation(46510),
    Moldavia => adjust_value_to_inflation(5714),
    China => adjust_value_to_inflation(12970),
    SaoTomeEPrincipe => adjust_value_to_inflation(2422),
)

const FOREIGNER_PERCENTILE_MULTIPLIER = Dict(foreignCountry => GDP_PER_CAPITA_MAP[foreignCountry] / LISBON_GDP_PER_CAPITA for foreignCountry in keys(GDP_PER_CAPITA_MAP))

#https://censos.ine.pt/xportal/xmain?xpgid=censos21_populacao&xpid=CENSOS21
const NUMBER_OF_PEOPLE_WITH_AGES_LMA = Dict(
    0 => 134741 + 127979,
    10 => 153734 + 146714,
    20 => 161488 + 161469,
    30 => 175513 + 185894,
    40 => 212770 + 235831,
    50 => 176750 + 204599,
    60 => 148212 + 185317,
    70 => 121692 + 158697,
    80 => 56832 + 91280,
    90 => 8103 + 21407,
)

# convert person's ages to households 
# (move the people below 30 to the 30s, 40s, 50s, as the households ages 
# are represented by the older person)
const NUMBER_OF_HOUSEHOLDS_WITH_AGES_LMA = Dict(
    20 => NUMBER_OF_PEOPLE_WITH_AGES_LMA[20] / 2,
    30 => NUMBER_OF_PEOPLE_WITH_AGES_LMA[30],
    40 => NUMBER_OF_PEOPLE_WITH_AGES_LMA[40],
    50 => NUMBER_OF_PEOPLE_WITH_AGES_LMA[50],
    60 => NUMBER_OF_PEOPLE_WITH_AGES_LMA[60],
    70 => NUMBER_OF_PEOPLE_WITH_AGES_LMA[70],
    80 => NUMBER_OF_PEOPLE_WITH_AGES_LMA[80],
    90 => NUMBER_OF_PEOPLE_WITH_AGES_LMA[90],
)

const INITIAL_WEALTH_MULTIPLIER = 0.8