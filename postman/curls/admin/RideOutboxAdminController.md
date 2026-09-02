# RideOutboxAdminController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## GET /admin/outbox/ride-events/summary
```bash
curl -X GET "$BASE_URL/admin/outbox/ride-events/summary" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/outbox/ride-events
```bash
curl -X GET "$BASE_URL/admin/outbox/ride-events" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## POST /admin/outbox/ride-events/{outboxId}/replay
```bash
curl -X POST "$BASE_URL/admin/outbox/ride-events/{outboxId}/replay" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```

## POST /admin/outbox/ride-events/replay-failed
```bash
curl -X POST "$BASE_URL/admin/outbox/ride-events/replay-failed" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```
