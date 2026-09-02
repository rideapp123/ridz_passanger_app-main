# CarController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## POST /driver/car/images/{carId}/{type}/{subType}
```bash
curl -X POST "$BASE_URL/driver/car/images/{carId}/{type}/{subType}" \
-H "Authorization: Bearer $TOKEN" \
-F "file=@/absolute/path/car_image.jpg"
```

## GET /driver/car/{carId}
```bash
curl -X GET "$BASE_URL/driver/car/{carId}" \
-H "Authorization: Bearer $TOKEN"
```

## PUT /driver/car/{carId}
```bash
curl -X PUT "$BASE_URL/driver/car/{carId}" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"plateNumber":"ABC123","vehicleType":"sedan","make":"Toyota","model":"Corolla","year":2021,"color":"White"}'
```

## DELETE /driver/car/{carId}
```bash
curl -X DELETE "$BASE_URL/driver/car/{carId}" \
-H "Authorization: Bearer $TOKEN"
```

## PUT /driver/car/{carId}/status
```bash
curl -X PUT "$BASE_URL/driver/car/{carId}/status" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"plateNumber":"ABC123","vehicleType":"sedan","make":"Toyota","model":"Corolla","year":2021,"color":"White"}'
```
