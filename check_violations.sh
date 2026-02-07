#!/bin/bash

echo "==================================================================="
echo "DESIGN TOKEN VIOLATION CHECK - POST FIX"
echo "==================================================================="
echo ""

SCREENS=(
  "lib/features/splash/presentation/pages/splash_page.dart"
  "lib/features/dashboard/presentation/pages/dashboard_page.dart"
  "lib/features/transactions/presentation/pages/transaction_page.dart"
  "lib/features/redeem/presentation/pages/redeem_page.dart"
  "lib/features/wallet/presentation/pages/wallet_page.dart"
  "lib/features/settings/presentation/pages/notification_settings_page.dart"
  "lib/features/notifications/presentation/pages/notifications_page.dart"
  "lib/features/spin/presentation/pages/daily_spin_page.dart"
  "lib/features/home/presentation/pages/home_page.dart"
  "lib/features/bills/presentation/pages/add_bill_page.dart"
  "lib/features/profile/presentation/pages/profile_page.dart"
  "lib/features/profile/presentation/pages/edit_profile_page.dart"
  "lib/features/admin/presentation/pages/admin_home_page.dart"
  "lib/features/admin/presentation/pages/admin_add_bill_page.dart"
  "lib/features/bills/presentation/pages/admin_add_bill_page.dart"
  "lib/features/bills/presentation/pages/bill_details_page.dart"
  "lib/features/admin/presentation/pages/bill_details_page.dart"
)

total_violations=0

for screen in "${SCREENS[@]}"; do
  echo "Checking: $screen"
  
  # Count EdgeInsets.all with raw numbers (not using DesignToken)
  edge_all=$(grep -o 'EdgeInsets\.all([0-9]\+' "$screen" | grep -v 'DesignToken' | wc -l)
  
  # Count SizedBox with raw height/width (not using DesignToken)
  sized_box=$(grep -o 'SizedBox(height: [0-9]\+\|SizedBox(width: [0-9]\+' "$screen" | grep -v 'DesignToken' | wc -l)
  
  # Count BorderRadius.circular with raw numbers
  border_radius=$(grep -o 'BorderRadius\.circular([0-9]\+' "$screen" | grep -v 'DesignToken' | wc -l)
  
  # Count fontSize with raw numbers
  font_size=$(grep -o 'fontSize: [0-9]\+' "$screen" | grep -v 'DesignToken' | wc -l)
  
  violations=$((edge_all + sized_box + border_radius + font_size))
  total_violations=$((total_violations + violations))
  
  if [ $violations -gt 0 ]; then
    echo "  ❌ Found $violations violations (EdgeInsets: $edge_all, SizedBox: $sized_box, BorderRadius: $border_radius, FontSize: $font_size)"
  else
    echo "  ✅ No violations found"
  fi
  echo ""
done

echo "==================================================================="
echo "SUMMARY"
echo "==================================================================="
echo "Total screens checked: ${#SCREENS[@]}"
echo "Total violations remaining: $total_violations"
echo ""

if [ $total_violations -eq 0 ]; then
  echo "🎉 SUCCESS! All design token violations fixed!"
else
  echo "⚠️ Some violations remain. Manual review needed."
fi

