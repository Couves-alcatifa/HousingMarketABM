

location="Oeiras"
python generateScope.py $location

policies=("ConstructionVatReduction" "ConstructionLicensingSimplification" "RentSubsidy" "NonResidentsProhibition")
for policy in ${policies[@]}
do
    sed -i "s/const CURRENT_POLICIES = Policy.*/const CURRENT_POLICIES = Policy[$policy]/" policies.jl
    ./run.sh
    git add .
    git commit -m "run in $location with $policy"
    git push
done