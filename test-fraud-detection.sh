#!/bin/bash

# Fraud Detection System - Test Script
# This script demonstrates the fraud detection capabilities

BASE_URL="http://localhost:8080/api"

echo "========================================="
echo "Fraud Detection System - Test Suite"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Register a new user
echo -e "${YELLOW}Test 1: Registering new user...${NC}"
USER_RESPONSE=$(curl -s -X POST "${BASE_URL}/users/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "phoneNumber": "+1234567890",
    "name": "John Doe",
    "password": "SecurePass123"
  }')

echo "$USER_RESPONSE" | jq .
USER_ID=$(echo "$USER_RESPONSE" | jq -r '.userId')
echo -e "${GREEN}User registered: ${USER_ID}${NC}"
echo ""
sleep 2

# Test 2: Normal transaction (should pass)
echo -e "${YELLOW}Test 2: Normal transaction (Should APPROVE)...${NC}"
curl -s -X POST "${BASE_URL}/transactions" \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"${USER_ID}\",
    \"amount\": 50.00,
    \"currency\": \"USD\",
    \"transactionType\": \"UPI\",
    \"merchantId\": \"MERCH-001\",
    \"merchantName\": \"Coffee Shop\",
    \"merchantCategory\": \"FOOD\",
    \"ipAddress\": \"192.168.1.100\",
    \"country\": \"USA\",
    \"city\": \"New York\",
    \"latitude\": 40.7128,
    \"longitude\": -74.0060,
    \"deviceId\": \"DEVICE-001\",
    \"deviceType\": \"MOBILE\"
  }" | jq .

echo ""
sleep 3

# Test 3: Another normal transaction
echo -e "${YELLOW}Test 3: Another normal transaction...${NC}"
curl -s -X POST "${BASE_URL}/transactions" \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"${USER_ID}\",
    \"amount\": 75.50,
    \"currency\": \"USD\",
    \"transactionType\": \"UPI\",
    \"merchantId\": \"MERCH-002\",
    \"merchantName\": \"Restaurant\",
    \"merchantCategory\": \"FOOD\",
    \"ipAddress\": \"192.168.1.100\",
    \"country\": \"USA\",
    \"city\": \"New York\",
    \"deviceId\": \"DEVICE-001\",
    \"deviceType\": \"MOBILE\"
  }" | jq .

echo ""
sleep 3

# Test 4: High amount transaction (should trigger fraud alert)
echo -e "${YELLOW}Test 4: High amount transaction (Should FLAG as SUSPICIOUS)...${NC}"
curl -s -X POST "${BASE_URL}/transactions" \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"${USER_ID}\",
    \"amount\": 5000.00,
    \"currency\": \"USD\",
    \"transactionType\": \"CARD\",
    \"merchantId\": \"MERCH-003\",
    \"merchantName\": \"Electronics Store\",
    \"merchantCategory\": \"ELECTRONICS\",
    \"ipAddress\": \"192.168.1.100\",
    \"country\": \"USA\",
    \"city\": \"New York\",
    \"deviceId\": \"DEVICE-001\",
    \"deviceType\": \"MOBILE\"
  }" | jq .

echo ""
sleep 3

# Test 5: Transaction from new device (should trigger alert)
echo -e "${YELLOW}Test 5: New device transaction (Should FLAG)...${NC}"
curl -s -X POST "${BASE_URL}/transactions" \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"${USER_ID}\",
    \"amount\": 200.00,
    \"currency\": \"USD\",
    \"transactionType\": \"UPI\",
    \"merchantId\": \"MERCH-004\",
    \"merchantName\": \"Online Store\",
    \"merchantCategory\": \"E-COMMERCE\",
    \"ipAddress\": \"203.0.113.45\",
    \"country\": \"USA\",
    \"city\": \"Los Angeles\",
    \"deviceId\": \"DEVICE-NEW-999\",
    \"deviceType\": \"WEB\"
  }" | jq .

