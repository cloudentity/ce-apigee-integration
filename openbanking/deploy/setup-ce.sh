#!/bin/bash

source deploy/ce_admin.env

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OPT="-w 0"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        OPT=""
fi

function get_token {
  ACCESS_TOKEN=$(curl -k --http1.1 --request POST \
  --url https://$DOMAIN/$TENANT_ID/admin/oauth2/token \
  --header "Authorization: Basic $(echo -n $CLIENT_ID:$CLIENT_SECRET | base64 $OPT)" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=client_credentials | jq -r '.access_token')
}

function create_oauth_server {
    printf "Creating workspace\n"

    CE_ACP_AUTH_SERVER=$(curl -k  --request POST \
  --url https://$DOMAIN/api/admin/$TENANT_ID/servers \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Content-Type: application/json' \
  --data '{
    "tenant_id": '"\"$TENANT_ID\""',
    "id": '"\"$WORKSPACE_ID\""',
    "profile": "cdr_australia",
    "name": '"\"$WORKSPACE_ID\""',
    "type": "regular",
    "color": "#fabc3e",
    "secret": "mNowOQHqrRmh9yiEATEZ77gYuKWeBt16C3kgS411BPM",
    "rotated_secrets": [],
    "access_token_strategy": "jwt",
    "key_type": "ps",
    "logo_uri": "",
    "custom_issuer_url": "",
    "dynamic_client_registration": {
        "enabled": true,
        "initial_access_token": {
            "required": false
        },
        "payload": {
            "format": "jws",
            "jws_payload": {
                "source": "client_software_statement",
                "jwks": {
                    "keys": null
                },
                "jwks_uri": ""
            }
        },
        "default_scopes": null,
        "disable_registration_token_rotation": false,
        "cert_bound_registration_token": false
    },
    "grant_types": [
        "authorization_code",
        "refresh_token",
        "client_credentials"
    ],
    "token_endpoint_auth_methods": [
        "client_secret_basic",
        "client_secret_post",
        "private_key_jwt",
        "tls_client_auth"
    ],
    "token_endpoint_authn_methods": [
        "client_secret_basic",
        "client_secret_post",
        "private_key_jwt",
        "tls_client_auth"
    ],
    "access_token_ttl": "10m0s",
    "refresh_token_ttl": "4h0m0s",
    "authorization_code_ttl": "5m0s",
    "id_token_ttl": "10m0s",
    "cookie_max_age": "10m0s",
    "jwks": {
        "keys": [
            {
                "use": "sig",
                "kty": "RSA",
                "kid": "335959492614201850165503050501718813342",
                "alg": "PS256",
                "n": "5uGGVHtlicak0i5089Ci2whukXxlOR6U2nt4fDtA1Zkg5WA0utjxTL3PEDo47D1ysYvJnTZrcMBwthcvLqGwvzmzNldnMw2LlN4UUEW4BpqVA69KtJDNN8Y3CaAiAtG2Nq7j4zsRZKmXwjgDega4_r_2ouHqdNLuRyED10nRl3eDTSMpHopsl3TsrZr-sP6xxmzBTqBHZsTXoM-YhNl7RJiVp2vaX8N5lroNbj1vIQzm_TPxKUvJLll8OyoCbhOHGiGVlgbN99_XrtBUPIyyxIRxem-VI2WJc_CWqVWIAWUs7RlvTQw8iLCoIDPaWcmBIc_rEraipbe3mz-T6pfQKw",
                "e": "AQAB",
                "d": "TynOzFLPGvGAfAyvzxWfcWivuLSlZHNm6I7jXf1XGqX5kIxvKA3QltaSE-dSszXSiKv8gioxpqRlQRor9Fo-ZyLanuxTFz8yt-V5o5h0I9eG9o95FvZ7Vv9gya0dXEgZqSBIRRZwvUolHdPk5Uc-0SJy56B8qnfUeZEJZx0Jf1w1ZUjbBLsfqh2CcThZYDn9ZFELmuJ3JGZG9bSFvnV_E3r00lUvdw_Qt2xifCMEJRbTBF3B2gf4yeKLL3lS1HcKg0RT4lutYD71R1wBLA8fPx_3e9nSZ_fGrqHMy74T9SS9uaRm0mIgiO-DvZmTKeOkWIywOzvAuZkNwOe5oFVzWQ",
                "p": "7UiRmDFP2Ld74jIWXeObq4HYnp76y46jgTbpb6ITCNvxaacE7lgbyMNVlOOy2lCrLDvfdW_2zPqsFOlvlvEyBhTiJl5u0LDwVffXZ5VmxDCVjVIVBi2BsH212mQV1Jzin4apUooj1DY9LZxw2R5FwuJbpyU4ySHaumHLvIulf30",
                "q": "-RerwQHwTkC6HTEmhQVak1wq3rsbP1FRhgjLrbMJvG_xnkDWdNyoHWG9eEXxDaQoFRtMgY8uj3lN5lhRklO-gbBr3QKIWb07KHZrYODKaa6WzybqMRD02VsdlrEl9Qt7N5OM9tOwhFuzggVhroSWjKeASXFKidrhoh6Pk2zybsc",
                "dp": "3lK5QA0sEBVS-MwPUuc460hdC7pPqDw8jIxDynnkNc_GcUSxhRR-6-vBmyCBarZcu7RZmjJO3x4b7_gMuzPAuBwHDQY79ENk3Fe8tuwv_rC630_CLSikNBaFNlvCbJSWbfwBWDngeixbxAmpXnVTzdbDI2fnveR_iVSqTT3W0g0",
                "dq": "jd5Ldjvyb78xwRqTQ8PO2Irv57dNR3y7H8m2p5GHBAoF5QosmpZqMYHPdcbwCcLrCUppAolYDWMbWQwIOXz0zcx7Qn8ExYefP-ZiNeURo6tKPWV-kL-FlJ3udjsi0TPe08J30MS0jk3kKTODdPATBr0HtcyOlYFSbRFW2LJ-SVU",
                "qi": "StBHQTltZUWUH7EN1exGPHpFyxeaFN-qVbWK9gP1_lKbWuXkyXPY_DiyB7Ka3pUXXyZfM8QGkUR3rJinK3933dY9twcznKJXG3l7O5YS6gqE-BXSha2tWJTlJcffqFewxvbqII9PZlvZf-GicdwzvNVCsTEyn5el9iF1aFrszsw",
                "x5c": [
                    "MIIDUDCCAjigAwIBAgIRAPy/cddhM90FWOjVzQa8Kp4wDQYJKoZIhvcNAQELBQAwLDEUMBIGA1UEChMLQ2xvdWRlbnRpdHkxFDASBgNVBAMTC0Nsb3VkZW50aXR5MB4XDTIyMDYwOTIyMjIxOVoXDTIyMDcxMDIyMjIxOVowLDEUMBIGA1UEChMLQ2xvdWRlbnRpdHkxFDASBgNVBAMTC0Nsb3VkZW50aXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5uGGVHtlicak0i5089Ci2whukXxlOR6U2nt4fDtA1Zkg5WA0utjxTL3PEDo47D1ysYvJnTZrcMBwthcvLqGwvzmzNldnMw2LlN4UUEW4BpqVA69KtJDNN8Y3CaAiAtG2Nq7j4zsRZKmXwjgDega4/r/2ouHqdNLuRyED10nRl3eDTSMpHopsl3TsrZr+sP6xxmzBTqBHZsTXoM+YhNl7RJiVp2vaX8N5lroNbj1vIQzm/TPxKUvJLll8OyoCbhOHGiGVlgbN99/XrtBUPIyyxIRxem+VI2WJc/CWqVWIAWUs7RlvTQw8iLCoIDPaWcmBIc/rEraipbe3mz+T6pfQKwIDAQABo20wazAOBgNVHQ8BAf8EBAMCAqQwEwYDVR0lBAwwCgYIKwYBBQUHAwEwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUxXDH8Eh+e7TPgrqpVWZ7IttuyEgwFAYDVR0RBA0wC4IJbG9jYWxob3N0MA0GCSqGSIb3DQEBCwUAA4IBAQBS2U1zqV69gfEBeJ0P1CqKYOG+F+K6nNgElsdJHz/FXXQG5y2xggCt0XCmQKoJOxikQnW7Rls8zrNU1lI5zY3VjuBVev9fHmSSybglbYZL09Th7oat49t+6NHszdt7w/cIlDSBF/o1Q7qx6DdwMx7+QbwshhGtGVz4Grr++Cj1OHb8M+qmCX7sJkMwnD2bQmarvmjQSz8c9jj+9YvJxSK0zV5/pzW/59zN2aFOfznNhNuh462riTGMOMV2bC0aGhXCQymCR6tK6MCoO/SnrOR/3HBXcgoScDjzy3+jl8lG3tMcrQkB7sPRpH+cTft6WCOcFiwiany4rcIti14GgtKE"
                ],
                "x5t": "A6YtVT3QZDzGYLtrazguMkYGsJc",
                "x5t#S256": "4IbbR7pIR9Ugjsc47XqkfFcniyIfux3NVoV3VuZ_10Y",
                "created_at": "2022-06-09T22:22:19Z",
                "promoted_at": "2022-06-09T22:22:19Z",
                "rotated_at": null,
                "revoked_at": null
            },
            {
                "use": "enc",
                "kty": "RSA",
                "kid": "cah756q1pkhkrv71kd5g",
                "alg": "RSA-OAEP-256",
                "n": "tOczuyzCJ4e2CWuLA1ikXqd09-TmQ4Q-DL2Y2sWmnFa7uretbe_5hh-d6N3BkTUrSeB1wL_LGv1Yc7BZ-2OQdUjEQ1SjK6c3b3nfLJZZOpxGSfzk7oGv_oQtAAPtC4QXxQcJXPCyPkSEfrePC5g9xKmtQ2H8EzfyZcncsSlN3ge8Qg1JHBzSuNM1KvQK4quLERNPMBMIq0qpE_tQ2C-PI62dZcAX9lDtLzXQAtQ0ZM9d05YQyLDkqkcBMqbJtcjzAhbDomeyI1QyWu-hu4V8CaTAUbksbrNvSrQfTi9lzi3B4O_9dNCa4nEUKWOJ9vt3WUyjBAxjOjGnyCNdCevemQ",
                "e": "AQAB",
                "d": "hmIpv6WkJRFfXOgSwE2c7OOgtHXJx-X44iYF4p5pAkI7-pxvrPdTeRsLhu0U2fWRTrP7RVA0ZLxGdMpQTbrMmRORGCNLgyYYvCrgapLVfgCRBm1i8vpL7tnpQ9WmxaM-tRJhFjWHc1Iayrc4__f8CpexKhkj1HL_EjY-RyzTt1buWBDItC1uF4Hyn-GO8jVfz1Ud-_eti8F4pCSoG5FmMJgsYYVIeA7-DDHKGCCG6IeyGMeRh-4Qcu7Cq9_gUkoyIZ3LwrJM6cEr_5MdzuJshiSlUDpPgS4zIPrnq-sZPCsa8l7LOte43kWMqQMfWW0wuju0J23TRIMYSILdecRewQ",
                "p": "wng7hV6HO2p0EA4GA4ti3gPFSN4Sl-nE1qUdlKNbVIG6qmJv3U_2NgSUDUY7Tce7a1oTJhYqUEs0Z5ubVMqudyzRGxKIaMu_Fr1FG_fmYzmpXY6Oqt5Dw_InxbYeNUvNUiLLtpu5HgkoIJ0x1RqaiWbC4AetDJZuS8J-Rhi16HU",
                "q": "7iQZp0bsLKksa_cxzhwX-PrE8Rd6PPQCMQ4FRuv7Uj4smOVlFX9XAKQk1IABt2M4yMM0UrYPvNsXSDJ4PdHpucHLnT5LBc2MibkOd4jvviz3I83fxm5PjKQh39uSCQh20ia2La7nYqbFQ_zZ7m1MHaz6TMgSjTWpKx75TDeO-RU",
                "dp": "RZh9xKclwm_AhZZfNJmHkmjLC97dzJwOo7qHsZAcuUuMIDoGSq-5L2_IBFAkHRvjyPF9dN3t2rpvULzxhBDdCy1w0D17r_Vqt5qYxv-a5dvW7vJ7wE629cMN1MXuXah5HHHzcbCdOVCRmcpn8RoKQC4Ug9R7a8vSQS6jvjZNs5k",
                "dq": "1SfhAnacDXm7tkQEA43n80dbIsW193sdvxTiqlGtmjbmqlCiQzTBBmTmRoLxhlm8yQ7Y9bPasFuXIltyfzs2LrwFahEJC_-pbNkE1v_uP9Z1vEmZpD6225dKbtpVg9pcqMxXwtpMaGQILEvWMfEI8YMUY8etu1Gtw1gtIwiT4-U",
                "qi": "DZgAf6CX80MujIB03t-LvQtBbgBal0CTCL6PIcr7THOljXiJE4fE1y6NdMGBTeKGnEbrFFL7wc37W4Afxj03jGkaQFGELf1S5Qai-URMX-kZmNZgf7Zdw9EByXFnZL8hPIpKiMOhM9XUde83FWaH4l94sXyEIkIH3xyB3wuncNc",
                "created_at": "2022-06-09T22:22:19Z",
                "promoted_at": "2022-06-09T22:22:19Z",
                "rotated_at": null,
                "revoked_at": null
            }
        ],
        "next_signing_key": {
            "use": "sig",
            "kty": "RSA",
            "kid": "9166259213405770085147486224364405463",
            "alg": "PS256",
            "n": "1xQiLUILG0JkZTpzgZZdcZpxjdaVknGZi6paSgrx3MfWWT5wXDOSN2tUzFm7abWWo2FIk0rpPT_oTNJZafiN-WiCCpvRyC_4_bxq0lVaSG_7tWePJDrSwkYowNovtB3YjBMy7NJwy3unEeJSiXIaS4B3t9oOaOFylmRVa94bo2aIwnxyHR94Padc46WcplTwiVpE7vdjkeqLKlpHPkNZfUEHnzMvmqNFkAxIZaYSElSLrsY7VfQoJlu7cVwOyJ09DWYJ6ls-9nLQ_NIooZZGVRMJTDJ8wNoXvg7CNq7T-guF6lz30QVuFRPnS3mURLnAwDXXHmLPX-akjFJmwU8Rnw",
            "e": "AQAB",
            "d": "B_Onm9LARF69BX0WvijIBaY3Io5Xc1Wd3qsKsYgcDxSYWS5UyyPg-QmP1gpPQoZDLoEvRLrVSr1tIkH4qlFVNm5luGywYd1cME1iCaq8LsdtH_TXNvixyBr98LtgXiFoWy1uiZDyOKO2tpOOh6RfUoFKa9K1C62iJetJuTY6AV18s-x7yvpr0whZhOguAxWXfJzIMQCs4CmpMkhuT_vP93-YwKboinrubaRlmg1JY-xSDAgPRqNzgQafsY57CWgNpx_JwWENn8otu4zaSlP2-9m_7-MgdM-1Z5SU0mf019Al2EHgbtrAZmv_w37W5uN9ByS-f7ZO9hcj46-6QVwIqQ",
            "p": "_Wzg7J_woUyAmqn6d2N7AsXQ6hFwmCfrVjSua0VeZjocC8wWMmKGBsld20OZcWVRd9sEywZ33mZsnJz1uuaI55wgjMonoBXr_99ftqorpgPReMN2nuYvfMjUJai2kJvTXYWIewfTwemti_aoUCIm9-3sNXimQ2Tz-kkBWDKeiWs",
            "q": "2UOFXS-cNmfIWerh4gmF35WnfLKKFS2Bi9A0FxhCq7ObSjGal27mGnnjpnSuwpGSjxafmM7T3D3cPOwMP2XtITsGNvQqAXgONdUDGkEi2qhy7XFFmnQPD0Cq4SAc5hmLjhiTwREgAFuJM_nJFruE89yPZqTpYO_X7808WtSaIZ0",
            "dp": "3m-ZgLflqn4OhzJY0D-18boVY82I6VRogJLe4PLTJ6ErisNIXFMT1pMaWWEdJmXKuwu3SkhUIBYAkPpHyROd6MSl4U1yuFVlfoHebeMxSpchXgEadeAOoFVZt_A8xfKv8-9H2s0E9bgYhrgqBaPkVkszv781GARdDTrU_kf31R8",
            "dq": "SXGDwa54dgO7PHokBY8GjEBAr-yCtQn_As5M7Ymr7_L1Ca2e_pXkfwq5I-nJscgX7PrO1I8GGytmKcn5kezYriUPwr_i-0AkPZpWRCfEqnnK7-0chEu7U4KewR9j5Xy5Kj2wpNEvKi_HP6Suj1qwZOcoKqCQq84oBs4wGtxHhhk",
            "qi": "ivA8--wQGd0fP_7Qi7qVM0qeyqGVo456dj6fMtSyGGZBXFDO7dc6oLyj3FBr3oDKcpoQO-JS4cpbw6qv8ROQL6Kg3spWaACzJtfRQm0xOeCbuzqBrbGpYry7i73m5SAqH4VB2KRNR6hiITJN4ndujFBxtEXM-3l86SJ80Moo4Ao",
            "x5c": [
                "MIIDTzCCAjegAwIBAgIQBuVbeKY00YrAQItmOvUC1zANBgkqhkiG9w0BAQsFADAsMRQwEgYDVQQKEwtDbG91ZGVudGl0eTEUMBIGA1UEAxMLQ2xvdWRlbnRpdHkwHhcNMjIwNjA5MjIyMjE5WhcNMjIwNzEwMjIyMjE5WjAsMRQwEgYDVQQKEwtDbG91ZGVudGl0eTEUMBIGA1UEAxMLQ2xvdWRlbnRpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDXFCItQgsbQmRlOnOBll1xmnGN1pWScZmLqlpKCvHcx9ZZPnBcM5I3a1TMWbtptZajYUiTSuk9P+hM0llp+I35aIIKm9HIL/j9vGrSVVpIb/u1Z48kOtLCRijA2i+0HdiMEzLs0nDLe6cR4lKJchpLgHe32g5o4XKWZFVr3hujZojCfHIdH3g9p1zjpZymVPCJWkTu92OR6osqWkc+Q1l9QQefMy+ao0WQDEhlphISVIuuxjtV9CgmW7txXA7InT0NZgnqWz72ctD80iihlkZVEwlMMnzA2he+DsI2rtP6C4XqXPfRBW4VE+dLeZREucDANdceYs9f5qSMUmbBTxGfAgMBAAGjbTBrMA4GA1UdDwEB/wQEAwICpDATBgNVHSUEDDAKBggrBgEFBQcDATAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBQW3uY2Nj6FKFVUOP69mRlvTCE3dTAUBgNVHREEDTALgglsb2NhbGhvc3QwDQYJKoZIhvcNAQELBQADggEBAI93S9eeB5GPCrHQOyrkIfkMQY1dBxN6K87iEw6Rr9/AY8i6mMrOB7N4FXet4KhOCXO2qgQ9J/S5/uwQci8E8fnsocAC0qOylSZCzYu9c5QBoYhrMpLEuwmiE7H87WdmV9zEkTAhROnq+0+fmuTsZtAYC0zwerDQ0piCsaT6WwxYII4bao4G/YsnYPy9dkbhqcEUiUULqMpQOHs8tVtdEXkzNoi0uTKqJbvZhrYhGDCzDJNjWxGmrMq4v5OkZu4gwFebzHaNP3pfbDa1llX23aEDczitDVrMqetz6F2Cxybhupe4ia3LACYwGjB4/38NoaWy1s8HMvnxdel1rJylElY="
            ],
            "x5t": "r7Kb3nsSFGMsVheIqbY0wCmsWUU",
            "x5t#S256": "h5XxtEMdORmGlJ_wJmLuvGcWMpOJaxnKKcLQh3rJmH4",
            "created_at": "2022-06-09T22:22:19Z",
            "promoted_at": null,
            "rotated_at": null,
            "revoked_at": null
        },
        "next_encryption_key": {
            "use": "enc",
            "kty": "RSA",
            "kid": "cah756q1pkhkrv71kdag",
            "alg": "RSA-OAEP-256",
            "n": "tko805MtRqieoKz3TZgl73Y3Jjka8TDwcVXs-FgnGH5VWY5TKmLSXH04XWxHadZKecbXKYU24AcencBnnqkoMHFufD7RxSDuIHlKdZb1NXnLZdLGD9ZsVdFhaKDtLCEMKgKHIwAYvKspy4z1uxhntQ0ibL_zXNyMw0qIbvqqCVoVhQ8tbYuBhLzmnT55bxeCRLl2tBT7TSwsj3CqE4-JvEwAXdYY73jSvxgluUS4PMoSpSY-Ub-yPA2t733n4oa5TjxAmDv9_mOqwJje4Kaj8088GcCTwGVov5wTsKLeuMsIfinQzxscft8YVrmkb_3lTiVkaN9mqE9GeqlgvowVow",
            "e": "AQAB",
            "d": "LPIrA0PTswtaaWWcaG5uVBfCy1LjOLsHXfqAvk8F_L0RkE5OZTIOii1521caWJc0r8f-P0eQWzaGLwFEy1MMDL27LzlSAZf3_tvJJys8dJ3-L7IDkd4dwh8pNGIReIMBe845wcCBWOufF4g_Ao2m7HY7mbLOb4QV1QUolKyLhlhb-0p_lVqANKhtQI6kaIOJokRJq_wgNUvZ3ZHG-KidhjMxw7qMp7seZyx62TYyHfFm5frVaQ-DtvpKd6Vb9p0_9Y_xDXUCkyU7-eEqUcq74smbKxe-ew-viFXxKhBJWgBYorLQOjPWQ4l2_wowKu1c0RMRhPl5c1MLnT1W7S8SCQ",
            "p": "6jzPOJzcPfUsqsMkjUNBRm5VO-37yj1wKDtcahrlPSDyCEaDPSlivcMgaurnnfaSE1VZaIJnMTb1ycuzBLTEv2_RAKiJjTnVAGUE2k2Cmokk59WFwvtk5wcIQGICkKiV54jbcmTIx_WEfS7CgTUm1Ec-eDCerUc1HnBUlYoMcfc",
            "q": "xznjjHJbTiguP7vP2-4ddaZr5frnph2QZlb31eoQn5vlAQcMYnqJYczakC28N1fb8E2B2J2iCGsinAqS6_zVHuFJu6UDohVPUzCsnkOgR35TPEED3UnKrhyNZrjb-jAuv_w01O7sP8ruPAeEUsF2OZfErXNouEoTN-Tte1WcDrU",
            "dp": "347cI-cqGQQn9m67MwvOf_8L4F_ZoYMTyYImSKqUwcvw1E8gML6QHBbgmMrL9qp_bm5WH_XdsU4INenxWPuCkEeTDXLNnXllvrOrdwLlNMLR82aJ_Ldc7VZ73J7uXcxZDhtDfqGMM7QzGBsJzrHA9ndsut-EglLk8sE5KWQRTq8",
            "dq": "On2jcfONHPgtA-c3EoHpQkZW_VFZu2qIn5M-9h3fPYz-gfu4xhzlwsHrFVNoI_N2jimjSp6VGNWjdp6gHgq_424PQLkkxOxuuqTauShvoS3UcCdCZDCrAc0-Mn9pjh2hTBpWxIFU-TGyGgu27LkB5czKIIZ2o0yUMd_TXVd4FtU",
            "qi": "oUdb5Yr9mHCH5CSD8ZHtK01IV57TOs6ENA_C7aeAKTCiJRXSVNnEhCZJekhNM4dQ9pfkF-ePjyq0GhTmFO8uiqsPRBU4r7kWXl30M92dXhnbGUGNZUSQjZwDfDmS7FGwNXGC9tINle5C8w2o3_do1X5Dtwss7P9OkqJU1yjjEkI",
            "created_at": "2022-06-09T22:22:19Z",
            "promoted_at": null,
            "rotated_at": null,
            "revoked_at": null
        },
        "revoked_signing_keys": null,
        "revoked_encryption_keys": null,
        "rotated_keys_limit": 8,
        "revoked_keys_limit": 16
    },
    "enforce_pkce": false,
    "enforce_pkce_for_public_clients": false,
    "root_cas": "-----BEGIN CERTIFICATE-----\nMIIEVjCCAz6gAwIBAgIUHVV9LeNtt81MoMzosAABgejAp60wDQYJKoZIhvcNAQEL\nBQAwVzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT\nB1NlYXR0bGUxFDASBgNVBAoTC0Nsb3VkZW50aXR5MQswCQYDVQQLEwJDQTAeFw0y\nMTAxMjAwOTQ4MDBaFw0yNjAxMTkwOTQ4MDBaMIGQMQswCQYDVQQGEwJVUzEUMBIG\nA1UECBMLV2FzaGluZ2h0b24xEDAOBgNVBAcTB1NlYXR0bGUxFDASBgNVBAoTC0Ns\nb3VkZW50aXR5MRYwFAYDVQQLEw1BdXRob3JpemF0aW9uMSswKQYDVQQDEyJjaWQx\nLmF1dGhvcml6YXRpb24uY2xvdWRlbnRpdHkuY29tMIIBIjANBgkqhkiG9w0BAQEF\nAAOCAQ8AMIIBCgKCAQEA4b/IX1bV29pw6/Ce8DdkoNx4dxJnDD9AyxmTG2z99cvl\nHG6BJaMF6l09ncGXGbv3dufDKrhftkwfbTBdpUEAeext/ugCmXTV06Fayva6Iq7x\nCNE8pA6hJT1y3Edsqq3IU8KVivYjYwd/vrSUfCe8pQRsR6K8rqnJ66ryn0yewkTE\nyCgPIv6pOMbgq1d5iX/2G9rZNhj74miN5y4fy0tsbI3q2RUOzt2d+htkoysqu3Xt\na6qPA3vEJ2FnQo3dhgw4XSCEvjz+HSGnsTC+XBv6j6jI9SD5jI2UYqnyDcYmRHPJ\nx2sQ/c8aLYHRdZxrxqIxUzulS6g0x74E2m0gBMKF5wIDAQABo4HfMIHcMA4GA1Ud\nDwEB/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwDAYDVR0T\nAQH/BAIwADAdBgNVHQ4EFgQUt+G5I2aokd3gFFMty1rsIT8yMuwwHwYDVR0jBBgw\nFoAUylkHhGQUSf1DtT8uxH02jqlbo20wXQYDVR0RBFYwVIIJbG9jYWxob3N0giJj\naWQxLmF1dGhvcml6YXRpb24uY2xvdWRlbnRpdHkuY29tgh1hdXRob3JpemF0aW9u\nLmNsb3VkZW50aXR5LmNvbYcEfwAAATANBgkqhkiG9w0BAQsFAAOCAQEAjKXSkhqk\nL7tpjk5KbQe8OIvpsR0EjO3Za2KsvzUGDQzE+3tqL3jDvAhqWpICGGzv0kkroveb\n0kXc2Ltc5a+EQtm5l100N0kMB8f11/B1tcLFWQQnqEPB4RTkesGv70e1C3LbjmgJ\nbE62cLR8X2dXr20HxUMZAzmlDdRZS/80YnXSDgjcWxDiFVitFbFeUyYF/oh4RmO5\nHQKvMEd3XIO/hWKp0Jv2G4B5IwtWm2ZodaM6zwMgX0BBp1LUsSF5OYDjuJ2Tq8da\nEGmUj5Y/+CroeW7nFDgAwt+1x3M76uT8fo+rP+UHweR8TCSq28dY3+N8UYrD5YIB\nZD/0ro2b2KVvgg==\n-----END CERTIFICATE-----",
    "subject_identifier_types": [
        "pairwise"
    ],
    "subject_format": "hash",
    "subject_identifier_algorithm_salt": "8Yr3jZSsJOirrskIWJEDTCUUst4vP67umY9C6_6Aqzg",
    "enable_trust_anchor": true,
    "trust_anchor_configuration": {
        "jwks": {
            "keys": null
        },
        "jwks_uri": "https://api.cdr.gov.au/idp/.well-known/openid-configuration/jwks"
    },
    "enable_quick_access": false,
    "enable_idp_discovery": false,
    "idp_discovery": {
        "enabled": false,
        "discovery_mode": "domain_matching"
    },
    "enable_legacy_clients_with_no_software_statement": false,
    "dynamic_scope_separator": ".",
    "issuer_id": "",
    "backchannel_token_delivery_modes_supported": [
        "poll",
        "ping"
    ],
    "backchannel_user_code_parameter_supported": false,
    "consent_id_namespace": "",
    "require_pushed_authorization_requests": false,
    "pushed_authorization_request_ttl": "1m0s",
    "device_authorization": {
        "request_ttl": "30m0s",
        "user_code_length": 8,
        "user_code_character_set": "base20"
    },
    "enable_id_token_encryption": true,
    "legal_entity": {
        "party": {
            "name": "",
            "home_uri": "",
            "logo_uri": "",
            "registry_name": "",
            "registered_entity_name": "",
            "registered_entity_identifier": ""
        }
    },
    "authentication_context_settings": {
        "attributes": [
            {
                "name": "sub",
                "description": "Subject",
                "type": "string",
                "labels": [
                    "advanced"
                ]
            },
            {
                "name": "scp",
                "description": "List of scopes",
                "type": "string_array",
                "labels": [
                    "advanced"
                ]
            },
            {
                "name": "groups",
                "description": "List of groups that user belongs to",
                "type": "string_array",
                "labels": []
            },
            {
                "name": "email",
                "description": "Email",
                "type": "string",
                "labels": [
                    "simple"
                ]
            },
            {
                "name": "email_verified",
                "description": "Email verified",
                "type": "bool",
                "labels": [
                    "advanced"
                ]
            },
            {
                "name": "phone_number",
                "description": "Phone",
                "type": "string",
                "labels": [
                    "simple"
                ]
            },
            {
                "name": "phone_number_verified",
                "description": "Phone verified",
                "type": "bool",
                "labels": [
                    "advanced"
                ]
            },
            {
                "name": "address.formatted",
                "description": "Full mailing address",
                "type": "string",
                "labels": []
            },
            {
                "name": "address.street_address",
                "description": "Full street address",
                "type": "string",
                "labels": []
            },
            {
                "name": "address.locality",
                "description": "City or locality",
                "type": "string",
                "labels": []
            },
            {
                "name": "address.region",
                "description": "Stage, province, prefecture or region",
                "type": "string",
                "labels": []
            },
            {
                "name": "address.country",
                "description": "Country",
                "type": "string",
                "labels": []
            },
            {
                "name": "address.postal_code",
                "description": "Postal code",
                "type": "string",
                "labels": []
            },
            {
                "name": "name",
                "description": "Name",
                "type": "string",
                "labels": []
            },
            {
                "name": "given_name",
                "description": "Given name",
                "type": "string",
                "labels": [
                    "simple"
                ]
            },
            {
                "name": "middle_name",
                "description": "Middle name",
                "type": "string",
                "labels": []
            },
            {
                "name": "family_name",
                "description": "Family name",
                "type": "string",
                "labels": [
                    "simple"
                ]
            },
            {
                "name": "nickname",
                "description": "Nickname",
                "type": "string",
                "labels": []
            },
            {
                "name": "preferred_username",
                "description": "The primary username that represents the user",
                "type": "string",
                "labels": [
                    "simple"
                ]
            },
            {
                "name": "profile",
                "description": "URL of the profile page",
                "type": "string",
                "labels": []
            },
            {
                "name": "picture",
                "description": "URL of the profile picture",
                "type": "string",
                "labels": []
            },
            {
                "name": "website",
                "description": "URL of the web page",
                "type": "string",
                "labels": []
            },
            {
                "name": "gender",
                "description": "Gender",
                "type": "string",
                "labels": []
            },
            {
                "name": "birthdate",
                "description": "Birthdate",
                "type": "string",
                "labels": []
            },
            {
                "name": "zoneinfo",
                "description": "Zoneinfo",
                "type": "string",
                "labels": []
            },
            {
                "name": "locale",
                "description": "Locale",
                "type": "string",
                "labels": []
            },
            {
                "name": "updated_at",
                "description": "Last update",
                "type": "number",
                "labels": []
            },
            {
                "name": "idp_sub",
                "description": "IDP Subject",
                "type": "string",
                "labels": []
            },
            {
                "name": "customer_id",
                "description": "Customer ID",
                "type": "string",
                "labels": []
            }
        ]
    },
    "cdr": {
        "brand_id": "",
        "adr_validation_enabled": true,
        "register_url": "https://api.cdr.gov.au",
        "industry": "banking"
    },
    "supported_application_purposes": [
        "single_page",
        "server_web",
        "mobile_desktop",
        "service"
    ]
}'  | jq -r '.issuer_url')
}

