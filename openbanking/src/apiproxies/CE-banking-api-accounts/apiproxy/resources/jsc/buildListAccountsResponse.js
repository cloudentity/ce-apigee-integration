    /*
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

/**
 * @file
 * buildListAccountsResponse.js
 * Format response. Depending on the value of the property internalResponse, it will include all accounts
 * or (for external responses) only the accounts included in the consent. 
 */

const isInternalResponse = properties.internalResponse;
print("property.internalResponse = " + properties.internalResponse + " - var isInternalResponse = " + isInternalResponse);

var listOfAccountDetails = JSON.parse(context.getVariable("listOfAllAccountDetails"));

if (isInternalResponse != "true") {
    var accountsInConsent = JSON.parse(context.getVariable("consentInfo.accounts"));
    // print("Only include accounts in " + JSON.stringify(accountsInConsent));

}

var listOfAccounts = [];
var curAccount;
for (i = 0; i < listOfAccountDetails.length; i++) {
    curAccount = listOfAccountDetails[i];
    // print("curAccount = " + JSON.stringify(curAccount));
    if ( (isInternalResponse == "true") || (accountsInConsent.includes(curAccount.accountId))) {
        // only include the required subset of attributes - The rest are meant of account details response
        var formattedAccount = {}
        formattedAccount.accountId = curAccount.accountId;
        formattedAccount.creationDate = curAccount.creationDate;
        formattedAccount.displayName = curAccount.displayName;
        formattedAccount.nickname = curAccount.nickname;
        formattedAccount.openStatus = curAccount.openStatus;
        formattedAccount.isOwned = curAccount.isOwned;
        formattedAccount.maskedNumber = curAccount.maskedNumber;
        formattedAccount.productCategory = curAccount.productCategory;
        formattedAccount.productName = curAccount.productName;
        // print("formattedAccount = " + JSON.stringify(curAccount));
        listOfAccounts.push(formattedAccount);
    }
}
var results = {};
results.data = {};
results.data.accounts = listOfAccounts;
// print("Response = " + JSON.stringify(results));
context.setVariable("response.content",JSON.stringify(results));
context.setVariable("response.header.content-type","application/json");
    