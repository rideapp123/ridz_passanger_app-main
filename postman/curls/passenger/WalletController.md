# WalletController

```bash
BASE_URL="http://localhost:9091"
TOKEN="<jwt_token>"
ADMIN_TOKEN="<admin_jwt_token>"
```

## POST /passenger/wallet/add
```bash
curl -X POST "$BASE_URL/passenger/wallet/add" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"amount":50,"paymentMethodId":"pm_123"}'
```

## GET /passenger/wallet/balance
```bash
curl -X GET "$BASE_URL/passenger/wallet/balance" \
-H "Authorization: Bearer $TOKEN"
```

## GET /passenger/wallet/transactions
```bash
curl -X GET "$BASE_URL/passenger/wallet/transactions" \
-H "Authorization: Bearer $TOKEN"
```

## POST /passenger/wallet/bonus
```bash
curl -X POST "$BASE_URL/passenger/wallet/bonus" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"bonusCode":"SAVE10"}'
```

## POST /driver/wallet/withdraw
```bash
curl -X POST "$BASE_URL/driver/wallet/withdraw" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"amount":100}'
```

## GET /driver/wallet/balance
```bash
curl -X GET "$BASE_URL/driver/wallet/balance" \
-H "Authorization: Bearer $TOKEN"
```

## GET /driver/wallet/transactions
```bash
curl -X GET "$BASE_URL/driver/wallet/transactions" \
-H "Authorization: Bearer $TOKEN"
```

## POST /passenger/wallet/initialize-payment
```bash
curl -X POST "$BASE_URL/passenger/wallet/initialize-payment" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{"amount":100}'
```

## GET /passenger/wallet/retrieve-payment-intent/{clientSecret}
```bash
curl -X GET "$BASE_URL/passenger/wallet/retrieve-payment-intent/{clientSecret}" \
-H "Authorization: Bearer $TOKEN"
```
