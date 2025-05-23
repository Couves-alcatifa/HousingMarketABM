@enum Policy begin
    ConstructionVatReduction = 1
    ConstructionLicensingSimplification = 2
    RentSubsidy = 3
    NonResidentsProhibition = 4
    Baseline = 5
    ReducedRentTax = 6
    RentsIncreaseCeiling = 7
end

const CURRENT_POLICIES = Policy[]
const POLICIES_STRING = join([string(policy) for policy in CURRENT_POLICIES], "_")

const RENT_SUBSIDY = 0.2
const REDUCED_PERMIT_TIME_MIN = 12
const REDUCED_PERMIT_TIME_MAX = 24
const REDUCED_VAT = 0.06
const REDUCED_RENT_TAX = 0.15
const RENTS_INCREASE_CEILLING = 1.02
