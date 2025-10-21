#!/usr/bin/env python3
"""
Systematic page tester for Midday Dashboard
Tests each page and captures errors from the dashboard logs
"""

import subprocess
import time
import requests

PAGES_TO_TEST = [
    ("/", "Home/Dashboard"),
    ("/transactions", "Transactions"),
    ("/transactions/categories", "Transaction Categories"),
    ("/customers", "Customers"),
    ("/inbox", "Inbox"),
    ("/invoices", "Invoices"),
    ("/invoices/products", "Invoice Products"),
    ("/tracker", "Tracker/Time Tracking"),
    ("/vault", "Vault/Documents"),
    ("/account", "Account Settings"),
    ("/settings", "Settings"),
    ("/settings/accounts", "Settings - Accounts"),
    ("/settings/categories", "Settings - Categories"),
    ("/settings/display", "Settings - Display"),
    ("/settings/invoice", "Settings - Invoice"),
    ("/settings/members", "Settings - Members"),
    ("/settings/notifications", "Settings - Notifications"),
    ("/settings/security", "Settings - Security"),
    ("/apps", "Apps/Integrations"),
]

BASE_URL = "http://localhost:3001"

print("=" * 80)
print("MIDDAY DASHBOARD - SYSTEMATIC PAGE TESTING")
print("=" * 80)
print()

errors_found = []

for path, description in PAGES_TO_TEST:
    url = f"{BASE_URL}{path}"
    print(f"Testing: {description}")
    print(f"URL: {url}")
    
    try:
        response = requests.get(url, timeout=30)
        status = response.status_code
        print(f"Status: {status}")
        
        if status != 200:
            errors_found.append((path, description, f"HTTP {status}"))
        
    except Exception as e:
        print(f"Error: {e}")
        errors_found.append((path, description, str(e)))
    
    print()
    time.sleep(3)  # Wait between requests

print("=" * 80)
print("SUMMARY")
print("=" * 80)
print(f"Total pages tested: {len(PAGES_TO_TEST)}")
print(f"Errors found: {len(errors_found)}")
print()

if errors_found:
    print("PAGES WITH ERRORS:")
    for path, desc, error in errors_found:
        print(f"  - {desc} ({path}): {error}")
else:
    print("All pages loaded successfully!")

print()
print("Check the dashboard logs (PID 82344) for detailed error messages.")
print("=" * 80)
