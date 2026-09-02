# PaymentCardController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## POST /passenger/payment/create-setup-intent
```bash
curl -X POST "$BASE_URL/passenger/payment/create-setup-intent" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{}'
```

## POST /passenger/payment/add-card
```bash
curl -X POST "$BASE_URL/passenger/payment/add-card" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"setupIntentId":"seti_123"}'
```

## GET /passenger/payment/cards
```bash
curl -X GET "$BASE_URL/passenger/payment/cards" \
-H "Authorization: Bearer $TOKEN"
```

## DELETE /passenger/payment/cards/{cardId}
```bash
curl -X DELETE "$BASE_URL/passenger/payment/cards/{cardId}" \
-H "Authorization: Bearer $TOKEN"
```
