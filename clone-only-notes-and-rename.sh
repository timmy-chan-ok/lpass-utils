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
done


A=$(./extract-component-name.sh "$lpass_response")
echo $A


response_ids=""
get_ids_from_lpass_query() {
    local ids=$(echo "$lpass_response" | grep -oP 'id: \K\d+') >/dev/null
    response_ids=$ids
}

get_ids_from_lpass_query "$SEARCH_QUERY" >/dev/null


#echo "$response_ids"
echo "$response_ids" | while read -r a; do 
    echo "Processing $a";
    lpass duplicate
done


#A=$(echo "$response_ids" | head -1)
#echo $A





while true; do
    echo 
    read -p "Do you wish to sync now? " yn
    case $yn in
        [Yy]* ) echo; break;;
        [Nn]* ) echo " > Not synced yet"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

lpass sync

# printf "okonomi" | lpass add --sync=no --non-interactive --notes Shared-secrets-okonomi-test/okonomi-ordre-api.test.jms.activemq.userblfddab1