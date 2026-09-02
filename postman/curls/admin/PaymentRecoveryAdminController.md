# PaymentRecoveryAdminController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## GET /admin/payments/recovery/rides
```bash
curl -X GET "$BASE_URL/admin/payments/recovery/rides" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## POST /admin/payments/recovery/rides/{rideId}/retry
```bash
curl -X POST "$BASE_URL/admin/payments/recovery/rides/{rideId}/retry" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```

## GET /admin/payments/webhooks
```bash
curl -X GET "$BASE_URL/admin/payments/webhooks" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/payments/webhooks/summary
```bash
curl -X GET "$BASE_URL/admin/payments/webhooks/summary" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/payments/webhooks/inbox
```bash
curl -X GET "$BASE_URL/admin/payments/webhooks/inbox" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/payments/webhooks/inbox/summary
```bash
curl -X GET "$BASE_URL/admin/payments/webhooks/inbox/summary" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/payments/outbox/summary
```bash
curl -X GET "$BASE_URL/admin/payments/outbox/summary" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/payments/outbox
```bash
curl -X GET "$BASE_URL/admin/payments/outbox" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## POST /admin/payments/outbox/{outboxId}/replay
```bash
curl -X POST "$BASE_URL/admin/payments/outbox/{outboxId}/replay" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```

## POST /admin/payments/outbox/replay-failed
```bash
curl -X POST "$BASE_URL/admin/payments/outbox/replay-failed" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```

## GET /admin/payments/reconciliation/run
```bash
curl -X GET "$BASE_URL/admin/payments/reconciliation/run" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/payments/payout/webhooks/inbox
```bash
curl -X GET "$BASE_URL/admin/payments/payout/webhooks/inbox" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/payments/payout/webhooks/inbox/summary
```bash
curl -X GET "$BASE_URL/admin/payments/payout/webhooks/inbox/summary" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/payments/payout/webhooks
```bash
curl -X GET "$BASE_URL/admin/payments/payout/webhooks" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/payments/payout/webhooks/summary
```bash
curl -X GET "$BASE_URL/admin/payments/payout/webhooks/summary" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```

## GET /admin/payments/payout/reconciliation/run
```bash
curl -X GET "$BASE_URL/admin/payments/payout/reconciliation/run" \
-H "Authorization: Bearer $ADMIN_TOKEN"
```
