# Detailed Violation Breakdown by Category

## Design Token Violations (47+ occurrences)

### Screens with Design Token Issues:
1. **splash_page** - 5 violations
   - Raw EdgeInsets.all values
   - Raw SizedBox dimensions  
   - Raw fontSize
   - Raw BorderRadius.circular
   - Raw Radius.circular

2. **dashboard_page** - 2+ violations
   - Raw Color(0x...) literals
   - Multiple design token uses missing

3. **home_page** - 8+ violations
   - Raw EdgeInsets values
   - Raw SizedBox values
   - Raw fontSize
   - Raw fontWeight
   - Raw BorderRadius.circular
   - Raw Radius.circular
   - Raw elevation values

4. **add_bill_page** - Multiple violations
5. **admin_add_bill_page** - Multiple violations  
6. **bill_details_page (Bills)** - Multiple violations
7. **wallet_page** - Multiple violations
8. **profile_page** - Multiple violations
9. **edit_profile_page** - Multiple violations
10. **admin_home_page** - Multiple violations
11. **admin_add_bill_page (Admin)** - Multiple violations
12. **bill_details_page (Admin)** - Multiple violations
13. **diagnostic_page** - Multiple violations
14. **daily_spin_page** - Multiple violations
15. **redeem_page** - Multiple violations
16. **notification_settings_page** - Multiple violations
17. **notifications_page** - Multiple violations

---

## Architecture Issues (15+ screens)

### Direct Firestore Operations:
- **home_page** - CRITICAL
  - Direct `FirebaseFirestore.instance` calls
  - StreamBuilder without proper error handling
  - Should use BLoC/Service layer

### StatefulWidget Without BLoC:
- dashboard_page
- home_page
- Multiple bill screens
- Profile screens
- Admin screens
- Spin, Redeem, Notifications pages

### Service Layer Imports in UI:
- splash_page (detected service import)

---

## Widget Composition Issues (18+ violations)

### Large Build Methods:
- login_page
- pin_login_page
- pin_setup_page
- reset_pin_page
- splash_page
- home_page (has additional loop iteration in build)
- add_bill_page
- admin_add_bill_page
- bill_details_page
- wallet_page
- profile_page
- edit_profile_page
- notification_settings_page
- admin_home_page
- diagnostic_page
- daily_spin_page
- redeem_page
- notifications_page

---

## Performance Issues

### ListView Issues:
- **home_page**
  - ListView without .builder (causes poor performance with large lists)
  - Loop/iteration in build method (should be in initState/computed)

### Widget Efficiency:
- Multiple screens with loops/iterations in build()
- Heavy nesting without proper widget extraction

---

## Accessibility Violations (16+ violations)

### Missing semanticsLabel:
- reset_pin_page
- splash_page
- dashboard_page
- home_page
- add_bill_page
- admin_add_bill_page
- bill_details_page
- wallet_page
- profile_page
- edit_profile_page
- notification_settings_page
- admin_home_page
- diagnostic_page
- daily_spin_page
- redeem_page
- notifications_page

### Manual Testing Required:
- All screens need verification of 48x48 dp tap target sizes
- All screens need testing with 200% text scale
- All screens need testing on multiple device sizes

---

## Code Quality Issues (44+ violations)

### Magic Numbers:
- login_page
- pin_login_page
- pin_setup_page
- reset_pin_page
- splash_page
- dashboard_page
- home_page
- add_bill_page
- admin_add_bill_page
- bill_details_page
- wallet_page
- transaction_page
- profile_page
- edit_profile_page
- notification_settings_page
- admin_home_page
- diagnostic_page
- daily_spin_page
- redeem_page
- notifications_page

### Missing Documentation:
- All 22 screens missing class-level doc comments

### Debug Code:
- **home_page** - Contains debug print statements

---

## Responsive Design Issues (22+ violations)

### Hardcoded Sizes:
- login_page
- pin_login_page
- pin_setup_page
- reset_pin_page
- splash_page
- dashboard_page
- home_page
- add_bill_page
- admin_add_bill_page
- bill_details_page
- wallet_page
- profile_page
- edit_profile_page
- notification_settings_page
- admin_home_page
- diagnostic_page
- daily_spin_page
- redeem_page
- notifications_page

### Manual Testing Needed:
- Test on device: 320x568 (small phone)
- Test on device: 428x926 (modern phone)
- Test on tablet: 768x1024
- Test at 200% text scale

---

## Asset Management Issues

### Icon Issues:
- dashboard_page - Icons.* detected
- home_page - Icons.* detected
- Multiple screens prefer custom icon assets

### Image Loading:
- home_page - Should consider cached_network_image

---

## Localization Status

### ✅ PASSING - Proper Localization:
- All 22 screens properly using AppLocalizations
- All text using localized strings
- No hardcoded strings detected

---

## Firebase Integration Issues

### StreamBuilder Issues:
- **home_page** - Missing error handling

### FutureBuilder Issues:
- **home_page** - Needs verification of loading/error states

### Service Layer Violations:
- **home_page** - Direct Firestore instance calls

---

# Issue Frequency Analysis

## By Category (Percentage of Total 306 Issues):
- Code Quality Issues: 14.4%
- Widget Composition: 5.9%
- Responsive Design: 7.2%
- Design Tokens: 15.4%
- Architecture: 4.9%
- Accessibility: 5.2%
- Performance: 3.3%
- Firebase: 0.6%
- Localization: 0% (PASSING)
- Asset Management: 2% (low priority)
- Manual Testing: 41.1% (needs QA)

## By Severity:
- Critical: 161 (53%)
- Warnings: 145 (47%)

## By Effort to Fix:
- Low (1-2 hours): 89 issues (29%)
- Medium (2-4 hours): 134 issues (44%)
- High (4+ hours): 83 issues (27%)

---

# Quick Reference: Fix Order

## Batch 1 - Design Tokens (Can be partially automated)
- Touch: 18 screens
- Time: 3-4 days
- Impact: HIGH (enables ~47 issues to pass)
- Difficulty: LOW

## Batch 2 - Firebase Architecture  
- Touch: 1-3 screens (mainly home_page)
- Time: 2-3 days
- Impact: CRITICAL
- Difficulty: HIGH

## Batch 3 - BLoC Refactoring
- Touch: 15+ screens
- Time: 5-7 days
- Impact: CRITICAL
- Difficulty: HIGH

## Batch 4 - Widget Decomposition
- Touch: 18 screens
- Time: 4-5 days
- Impact: MEDIUM
- Difficulty: MEDIUM

## Batch 5 - Accessibility
- Touch: 16+ screens
- Time: 2-3 days
- Impact: MEDIUM
- Difficulty: LOW-MEDIUM

## Batch 6 - Code Cleanup
- Touch: 22 screens
- Time: 1-2 days  
- Impact: LOW
- Difficulty: LOW

## Batch 7 - Testing & Verification
- Touch: 22 screens
- Time: 2-3 days
- Impact: CRITICAL
- Difficulty: MEDIUM

---
