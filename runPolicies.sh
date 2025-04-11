# locations=("Cascais" "Odivelas" "Setubal" "Amadora")
locations=("Sesimbra" "Moita" "Oeiras" "Cascais")

# policies=("Baseline" "ConstructionVatReduction" "ConstructionLicensingSimplification" "RentSubsidy" "NonResidentsProhibition")
# policies=("ConstructionVatReduction" "ConstructionLicensingSimplification" "RentSubsidy" "NonResidentsProhibition")
policies=("Baseline" "ConstructionVatReduction" "ConstructionLicensingSimplification" "ReducedRentTax" "RentsIncreaseCeiling" "NonResidentsProhibition")
for location in ${locations[@]}
do
    for policy in ${policies[@]}
    do
        python generateScope.py $location
        sed -i "s/const CURRENT_POLICIES = Policy.*/const CURRENT_POLICIES = Policy[$policy]/" policies.jl
        ./run.sh
        git add .
        git commit -m "run in $location with $policy"
        git push
    done
done