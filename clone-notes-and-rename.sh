#!/bin/bash


if [[ -z "$1" ]]; then
    set -- "ordre-api.test.jms.activemq.use"
    SEARCH_QUERY=$1
    #read -p "Hvilken lpass-cli search query? (eks. 'okonomi-epay-api.test.jms'): " SEARCH_QUERY
else
    SEARCH_QUERY=$1
fi

lpass_response="[empty response]"

lpass_response=$(lpass show -G "$SEARCH_QUERY") #>/dev/null

# Hvis det er ingen resultater fra lastpass. Avslutt skriptet
if [ $? -ne 0 ]; then
  echo "Kan ikke finne relaterte lastpass hemmeligheter til \""$SEARCH_QUERY"\""
  exit 0
fi


#------------------------------------------------------------------
# Ask user if it wants to clone the passwords from the results.
#------------------------------------------------------------------
echo "$lpass_response"
while true; do
    echo 
    read -p "Do you wish to clone the results for another component? " yn
    case $yn in
        [Yy]* ) echo; break;;
        [Nn]* ) echo " > None cloned"; exit;;
        * ) echo " > Please answer yes or no.";;
    esac
    sleep 1  # Wait for 1 second before the next iteration
done



if [[ -z "$2" ]]; then
    read -p "Hva er navnet til komponenten som du ønsker å duplisere til? " KOMPONENT_NAVN_NEW
else
    KOMPONENT_NAVN_NEW=$2
fi


#response_ids=""
#get_ids_from_lpass_query() {
#    local ids=$(echo "$lpass_response" | grep -oP 'id: \K\d+') >/dev/null
#    response_ids=$ids
#}
ids_from_lpass_query=$(echo "$lpass_response" | grep -oP 'id: \K\d+') >/dev/null
#get_ids_from_lpass_query "$SEARCH_QUERY" >/dev/null


#echo "$response_ids"
echo "$ids_from_lpass_query" | while read -r lpass_id_original; do 
    echo "Processing $lpass_id_original";
    lpass_path_original=$(echo "$lpass_response" | grep $lpass_id_original | sed 's/ \[id: .*$//')

    lpass duplicate --sync=now "$lpass_id_original"
    lpass sync
    #lpass show $path
    sleep 0.1

    timeout=60  # Maximum duration of the loop in seconds
    start_time=$(date +%s)  # Get the current timestamp in seconds

    while true; do
        current_time=$(date +%s)  # Get the current timestamp in seconds
        elapsed_time=$((current_time - start_time))  # Calculate elapsed time

        # Check if the elapsed time exceeds the timeout
        if [ "$elapsed_time" -gt "$timeout" ]; then
            echo "Error: Timeout reached. Could not fetch new duplicate ID from lastpass.
Make sure you are connected to internet. Exiting program with failure."
            exit 1
        fi

        new_lastpass_response=$(lpass show $lpass_path_original) >/dev/null

        # Check if " [id: 0]" is present in the string
        if [[ $new_lastpass_response == *" [id: 0]"* ]]; then
            echo "Fetching new ID..."
        else
            break
        fi

        sleep 1  # Wait for 1 second before the next iteration
    done

    lpass_id_new=$(echo "$new_lastpass_response" | grep -v " \[id: $lpass_id_original\]" | grep -oP 'id: \K\d+')


    A="$lpass_path_original"
    [[ $A == */* ]] && A1="${A%/*}"
    [[ $A == */* ]] && A="${A##*/}"
    [[ $A == *.* ]] && A3="${A#*.}"
    [[ $A == *.* ]] && A="${A%%.*}"
    A2="$A"

    # WARN: Antar at A1 og A3 existerer
    lpass_path_new="$A1/$KOMPONENT_NAVN_NEW.$A3"
    echo "  Original: $lpass_path_original [id: $lpass_id_original]"
    echo "  Cloned     : $lpass_path_new [id: $lpass_id_new]"

    # Endrer navn på lastpass ny secret
    echo "$lpass_path_new" | lpass edit --non-interactive --sync=no --name "$lpass_id_new"
done


while true; do
    echo 
    read -p "Do you wish to sync now? " yn
    case $yn in
        [Yy]* ) echo; break;;
        [Nn]* ) echo " > Not synced yet"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
    sleep 1  # Wait for 1 second before the next iteration
done

lpass Sync
