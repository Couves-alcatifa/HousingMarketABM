include("types.jl")
include("calibrationTable.jl")

MAX_BUCKET_SIZE = 50
NUMBER_OF_HOUSEHOLDS = 25000
NUMBER_OF_STEPS = 180
STARTING_GOV_WEALTH_PER_CAPITA = 100000.0
STARTING_COMPANY_WEALTH_PER_CAPITA = 60000.0
STARTING_BANK_WEALTH_PER_CAPITA = 67000.0
STARTING_CONSTRUCTION_SECTOR_WEALTH_PER_CAPITA = 5000.0
STARTING_GOV_WEALTH = STARTING_GOV_WEALTH_PER_CAPITA * NUMBER_OF_HOUSEHOLDS
STARTING_COMPANY_WEALTH = STARTING_COMPANY_WEALTH_PER_CAPITA * NUMBER_OF_HOUSEHOLDS
STARTING_BANK_WEALTH = STARTING_BANK_WEALTH_PER_CAPITA * NUMBER_OF_HOUSEHOLDS
STARTING_CONSTRUCTION_SECTOR_WEALTH = STARTING_CONSTRUCTION_SECTOR_WEALTH_PER_CAPITA * NUMBER_OF_HOUSEHOLDS
INTEREST_RATE = 0.015
LTV = 0.90
DSTI = 0.35
IRS = 0.2
VAT = 0.15
SOCIAL_SECURITY_TAX = 0.11
MAX_EFFORT_FOR_RENT = 0.5
FRACTION_OF_HOMEOWNERS = 0.7
FRACTION_OF_DOUBLE_OWNERS = 0.3
CONSTRUCTION_DELAY_MIN = 24
CONSTRUCTION_DELAY_MAX = 48
CONSTRUCTION_COSTS_MIN = 1500 # to be multiplied by the area of the house
CONSTRUCTION_COSTS_MAX = 2500 # to be multiplied by the area of the house
CONSTRUCTION_TIME_MIN = 12
CONSTRUCTION_TIME_MAX = 18
CONSTRUCTION_VAT = 0.23
LAND_COSTS = 1000 # TODO: this should be a dict, different price for each region
PROJECT_COST_MULTIPLIER = 1.1
RENT_TAX = 0.25

INITIAL_WEALTH_MULTIPLICATION_BASE = 1.0
INITIAL_WEALTH_MULTIPLICATION_ROOF = 4.0
INITIAL_WEALTH_MULTIPLICATION_AVERAGE = 12.0
INITIAL_WEALTH_MULTIPLICATION_STDEV = 6.0
CONSUMER_SURPLUS_MIN = 0.94
CONSUMER_SURPLUS_MAX = 1.05
CONSTRUCTION_SECTOR_MARKUP = 1.2


TotalTheoreticalNumberOfHouses = 1191363
# TheoreticalNumberOfHousesInGrandeLisboa = 858646
TheoreticalNumberOfHousesInAmadora = 73513
TheoreticalNumberOfHousesInCascais = 86465
TheoreticalNumberOfHousesInLisboa = 242044
TheoreticalNumberOfHousesInLoures =  81552
TheoreticalNumberOfHousesInMafra = 33152
TheoreticalNumberOfHousesInOdivelas = 60119
TheoreticalNumberOfHousesInOeiras = 73013
TheoreticalNumberOfHousesInSintra = 153147
TheoreticalNumberOfHousesInVilaFrancaDeXira = 55641
TheoreticalNumberOfHousesInAlcochete = 7411
TheoreticalNumberOfHousesInAlmada = 75485
TheoreticalNumberOfHousesInBarreiro = 34346
TheoreticalNumberOfHousesInMoita = 27489
TheoreticalNumberOfHousesInMontijo = 22104
TheoreticalNumberOfHousesInPalmela = 26622
TheoreticalNumberOfHousesInSeixal = 67534
TheoreticalNumberOfHousesInSesimbra = 20557
TheoreticalNumberOfHousesInSetubal = 51169

NUMBER_OF_HOUSES=NUMBER_OF_HOUSEHOLDS

# TODO: region hack
MODEL_SCALE = NUMBER_OF_HOUSES / TheoreticalNumberOfHousesInLisboa
# MODEL_SCALE = NUMBER_OF_HOUSES / TotalTheoreticalNumberOfHouses

