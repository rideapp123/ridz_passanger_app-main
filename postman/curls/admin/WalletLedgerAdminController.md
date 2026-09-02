# WalletLedgerAdminController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## GET /admin/ledger/wallet/summary
```bash
curl -X GET "$BASE_URL/admin/ledger/wallet/summary" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/ledger/wallet/by-user
```bash
curl -X GET "$BASE_URL/admin/ledger/wallet/by-user" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/ledger/wallet/by-ride
```bash
curl -X GET "$BASE_URL/admin/ledger/wallet/by-ride" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```
