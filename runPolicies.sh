# locations=("Cascais" "Odivelas" "Setubal")
locations=("Oeiras")

# policies=("ConstructionVatReduction" "ConstructionLicensingSimplification" "RentSubsidy" "NonResidentsProhibition" "Baseline")
policies=("Baseline" "ConstructionLicensingSimplification")
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