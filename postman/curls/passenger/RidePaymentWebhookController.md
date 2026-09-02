# RidePaymentWebhookController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## POST /passenger/payment/webhook
```bash
curl -X POST "$BASE_URL/passenger/payment/webhook" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"id":"evt_payment","type":"payment_intent.succeeded","data":{"object":{"id":"pi_123"}}}'
```
