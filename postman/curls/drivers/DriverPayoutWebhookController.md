# DriverPayoutWebhookController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## POST /driver/payout/webhook
```bash
curl -X POST "$BASE_URL/driver/payout/webhook" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"id":"evt_payout","type":"transfer.paid","data":{"object":{"id":"tr_123"}}}'
```
