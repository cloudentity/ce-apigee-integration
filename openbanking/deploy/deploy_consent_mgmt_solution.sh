#!/bin/bash

# Deploy all necessary artefacts to demonstrate how to use CloudEntity ACP and GCP Apigee to manage consent in Embedded Finance (Open Banking APIs)

if [ "$#" -ne 1 ]; then
    echo "This script deploys all necessary artefacts to demonstrate how to use CloudEntity ACP and GCP Apigee to manage consent in Embedded Finance (Open Banking APIs)"
    echo "Usage: deploy_consent_management_solution.sh CONFIG_FILE"
    exit
fi

# Check prerequisites
TEST_GC=$(which gcloud)
if [[ -z "$TEST_GC" ]];
then
    echo "This script requires gcloud, the Google Cloud CLI tool. Installation instructions: https://cloud.google.com/sdk/docs/install"
    exit -1
fi

# Check prerequisites
TEST_JQ=$(which jq)
if [[ -z "$TEST_JQ" ]];
then
    echo "This script requires jq. If using Linux, install it by running: sudo apt-get install jq"
    exit -1
fi

TEST_AP_CLI=$(which apigeecli)
if [[ -z "$TEST_AP_CLI" ]];
then
    echo "This script requires apigeecli. Download the appropriate binary for your platform from https://github.com/apigee/apigeecli/releases"
    exit -1
fi

CONFIG_FILE=$1
# Get absolute path to config file
export CONFIG_FILE_ABS_PATH=$(echo "$(cd "$(dirname "$CONFIG_FILE")" && pwd)/$(basename "$CONFIG_FILE")")

# Set up environment variables
echo "========================================================================="
echo "--> Setting up environment using file "
echo "    $CONFIG_FILE_ABS_PATH"
echo "========================================================================="
source $CONFIG_FILE_ABS_PATH

# Enable APIs and grant required permission in the GCP Project
gcloud config set project $PROJECT_ID
echo "========================================================================="
echo "--> Enabling required GCP APIs..."
echo "----> Enabling Cloud Build APIs ..."
echo "========================================================================="
gcloud services enable cloudbuild.googleapis.com
echo "========================================================================="
echo "----> Enabling Cloud Run APIs ..."
echo "========================================================================="
gcloud services enable run.googleapis.com
echo "========================================================================="
echo "----> Enabling Secret Manager APIs ..."
echo "========================================================================="
gcloud services enable secretmanager.googleapis.com

# Grant required permissions to Cloud Build service account
PROJECT_NUMBER=$(gcloud projects describe  $PROJECT_ID --format 'value(projectNumber)')
CB_SVC_ACCOUNT="$PROJECT_NUMBER@cloudbuild.gserviceaccount.com"
echo "=================================================================================================="
echo "--> Granting required permissions to Cloud Build service account:"
echo "      $CB_SVC_ACCOUNT"
echo "=================================================================================================="
gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$CB_SVC_ACCOUNT" \
        --role="roles/cloudbuild.builds.builder"

gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$CB_SVC_ACCOUNT" \
        --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$CB_SVC_ACCOUNT" \
        --role="roles/run.developer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$CB_SVC_ACCOUNT" \
        --role="roles/secretmanager.admin"

# Grant required permissions to Cloud Run service account
CR_SVC_ACCOUNT="$PROJECT_NUMBER-compute@developer.gserviceaccount.com"
echo "=================================================================================================="
echo "--> Granting required permissions to Cloud Run service account: "
echo "      $CR_SVC_ACCOUNT"
echo "=================================================================================================="
gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$CR_SVC_ACCOUNT" \
        --role="roles/secretmanager.secretAccessor"

# Deploy Apigee Artefacts
echo "========================================================================="
echo "--> Deploying Apigee artefacts..."
echo "========================================================================="
deploy/apigee-artefacts-deploy.sh $CONFIG_FILE

