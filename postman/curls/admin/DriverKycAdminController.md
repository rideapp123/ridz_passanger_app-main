# DriverKycAdminController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## GET /admin/driver/kyc/{driverId}
```bash
curl -X GET "$BASE_URL/admin/driver/kyc/{driverId}" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## POST /admin/driver/kyc/{driverId}/approve
```bash
curl -X POST "$BASE_URL/admin/driver/kyc/{driverId}/approve" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{"notes":"Approved by admin"}'
```

## POST /admin/driver/kyc/{driverId}/reject
```bash
curl -X POST "$BASE_URL/admin/driver/kyc/{driverId}/reject" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{"reason":"document_blurry"}'
```
