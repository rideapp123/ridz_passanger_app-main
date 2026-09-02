# PassengerCoreController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## GET /passenger/nearby-drivers
```bash
curl -X GET "$BASE_URL/passenger/nearby-drivers" \
-H "Authorization: Bearer $TOKEN"
```
