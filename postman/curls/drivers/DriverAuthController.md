# DriverAuthController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## POST /driver/auth/send-otp
```bash
curl -X POST "$BASE_URL/driver/auth/send-otp" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"recipient":"user@example.com"}'
```

## POST /driver/auth/verify-otp
```bash
curl -X POST "$BASE_URL/driver/auth/verify-otp" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"recipient":"user@example.com","otp":"123456"}'
```

## POST /driver/auth/google-login
```bash
curl -X POST "$BASE_URL/driver/auth/google-login" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"idToken":"google_id_token_here"}'
```

## GET /driver/auth/me
```bash
curl -X GET "$BASE_URL/driver/auth/me" \
-H "Authorization: Bearer $TOKEN"
```

## PUT /driver/auth/basic-details
```bash
curl -X PUT "$BASE_URL/driver/auth/basic-details" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```

## PUT /driver/auth/living-address
```bash
curl -X PUT "$BASE_URL/driver/auth/living-address" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```

## PUT /driver/auth/bank-details
```bash
curl -X PUT "$BASE_URL/driver/auth/bank-details" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```

## POST /driver/auth/request-mobile-update
```bash
curl -X POST "$BASE_URL/driver/auth/request-mobile-update" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"newMobileNumber":"+15551234567"}'
```

## POST /driver/auth/verify-mobile-update
```bash
curl -X POST "$BASE_URL/driver/auth/verify-mobile-update" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"newMobileNumber":"+15551234567","otp":"123456"}'
```

## POST /driver/auth/request-email-update
```bash
curl -X POST "$BASE_URL/driver/auth/request-email-update" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"newEmail":"updated@example.com"}'
```

## POST /driver/auth/verify-email-update
```bash
curl -X POST "$BASE_URL/driver/auth/verify-email-update" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"newEmail":"updated@example.com","otp":"123456"}'
```

## POST /driver/auth/upload-document
```bash
curl -X POST "$BASE_URL/driver/auth/upload-document" \
-H "Authorization: Bearer $TOKEN" \
-F "file=@/absolute/path/license.pdf" \
-F "type=license"
```

## POST /driver/auth/verify-face
```bash
curl -X POST "$BASE_URL/driver/auth/verify-face" \
-H "Authorization: Bearer $TOKEN" \
-F "file=@/absolute/path/selfie.jpg"
```

## GET /driver/auth/document-status
```bash
curl -X GET "$BASE_URL/driver/auth/document-status" \
-H "Authorization: Bearer $TOKEN"
```

## PUT /driver/auth/update-fcm-token
```bash
curl -X PUT "$BASE_URL/driver/auth/update-fcm-token" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"fcmToken":"fcm_token_here"}'
```
