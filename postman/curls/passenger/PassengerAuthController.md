# PassengerAuthController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## POST /passenger/auth/send-otp
```bash
curl -X POST "$BASE_URL/passenger/auth/send-otp" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"recipient":"user@example.com"}'
```

## POST /passenger/auth/verify-otp
```bash
curl -X POST "$BASE_URL/passenger/auth/verify-otp" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"recipient":"user@example.com","otp":"123456"}'
```

## POST /passenger/auth/google-login
```bash
curl -X POST "$BASE_URL/passenger/auth/google-login" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"idToken":"google_id_token_here"}'
```

## GET /passenger/auth/me
```bash
curl -X GET "$BASE_URL/passenger/auth/me" \
-H "Authorization: Bearer $TOKEN"
```

## PUT /passenger/auth/update-profile
```bash
curl -X PUT "$BASE_URL/passenger/auth/update-profile" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"username":"john_doe","email":"john@example.com"}'
```

## PUT /passenger/auth/update-fcm-token
```bash
curl -X PUT "$BASE_URL/passenger/auth/update-fcm-token" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"fcmToken":"fcm_token_here"}'
```

## POST /passenger/auth/update-profile-image
```bash
curl -X POST "$BASE_URL/passenger/auth/update-profile-image" \
-H "Authorization: Bearer $TOKEN" \
-F "file=@/absolute/path/profile.jpg"
```

## POST /passenger/auth/request-mobile-update
```bash
curl -X POST "$BASE_URL/passenger/auth/request-mobile-update" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"newMobileNumber":"+15551234567"}'
```

## POST /passenger/auth/verify-mobile-update
```bash
curl -X POST "$BASE_URL/passenger/auth/verify-mobile-update" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"newMobileNumber":"+15551234567","otp":"123456"}'
```

## POST /passenger/auth/request-email-update
```bash
curl -X POST "$BASE_URL/passenger/auth/request-email-update" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"newEmail":"updated@example.com"}'
```

## POST /passenger/auth/verify-email-update
```bash
curl -X POST "$BASE_URL/passenger/auth/verify-email-update" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"newEmail":"updated@example.com","otp":"123456"}'
```
