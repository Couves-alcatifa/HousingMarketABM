locations=("Amadora" "Cascais" "Lisboa" "Loures" "Mafra" "Odivelas" "Oeiras" "Sintra" "VilaFrancaDeXira" "Alcochete" "Almada" "Barreiro" "Moita" "Montijo" "Palmela" "Seixal" "Sesimbra" "Setubal")
for location in ${locations[@]}
do
    python generateScope.py $location
    ./run.sh
    ./push_run_in_location.sh $location
done
