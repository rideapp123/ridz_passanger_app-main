# ChatController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## GET /driver/chat/{rideId}
```bash
curl -X GET "$BASE_URL/driver/chat/{rideId}" \
-H "Authorization: Bearer $TOKEN"
```

## GET /passenger/chat/{rideId}
```bash
curl -X GET "$BASE_URL/passenger/chat/{rideId}" \
-H "Authorization: Bearer $TOKEN"
```

## POST /driver/chat/{rideId}/rating
```bash
curl -X POST "$BASE_URL/driver/chat/{rideId}/rating" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"rating":5,"feedback":"Great ride"}'
```

## POST /passenger/chat/{rideId}/rating
```bash
curl -X POST "$BASE_URL/passenger/chat/{rideId}/rating" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"rating":5,"feedback":"Great ride"}'
```

## POST /driver/chat/{rideId}/emergency
```bash
curl -X POST "$BASE_URL/driver/chat/{rideId}/emergency" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"reason":"Emergency","location":{"latitude":37.77,"longitude":-122.42}}'
```

## POST /passenger/chat/{rideId}/emergency
```bash
curl -X POST "$BASE_URL/passenger/chat/{rideId}/emergency" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"reason":"Emergency","location":{"latitude":37.77,"longitude":-122.42}}'
```

## POST /driver/chat/{rideId}/emergency/resolve
```bash
curl -X POST "$BASE_URL/driver/chat/{rideId}/emergency/resolve" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```

## POST /passenger/chat/{rideId}/emergency/resolve
```bash
curl -X POST "$BASE_URL/passenger/chat/{rideId}/emergency/resolve" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```
