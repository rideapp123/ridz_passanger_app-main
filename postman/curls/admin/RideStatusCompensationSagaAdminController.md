# RideStatusCompensationSagaAdminController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## GET /admin/saga/ride-status-compensation/summary
```bash
curl -X GET "$BASE_URL/admin/saga/ride-status-compensation/summary" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/saga/ride-status-compensation
```bash
curl -X GET "$BASE_URL/admin/saga/ride-status-compensation" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## POST /admin/saga/ride-status-compensation/{taskId}/replay
```bash
curl -X POST "$BASE_URL/admin/saga/ride-status-compensation/{taskId}/replay" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```
