# NotificationAdminController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## GET /admin/notifications/recent
```bash
curl -X GET "$BASE_URL/admin/notifications/recent" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```
