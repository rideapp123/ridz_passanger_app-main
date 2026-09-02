# DriverCoreController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## POST /driver/location
```bash
curl -X POST "$BASE_URL/driver/location" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"latitude":37.77,"longitude":-122.42,"isAvailable":true,"speed":12.3,"heading":45}'
```

## POST /driver/availability
```bash
curl -X POST "$BASE_URL/driver/availability" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"isAvailable":true}'
```
