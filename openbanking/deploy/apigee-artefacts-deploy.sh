#/bin/bash

#
# Copyright 202 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

## Deploys example Apigee X artefacts that interact with Cloud Entity ACP for Consent Management

#### Utility functions

function upload_and_deploy_artefact {
 ARTEFACT_TYPE=$1
 ARTEFACT_NAME=$2

 if [[ "$ARTEFACT_TYPE" == "apis" ]]; then
    APIGEECLI_SUBCMD="create bundle -z ./$ARTEFACT_NAME.zip"
    ARTEFACT_DESC="apiproxy"
    # Create bundle file
    zip -r $ARTEFACT_NAME.zip apiproxy/* >/dev/null
 else
    APIGEECLI_SUBCMD="create -p ./$ARTEFACT_NAME.zip"
    ARTEFACT_DESC="sharedflow"
    # Create bundle file
    zip -r $ARTEFACT_NAME.zip sharedflowbundle/* >/dev/null
 fi

 echo "--->"  Uploading $ARTEFACT_NAME $ARTEFACT_DESC
 ARTEFACT_REV=$(apigeecli $ARTEFACT_TYPE $APIGEECLI_SUBCMD --token $TOKEN --org $APIGEE_X_ORG --name $ARTEFACT_NAME | grep -v 'WARNING' | jq -r '.revision')
 # Delete bundle file
 rm $ARTEFACT_NAME.zip
 echo "--->"  Deploying $ARTEFACT_NAME $ARTEFACT_DESC - Revision $ARTEFACT_REV 
 apigeecli $ARTEFACT_TYPE deploy --token $TOKEN --org $APIGEE_X_ORG --env $APIGEE_X_ENV --ovr --rev $ARTEFACT_REV --name $ARTEFACT_NAME
}

#### End Utility functions

# Deploy KVM admin proxy for configuring KVM values
echo "-->" Cloning KVM Admin proxy from https://github.com/apigee/devrel
cd deploy
mkdir tmp
git clone https://github.com/apigee/devrel.git tmp/devrel
cd tmp/devrel/references/kvm-admin-api
KVM_ARTEFACT_NAME=kvm-admin-v1
upload_and_deploy_artefact apis $KVM_ARTEFACT_NAME
cd ../../../../..
rm -rf deploy/tmp


# Obtain ACP Instance hostname and basepath from env variable
CE_ACP_HOSTNAME=$(echo $CE_ACP_AUTH_SERVER  |  awk -F/ '{print $3}')
echo CE_ACP_HOSTNAME = "$CE_ACP_HOSTNAME"
CE_ACP_BASEPATH=$(echo $CE_ACP_AUTH_SERVER  |  cut -d/ -f4-)
echo CE_ACP_BASEPATH = "$CE_ACP_BASEPATH"


# Create Target Server
echo "--->" Creating target server
apigeecli targetservers create --token $TOKEN --org $APIGEE_X_ORG --env $APIGEE_X_ENV --name CE-ACP-Instance --host $CE_ACP_HOSTNAME --port 443 --tls

# Deploy sharedflows
# They need to be deployed in order
echo "--->"  Deploying shared flows....
cd src/sharedflows
SHAREDFLOW_LIST=("add-response-headers-links-meta" "paginate-backend-response" "CE-get-jwks-from-ACP" "CE-check-request-is-allowed")
for sf in "${SHAREDFLOW_LIST[@]}"
do 
    cd $sf
    upload_and_deploy_artefact sharedflows $sf
    cd ..
done
cd ../..

# # Deploy  apiproxies
echo "--->"  Deploying proxies....
cd src/apiproxies
for ap in $(ls .) 
do 
    cd $ap
    upload_and_deploy_artefact apis $ap
    cd ..
done
cd ../..

# Create product for internal access
echo "--->"  Creating product for internal access...
cd deploy
apigeecli products create --token $TOKEN --org $APIGEE_X_ORG --name CloudEntity-InternalAccess -m CloudEntity-InternalAccess -d "Access to internal operations required by CloudEntity Consent Management Solution" --envs $APIGEE_X_ENV -f auto -s bank:accounts.internal:read --opgrp internal-prod-operation-config.json --attrs "access=private"
cd ..

# Create developer to own the CloudEntity client app
echo "--->"  Creating test developer consent-test-developer@somefictitioustestcompany.com ...
apigeecli developers create --token $TOKEN --org $APIGEE_X_ORG --first "Consent Test" --last "Developer" --email "consent-test-developer@somefictitioustestcompany.com" --user "consent-test-developer@somefictitioustestcompany.com" 


# Create CloudEntity client app
echo "--->"  Creating client for CloudEntity 
APP_CREDENTIALS=$(apigeecli apps create --token $TOKEN --org $APIGEE_X_ORG --name "CloudEntityInternal" --email consent-test-developer@somefictitioustestcompany.com --prods CloudEntity-InternalAccess --attrs="DisplayName=CloudEntity - Internal" --attrs "Notes=App for CloudEntity to access internal banking APIs" | grep -v 'WARNING' | jq .credentials[0])
export APIGEE_CE_CLIENT_ID=$(echo $APP_CREDENTIALS | jq -r .consumerKey)
export APIGEE_CE_CLIENT_SECRET=$(echo $APP_CREDENTIALS | jq -r .consumerSecret)
echo "--->"  Client created with the following credentials: 
echo "--->"  Client Key = $APIGEE_CE_CLIENT_ID
echo "--->"  Client Secret = $APIGEE_CE_CLIENT_SECRET
echo "--->" These values will be used to configure the consent screen demo app 


# Update the environment configuration file with these values
sed -i '' "s/.*APIGEE_CE_CLIENT_ID.*/export APIGEE_CE_CLIENT_ID=$APIGEE_CE_CLIENT_ID # Edited by apigee-artefacts-deploy script/" $CONFIG_FILE_ABS_PATH
sed -i '' "s/.*APIGEE_CE_CLIENT_SECRET.*/export APIGEE_CE_CLIENT_SECRET=$APIGEE_CE_CLIENT_SECRET # Edited by apigee-artefacts-deploy script/" $CONFIG_FILE_ABS_PATH


# Create Config KVM
echo "--->" Creating Config Key Value Map
KVM_NAME=Config
apigeecli kvms create --token $TOKEN --org $APIGEE_X_ORG --env $APIGEE_X_ENV --name $KVM_NAME --encrypt

# Configure KVM values 
# TODO - Use apigeecli
echo "--->" Adding Client Id and Secret defined in ACP for Apigee use - Adding ACP base path
curl -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -d key=ApigeeConsentManagement_ClientId -d value=$CE_ACP_APIGEE_CLIENT_ID \
    "https://$APIGEE_X_ENDPOINT/kvm-admin/v1/organizations/$APIGEE_X_ORG/environments/$APIGEE_X_ENV/keyvaluemaps/$KVM_NAME/entries"

curl -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -d key=ApigeeConsentManagement_ClientSecret -d value=$CE_ACP_APIGEE_CLIENT_SECRET \
    "https://$APIGEE_X_ENDPOINT/kvm-admin/v1/organizations/$APIGEE_X_ORG/environments/$APIGEE_X_ENV/keyvaluemaps/$KVM_NAME/entries"

curl -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -d key=ApigeeConsentManagement_BasePath -d value=$CE_ACP_BASEPATH \
    "https://$APIGEE_X_ENDPOINT/kvm-admin/v1/organizations/$APIGEE_X_ORG/environments/$APIGEE_X_ENV/keyvaluemaps/$KVM_NAME/entries"
 

# Undeploy kvm-admin-v1 from the environment
# Get deployed revision
KVM_PROXY_REV=$(apigeecli apis listdeploy --token $TOKEN --org $APIGEE_X_ORG  --name $KVM_ARTEFACT_NAME | grep -v 'WARNING' | jq -r ".deployments[] | select(.environment==\"$APIGEE_X_ENV\") | .revision")
echo "---> Undeploying $KVM_ARTEFACT_NAME - Revision $KVM_PROXY_REV from Environment $APIGEE_X_ENV. You can deploy it again if you need to change KVM configuration values"
apigeecli apis undeploy  --token $TOKEN --org $APIGEE_X_ORG --env $APIGEE_X_ENV --name $KVM_ARTEFACT_NAME --rev $KVM_PROXY_REV
echo "--->" Done


