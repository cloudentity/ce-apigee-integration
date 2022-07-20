     /*
 * Copyright 2021 Google LLC
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
* checkScopeIsSufficient.js
* Checks if the token has the required Scope
**/

// First try to retrieve information from the token Introspect response from CloudEntity ACP
// If that fails, retrieve it from the access token included in the request itself 
// (This information may be stale if the consent has been updated out of bounds, directly in ACP)
const tokenScopesStr = context.getVariable("consentInfo.scope");
var tokenScopes;
if ( (tokenScopesStr === null) || tokenScopesStr === "") {
    // Extract the scope associated in Apigee with the access token, this is a JSON array
    tokenScopes = JSON.parse(context.getVariable("jwt.JWT-Verify-Token.decoded.claim.scp"));
}
else {
    // consentInfo.scope is a string of all the scopes, convert to an array
    tokenScopes = tokenScopesStr.split(" ");
    
}
const requiredScope = context.getVariable("theRequiredScope");
const isAllowed = tokenScopes.includes(requiredScope);
print("Token scopes = " + tokenScopes + " - requiredScope = " + requiredScope + " - isAllowed = " + isAllowed );
context.setVariable("isAllowed", isAllowed);

