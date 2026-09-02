# PricingController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## POST /passenger/pricing/estimate
```bash
curl -X POST "$BASE_URL/passenger/pricing/estimate" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"vehicleType":"economy","distanceInKm":12.5,"timeInMinutes":25,"waitingTimeInMinutes":2,"zoneId":"zone-a"}'
```

## GET /passenger/pricing
```bash
curl -X GET "$BASE_URL/passenger/pricing" \
-H "Authorization: Bearer $TOKEN"
```

## POST /admin/price
```bash
curl -X POST "$BASE_URL/admin/price" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{"vehicleType":"economy","baseFare":3.5,"pricePerKm":1.4,"pricePerMinute":0.25,"active":true}'
```

## PUT /admin/price/{vehicleType}
```bash
curl -X PUT "$BASE_URL/admin/price/{vehicleType}" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{"vehicleType":"economy","baseFare":3.5,"pricePerKm":1.4,"pricePerMinute":0.25,"active":true}'
```
