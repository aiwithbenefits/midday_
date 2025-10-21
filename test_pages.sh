#!/bin/bash

# Test script to access all Midday pages and check for errors

BASE_URL="http://localhost:3001"
PAGES=(
  "/"
  "/transactions"
  "/transactions/categories"
  "/customers"
  "/inbox"
  "/invoices"
  "/invoices/products"
  "/tracker"
  "/vault"
  "/account"
  "/settings"
  "/settings/accounts"
  "/settings/categories"
  "/settings/display"
  "/settings/invoice"
  "/settings/members"
  "/settings/notifications"
  "/settings/security"
  "/apps"
)

echo "Testing Midday Dashboard Pages..."
echo "=================================="
echo ""

for page in "${PAGES[@]}"; do
  echo "Testing: ${BASE_URL}${page}"
  response=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}${page}")
  echo "  Status: $response"
  sleep 2
  echo ""
done

echo "=================================="
echo "All pages tested. Check dashboard logs for errors."