# NUMBER_OF_HOUSES_IN_GrandeLisboa = (TheoreticalNumberOfHousesInGrandeLisboa / TotalTheoreticalNumberOfHouses) * NUMBER_OF_HOUSES 
NUMBER_OF_HOUSES_MAP = Dict(
    Amadora => TheoreticalNumberOfHousesInAmadora * MODEL_SCALE,
    Cascais => TheoreticalNumberOfHousesInCascais * MODEL_SCALE,
    Lisboa => TheoreticalNumberOfHousesInLisboa * MODEL_SCALE,
    Loures => TheoreticalNumberOfHousesInLoures * MODEL_SCALE,
    Mafra => TheoreticalNumberOfHousesInMafra * MODEL_SCALE,
    Odivelas => TheoreticalNumberOfHousesInOdivelas * MODEL_SCALE,
    Oeiras => TheoreticalNumberOfHousesInOeiras * MODEL_SCALE,
    Sintra => TheoreticalNumberOfHousesInSintra * MODEL_SCALE,
    VilaFrancaDeXira => TheoreticalNumberOfHousesInVilaFrancaDeXira * MODEL_SCALE,
    Alcochete => TheoreticalNumberOfHousesInAlcochete * MODEL_SCALE,
    Almada => TheoreticalNumberOfHousesInAlmada * MODEL_SCALE,
    Barreiro => TheoreticalNumberOfHousesInBarreiro * MODEL_SCALE,
    Moita => TheoreticalNumberOfHousesInMoita * MODEL_SCALE,
    Montijo => TheoreticalNumberOfHousesInMontijo * MODEL_SCALE,
    Palmela => TheoreticalNumberOfHousesInPalmela * MODEL_SCALE,
    Seixal => TheoreticalNumberOfHousesInSeixal * MODEL_SCALE,
    Sesimbra => TheoreticalNumberOfHousesInSesimbra * MODEL_SCALE,
    Setubal => TheoreticalNumberOfHousesInSetubal * MODEL_SCALE,
)

FIRST_QUARTILE_RENT_MAP = Dict(
    Amadora => 7.14,
    Cascais => 8.62,
    Lisboa => 8.89,
    Loures => 5.94,
    Mafra => 5.03,
    Odivelas => 6.12,
    Oeiras => 8.05,
    Sintra => 5.67,
    VilaFrancaDeXira => 5.56,
    Alcochete => 5.35,
    Almada => 6.75,
    Barreiro => 5.80,
    Moita => 4.99,
    Montijo => 5.26,
    Palmela => 4.74,
    Seixal => 5.52,
    Sesimbra => 4.22,
    Setubal => 5.17,
)

MEDIAN_RENT_MAP = Dict(
    Amadora => 8.85,
    Cascais => 10.95,
    Lisboa => 11.24,
    Loures => 7.90,
    Mafra => 6.94,
    Odivelas => 8.43,
    Oeiras =>.10,
    Sintra => 7.46,
    VilaFrancaDeXira => 7.09,
    Alcochete => 6.74,
    Almada => 8.58,
    Barreiro => 7.24,
    Moita => 6.21,
    Montijo => 6.48,
    Palmela => 6.03,
    Seixal => 7.01,
    Sesimbra => 6.07,
    Setubal => 6.85,
)

THIRD_QUARTILE_RENT_MAP = Dict(
    Amadora => 10.66,
    Cascais => 13.84,
    Lisboa => 13.87,
    Loures => 9.75,
    Mafra => 8.92,
    Odivelas => 10.15,
    Oeiras => 12.17,
    Sintra => 9.10,
    VilaFrancaDeXira => 8.51,
    Alcochete => 8.66,
    Almada => 10.59,
    Barreiro => 8.66,
    Moita => 7.78,
    Montijo => 7.58,
    Palmela => 7.57,
    Seixal => 8.50,
    Sesimbra => 7.78,
    Setubal => 8.42,
)

