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

## Undeploys example Apigee X artefacts that interact with Cloud Entity ACP for Consent Management

#### Utility functions

function undeploy_and_optionally_delete_artefact {
 ARTEFACT_TYPE=$1
 ARTEFACT_NAME=$2
 ALSO_DELETE=$3
 # Find revision deployed to environment
 if [[ "$ARTEFACT_TYPE" == "apis" ]]; then
    ARTEFACT_DESC="apiproxy"
 else
    ARTEFACT_DESC="sharedflow"
 fi
 ARTEFACT_REV=$(apigeecli $ARTEFACT_TYPE listdeploy --token $TOKEN --org $APIGEE_X_ORG  --name $ARTEFACT_NAME | grep -v 'WARNING' | jq -r ".deployments[]? | select(.environment==\"$APIGEE_X_ENV\") | .revision")
 if [[ -n "$ARTEFACT_REV" ]]; 
 then
   echo "--->"  Undeploying $ARTEFACT_NAME $ARTEFACT_DESC - Revision $ARTEFACT_REV 
   apigeecli $ARTEFACT_TYPE undeploy --token $TOKEN --org $APIGEE_X_ORG --env $APIGEE_X_ENV --rev $ARTEFACT_REV --name $ARTEFACT_NAME
 fi
 if [[ "$ALSO_DELETE" == "also_delete" ]]; then
   echo "--->"  Deleting $ARTEFACT_NAME $ARTEFACT_DESC
   apigeecli $ARTEFACT_TYPE delete --token $TOKEN --org $APIGEE_X_ORG --name $ARTEFACT_NAME
 fi
}

#### End Utility functions

FORCE_ARTEFACT_DELETE=$1

# Delete CloudEntity client app
echo "--->"  Deleting client for CloudEntity 
#Get developer id
DEVELOPER_ID=$(apigeecli developers get --token $TOKEN --org $APIGEE_X_ORG --email "consent-test-developer@somefictitioustestcompany.com" | grep -v 'WARNING' | jq -r ".developerId")
apigeecli apps delete --token $TOKEN --org $APIGEE_X_ORG --name "CloudEntityInternal" --id $DEVELOPER_ID

# Delete developer who owned the CloudEntity client app
echo "--->"  Deleting test developer consent-test-developer@somefictitioustestcompany.com...
apigeecli developers delete --token $TOKEN --org $APIGEE_X_ORG --email "consent-test-developer@somefictitioustestcompany.com"


# Delete product for internal access
echo "--->"  Deleting product for internal access...
apigeecli products delete --token $TOKEN --org $APIGEE_X_ORG --name CloudEntity-InternalAccess 

# Undeploy apiproxies
echo "--->"  Undeploying proxies....
cd src/apiproxies
for ap in $(ls .) 
do  
  undeploy_and_optionally_delete_artefact apis $ap $FORCE_ARTEFACT_DELETE
done
cd ../..

# Undeploy sharedflows
# They need to be undeployed in order
echo "--->"  Undeploying shared flows....
SHAREDFLOW_LIST=("CE-check-request-is-allowed" "CE-get-jwks-from-ACP" "paginate-backend-response" "add-response-headers-links-meta" "add-response-fapi-interaction-id" "apply-traffic-thresholds" "check-request-headers" "collect-performance-slo" "decide-if-customer-present" "validate-request-params")

for sf in "${SHAREDFLOW_LIST[@]}"
do 
    undeploy_and_optionally_delete_artefact sharedflows $sf $FORCE_ARTEFACT_DELETE
done

# Delete Data Collectors
for dc in dc_PerformanceTier dc_MeetsPerformanceSLO dc_CustomerPPId dc_TokenOp; do
    apigeecli datacollectors delete --token $TOKEN --org $APIGEE_X_ORG --name $dc
done

# Delete Target Server
echo "--->" Deleting target server
apigeecli targetservers delete --token $TOKEN --org $APIGEE_X_ORG --env $APIGEE_X_ENV --name CE-ACP-Instance 


# Delete Config KVM
echo "--->" Deleting Config Key Value Map
KVM_NAME=Config
apigeecli kvms delete --token $TOKEN --org $APIGEE_X_ORG --env $APIGEE_X_ENV --name $KVM_NAME 

echo "--->" Done