echo ""
sleep 3

# Test 6: Multiple rapid transactions (velocity check)
echo -e "${YELLOW}Test 6: High velocity - Multiple rapid transactions...${NC}"
for i in {1..3}
do
  echo "Transaction $i:"
  curl -s -X POST "${BASE_URL}/transactions" \
    -H "Content-Type: application/json" \
    -d "{
      \"userId\": \"${USER_ID}\",
      \"amount\": 30.00,
      \"currency\": \"USD\",
      \"transactionType\": \"UPI\",
      \"merchantId\": \"MERCH-005\",
      \"merchantName\": \"Quick Mart\",
      \"merchantCategory\": \"RETAIL\",
      \"ipAddress\": \"192.168.1.100\",
      \"country\": \"USA\",
      \"deviceId\": \"DEVICE-001\",
      \"deviceType\": \"MOBILE\"
    }" | jq -c '{status, fraudStatus, fraudScore, message}'
  echo ""
  sleep 1
done

sleep 2

# Test 7: QR Code transaction
echo -e "${YELLOW}Test 7: QR Code payment transaction...${NC}"
curl -s -X POST "${BASE_URL}/transactions/qr" \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"${USER_ID}\",
    \"amount\": 150.00,
    \"currency\": \"USD\",
    \"transactionType\": \"QR_CODE\",
    \"qrCodeId\": \"QR-ABC123\",
    \"qrCodeData\": \"merchant_upi@bank\",
    \"merchantId\": \"MERCH-006\",
    \"merchantName\": \"Grocery Store\",
    \"merchantCategory\": \"GROCERIES\",
    \"ipAddress\": \"192.168.1.100\",
    \"country\": \"USA\",
    \"deviceId\": \"DEVICE-001\",
    \"deviceType\": \"MOBILE\"
  }" | jq .

echo ""
sleep 2

# Test 8: Get user fraud statistics
echo -e "${YELLOW}Test 8: Getting fraud statistics for user...${NC}"
curl -s -X GET "${BASE_URL}/fraud/statistics/${USER_ID}" | jq .
echo ""
sleep 2

# Test 9: Get user transactions
echo -e "${YELLOW}Test 9: Getting all transactions for user...${NC}"
curl -s -X GET "${BASE_URL}/transactions/user/${USER_ID}" | jq 'map({transactionId, amount, status, fraudStatus, fraudScore})'
echo ""
sleep 2

# Test 10: Get fraud alerts
echo -e "${YELLOW}Test 10: Getting fraud alerts for user...${NC}"
curl -s -X GET "${BASE_URL}/fraud/alerts/${USER_ID}" | jq 'map({transactionId, severity, fraudScore, reason})'
echo ""

# Test 11: Round amount transaction (suspicious pattern)
echo -e "${YELLOW}Test 11: Round amount transaction (Suspicious pattern)...${NC}"
curl -s -X POST "${BASE_URL}/transactions" \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"${USER_ID}\",
    \"amount\": 5000.00,
    \"currency\": \"USD\",
    \"transactionType\": \"UPI\",
    \"merchantId\": \"MERCH-007\",
    \"merchantName\": \"Unknown Merchant\",
    \"merchantCategory\": \"OTHER\",
    \"ipAddress\": \"192.168.1.100\",
    \"country\": \"USA\",
    \"deviceId\": \"DEVICE-001\",
    \"deviceType\": \"MOBILE\"
  }" | jq .

echo ""
echo -e "${GREEN}========================================="
echo "Test Suite Completed!"
echo "=========================================${NC}"
echo ""
echo "Summary:"
echo "- Registered user: ${USER_ID}"
echo "- Executed various transaction scenarios"
echo "- Tested fraud detection rules"
echo "- Demonstrated behavioral analysis"
echo ""
echo "Next steps:"
echo "1. Check the database for transaction records"
echo "2. Review fraud alerts in the system"
echo "3. Monitor user trust score changes"
echo "4. Test additional edge cases"