# Duplicate and set name
# Assume that ALL secrets only contain information in notes

LOCAL_SECRET_SHARE=Shared-secrets-kommunikasjon-test



# Check if the first command-line argument is empty
if [[ -z "$1" ]]; then
    # Prompt the user to enter a search query if no argument is provided
    read -p "Enter original secret path: " SECRET_PATH_ORIG
else
    SECRET_PATH_ORIG=$1
fi

# Check if the second command-line argument is empty
if [[ -z "$2" ]]; then
    read -p "Enter original secret path: " SECRET_PATH_NEW
else
    SECRET_PATH_NEW=$2
fi


echo "The following operation will be performed: Make a copy of secret"
echo "Original: $SECRET_PATH_ORIG"
echo "Copy:     $SECRET_PATH_NEW"


while true; do
    echo 
    read -p "Are you sure you want to proceed? " yn
    case $yn in
        [Yy]* ) echo; break;;
        [Nn]* ) echo " > No secrets generated"; exit;;
        * ) echo " > Please answer yes or no.";;
    esac
    sleep 0.5  # Wait for half second before the next iteration
done


SECRET_NOTE=$(lpass show $SECRET_PATH_ORIG --notes)

printf "$SECRET_NOTE" | lpass add $SECRET_PATH_NEW --notes --non-interactive 

lpass sync
