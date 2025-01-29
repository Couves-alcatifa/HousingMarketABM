# locations=("Amadora" "Cascais" "Lisboa" "Loures" "Mafra" "Odivelas" "Oeiras" "Sintra" "VilaFrancaDeXira" "Alcochete" "Almada" "Barreiro" "Moita" "Montijo" "Palmela" "Seixal" "Sesimbra" "Setubal")
locations=("Amadora" "Cascais" "Loures" "Mafra" "VilaFrancaDeXira" "Alcochete" "Barreiro" "Moita" "Palmela" "Seixal" "Sesimbra" "Setubal")
# locations=("Palmela" "Seixal", "Sesimbra")
for location in ${locations[@]}
do
    python generateScope.py $location
    ./run.sh
    ./push_run_in_location.sh $location
done
