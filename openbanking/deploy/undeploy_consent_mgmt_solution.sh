#!/bin/bash

# Undeploy artefacts used to demonstrate how to use CloudEntity ACP and GCP Apigee to manage consent in Embedded Finance (Open Banking APIs)

if [ "$#" -ne 1 ]; then
    echo "This script un deploys used artefacts to demonstrate how to use CloudEntity ACP and GCP Apigee to manage consent in Embedded Finance (Open Banking APIs)"
    echo "Usage: undeploy_consent_management_solution.sh CONFIG_FILE"
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


# Undeploy demo client app
echo "========================================================================="
echo "--> Undeploying demo client (Financroo) app ...."
echo "========================================================================="
 gcloud run services delete ce-demo-client --region=$REGION --project=$PROJECT_ID

# Undeploy consent page app
echo "========================================================================="
echo "--> Undeploying consent page app ...."
echo "========================================================================="
 gcloud run services delete ce-consent-page --region=$REGION --project=$PROJECT_ID

# Delete Cloud secrets
echo "========================================================================="
echo "--> Deleting Google Cloud secrets used to store certificates used by apps"
echo "========================================================================="
gcloud secrets delete ce-tpp-cert
gcloud secrets delete ce-tpp-key
gcloud secrets delete ce-cert-auth

# Undeploy Apigee Artefacts
echo "========================================================================="
echo "--> Undeploying Apigee artefacts..."
echo "========================================================================="
deploy/apigee-artefacts-undeploy.sh also_delete

echo Done
