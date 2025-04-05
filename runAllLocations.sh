locations=("Amadora" "Cascais" "Lisboa" "Loures" "Mafra" "Odivelas" "Oeiras" "Sintra" "VilaFrancaDeXira" "Alcochete" "Almada" "Barreiro" "Moita" "Montijo" "Palmela" "Seixal" "Sesimbra" "Setubal")
# locations=("Lisboa" "Loures" "Sintra" "VilaFrancaDeXira" "Alcochete" "Almada" "Barreiro" "Montijo" "Palmela" "Seixal" "Sesimbra")
# locations=("Moita" "Setubal" "Amadora" "Oeiras" "Mafra" "Odivelas" "Cascais")
# locations=("Amadora" "VilaFrancaDeXira" "Barreiro" "Cascais")
# locations=("Montijo")
for location in ${locations[@]}
do
    python generateScope.py $location
    ./run.sh
    ./push_run_in_location.sh $location
done
