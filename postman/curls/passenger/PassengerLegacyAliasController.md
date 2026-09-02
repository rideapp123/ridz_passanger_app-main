# PassengerLegacyAliasController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## POST /passanger/auth/send-otp
```bash
curl -X POST "$BASE_URL/passanger/auth/send-otp" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"recipient":"user@example.com"}'
```

## POST /passanger/auth/verify-otp
```bash
curl -X POST "$BASE_URL/passanger/auth/verify-otp" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"recipient":"user@example.com","otp":"123456"}'
```

## GET /passanger/auth/me
```bash
curl -X GET "$BASE_URL/passanger/auth/me" \
-H "Authorization: Bearer $TOKEN"
```
