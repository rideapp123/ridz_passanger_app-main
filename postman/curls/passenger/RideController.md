# RideController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## POST /passenger/rides
```bash
curl -X POST "$BASE_URL/passenger/rides" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"vehicleType":"economy","pickup":{"latitude":37.77,"longitude":-122.42,"address":"Pickup"},"destination":{"latitude":37.78,"longitude":-122.41,"address":"Destination"},"paymentMethod":"card","promoCode":"SAVE10"}'
```

## GET /passenger/rides
```bash
curl -X GET "$BASE_URL/passenger/rides" \
-H "Authorization: Bearer $TOKEN"
```

## GET /passenger/rides/current
```bash
curl -X GET "$BASE_URL/passenger/rides/current" \
-H "Authorization: Bearer $TOKEN"
```

## GET /passenger/rides/{rideId}
```bash
curl -X GET "$BASE_URL/passenger/rides/{rideId}" \
-H "Authorization: Bearer $TOKEN"
```

## PUT /passenger/rides/{rideId}/status
```bash
curl -X PUT "$BASE_URL/passenger/rides/{rideId}/status" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"vehicleType":"economy","pickup":{"latitude":37.77,"longitude":-122.42,"address":"Pickup"},"destination":{"latitude":37.78,"longitude":-122.41,"address":"Destination"},"paymentMethod":"card","promoCode":"SAVE10"}'
```

## GET /driver/rides
```bash
curl -X GET "$BASE_URL/driver/rides" \
-H "Authorization: Bearer $TOKEN"
```

## GET /driver/rides/current
```bash
curl -X GET "$BASE_URL/driver/rides/current" \
-H "Authorization: Bearer $TOKEN"
```

## GET /driver/rides/{rideId}
```bash
curl -X GET "$BASE_URL/driver/rides/{rideId}" \
-H "Authorization: Bearer $TOKEN"
```

## PUT /driver/rides/{rideId}/status
```bash
curl -X PUT "$BASE_URL/driver/rides/{rideId}/status" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"status":"accepted","details":"accepted by driver","finalAmount":24.5}'
```