FIRST_QUARTILE_SALES_MAP = Dict(
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

MEDIAN_SALES_MAP = Dict(
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

THIRD_QUARTILE_SALES_MAP = Dict(
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

color_map = Dict(
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

sizes_color_map = Dict(
    LessThan50 => :olive,
    LessThan75 => :cyan,
    LessThan125 => :pink,
    More => :gold
)

Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_1 = 336274
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Alcochete = 1699
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Almada = 22459
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Amadora = 22151
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Barreiro = 10183
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Cascais = 23431
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Lisboa =  85477
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Loures =  20967
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Mafra = 7359
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Moita = 7285
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Montijo = 5440
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Odivelas = 15483
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Oeiras = 22114
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Palmela = 6195
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Seixal = 16387
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Sesimbra = 4636
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Setubal = 13899
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_Sintra = 37771
Theoretical_HOUSEHOLDS_WITH_SIZE_1_IN_VilaFrancaDeXira = 13338
Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_2 = 392111
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Alcochete = 2289
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Almada = 25601
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Amadora = 24547
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Barreiro = 12161
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Cascais = 27793
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Lisboa =  78584
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Loures =  27299
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Mafra = 10276
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Moita = 9270
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Montijo = 7231
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Odivelas = 19776
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Oeiras = 23966
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Palmela = 8843
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Seixal = 23196
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Sesimbra = 6742
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Setubal = 17253
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_Sintra = 48985
Theoretical_HOUSEHOLDS_WITH_SIZE_2_IN_VilaFrancaDeXira = 18299
Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_3 = 238291
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Alcochete = 1675
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Almada = 14318
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Amadora = 14246
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Barreiro = 6769
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Cascais = 17047
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Lisboa =  39037
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Loures =  17089
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Mafra = 7544
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Moita = 5879
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Montijo = 4974
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Odivelas = 12703
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Oeiras = 13479
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Palmela = 5853
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Seixal = 14841
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Sesimbra = 4644
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Setubal = 10598
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_Sintra = 34425
Theoretical_HOUSEHOLDS_WITH_SIZE_3_IN_VilaFrancaDeXira = 13170
Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_4 = 160982
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Alcochete = 1347
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Almada = 9462
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Amadora = 8682
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Barreiro = 3881
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Cascais = 12688
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Lisboa =  26629
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Loures =  11535
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Mafra = 6060
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Moita = 3610
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Montijo = 3277
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Odivelas = 8843
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Oeiras = 9703
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Palmela = 4318
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Seixal = 9630
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Sesimbra = 3378
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Setubal = 6954
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_Sintra = 22670
Theoretical_HOUSEHOLDS_WITH_SIZE_4_IN_VilaFrancaDeXira = 8315
Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_GT_5 = 65326
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Alcochete = 427
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Almada = 3852
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Amadora = 3913
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Barreiro = 1372
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Cascais = 5525
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Lisboa =  12844
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Loures =  4812
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Mafra = 1970
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Moita = 1462
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Montijo = 1233
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Odivelas = 3334
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Oeiras = 3764
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Palmela = 1569
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Seixal = 3615
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Sesimbra = 1164
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Setubal = 2525
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_Sintra = 9371
Theoretical_HOUSEHOLDS_WITH_SIZE_GT_5_IN_VilaFrancaDeXira = 2574


TOTAL_HOUSEHOLDS_WITH_SIZE_1 = Int64(round(MODEL_SCALE * Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_1))

HOUSEHOLDS_WITH_SIZE_1_MAP = Dict(
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

TOTAL_HOUSEHOLDS_WITH_SIZE_2 = Int64(round(MODEL_SCALE * Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_2))
HOUSEHOLDS_WITH_SIZE_2_MAP = Dict(
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

TOTAL_HOUSEHOLDS_WITH_SIZE_3 = Int64(round(MODEL_SCALE * Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_3))
HOUSEHOLDS_WITH_SIZE_3_MAP = Dict(
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

TOTAL_HOUSEHOLDS_WITH_SIZE_4 = Int64(round(MODEL_SCALE * Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_4))
HOUSEHOLDS_WITH_SIZE_4_MAP = Dict(
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

TOTAL_HOUSEHOLDS_WITH_SIZE_GT_5 = Int64(round(MODEL_SCALE * Theoretical_TOTAL_HOUSEHOLDS_WITH_SIZE_GT_5))
HOUSEHOLDS_WITH_SIZE_GT_5_MAP = Dict(
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

HOUSEHOLDS_SIZES_MAP = Dict(
    1 => HOUSEHOLDS_WITH_SIZE_1_MAP,
    2 => HOUSEHOLDS_WITH_SIZE_2_MAP,
    3 => HOUSEHOLDS_WITH_SIZE_3_MAP,
    4 => HOUSEHOLDS_WITH_SIZE_4_MAP,
    5 => HOUSEHOLDS_WITH_SIZE_GT_5_MAP,
)

HOME_OWNERS_MAP = Dict(
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

NOT_HOME_OWNERS_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LT_10_M2_PER_PERSON_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LT_15_M2_PER_PERSON_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LT_20_M2_PER_PERSON_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LT_30_M2_PER_PERSON_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LT_40_M2_PER_PERSON_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LT_60_M2_PER_PERSON_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LT_80_M2_PER_PERSON_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_MT_80_M2_PER_PERSON_MAP = Dict(
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


FIRST_QUINTILE_INCOME_IN_Alcochete = 7532 / 12
FIRST_QUINTILE_INCOME_IN_Almada = 6937 / 12
FIRST_QUINTILE_INCOME_IN_Amadora = 6650 / 12
FIRST_QUINTILE_INCOME_IN_Barreiro = 7162 / 12
FIRST_QUINTILE_INCOME_IN_Cascais = 7004 / 12
FIRST_QUINTILE_INCOME_IN_Lisboa = 7308 / 12
FIRST_QUINTILE_INCOME_IN_Loures = 7006 / 12
FIRST_QUINTILE_INCOME_IN_Mafra = 6764 / 12
FIRST_QUINTILE_INCOME_IN_Moita = 6678 / 12
FIRST_QUINTILE_INCOME_IN_Montijo = 6691 / 12
FIRST_QUINTILE_INCOME_IN_Odivelas = 6793 / 12
FIRST_QUINTILE_INCOME_IN_Oeiras = 8424 / 12
FIRST_QUINTILE_INCOME_IN_Palmela = 6780 / 12
FIRST_QUINTILE_INCOME_IN_Seixal = 7126 / 12
FIRST_QUINTILE_INCOME_IN_Sesimbra = 6900 / 12
FIRST_QUINTILE_INCOME_IN_Setubal = 6930 / 12
FIRST_QUINTILE_INCOME_IN_Sintra = 6797 / 12
FIRST_QUINTILE_INCOME_IN_VilaFrancaDeXira = 7604 / 12


SECOND_QUINTILE_INCOME_IN_Alcochete = 10874 / 12
SECOND_QUINTILE_INCOME_IN_Almada = 10294 / 12
SECOND_QUINTILE_INCOME_IN_Amadora = 9713 / 12
SECOND_QUINTILE_INCOME_IN_Barreiro = 10140 / 12
SECOND_QUINTILE_INCOME_IN_Cascais = 10784 / 12
SECOND_QUINTILE_INCOME_IN_Lisboa = 11575 / 12
SECOND_QUINTILE_INCOME_IN_Loures = 9975 / 12
SECOND_QUINTILE_INCOME_IN_Mafra = 10077 / 12
SECOND_QUINTILE_INCOME_IN_Moita = 9517 / 12
SECOND_QUINTILE_INCOME_IN_Montijo = 9772 / 12
SECOND_QUINTILE_INCOME_IN_Odivelas = 9930 / 12
SECOND_QUINTILE_INCOME_IN_Oeiras = 12981 / 12
SECOND_QUINTILE_INCOME_IN_Palmela = 9996 / 12
SECOND_QUINTILE_INCOME_IN_Seixal = 10387 / 12
SECOND_QUINTILE_INCOME_IN_Sesimbra = 10159 / 12
SECOND_QUINTILE_INCOME_IN_Setubal = 10175 / 12
SECOND_QUINTILE_INCOME_IN_Sintra = 9892 / 12
SECOND_QUINTILE_INCOME_IN_VilaFrancaDeXira = 10648 / 12

THIRD_QUINTILE_INCOME_IN_Alcochete = 16169 / 12
THIRD_QUINTILE_INCOME_IN_Almada = 14750 / 12
THIRD_QUINTILE_INCOME_IN_Amadora = 13381 / 12
THIRD_QUINTILE_INCOME_IN_Barreiro = 13662 / 12
THIRD_QUINTILE_INCOME_IN_Cascais = 16480 / 12
THIRD_QUINTILE_INCOME_IN_Lisboa = 18918 / 12
THIRD_QUINTILE_INCOME_IN_Loures = 13702 / 12
THIRD_QUINTILE_INCOME_IN_Mafra = 14539 / 12
THIRD_QUINTILE_INCOME_IN_Moita = 12528 / 12
THIRD_QUINTILE_INCOME_IN_Montijo = 13748 / 12
THIRD_QUINTILE_INCOME_IN_Odivelas = 13918 / 12
THIRD_QUINTILE_INCOME_IN_Oeiras = 20024 / 12
THIRD_QUINTILE_INCOME_IN_Palmela = 14193 / 12
THIRD_QUINTILE_INCOME_IN_Seixal = 14328 / 12
THIRD_QUINTILE_INCOME_IN_Sesimbra = 14009 / 12
THIRD_QUINTILE_INCOME_IN_Setubal = 14297 / 12
THIRD_QUINTILE_INCOME_IN_VilaFrancaDeXira = 14252 / 12
THIRD_QUINTILE_INCOME_IN_Sintra = 13417 / 12


FOURTH_QUINTILE_INCOME_IN_Alcochete = 26716 / 12
FOURTH_QUINTILE_INCOME_IN_Almada = 23502 / 12
FOURTH_QUINTILE_INCOME_IN_Amadora = 20882 / 12
FOURTH_QUINTILE_INCOME_IN_Barreiro = 20486 / 12
FOURTH_QUINTILE_INCOME_IN_Cascais = 27978 / 12
FOURTH_QUINTILE_INCOME_IN_Lisboa = 33444 / 12
FOURTH_QUINTILE_INCOME_IN_Loures = 21271 / 12
FOURTH_QUINTILE_INCOME_IN_Mafra = 23325 / 12
FOURTH_QUINTILE_INCOME_IN_Moita = 17930 / 12
FOURTH_QUINTILE_INCOME_IN_Montijo = 21880 / 12
FOURTH_QUINTILE_INCOME_IN_Odivelas = 21633 / 12
FOURTH_QUINTILE_INCOME_IN_Oeiras = 32601 / 12
FOURTH_QUINTILE_INCOME_IN_Palmela = 21810 / 12
FOURTH_QUINTILE_INCOME_IN_Seixal = 21505 / 12
FOURTH_QUINTILE_INCOME_IN_Sesimbra = 20735 / 12
FOURTH_QUINTILE_INCOME_IN_Setubal = 22410 / 12
FOURTH_QUINTILE_INCOME_IN_Sintra = 20169 / 12
FOURTH_QUINTILE_INCOME_IN_VilaFrancaDeXira = 20828 / 12

FOREIGN_RESIDENTS_IN_Alcochete = 1388 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Almada = 16570 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Amadora = 23834 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Barreiro = 5768 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Cascais = 34097 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Lisboa = 108653 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Loures = 21579 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Mafra = 6116 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Moita = 4460 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Montijo = 5848 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Odivelas = 20788 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Oeiras = 14070 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Palmela = 3469 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Seixal = 12904 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Sesimbra = 3290 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Setúbal = 9509 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_Sintra = 42475 * MODEL_SCALE
FOREIGN_RESIDENTS_IN_VilaFrancaDeXira = 9177 * MODEL_SCALE


NEW_FOREIGN_RESIDENTS_IN_Alcochete = 192 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Almada = 2739 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Amadora = 3239 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Barreiro = 997 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Cascais = 4937 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Lisboa = 18664 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Loures = 3337 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Mafra = 1121 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Moita = 782 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Montijo = 903 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Odivelas = 3267 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Oeiras = 2086 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Palmela = 550 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Seixal = 2206 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Sesimbra = 510 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Setubal = 1535 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_Sintra = 6077 * MODEL_SCALE
NEW_FOREIGN_RESIDENTS_IN_VilaFrancaDeXira = 1141 * MODEL_SCALE


BIRTH_RATE = 9.8/1000
PROBABILITY_OF_BIRTH_IN_Alcochete = 7.9 / 1000
PROBABILITY_OF_BIRTH_IN_Almada = 8.8 / 1000
PROBABILITY_OF_BIRTH_IN_Amadora = 10.0 / 1000
PROBABILITY_OF_BIRTH_IN_Barreiro = 8.3 / 1000
PROBABILITY_OF_BIRTH_IN_Cascais = 8.0 / 1000
PROBABILITY_OF_BIRTH_IN_Lisboa = 9.9 / 1000
PROBABILITY_OF_BIRTH_IN_Loures = 10.2 / 1000
PROBABILITY_OF_BIRTH_IN_Mafra = 8.6 / 1000
PROBABILITY_OF_BIRTH_IN_Moita = 10.2 / 1000
PROBABILITY_OF_BIRTH_IN_Montijo = 10.2 / 1000
PROBABILITY_OF_BIRTH_IN_Odivelas = 11.1 / 1000
PROBABILITY_OF_BIRTH_IN_Oeiras = 8.3 / 1000
PROBABILITY_OF_BIRTH_IN_Palmela = 8.4 / 1000
PROBABILITY_OF_BIRTH_IN_Seixal = 8.8 / 1000
PROBABILITY_OF_BIRTH_IN_Sesimbra = 8.2 / 1000
PROBABILITY_OF_BIRTH_IN_Setubal = 8.0 / 1000
PROBABILITY_OF_BIRTH_IN_Sintra = 9.6 / 1000
PROBABILITY_OF_BIRTH_IN_VilaFrancaDeXira = 8.9 / 1000

MORTALITY_RATE = 10.9 / 1000
PROBABILITY_OF_DEATH_IN_Alcochete = 8.6 / 1000
PROBABILITY_OF_DEATH_IN_Almada = 12.5 / 1000
PROBABILITY_OF_DEATH_IN_Amadora = 11.1 / 1000
PROBABILITY_OF_DEATH_IN_Barreiro = 13.7 / 1000
PROBABILITY_OF_DEATH_IN_Cascais = 11.2 / 1000
PROBABILITY_OF_DEATH_IN_Lisboa = 14.1 / 1000
PROBABILITY_OF_DEATH_IN_Loures = 11.5 / 1000
PROBABILITY_OF_DEATH_IN_Mafra = 9.1 / 1000
PROBABILITY_OF_DEATH_IN_Moita = 12.9 / 1000
PROBABILITY_OF_DEATH_IN_Montijo = 11.5 / 1000
PROBABILITY_OF_DEATH_IN_Odivelas = 10.6 / 1000
PROBABILITY_OF_DEATH_IN_Oeiras = 10.9 / 1000
PROBABILITY_OF_DEATH_IN_Palmela = 13.0 / 1000
PROBABILITY_OF_DEATH_IN_Seixal = 10.5 / 1000
PROBABILITY_OF_DEATH_IN_Sesimbra = 10.7 / 1000
PROBABILITY_OF_DEATH_IN_Setubal = 13.6 / 1000
PROBABILITY_OF_DEATH_IN_Sintra = 9.1 / 1000
PROBABILITY_OF_DEATH_IN_VilaFrancaDeXira = 9.8 / 1000

MIGRATION_RATE_IN_Alcochete = 177 * MODEL_SCALE
MIGRATION_RATE_IN_Almada = 3810 * MODEL_SCALE
MIGRATION_RATE_IN_Amadora = 4629 * MODEL_SCALE
MIGRATION_RATE_IN_Barreiro = 1308 * MODEL_SCALE
MIGRATION_RATE_IN_Cascais = 5774 * MODEL_SCALE
MIGRATION_RATE_IN_Lisboa = 25169 * MODEL_SCALE
MIGRATION_RATE_IN_Loures = 4544 * MODEL_SCALE
MIGRATION_RATE_IN_Mafra = 1284 * MODEL_SCALE
MIGRATION_RATE_IN_Moita = 1063 * MODEL_SCALE
MIGRATION_RATE_IN_Montijo = 1164 * MODEL_SCALE
MIGRATION_RATE_IN_Odivelas = 4738 * MODEL_SCALE
MIGRATION_RATE_IN_Oeiras = 2762 * MODEL_SCALE
MIGRATION_RATE_IN_Palmela = 609 * MODEL_SCALE
MIGRATION_RATE_IN_Seixal = 2881 * MODEL_SCALE
MIGRATION_RATE_IN_Sesimbra = 543 * MODEL_SCALE
MIGRATION_RATE_IN_Setubal = 2001 * MODEL_SCALE
MIGRATION_RATE_IN_Sintra = 7733 * MODEL_SCALE
MIGRATION_RATE_IN_VilaFrancaDeXira = 1628 * MODEL_SCALE

NUMBER_OF_HOUSEHOLDS_MAP = Dict(
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
0.66

migrationValueMap = Dict(
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

PROBABILITY_OF_DIVORCE_IN_Alcochete = 2.3 / 1000
PROBABILITY_OF_DIVORCE_IN_Almada = 1.6 / 1000
PROBABILITY_OF_DIVORCE_IN_Amadora = 1.6 / 1000
PROBABILITY_OF_DIVORCE_IN_Barreiro = 1.7 / 1000
PROBABILITY_OF_DIVORCE_IN_Cascais = 1.8 / 1000
PROBABILITY_OF_DIVORCE_IN_Lisboa = 1.4 / 1000
PROBABILITY_OF_DIVORCE_IN_Loures = 1.4 / 1000
PROBABILITY_OF_DIVORCE_IN_Mafra = 1.8 / 1000
PROBABILITY_OF_DIVORCE_IN_Moita = 1.9 / 1000
PROBABILITY_OF_DIVORCE_IN_Montijo = 1.6 / 1000
PROBABILITY_OF_DIVORCE_IN_Odivelas = 1.5 / 1000
PROBABILITY_OF_DIVORCE_IN_Oeiras = 1.4 / 1000
PROBABILITY_OF_DIVORCE_IN_Palmela = 1.9 / 1000
PROBABILITY_OF_DIVORCE_IN_Seixal = 1.9 / 1000
PROBABILITY_OF_DIVORCE_IN_Sesimbra = 1.7 / 1000
PROBABILITY_OF_DIVORCE_IN_Setubal = 2.0 / 1000
PROBABILITY_OF_DIVORCE_IN_Sintra = 1.7 / 1000
PROBABILITY_OF_DIVORCE_IN_VilaFrancaDeXira = 1.7 / 1000

RATIO_OF_FERTILE_WOMEN = 42.1 / 100
RATIO_OF_FERTILE_WOMEN_IN_Alcochete = 44.8 / 100
RATIO_OF_FERTILE_WOMEN_IN_Almada = 40.3 / 100
RATIO_OF_FERTILE_WOMEN_IN_Amadora = 42.1 / 100
RATIO_OF_FERTILE_WOMEN_IN_Barreiro = 40.1 / 100
RATIO_OF_FERTILE_WOMEN_IN_Cascais = 39.6 / 100
RATIO_OF_FERTILE_WOMEN_IN_Lisboa = 41.5 / 100
RATIO_OF_FERTILE_WOMEN_IN_Loures = 41.8 / 100
RATIO_OF_FERTILE_WOMEN_IN_Mafra = 45.2 / 100
RATIO_OF_FERTILE_WOMEN_IN_Moita = 41.7 / 100
RATIO_OF_FERTILE_WOMEN_IN_Montijo = 45.2 / 100
RATIO_OF_FERTILE_WOMEN_IN_Odivelas = 43.1 / 100
RATIO_OF_FERTILE_WOMEN_IN_Oeiras = 40.0 / 100
RATIO_OF_FERTILE_WOMEN_IN_Palmela = 42.7 / 100
RATIO_OF_FERTILE_WOMEN_IN_Seixal = 42.4 / 100
RATIO_OF_FERTILE_WOMEN_IN_Sesimbra = 43.5 / 100
RATIO_OF_FERTILE_WOMEN_IN_Setubal = 40.6 / 100
RATIO_OF_FERTILE_WOMEN_IN_Sintra = 44.1 / 100
RATIO_OF_FERTILE_WOMEN_IN_VilaFrancaDeXira = 44.4 / 100


MAX_NEW_CONSTRUCTIONS_MAP = Dict(
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

HOUSES_BOUGHT_BY_NON_RESIDENTS = (4047 * MODEL_SCALE) / 12

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



NUMBER_OF_HOUSES_WITH_LessThan29_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LessThan39_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LessThan49_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LessThan59_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LessThan79_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LessThan99_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LessThan119_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LessThan149_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_LessThan199_MAP = Dict(
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

NUMBER_OF_HOUSES_WITH_MoreThan200_MAP = Dict(
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

NUMBER_OF_HOUSES_PER_SIZE_MAP = Dict(
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


NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan29_MAP = Dict(
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

NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan39_MAP = Dict(
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

NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan49_MAP = Dict(
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

NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan59_MAP = Dict(
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

NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan79_MAP = Dict(
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

NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan99_MAP = Dict(
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

NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan119_MAP = Dict(
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

NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan149_MAP = Dict(
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

NUMBER_OF_HOUSES_FOR_RENTAL_WITH_LessThan199_MAP = Dict(
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

NUMBER_OF_HOUSES_FOR_RENTAL_WITH_MoreThan200_MAP = Dict(
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

NUMBER_OF_HOUSES_FOR_RENTAL_PER_SIZE_MAP = Dict(
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