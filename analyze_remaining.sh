#!/bin/bash

echo "Analyzing remaining violations..."
echo ""

SCREENS=(
  "lib/features/transactions/presentation/pages/transaction_page.dart"
  "lib/features/redeem/presentation/pages/redeem_page.dart"
  "lib/features/wallet/presentation/pages/wallet_page.dart"
  "lib/features/notifications/presentation/pages/notifications_page.dart"
  "lib/features/spin/presentation/pages/daily_spin_page.dart"
  "lib/features/home/presentation/pages/home_page.dart"
  "lib/features/bills/presentation/pages/add_bill_page.dart"
  "lib/features/profile/presentation/pages/profile_page.dart"
  "lib/features/admin/presentation/pages/admin_home_page.dart"
  "lib/features/admin/presentation/pages/admin_add_bill_page.dart"
  "lib/features/bills/presentation/pages/admin_add_bill_page.dart"
  "lib/features/bills/presentation/pages/bill_details_page.dart"
  "lib/features/admin/presentation/pages/bill_details_page.dart"
)

for screen in "${SCREENS[@]}"; do
  echo "=== $(basename $screen) ==="
  
  # Find EdgeInsets patterns
  grep -n "EdgeInsets\\.all([0-9]" "$screen" 2>/dev/null | grep -v "DesignToken" || true
  grep -n "EdgeInsets\\.symmetric" "$screen" 2>/dev/null | grep "[0-9])" | grep -v "DesignToken" || true
  grep -n "EdgeInsets\\.only" "$screen" 2>/dev/null | grep "[0-9]" || true
  
  # Find fontSize patterns  
  grep -n "fontSize: [0-9]" "$screen" 2>/dev/null | grep -v "DesignToken" || true
  
  # Find BorderRadius patterns
  grep -n "BorderRadius\\.circular([0-9]" "$screen" 2>/dev/null | grep -v "DesignToken" || true
  
  # Find SizedBox patterns
  grep -n "SizedBox(height: [0-9]\|SizedBox(width: [0-9]" "$screen" 2>/dev/null | grep -v "DesignToken" || true
  
  echo ""
done
