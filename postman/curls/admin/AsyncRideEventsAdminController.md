# AsyncRideEventsAdminController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## GET /admin/async/ride-events/dlq
```bash
curl -X GET "$BASE_URL/admin/async/ride-events/dlq" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## POST /admin/async/ride-events/dlq/replay/{recordId}
```bash
curl -X POST "$BASE_URL/admin/async/ride-events/dlq/replay/{recordId}" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```
