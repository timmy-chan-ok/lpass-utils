#!/bin/bash

# Check if the first command-line argument is empty
if [[ -z "$1" ]]; then
    # Prompt the user to enter a search query if no argument is provided
    read -p "Enter search query? (ex. 'okonomi-ordre-api.*.jms.activemq') (tip: .* is wildcard): " SEARCH_QUERY
else
    # Use the provided command-line argument as the search query
    SEARCH_QUERY=$1
fi

# Retrieve the LastPass response for the given search query
lpass_response=$(lpass show -G "$SEARCH_QUERY") #>/dev/null

# Check if there are no results from LastPass. Exit the script if so.
if [ $? -ne 0 ]; then
  echo "There are no related LastPass secrets for \""$SEARCH_QUERY"\""
  exit 0
fi

echo "$lpass_response"

# Clean up the LastPass response. Check if the first line is "Multiple matches found."
if [[ "$(echo "$lpass_response" | head -n 1)" == "Multiple matches found." ]]; then
    # Remove the first line from lpass_response
    lpass_response=$(echo "$lpass_response" | sed '1d')
else
    # Keep only the first line
    lpass_response=$(echo "$lpass_response" | head -n 1)
fi

# Iterate over each line in the cleaned LastPass response, then get the component name only.
list_of_results=()
while IFS= read -r line; do
    A="$line"
    [[ $A == */* ]] && A="${A##*/}"
    [[ $A == *.* ]] && A="${A%%.*}"
    list_of_results+=("$A")
done << EOF
$lpass_response
EOF

# Check if all secrets in the list have the same component name
if [[ "$(printf "%s\n" "${list_of_results[@]}" | uniq -c | wc -l)" -eq 1 ]]; then
    echo "All secrets in the list are for the component: ${list_of_results[0]}"
else
    echo
    echo "There are multiple component names in the search results. The results must have the same component name."
    exit 0
fi

#------------------------------------------------------------------
# Ask user if it wants to clone the passwords from the results.
#------------------------------------------------------------------
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
    read -p "What name do you want to clone the secrets to? (ex. okonomi-ehf-api): " COMPONENT_NAME_CLONE
else
    COMPONENT_NAME_CLONE=$2
fi

ids_from_lpass_query=$(echo "$lpass_response" | grep -oP 'id: \K\d+') >/dev/null


#---------------------------------------------------------------------------------
# Loop each of the ids, duplicate the secret and rename it with the chosen name
#---------------------------------------------------------------------------------
echo "$ids_from_lpass_query" | while read -r lpass_id_original; do 
    echo "Processing $lpass_id_original";
    lpass_path_original=$(echo "$lpass_response" | grep $lpass_id_original | sed 's/ \[id: .*$//')

    # Create a duplicate for the selected LastPass secret
    lpass duplicate --sync=now "$lpass_id_original"
    lpass sync
    sleep 0.1

    timeout=60               # Maximum duration of the loop in seconds
    start_time=$(date +%s)   # Get the current timestamp in seconds

    while true; do
        current_time=$(date +%s)                     # Get the current timestamp in seconds
        elapsed_time=$((current_time - start_time))  # Calculate elapsed time

        # Check if the elapsed time exceeds the timeout
        if [ "$elapsed_time" -gt "$timeout" ]; then
            echo "Error: Timeout reached. Could not fetch new duplicate ID from LastPass."
            echo "Make sure you are connected to the internet. Exiting program with failure."
            exit 1
        fi

        lastpass_response_new=$(lpass show $lpass_path_original) >/dev/null

        # Check if the response contains the expected string " [id: 0]"
        if [[ $lastpass_response_new != *" [id: 0]"* ]]; then
            break  # Break the loop if a new duplicate ID is found
        fi

        echo "Fetching new ID..."
        sleep 1  # Wait for 1 second before the next iteration
    done

    # Extract the new duplicate ID from the LastPass response
    lpass_id_clone=$(echo "$lastpass_response_new" | grep -v " \[id: $lpass_id_original\]" | grep -oP 'id: \K\d+')

    
    # Split the original path into components
    A="$lpass_path_original"
    [[ $A == */* ]] && A1="${A%/*}"
    [[ $A == */* ]] && A="${A##*/}"
    [[ $A == *.* ]] && A3="${A#*.}"
    [[ $A == *.* ]] && A="${A%%.*}"
    A2="$A"

    # NOTE: Assumes that the secret is placed in a folder and the "." is used.
    # Construct the new clone path using the cloned component name and extension
    lpass_path_clone="$A1/$COMPONENT_NAME_CLONE.$A3"
    echo "  Original: $lpass_path_original [id: $lpass_id_original]"
    echo "  Cloned:   $lpass_path_clone [id: $lpass_id_clone]"

    # Rename the new LastPass entry to match the selected new clone path name
    echo "$lpass_path_clone" | lpass edit --non-interactive --sync=no --name "$lpass_id_clone"
done

lpass sync
echo "Synced"
