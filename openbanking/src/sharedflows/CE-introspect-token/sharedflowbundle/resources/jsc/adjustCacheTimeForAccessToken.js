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
 * adjustCacheTimeForAccessToken.js
 * Calculates an expiry time for caching the access token just acquired
 * To account for latency, it will be set to be 5 seconds less than the expiry 
 * returned when acquiring the token
 */


const tokenExpiry = parseInt(context.getVariable("consentMgmtToken.expires_in"));
// Make sure it is not less than 30 seconds
var newTokenExpiry = parseInt(tokenExpiry - 5);
if (newTokenExpiry < 30) {
    newTokenExpiry = 30;
}
print("Original Expiry = " + tokenExpiry + " - New expiry = " + newTokenExpiry.toString());
context.setVariable("consentMgmtToken.expires_in",newTokenExpiry.toString());
