#!/bin/bash

# Assume the input argument is an ID in lastpass, not a name.
#5343706986289480045

if [[ -z "$1" ]]; then
    set -- "1038559031490683608"
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
    read -p "Do you wish to clone the secret? " yn
    case $yn in
        [Yy]* ) echo; break;;
        [Nn]* ) echo " > None cloned"; exit;;
        * ) echo " > Please answer yes or no.";;
    esac
done

lpass_response=$(echo "$lpass_response" | head -n 1)

A=$(./extract-component-name.sh "$lpass_response")
echo $A


path=$(echo "$lpass_response" | sed 's/ \[id: .*$//')
id=$(echo "$lpass_response" | grep -oP 'id: \K\d+') 
echo Path: "$path".
echo ID: "$id".

# response_ids=""
# get_ids_from_lpass_query() {
#     local ids=$(echo "$lpass_response" | grep -oP 'id: \K\d+') >/dev/null
#     response_ids=$ids
# }

# get_ids_from_lpass_query "$SEARCH_QUERY" >/dev/null

lpass duplicate --sync=now "$id"
lpass sync
lpass show $path



#------------------------------------------------------------------
# Loop and get the id of the duplicate
#------------------------------------------------------------------
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

    new_lastpass_response=$(lpass show $path) >/dev/null

    # Check if " [id: 0]" is present in the string
    if [[ $new_lastpass_response == *" [id: 0]"* ]]; then
        echo "Still syncing..."
    else
        break
    fi

    sleep 1  # Wait for 1 second before the next iteration
done

echo "Sync completed successfully."

new_id=$(echo "$new_lastpass_response" | grep -v " \[id: $id\]" | grep -oP 'id: \K\d+')

echo New ID: "$new_id".

# Rename and add " - Copy" suffix to the name of the secret
echo "$path - Copy" | lpass edit --non-interactive --name "$new_id"
