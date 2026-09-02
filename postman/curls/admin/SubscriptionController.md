# SubscriptionController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## GET /driver/subscription/plans
```bash
curl -X GET "$BASE_URL/driver/subscription/plans" \
-H "Authorization: Bearer $TOKEN"
```

## GET /driver/subscription/current
```bash
curl -X GET "$BASE_URL/driver/subscription/current" \
-H "Authorization: Bearer $TOKEN"
```

## GET /driver/subscription/gate
```bash
curl -X GET "$BASE_URL/driver/subscription/gate" \
-H "Authorization: Bearer $TOKEN"
```

## GET /driver/subscription/create-setup-intent
```bash
curl -X GET "$BASE_URL/driver/subscription/create-setup-intent" \
-H "Authorization: Bearer $TOKEN"
```

## POST /driver/subscription/purchase
```bash
curl -X POST "$BASE_URL/driver/subscription/purchase" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"planId":"price_basic","paymentMethodId":"pm_123"}'
```

## PUT /driver/subscription/update
```bash
curl -X PUT "$BASE_URL/driver/subscription/update" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"planId":"price_pro","paymentMethodId":"pm_456"}'
```

## POST /driver/subscription/cancel
```bash
curl -X POST "$BASE_URL/driver/subscription/cancel" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```

## POST /driver/subscription/webhook
```bash
curl -X POST "$BASE_URL/driver/subscription/webhook" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"id":"evt_sub","type":"invoice.paid","data":{"object":{"id":"in_123"}}}'
```

## GET /admin/subscription/plans
```bash
curl -X GET "$BASE_URL/admin/subscription/plans" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## POST /admin/subscription/plans
```bash
curl -X POST "$BASE_URL/admin/subscription/plans" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{"priceId":"price_pro","name":"Pro","amount":999,"currency":"usd","interval":"month","active":true}'
```

## PUT /admin/subscription/plans/{priceId}
```bash
curl -X PUT "$BASE_URL/admin/subscription/plans/{priceId}" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{"priceId":"price_pro","name":"Pro","amount":999,"currency":"usd","interval":"month","active":true}'
```

## DELETE /admin/subscription/plans/{priceId}
```bash
curl -X DELETE "$BASE_URL/admin/subscription/plans/{priceId}" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/subscription/webhooks/inbox
```bash
curl -X GET "$BASE_URL/admin/subscription/webhooks/inbox" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/subscription/webhooks/inbox/summary
```bash
curl -X GET "$BASE_URL/admin/subscription/webhooks/inbox/summary" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/subscription/events
```bash
curl -X GET "$BASE_URL/admin/subscription/events" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/subscription/reconciliation/run
```bash
curl -X GET "$BASE_URL/admin/subscription/reconciliation/run" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```