function create_client_apigee_proxy {
    printf "Creating client - apigee proxy\n"

    read CE_ACP_APIGEE_CLIENT_ID CE_ACP_APIGEE_CLIENT_SECRET < <(echo $(curl -k  --request POST \
  --url https://$DOMAIN/api/admin/$TENANT_ID/clients \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Content-Type: application/json' \
  --data '
    {
        "tenant_id": '"\"$TENANT_ID\""',
        "client_name": "apigeex-introspect-proxy",
        "description": "apigeex-introspect-proxy",
        "client_uri": "",
        "logo_uri": "",
        "policy_uri": "",
        "tos_uri": "",
        "organisation_id": "",
        "authorization_server_id": '"\"$WORKSPACE_ID\""',
        "client_id": '"\"$WORKSPACE_ID"'-cah78bukor34hf105is0",
        "client_secret": "W1NXu5V670rsc6-PV-TQp60fYxakDVQhudtDtec5sHE",
        "hashed_secret": "e8ec84cc12d075cd392475b14783764f7456382aa7676be768d4e52baefddb3ae8d1b7e84e15f77973efa0f1c2054677de3ae00be228a835064728d5f845a5e05a7ad87444200587c38d0906e76a437ee7901757dea4409235f3136f05a826c37f3f80f6ea65b09d0a22982322dea77cdc03c78477be1d5dba81c48c70949e4a",
        "application_type": "web",
        "application_types": [
            "service"
        ],
        "redirect_uris": [],
        "grant_types": [
            "client_credentials"
        ],
        "response_types": [
            "token"
        ],
        "scopes": [
            "introspect_openbanking_tokens",
            "introspect_tokens",
            "revoke_tokens"
        ],
        "audience": [
            "cah78bukor34hf105is0"
        ],
        "token_endpoint_auth_method": "client_secret_post",
        "token_endpoint_auth_signing_alg": "none",
        "jwks": {
            "keys": []
        },
        "jwks_uri": "",
        "request_object_signing_alg": "any",
        "request_uris": [],
        "client_id_issued_at": 1654813743,
        "created_at": "2022-06-09T22:29:03.212206Z",
        "updated_at": "2022-06-16T06:38:50.207223Z",
        "client_secret_expires_at": 0,
        "sector_identifier_uri": "",
        "userinfo_signed_response_alg": "none",
        "id_token_signed_response_alg": "PS256",
        "id_token_encrypted_response_alg": "",
        "id_token_encrypted_response_enc": "",
        "tls_client_certificate_bound_access_tokens": false,
        "tls_client_auth_subject_dn": "",
        "tls_client_auth_san_dns": "",
        "tls_client_auth_san_uri": "",
        "tls_client_auth_san_ip": "",
        "tls_client_auth_san_email": "",
        "privacy": {
            "scopes": null
        },
        "subject_type": "pairwise",
        "backchannel_token_delivery_mode": "",
        "backchannel_client_notification_endpoint": "",
        "backchannel_authentication_request_signing_alg": "",
        "backchannel_user_code_parameter": false,
        "require_pushed_authorization_requests": false,
        "authorization_signed_response_alg": "PS256",
        "authorization_encrypted_response_alg": "",
        "authorization_encrypted_response_enc": "",
        "developer_id": null,
        "system": false,
        "trusted": false,
        "metadata": {},
        "developer_metadata": {},
        "software_statement_payload": {},
        "software_statement": "",
        "software_id": "",
        "software_version": "",
        "dynamically_registered": false
    }' | jq -r ' "\(.client_id) \(.client_secret)"'))
}

function create_client_financroo {
    printf "Creating client - financroo\n"

    CE_ACP_TPP_CLIENT_ID=$(curl -k  --request POST \
  --url https://$DOMAIN/api/admin/$TENANT_ID/clients \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Content-Type: application/json' \
  --data '
{
    "tenant_id": '"\"$TENANT_ID\""',
    "client_name": "financroo-tpp",
    "description": "",
    "client_uri": "",
    "logo_uri": "",
    "policy_uri": "",
    "tos_uri": "",
    "organisation_id": "",
    "authorization_server_id": '"\"$WORKSPACE_ID\""',
    "client_id": '"\"$WORKSPACE_ID"'-cah9d021pkhkrv729gg0",
    "client_secret": "LUdsbeG5ggDa4iC9KX9llnpg3ZRTe7dxMl_FIhj-HWg",
    "hashed_secret": "5e655e14c3da344cce0b7e54fb12ff58b878e4b6f13d71a736bbc9fc0cedbcb236f8ce89ae5acaf77fa4b9ff24b60c2ca8a0c6fd08901e85a57c20eae4f340d6fc491e89cdbe4a1b9f7ceb5ee1c6fa0b98f4806a8781a16e843d985711ec7cbce0ce5d32d3586e7a8d01e584895d142c67af910a5d40526df662b80d56df8cf0",
    "application_type": "web",
    "application_types": [
        "server_web",
        "service"
    ],
    "redirect_uris": [
        '"\"https://$WORKSPACE_ID-ftz6uwntrq-ts.a.run.app/api/callback\""'
    ],
    "grant_types": [
        "authorization_code",
        "refresh_token",
        "client_credentials"
    ],
    "response_types": [
        "id_token",
        "code",
        "token",
        "code id_token"
    ],
    "scopes": [
        "admin:metadata:update",
        "admin:metrics.basic:read",
        "bank:accounts.basic:read",
        "bank:accounts.detail:read",
        "bank:payees:read",
        "bank:regular_payments:read",
        "bank:transactions:read",
        "cdr-register:bank:read",
        "cdr:registration",
        "common:customer.basic:read",
        "common:customer.detail:read",
        "email",
        "introspect_openbanking_tokens",
        "introspect_tokens",
        "offline_access",
        "openid",
        "profile",
        "revoke_tokens"
    ],
    "audience": [
        "cah9d021pkhkrv729gg0"
    ],
    "token_endpoint_auth_method": "tls_client_auth",
    "token_endpoint_auth_signing_alg": "none",
    "jwks": {
        "keys": [
            {
                "use": "sig",
                "kty": "RSA",
                "kid": "167467200346518873990055631921812347975180003245",
                "alg": "RS256",
                "n": "4b_IX1bV29pw6_Ce8DdkoNx4dxJnDD9AyxmTG2z99cvlHG6BJaMF6l09ncGXGbv3dufDKrhftkwfbTBdpUEAeext_ugCmXTV06Fayva6Iq7xCNE8pA6hJT1y3Edsqq3IU8KVivYjYwd_vrSUfCe8pQRsR6K8rqnJ66ryn0yewkTEyCgPIv6pOMbgq1d5iX_2G9rZNhj74miN5y4fy0tsbI3q2RUOzt2d-htkoysqu3Xta6qPA3vEJ2FnQo3dhgw4XSCEvjz-HSGnsTC-XBv6j6jI9SD5jI2UYqnyDcYmRHPJx2sQ_c8aLYHRdZxrxqIxUzulS6g0x74E2m0gBMKF5w",
                "e": "AQAB"
            }
        ]
    },
    "jwks_uri": "",
    "request_object_signing_alg": "any",
    "request_uris": [],
    "client_id_issued_at": 1654822528,
    "created_at": "2022-06-10T00:55:28.842375Z",
    "updated_at": "2022-06-16T06:20:58.068459Z",
    "client_secret_expires_at": 0,
    "sector_identifier_uri": "",
    "userinfo_signed_response_alg": "none",
    "id_token_signed_response_alg": "PS256",
    "id_token_encrypted_response_alg": "",
    "id_token_encrypted_response_enc": "",
    "tls_client_certificate_bound_access_tokens": true,
    "tls_client_auth_subject_dn": "CN=cid1.authorization.cloudentity.com,OU=Authorization,O=Cloudentity,L=Seattle,ST=Washinghton,C=US",
    "tls_client_auth_san_dns": "",
    "tls_client_auth_san_uri": "",
    "tls_client_auth_san_ip": "",
    "tls_client_auth_san_email": "",
    "privacy": {
        "scopes": null
    },
    "subject_type": "pairwise",
    "backchannel_token_delivery_mode": "",
    "backchannel_client_notification_endpoint": "",
    "backchannel_authentication_request_signing_alg": "",
    "backchannel_user_code_parameter": false,
    "require_pushed_authorization_requests": false,
    "authorization_signed_response_alg": "PS256",
    "authorization_encrypted_response_alg": "",
    "authorization_encrypted_response_enc": "",
    "developer_id": null,
    "system": false,
    "trusted": false,
    "metadata": {},
    "developer_metadata": {},
    "software_statement_payload": {},
    "software_statement": "",
    "software_id": "",
    "software_version": "",
    "dynamically_registered": false
}' | jq -r '.client_id')
}

function create_static_idp {
    printf "Creating static idp\n"

    RES=$(curl -k  --request POST \
  --url https://$DOMAIN/api/admin/$TENANT_ID/servers/$WORKSPACE_ID/idps/static \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Content-Type: application/json' \
  --data '{
    "id": '"\"$WORKSPACE_ID"'-cah75ea1pkhkrv71kfvg",
    "tenant_id": '"\"$TENANT_ID\""',
    "authorization_server_id": '"\"$WORKSPACE_ID\""',
    "name": "mock",
    "disabled": false,
    "hidden": false,
    "method": "static",
    "attributes": [
        {
            "name": "name",
            "description": "Name",
            "type": "string",
            "labels": null
        },
        {
            "name": "given_name",
            "description": "Given name",
            "type": "string",
            "labels": null
        },
        {
            "name": "family_name",
            "description": "Family name",
            "type": "string",
            "labels": null
        },
        {
            "name": "email",
            "description": "Email",
            "type": "string",
            "labels": null
        },
        {
            "name": "email_verified",
            "description": "Email verified",
            "type": "bool",
            "labels": null
        },
        {
            "name": "phone_number",
            "description": "Phone number",
            "type": "string",
            "labels": null
        },
        {
            "name": "phone_number_verified",
            "description": "Phone number verified",
            "type": "bool",
            "labels": null
        },
        {
            "name": "customer_id",
            "description": "customer_id",
            "type": "string",
            "labels": null
        }
    ],
    "mappings": [
        {
            "source": "name",
            "target": "name",
            "type": "string",
            "allow_weak_decoding": false
        },
        {
            "source": "given_name",
            "target": "given_name",
            "type": "string",
            "allow_weak_decoding": false
        },
        {
            "source": "family_name",
            "target": "family_name",
            "type": "string",
            "allow_weak_decoding": false
        },
        {
            "source": "email",
            "target": "email",
            "type": "string",
            "allow_weak_decoding": false
        },
        {
            "source": "email_verified",
            "target": "email_verified",
            "type": "bool",
            "allow_weak_decoding": false
        },
        {
            "source": "phone_number",
            "target": "phone_number",
            "type": "string",
            "allow_weak_decoding": false
        },
        {
            "source": "phone_number_verified",
            "target": "phone_number_verified",
            "type": "bool",
            "allow_weak_decoding": false
        },
        {
            "source": "customer_id",
            "target": "customer_id",
            "type": "string",
            "allow_weak_decoding": false
        }
    ],
    "static_amr": [],
    "transformer": {
        "enabled": false,
        "script": ""
    },
    "config": {
        "enable_stateful_ctx": false,
        "stateful_ctx_duration": "0s"
    },
    "discovery_settings": {
        "domains": [],
        "instant_redirect": false
    },
    "token_exchange_settings": {
        "enabled": false
    },
    "identity_pool_id": null,
    "settings": {
        "hint": false
    },
    "credentials": {
        "users": [
            {
                "username": "user",
                "password": "p@ssw0rd!",
                "email": "",
                "email_verified": false,
                "phone_number": "",
                "phone_number_verified": false,
                "authentication_context": {
                    "name": "user"
                },
                "additional_attributes": {
                    "customer_id": "bfb689fb-7745-45b9-bbaa-b21e00072447"
                }
            }
        ]
    }
}')
}

function update_consent_app_url {
    printf "Updating consent app url\n"

    CE_ACP_CONSENT_SCREEN_CLIENT_ID=$(curl -k  --request PUT \
  --url https://$DOMAIN/api/admin/$TENANT_ID/servers/$WORKSPACE_ID/server-consent \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Content-Type: application/json' \
  --data '{
    "tenant_id": '"\"$TENANT_ID\""',
    "server_id": '"\"$WORKSPACE_ID\""',
    "type": "custom",
    "oidc": {},
    "custom": {
        "server_consent_url": '"\"$1\""'
    },
    "openbanking": {
        "bank_url": ""
    }
}' | jq  -r '.client_id')
}

function get_consent_details {
  printf "Getting consent app details\n"

  CE_ACP_CONSENT_SCREEN_CLIENT_SECRET=$(curl -k  --request GET \
   --url https://$DOMAIN/api/admin/$TENANT_ID/clients/$CE_ACP_CONSENT_SCREEN_CLIENT_ID \
  --header "Authorization: Bearer $ACCESS_TOKEN" | jq -r '.client_secret')
}

function update_financroo_redirect_url {
    printf "Updating financroo redirect url\n"

    RES=$(curl -k  --request PUT \
  --url https://$DOMAIN/api/admin/$TENANT_ID/clients/$WORKSPACE_ID-cah9d021pkhkrv729gg0 \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Content-Type: application/json' \
  --data '{
    "tenant_id": '"\"$TENANT_ID\""',
    "client_name": "financroo-tpp",
    "description": "",
    "client_uri": "",
    "logo_uri": "",
    "policy_uri": "",
    "tos_uri": "",
    "organisation_id": "",
    "authorization_server_id": '"\"$WORKSPACE_ID\""',
    "client_id": '"\"$WORKSPACE_ID"'-cah9d021pkhkrv729gg0",
    "client_secret": "LUdsbeG5ggDa4iC9KX9llnpg3ZRTe7dxMl_FIhj-HWg",
    "hashed_secret": "5e655e14c3da344cce0b7e54fb12ff58b878e4b6f13d71a736bbc9fc0cedbcb236f8ce89ae5acaf77fa4b9ff24b60c2ca8a0c6fd08901e85a57c20eae4f340d6fc491e89cdbe4a1b9f7ceb5ee1c6fa0b98f4806a8781a16e843d985711ec7cbce0ce5d32d3586e7a8d01e584895d142c67af910a5d40526df662b80d56df8cf0",
    "application_type": "web",
    "application_types": [
        "server_web",
        "service"
    ],
    "redirect_uris": [
        '"\"$1\""'
    ],
    "grant_types": [
        "authorization_code",
        "refresh_token",
        "client_credentials"
    ],
    "response_types": [
        "id_token",
        "code",
        "token",
        "code id_token"
    ],
    "scopes": [
        "admin:metadata:update",
        "admin:metrics.basic:read",
        "bank:accounts.basic:read",
        "bank:accounts.detail:read",
        "bank:payees:read",
        "bank:regular_payments:read",
        "bank:transactions:read",
        "cdr-register:bank:read",
        "cdr:registration",
        "common:customer.basic:read",
        "common:customer.detail:read",
        "email",
        "introspect_openbanking_tokens",
        "introspect_tokens",
        "offline_access",
        "openid",
        "profile",
        "revoke_tokens"
    ],
    "audience": [
        "cah9d021pkhkrv729gg0"
    ],
    "token_endpoint_auth_method": "private_key_jwt",
    "token_endpoint_auth_signing_alg": "RS256",
    "jwks": {
        "keys": [
            {
                "use": "sig",
                "kty": "RSA",
                "kid": "167467200346518873990055631921812347975180003245",
                "alg": "RS256",
                "n": "4b_IX1bV29pw6_Ce8DdkoNx4dxJnDD9AyxmTG2z99cvlHG6BJaMF6l09ncGXGbv3dufDKrhftkwfbTBdpUEAeext_ugCmXTV06Fayva6Iq7xCNE8pA6hJT1y3Edsqq3IU8KVivYjYwd_vrSUfCe8pQRsR6K8rqnJ66ryn0yewkTEyCgPIv6pOMbgq1d5iX_2G9rZNhj74miN5y4fy0tsbI3q2RUOzt2d-htkoysqu3Xta6qPA3vEJ2FnQo3dhgw4XSCEvjz-HSGnsTC-XBv6j6jI9SD5jI2UYqnyDcYmRHPJx2sQ_c8aLYHRdZxrxqIxUzulS6g0x74E2m0gBMKF5w",
                "e": "AQAB"
            }
        ]
    },
    "jwks_uri": "",
    "request_object_signing_alg": "any",
    "request_uris": [],
    "client_id_issued_at": 1654822528,
    "created_at": "2022-06-10T00:55:28.842375Z",
    "updated_at": "2022-06-17T18:54:55.914443948Z",
    "client_secret_expires_at": 0,
    "sector_identifier_uri": "",
    "userinfo_signed_response_alg": "none",
    "id_token_signed_response_alg": "PS256",
    "id_token_encrypted_response_alg": "",
    "id_token_encrypted_response_enc": "",
    "tls_client_certificate_bound_access_tokens": true,
    "tls_client_auth_subject_dn": "CN=cid1.authorization.cloudentity.com,OU=Authorization,O=Cloudentity,L=Seattle,ST=Washinghton,C=US",
    "tls_client_auth_san_dns": "",
    "tls_client_auth_san_uri": "",
    "tls_client_auth_san_ip": "",
    "tls_client_auth_san_email": "",
    "privacy": {
        "scopes": {
            "admin:metadata:update": {
                "purpose": "",
                "pii_categories": []
            },
            "admin:metrics.basic:read": {
                "purpose": "",
                "pii_categories": []
            },
            "bank:accounts.basic:read": {
                "purpose": "",
                "pii_categories": []
            },
            "bank:accounts.detail:read": {
                "purpose": "",
                "pii_categories": []
            },
            "bank:payees:read": {
                "purpose": "",
                "pii_categories": []
            },
            "bank:regular_payments:read": {
                "purpose": "",
                "pii_categories": []
            },
            "bank:transactions:read": {
                "purpose": "",
                "pii_categories": []
            },
            "cdr-register:bank:read": {
                "purpose": "",
                "pii_categories": []
            },
            "cdr:registration": {
                "purpose": "",
                "pii_categories": []
            },
            "common:customer.basic:read": {
                "purpose": "",
                "pii_categories": []
            },
            "common:customer.detail:read": {
                "purpose": "",
                "pii_categories": []
            },
            "email": {
                "purpose": "",
                "pii_categories": []
            },
            "introspect_openbanking_tokens": {
                "purpose": "",
                "pii_categories": []
            },
            "introspect_tokens": {
                "purpose": "",
                "pii_categories": []
            },
            "offline_access": {
                "purpose": "",
                "pii_categories": []
            },
            "openid": {
                "purpose": "",
                "pii_categories": []
            },
            "profile": {
                "purpose": "",
                "pii_categories": []
            },
            "revoke_tokens": {
                "purpose": "",
                "pii_categories": []
            }
        }
    },
    "subject_type": "pairwise",
    "backchannel_token_delivery_mode": "",
    "backchannel_client_notification_endpoint": "",
    "backchannel_authentication_request_signing_alg": "",
    "backchannel_user_code_parameter": false,
    "require_pushed_authorization_requests": false,
    "authorization_signed_response_alg": "PS256",
    "authorization_encrypted_response_alg": "",
    "authorization_encrypted_response_enc": "",
    "developer_id": null,
    "system": false,
    "trusted": false,
    "metadata": {},
    "developer_metadata": {},
    "software_statement_payload": {},
    "software_statement": "",
    "software_id": "",
    "software_version": "",
    "dynamically_registered": false
}')
}

function update_customer_id_mapping {
    RES=$(curl --request POST \
        --url https://$DOMAIN/api/admin/$TENANT_ID/claims \
        --header "Authorization: Bearer $ACCESS_TOKEN" \
        --header 'Content-Type: application/json' \
        --data "{
        \"authorization_server_id\":\"$WORKSPACE_ID\",
        \"name\":\"customer_id\",
        \"source_path\":\"customer_id\",
        \"source_type\":\"authnCtx\",
        \"type\":\"access_token\"
    }")
}

function delete_workspace {
    printf "Deleting workspace\n"

    RES=$(curl -k  --request DELETE \
  --url https://$DOMAIN/api/admin/$TENANT_ID/servers/$WORKSPACE_ID \
  --header "Authorization: Bearer $ACCESS_TOKEN")
}

function replace_urls {
    printf "Updating urls\n"
    update_consent_app_url $2
    update_financroo_redirect_url $1
}

function setup_workspace {
    printf "Preparing workspace\n"
    create_oauth_server
    create_client_apigee_proxy

    create_client_financroo
    create_static_idp
    update_consent_app_url "http://replace-this-url"
    get_consent_details
    update_financroo_redirect_url "http://replace-this-url"
    update_customer_id_mapping

    printf "CE_ACP_AUTH_SERVER=$CE_ACP_AUTH_SERVER\nCE_ACP_APIGEE_CLIENT_ID=$CE_ACP_APIGEE_CLIENT_ID\nCE_ACP_APIGEE_CLIENT_SECRET=$CE_ACP_APIGEE_CLIENT_SECRET\nCE_ACP_TPP_CLIENT_ID=$CE_ACP_TPP_CLIENT_ID\nCE_ACP_CONSENT_SCREEN_CLIENT_ID=$CE_ACP_CONSENT_SCREEN_CLIENT_ID\nCE_ACP_CONSENT_SCREEN_CLIENT_SECRET=$CE_ACP_CONSENT_SCREEN_CLIENT_SECRET\nCE_ACP_ISSUER_URL=$(echo https://$DOMAIN/$TENANT_ID/system)
    " > deploy/ce_workspace.env

    printf '\n\n---workspace details---\n'

    echo CE_ACP_APIGEE_CLIENT_ID=$CE_ACP_APIGEE_CLIENT_ID
    echo CE_ACP_APIGEE_CLIENT_SECRET=$CE_ACP_APIGEE_CLIENT_SECRET
    echo CE_ACP_TPP_CLIENT_ID=$CE_ACP_TPP_CLIENT_ID
    echo CE_ACP_CONSENT_SCREEN_CLIENT_ID=$CE_ACP_CONSENT_SCREEN_CLIENT_ID
    echo CE_ACP_CONSENT_SCREEN_CLIENT_SECRET=$CE_ACP_CONSENT_SCREEN_CLIENT_SECRET
    CE_ACP_ISSUER_URL="https://$DOMAIN/$TENANT_ID/system"
    echo CE_ACP_ISSUER_URL=$CE_ACP_ISSUER_URL

    sed -i.bak "s|CE_ACP_AUTH_SERVER=.*|CE_ACP_AUTH_SERVER=$CE_ACP_AUTH_SERVER|" deploy/consent_mgmt_solution_config.env
    sed -i.bak "s|CE_ACP_APIGEE_CLIENT_ID=.*|CE_ACP_APIGEE_CLIENT_ID=$CE_ACP_APIGEE_CLIENT_ID|" deploy/consent_mgmt_solution_config.env
    sed -i.bak "s|CE_ACP_APIGEE_CLIENT_SECRET=.*|CE_ACP_APIGEE_CLIENT_SECRET=$CE_ACP_APIGEE_CLIENT_SECRET|" deploy/consent_mgmt_solution_config.env
    sed -i.bak "s|CE_ACP_TPP_CLIENT_ID=.*|CE_ACP_TPP_CLIENT_ID=$CE_ACP_TPP_CLIENT_ID|" deploy/consent_mgmt_solution_config.env
    sed -i.bak "s|CE_ACP_CONSENT_SCREEN_CLIENT_ID=.*|CE_ACP_CONSENT_SCREEN_CLIENT_ID=$CE_ACP_CONSENT_SCREEN_CLIENT_ID|" deploy/consent_mgmt_solution_config.env
    sed -i.bak "s|CE_ACP_CONSENT_SCREEN_CLIENT_SECRET=.*|CE_ACP_CONSENT_SCREEN_CLIENT_SECRET=$CE_ACP_CONSENT_SCREEN_CLIENT_SECRET|" deploy/consent_mgmt_solution_config.env
    sed -i.bak "s|CE_ACP_ISSUER_URL=.*|CE_ACP_ISSUER_URL=$CE_ACP_ISSUER_URL|" deploy/consent_mgmt_solution_config.env
    rm deploy/consent_mgmt_solution_config.env.bak
}

function full_deploy {
    sed -i.bak "s|PROJECT_ID=.*|PROJECT_ID=$GCP_PROJECT_ID|" deploy/consent_mgmt_solution_config.env
    sed -i.bak  "s|REGION=.*|REGION=$GCP_REGION|" deploy/consent_mgmt_solution_config.env
    sed -i.bak  "s|APIGEE_X_ENDPOINT=.*|APIGEE_X_ENDPOINT=$APIGEE_X_ENDPOINT|" deploy/consent_mgmt_solution_config.env
    sed -i.bak  "s|APIGEE_X_ENV=.*|APIGEE_X_ENV=$APIGEE_X_ENV|" deploy/consent_mgmt_solution_config.env
    rm deploy/consent_mgmt_solution_config.env.bak

    setup_workspace

    source deploy/consent_mgmt_solution_config.env
    source deploy/deploy_consent_mgmt_solution.sh deploy/consent_mgmt_solution_config.env
    source deploy/ce_workspace.env
    source deploy/setup-ce.sh replace-urls $DEMO_CLIENT_APP_URL/api/callback $CONSENT_APP_URL
}

case $1 in
    "create-workspace")
        get_token
        setup_workspace
    ;;
    "delete-workspace")
        get_token
        delete_workspace
    ;;
    "replace-urls")
        get_token
        replace_urls $2 $3
    ;;
    "full-deploy")
       get_token
       full_deploy
    ;;
    *)
       echo "unknown argument - requires one of: create-workspace, full-deploy, delete-workspace, replace-urls"
esac