# Clone CloudEntity quickstart repo
echo "==================================================================================================="
echo "--> Cloning Cloud Entity openbanking-quickstart repo from"
echo "        https://github.com/cloudentity/openbanking-quickstart"
echo "==================================================================================================="
mkdir deploy/tmp
pushd deploy
git clone https://github.com/cloudentity/openbanking-quickstart tmp/openbanking-quickstart
popd

pushd deploy/tmp/openbanking-quickstart

# Create Cloud secrets required for files that are mounted as volumes by the consent page app and the demo client app (Financroo)
echo "========================================================================="
echo "--> Creating Google Cloud secrets to store certificates used by apps"
echo "========================================================================="
../../create_update_secret.sh ce-tpp-cert ./data/tpp_cert.pem
../../create_update_secret.sh ce-tpp-key ./data/tpp_key.pem
../../create_update_secret.sh ce-cert-auth ./data/ca.pem

# Re-read the environment file to get the latest values updated from the previous Apigee deployment step
source $CONFIG_FILE_ABS_PATH

# Build consent page app demo client apps if necessary
if [[ "$USE_PREBUILT_CONTAINER_IMGS" == "true" ]]; then
   # Use prebuilt container images pulled from specified artefact repo
   # To DO - Use public repo. For now use prebuilt images
   CONSENT_APP_IMG=$PREBUILT_CONTAINER_REPO/ce-consent-screen:stable
   DEMO_CLIENT_IMG=$PREBUILT_CONTAINER_REPO/ce-demo-client:stable
else
   echo "========================================================================="
   echo "--> Building consent page app...."
   echo "========================================================================="
   gcloud builds submit --region=$REGION --config ../../cloudbuild/cloudbuild-consent-app.yaml 
   CONSENT_APP_IMG=gcr.io/$PROJECT_ID/ce-consent-screen
   echo "========================================================================="
   echo "--> Building demo client app -Financroo- ..."
   echo "========================================================================="
   gcloud builds submit --region=$REGION --config ../../cloudbuild/cloudbuild-financroo-app.yaml 
   DEMO_CLIENT_IMG=gcr.io/$PROJECT_ID/ce-demo-client   
fi

# Deploy consent app page
echo "========================================================================="
echo "--> Deploying consent page app as a CloudRun function...."
echo "--> Using image $CONSENT_APP_IMG "
echo "========================================================================="
gcloud run deploy ce-consent-page --region $REGION --image $CONSENT_APP_IMG \
        --set-env-vars ISSUER_URL=${CE_ACP_ISSUER_URL},CLIENT_ID=${CE_ACP_CONSENT_SCREEN_CLIENT_ID},CLIENT_SECRET=${CE_ACP_CONSENT_SCREEN_CLIENT_SECRET},LOG_LEVEL=debug,SPEC=cdr,GIN_MODE=release,OTP_MODE=mock,MFA_CLAIM=sub,BANK_ID_CLAIM=customer_id,BANK_URL=https://${APIGEE_X_ENDPOINT},BANK_CLIENT_TOKEN_URL=https://${APIGEE_X_ENDPOINT}/ce/token,BANK_ACCOUNTS_ENDPOINT=https://${APIGEE_X_ENDPOINT}/ce/internal/accounts,BANK_CLIENT_ID=${APIGEE_CE_CLIENT_ID},BANK_CLIENT_SECRET=${APIGEE_CE_CLIENT_SECRET},BANK_CLIENT_SCOPES=bank:accounts.internal:read,DB_FILE=/tmp/my.db,ENABLE_TLS_SERVER=false,CERT_FILE=/certs/tpp_cert.pem,KEY_FILE=/certs-keys/tpp_key.pem,BANK_CLIENT_CERT_FILE=/certs/tpp_cert.pem,BANK_CLIENT_KEY_FILE=/certs-keys/tpp_key.pem,ROOT_CA=/ca/ca.pem \
        --update-secrets /certs/tpp_cert.pem=ce-tpp-cert:latest,/certs-keys/tpp_key.pem=ce-tpp-key:latest,/ca/ca.pem=ce-cert-auth:latest \
        --allow-unauthenticated

