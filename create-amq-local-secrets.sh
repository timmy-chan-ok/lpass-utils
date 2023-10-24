
LOCAL_SECRET_SHARE=Shared-Team-Modernisering/AMQ-lokal

# Check if the first command-line argument is empty
if [[ -z "$1" ]]; then
    # Prompt the user to enter a search query if no argument is provided
    read -p "Enter component name (ex. 'okonomi-ordre-api'): " COMPONENT_NAME
else
    # Use the provided command-line argument as the search query
    COMPONENT_NAME=$1
fi
# Check if the second command-line argument is empty
if [[ -z "$2" ]]; then
    # Prompt the user to enter a search query if no argument is provided
    read -p "Enter share name (ex. 'Shared-Team-Modernisering' or 'Shared-secrets-okonomi-test'): " SHARE_NAME
else
    # Use the provided command-line argument as the search query
    SHARE_NAME=$2
fi


echo "The following secrets will be created:"
echo $SHARE_NAME/$COMPONENT_NAME.local.docker.broker.cert.pw
echo $SHARE_NAME/$COMPONENT_NAME.local.jms.activemq.ssl.keyStorePassword
echo $SHARE_NAME/$COMPONENT_NAME.local.jms.activemq.ssl.trustStorePassword
echo $SHARE_NAME/$COMPONENT_NAME.local.jms.activemq.password
echo $SHARE_NAME/$COMPONENT_NAME.local.jms.activemq.user
echo $SHARE_NAME/$COMPONENT_NAME.local.isolert-amq-component-local.p12


while true; do
    echo 
    read -p "Are you sure you want to generate these secrets to $SHARE_NAME/ for the component $COMPONENT_NAME? " yn
    case $yn in
        [Yy]* ) echo; break;;
        [Nn]* ) echo " > No secrets generated"; exit;;
        * ) echo " > Please answer yes or no.";;
    esac
    sleep 1  # Wait for 1 second before the next iteration
done


DOCKER_BROKER_CERT_PW=$(lpass show $LOCAL_SECRET_SHARE/eksempel-komponent.local.docker.broker.cert.pw --notes)
JMS_ACTIVEMQ_SSL_KEYSTOREPASSWORD=$(lpass show $LOCAL_SECRET_SHARE/eksempel-komponent.local.jms.activemq.ssl.keyStorePassword --notes)
JMS_ACTIVEMQ_SSL_TRUSTSTOREPASSWORD=$(lpass show $LOCAL_SECRET_SHARE/eksempel-komponent.local.jms.activemq.ssl.trustStorePassword --notes)
JMS_ACTIVEMQ_PASSWORD=$(lpass show $LOCAL_SECRET_SHARE/eksempel-komponent.local.jms.activemq.password --notes)
JMS_ACTIVEMQ_USER=$(lpass show $LOCAL_SECRET_SHARE/eksempel-komponent.local.jms.activemq.user --notes)
ISOLERT_AMQ_COMPONENT_LOCAL=$(lpass show $LOCAL_SECRET_SHARE/eksempel-komponent.local.isolert-amq-component-local.p12 --notes)

printf "$DOCKER_BROKER_CERT_PW" | lpass add $SHARE_NAME/$COMPONENT_NAME.local.docker.broker.cert.pw --notes --non-interactive 
printf "$JMS_ACTIVEMQ_SSL_KEYSTOREPASSWORD" | lpass add $SHARE_NAME/$COMPONENT_NAME.local.jms.activemq.ssl.keyStorePassword --notes --non-interactive 
printf "$JMS_ACTIVEMQ_SSL_TRUSTSTOREPASSWORD" | lpass add $SHARE_NAME/$COMPONENT_NAME.local.jms.activemq.ssl.trustStorePassword --notes --non-interactive 
printf "$JMS_ACTIVEMQ_PASSWORD" | lpass add $SHARE_NAME/$COMPONENT_NAME.local.jms.activemq.password --notes --non-interactive 
printf "$JMS_ACTIVEMQ_USER" | lpass add $SHARE_NAME/$COMPONENT_NAME.local.jms.activemq.user --notes --non-interactive 
printf "$ISOLERT_AMQ_COMPONENT_LOCAL" | lpass add $SHARE_NAME/$COMPONENT_NAME.local.isolert-amq-component-local.p12 --notes --non-interactive 

lpass sync
