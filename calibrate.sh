# locations=("Cascais" "Odivelas" "Setubal" "Amadora")
locations=("Sesimbra" "Seixal" "Montijo" "Barreiro" "Mafra")

# policies=("Baseline" "ConstructionVatReduction" "ConstructionLicensingSimplification" "RentSubsidy" "NonResidentsProhibition")
# policies=("ConstructionVatReduction" "ConstructionLicensingSimplification" "RentSubsidy" "NonResidentsProhibition")
initialWealthMultipliers=("0.8" "0.6" "0.5" "0.3")
for location in ${locations[@]}
do
    for initialWealthMultiplier in ${initialWealthMultipliers[@]}
    do
        python generateScope.py $location
        sed -i "s/const INITIAL_WEALTH_MULTIPLIER =.*/const INITIAL_WEALTH_MULTIPLIER = $initialWealthMultiplier/" consts.jl
        ./run.sh
        git add .
        git commit -m "run in $location with initial wealth mult = $initialWealthMultiplier"
        git push
    done
done