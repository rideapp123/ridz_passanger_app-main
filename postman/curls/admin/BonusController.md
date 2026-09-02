# BonusController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## POST /passenger/bonus/validate
```bash
curl -X POST "$BASE_URL/passenger/bonus/validate" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"code":"SAVE10","baseAmount":100}'
```

## POST /passenger/bonus/apply
```bash
curl -X POST "$BASE_URL/passenger/bonus/apply" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"code":"SAVE10","baseAmount":100}'
```

## GET /passenger/bonus/available
```bash
curl -X GET "$BASE_URL/passenger/bonus/available" \
-H "Authorization: Bearer $TOKEN"
```

## GET /passenger/bonus/{code}
```bash
curl -X GET "$BASE_URL/passenger/bonus/{code}" \
-H "Authorization: Bearer $TOKEN"
```

## POST /admin/bonus
```bash
curl -X POST "$BASE_URL/admin/bonus" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{"code":"SAVE10","type":"percentage","value":10,"maxDiscount":20,"startDate":"2026-03-01T00:00:00Z","endDate":"2026-12-31T23:59:59Z"}'
```

## GET /admin/bonus
```bash
curl -X GET "$BASE_URL/admin/bonus" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/bonus/{id}
```bash
curl -X GET "$BASE_URL/admin/bonus/{id}" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## PUT /admin/bonus/{id}
```bash
curl -X PUT "$BASE_URL/admin/bonus/{id}" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{"code":"SAVE10","type":"percentage","value":10,"maxDiscount":20,"startDate":"2026-03-01T00:00:00Z","endDate":"2026-12-31T23:59:59Z"}'
```

## PATCH /admin/bonus/{code}/deactivate
```bash
curl -X PATCH "$BASE_URL/admin/bonus/{code}/deactivate" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{"code":"SAVE10","type":"percentage","value":10,"maxDiscount":20,"startDate":"2026-03-01T00:00:00Z","endDate":"2026-12-31T23:59:59Z"}'
```

## DELETE /admin/bonus/{id}
```bash
curl -X DELETE "$BASE_URL/admin/bonus/{id}" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/bonus/{id}/stats
```bash
curl -X GET "$BASE_URL/admin/bonus/{id}/stats" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## POST /admin/bonus/bulk
```bash
curl -X POST "$BASE_URL/admin/bonus/bulk" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{"code":"SAVE10","type":"percentage","value":10,"maxDiscount":20,"startDate":"2026-03-01T00:00:00Z","endDate":"2026-12-31T23:59:59Z"}'
```

## POST /admin/bonus/generate
```bash
curl -X POST "$BASE_URL/admin/bonus/generate" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{"code":"SAVE10","type":"percentage","value":10,"maxDiscount":20,"startDate":"2026-03-01T00:00:00Z","endDate":"2026-12-31T23:59:59Z"}'
```