# Get URL for consent page app
CONSENT_APP_URL=$(gcloud run services describe ce-consent-page --platform managed --region=$REGION --format 'value(status.url)')
echo "========================================================================="
echo "--> Updating consent page app configuration...."
echo "========================================================================="
gcloud beta run services add-iam-policy-binding --region=$REGION --member=allUsers --role=roles/run.invoker ce-consent-page
echo "==================================================================================================="
echo "The consent page app has been deployed at $CONSENT_APP_URL "
echo "==================================================================================================="


# Deploy demo client app (Financroo)
echo "========================================================================="
echo "--> Deploying demo client app -Financroo- as a CloudRun function...."
echo "--> Using image $DEMO_CLIENT_IMG "
echo "========================================================================="
export CE_ACP_HOSTNAME=$(echo $CE_ACP_AUTH_SERVER  |  awk -F/ '{print $3}')
export CE_ACP_TENANT=$(echo $CE_ACP_AUTH_SERVER  |  awk -F/ '{print $4}')
export CE_ACP_WORKSPACE=$(echo $CE_ACP_AUTH_SERVER  |  awk -F/ '{print $5}')
export CE_ACP_MTLS_ISSUER=$(curl $CE_ACP_AUTH_SERVER/.well-known/openid-configuration -s | jq -r '.mtls_issuer')
export CE_ACP_MTLS_HOSTNAME=$(echo $CE_ACP_MTLS_ISSUER  |  awk -F/ '{print $3}')
gcloud run deploy ce-demo-client --region $REGION --image $DEMO_CLIENT_IMG \
        --set-env-vars ACP_URL=https://${CE_ACP_HOSTNAME},ACP_MTLS_URL=https://${CE_ACP_MTLS_HOSTNAME},TENANT=${CE_ACP_TENANT},OPENBANKING_SERVER_ID=${CE_ACP_WORKSPACE},LOG_LEVEL=debug,SPEC=cdr,GIN_MODE=debug,UI_URL=${DEMO_CLIENT_APP_URL},ENABLE_TLS_SERVER=false,BANK_URL=https://${APIGEE_X_ENDPOINT}/ce,CLIENT_ID=${CE_ACP_TPP_CLIENT_ID},DB_FILE=/tmp/my.db,CERT_FILE=/certs/tpp_cert.pem,KEY_FILE=/certs-keys/tpp_key.pem,ROOT_CA=/ca/ca.pem \
        --update-secrets /certs/tpp_cert.pem=ce-tpp-cert:latest,/certs-keys/tpp_key.pem=ce-tpp-key:latest,/ca/ca.pem=ce-cert-auth:latest \
        --allow-unauthenticated

# Let all users access the deployed cloud function
gcloud beta run services add-iam-policy-binding --region=$REGION --member=allUsers --role=roles/run.invoker ce-demo-client

# Get URL for demo client app
DEMO_CLIENT_APP_URL=$(gcloud run services describe ce-demo-client --platform managed --region=$REGION --format 'value(status.url)')
# Update config of deployed client app
echo "========================================================================="
echo "--> Updating demo client configuration...."
echo "========================================================================="
gcloud run services update ce-demo-client --region=$REGION --update-env-vars=UI_URL=$DEMO_CLIENT_APP_URL
gcloud beta run services add-iam-policy-binding --region=$REGION --member=allUsers --role=roles/run.invoker ce-demo-client

echo "==================================================================================================="
echo " The demo client app has now been deployed."
echo " You can test this solution by accessing the "
echo " demo client app at:                           "
echo "   $DEMO_CLIENT_APP_URL                        "
echo "================================================="
popd

# Remove temporary artefacts
rm -rf deploy/tmp/
echo Done

echo "DEMO_CLIENT_APP_URL=$DEMO_CLIENT_APP_URL" >> deploy/ce_workspace.env
echo "CONSENT_APP_URL=$CONSENT_APP_URL" >> deploy/ce_workspace.env