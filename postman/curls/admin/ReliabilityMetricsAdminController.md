# ReliabilityMetricsAdminController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## GET /admin/metrics/reliability/snapshot
```bash
curl -X GET "$BASE_URL/admin/metrics/reliability/snapshot" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```
