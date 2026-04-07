# Screen hard-coded report (screens only)
Generated: 2026-03-20

Scope: `lib/presentation/screens/**/*.dart`
Notes: regex-based scan for literal string/color usages in common UI properties. It may include localization fallbacks like `?? 'Error'`.

## Summary
- Hard-coded string literals found: 80
- Hard-coded color expressions found: 224

## Phase 1: Hard-coded Strings (fix one-by-one in this order)
1. `lib/presentation/screens/admin/admin_add_bill_page.dart:119` - `${l10n!.errorOccurred}: ${e.toString()}`
   - Code: `content: Text('${l10n!.errorOccurred}: ${e.toString()}'),`
2. `lib/presentation/screens/admin/admin_add_bill_page.dart:147` - `${l10n!.errorOccurred}: ${e.toString()}`
   - Code: `content: Text('${l10n!.errorOccurred}: ${e.toString()}'),`
3. `lib/presentation/screens/admin/admin_add_bill_page.dart:331` - `${l10n!.errorOccurred}: ${e.toString()}`
   - Code: `content: Text('${l10n!.errorOccurred}: ${e.toString()}'),`
4. `lib/presentation/screens/admin/admin_home_page.dart:116` - `${l10n.logoutFailed}: ${e.toString()}`
   - Code: `content: Text('${l10n.logoutFailed}: ${e.toString()}'),`
5. `lib/presentation/screens/admin/admin_home_page.dart:132` - `${l10n.delete} ${l10n.all} ${l10n.notifications}`
   - Code: `title: Text('${l10n.delete} ${l10n.all} ${l10n.notifications}'),`
6. `lib/presentation/screens/admin/admin_notifications_page.dart:68` - `${l10n.delete} ${l10n.all} ${l10n.notifications}`
   - Code: `title: Text('${l10n.delete} ${l10n.all} ${l10n.notifications}'),`
7. `lib/presentation/screens/admin/bill_details_page.dart:202` - `${l10n.error}: ${e.toString()}`
   - Code: `content: Text('${l10n.error}: ${e.toString()}'),`
8. `lib/presentation/screens/admin/bill_details_page.dart:251` - `${l10n.error}: ${e.toString()}`
   - Code: `content: Text('${l10n.error}: ${e.toString()}'),`
9. `lib/presentation/screens/admin/bill_details_page.dart:300` - `${l10n.error}: ${e.toString()}`
   - Code: `content: Text('${l10n.error}: ${e.toString()}'),`
10. `lib/presentation/screens/auth/login_page.dart:100` - `${l10n.error}: ${e.toString()}`
   - Code: `content: Text('${l10n.error}: ${e.toString()}'),`
11. `lib/presentation/screens/bills/add_bill_page.dart:206` - `${l10n!.errorOccurred}: ${e.toString()}`
   - Code: `content: Text('${l10n!.errorOccurred}: ${e.toString()}'),`
12. `lib/presentation/screens/bills/add_bill_page.dart:234` - `${l10n!.errorOccurred}: ${e.toString()}`
   - Code: `content: Text('${l10n!.errorOccurred}: ${e.toString()}'),`
13. `lib/presentation/screens/bills/add_bill_page.dart:386` - `${l10n!.errorOccurred}: ${e.toString()}`
   - Code: `content: Text('${l10n!.errorOccurred}: ${e.toString()}'),`
14. `lib/presentation/screens/home/home_page.dart:1222` - `${l10n.logoutFailed}: ${e.toString()}`
   - Code: `content: Text('${l10n.logoutFailed}: ${e.toString()}'),`
15. `lib/presentation/screens/notifications/notifications_page.dart:340` - `Notification deleted`
   - Code: `content: const Text('Notification deleted'),`
16. `lib/presentation/screens/notifications/notifications_page.dart:351` - `Error deleting notification: $e`
   - Code: `content: Text('Error deleting notification: $e'),`
17. `lib/presentation/screens/notifications/notifications_page.dart:411` - `Delete All`
   - Code: `child: const Text('Delete All', style: TextStyle(fontSize: 16)),`
18. `lib/presentation/screens/notifications/notifications_page.dart:474` - `${snapshot.length} notification(s) deleted`
   - Code: `content: Text('${snapshot.length} notification(s) deleted'),`
19. `lib/presentation/screens/notifications/notifications_page.dart:491` - `Error deleting notifications: $e`
   - Code: `content: Text('Error deleting notifications: $e'),`
20. `lib/presentation/screens/notifications/notifications_page.dart:605` - `Notifications`
   - Code: `title: 'Notifications',`
21. `lib/presentation/screens/notifications/notifications_page.dart:610` - `Unable to load notifications`
   - Code: `child: Center(child: Text('Unable to load notifications')),`
22. `lib/presentation/screens/notifications/notifications_page.dart:625` - `Notifications`
   - Code: `title: 'Notifications',`
23. `lib/presentation/screens/notifications/notifications_page.dart:644` - `Delete All`
   - Code: `tooltip: 'Delete All',`
24. `lib/presentation/screens/notifications/notifications_page.dart:700` - `Retry`
   - Code: `child: const Text('Retry'),`
25. `lib/presentation/screens/notifications/notifications_page.dart:842` - `Delete`
   - Code: `child: const Text('Delete'),`
26. `lib/presentation/screens/orders/order_detail_page.dart:35` - `Order Details`
   - Code: `title: const Text('Order Details'),`
27. `lib/presentation/screens/orders/order_detail_page.dart:411` - `Download / Share PDF`
   - Code: `label: const Text('Download / Share PDF'),`
28. `lib/presentation/screens/orders/orders_page.dart:55` - `My Orders`
   - Code: `title: const Text('My Orders'),`
29. `lib/presentation/screens/orders/orders_page.dart:78` - `My Orders`
   - Code: `title: const Text('My Orders'),`
30. `lib/presentation/screens/orders/orders_page.dart:86` - `Please log in to view orders.`
   - Code: `child: Text('Please log in to view orders.'),`
31. `lib/presentation/screens/orders/orders_page.dart:101` - `My Orders`
   - Code: `title: const Text('My Orders'),`
32. `lib/presentation/screens/orders/orders_page.dart:591` - `Download / Share PDF`
   - Code: `label: const Text('Download / Share PDF'),`
33. `lib/presentation/screens/products/product_detail_page.dart:31` - `Please log in to add items to cart.`
   - Code: `content: Text('Please log in to add items to cart.'),`
34. `lib/presentation/screens/products/product_detail_page.dart:59` - `Added to cart`
   - Code: `content: Text('Added to cart'),`
35. `lib/presentation/screens/products/product_detail_page.dart:95` - `Unable to open share app.`
   - Code: `content: Text('Unable to open share app.'),`
36. `lib/presentation/screens/products/product_detail_page.dart:119` - `Product Details`
   - Code: `title: const Text('Product Details'),`
37. `lib/presentation/screens/products/product_detail_page.dart:138` - `Cart`
   - Code: `tooltip: 'Cart',`
38. `lib/presentation/screens/products/product_detail_page.dart:165` - `Share`
   - Code: `tooltip: 'Share',`
39. `lib/presentation/screens/products/product_detail_page.dart:408` - `Unable to open catalog PDF.`
   - Code: `content: Text('Unable to open catalog PDF.'),`
40. `lib/presentation/screens/products/product_detail_page.dart:414` - `View catalog PDF`
   - Code: `label: const Text('View catalog PDF'),`
41. `lib/presentation/screens/products/product_detail_page.dart:456` - `Share`
   - Code: `label: const Text('Share'),`
42. `lib/presentation/screens/products/product_detail_page.dart:472` - `Add to cart`
   - Code: `label: const Text('Add to cart'),`
43. `lib/presentation/screens/products/product_detail_page.dart:550` - `Cart`
   - Code: `tooltip: 'Cart',`
44. `lib/presentation/screens/products/product_list_page.dart:42` - `Products`
   - Code: `title: const Text('Products'),`
45. `lib/presentation/screens/products/product_list_page.dart:54` - `Cart`
   - Code: `tooltip: 'Cart',`
46. `lib/presentation/screens/products/product_list_page.dart:166` - `All`
   - Code: `label: const Text('All'),`
47. `lib/presentation/screens/products/product_list_page.dart:298` - `Please log in to add items to cart.`
   - Code: `content: Text('Please log in to add items to cart.'),`
48. `lib/presentation/screens/products/product_list_page.dart:316` - `Added to cart`
   - Code: `const SnackBar(content: Text('Added to cart')),`
49. `lib/presentation/screens/products/product_list_page.dart:536` - `Cart`
   - Code: `tooltip: 'Cart',`
50. `lib/presentation/screens/profile/edit_profile_page.dart:97` - `Failed to pick image: ${e.toString()}`
   - Code: `content: Text('Failed to pick image: ${e.toString()}'),`
51. `lib/presentation/screens/profile/edit_profile_page.dart:158` - `Please add a profile photo`
   - Code: `content: Text('Please add a profile photo'),`
52. `lib/presentation/screens/profile/edit_profile_page.dart:318` - `Profile updated successfully`
   - Code: `content: Text('Profile updated successfully'),`
53. `lib/presentation/screens/profile/edit_profile_page.dart:357` - `Failed to update profile: ${e.toString()}`
   - Code: `content: Text('Failed to update profile: ${e.toString()}'),`
54. `lib/presentation/screens/profile/edit_profile_page.dart:582` - `First Name *`
   - Code: `labelText: 'First Name *',`
55. `lib/presentation/screens/profile/edit_profile_page.dart:586` - `Enter your first name`
   - Code: `hintText: 'Enter your first name',`
56. `lib/presentation/screens/profile/edit_profile_page.dart:640` - `Last Name *`
   - Code: `labelText: 'Last Name *',`
57. `lib/presentation/screens/profile/edit_profile_page.dart:644` - `Enter your last name`
   - Code: `hintText: 'Enter your last name',`
58. `lib/presentation/screens/profile/edit_profile_page.dart:799` - `Please complete your profile`
   - Code: `content: Text('Please complete your profile'),`
59. `lib/presentation/screens/profile/profile_page.dart:189` - `${l10n.logoutFailed}: ${e.toString()}`
   - Code: `content: Text('${l10n.logoutFailed}: ${e.toString()}'),`
60. `lib/presentation/screens/profile/profile_page.dart:491` - `My Orders`
   - Code: `title: 'My Orders',`
61. `lib/presentation/screens/profile/profile_page.dart:517` - `Notification Settings`
   - Code: `title: 'Notification Settings',`
62. `lib/presentation/screens/profile/profile_page.dart:644` - `Could not make call: $e`
   - Code: `content: Text('Could not make call: $e'),`
63. `lib/presentation/screens/profile/profile_page.dart:1039` - `English`
   - Code: `child: Text('English'),`
64. `lib/presentation/screens/profile/profile_page.dart:1041` - `हिंदी`
   - Code: `DropdownMenuItem(value: Locale('hi'), child: Text('हिंदी')),`
65. `lib/presentation/screens/profile/profile_page.dart:1042` - `தமிழ்`
   - Code: `DropdownMenuItem(value: Locale('ta'), child: Text('தமிழ்')),`
66. `lib/presentation/screens/redeem/redeem_page.dart:74` - `Add`
   - Code: `child: const Text("Add"),`
67. `lib/presentation/screens/settings/notification_settings_page.dart:79` - `Error loading preferences: ${e.toString()}`
   - Code: `content: Text('Error loading preferences: ${e.toString()}'),`
68. `lib/presentation/screens/settings/notification_settings_page.dart:115` - `Notification preferences saved`
   - Code: `content: Text('Notification preferences saved'),`
69. `lib/presentation/screens/settings/notification_settings_page.dart:126` - `Error saving preferences: ${e.toString()}`
   - Code: `content: Text('Error saving preferences: ${e.toString()}'),`
70. `lib/presentation/screens/settings/notification_settings_page.dart:143` - `Notification Settings`
   - Code: `title: 'Notification Settings',`
71. `lib/presentation/screens/settings/notification_settings_page.dart:172` - `Bill Approved`
   - Code: `title: 'Bill Approved',`
72. `lib/presentation/screens/settings/notification_settings_page.dart:185` - `Bill Rejected`
   - Code: `title: 'Bill Rejected',`
73. `lib/presentation/screens/settings/notification_settings_page.dart:198` - `Points Withdrawn`
   - Code: `title: 'Points Withdrawn',`
74. `lib/presentation/screens/settings/notification_settings_page.dart:213` - `Tier Upgraded`
   - Code: `title: 'Tier Upgraded',`
75. `lib/presentation/screens/settings/notification_settings_page.dart:228` - `Daily Spin`
   - Code: `title: 'Daily Spin',`
76. `lib/presentation/screens/settings/notification_settings_page.dart:241` - `New Offers`
   - Code: `title: 'New Offers',`
77. `lib/presentation/screens/spin/daily_spin_page.dart:126` - `Great!`
   - Code: `child: const Text('Great!', style: TextStyle(fontSize: 16)),`
78. `lib/presentation/screens/spin/daily_spin_page.dart:151` - `Please wait for spin to complete`
   - Code: `content: Text('Please wait for spin to complete'),`
79. `lib/presentation/screens/spin/daily_spin_page.dart:170` - `Daily Spin`
   - Code: `title: const Text('Daily Spin'),`
80. `lib/presentation/screens/transaction/transaction_page.dart:10` - `Transaction Page`
   - Code: `child: Text("Transaction Page", style: AppTextStyles.nunitoBold.copyWith(fontSize: 22)),`

## Phase 2: Hard-coded Colors (fix one-by-one in this order)
1. `lib/presentation/screens/admin/admin_add_bill_page.dart:83`
   - Code: `onPrimary: Colors.white,`
2. `lib/presentation/screens/admin/admin_add_bill_page.dart:84`
   - Code: `surface: Colors.white,`
3. `lib/presentation/screens/admin/admin_add_bill_page.dart:375`
   - Code: `backgroundColor: Colors.white,`
4. `lib/presentation/screens/admin/admin_add_bill_page.dart:810`
   - Code: `color: Colors.black.withOpacity(0.1),`
5. `lib/presentation/screens/admin/admin_add_bill_page.dart:837`
   - Code: `Colors.white,`
6. `lib/presentation/screens/admin/admin_home_page.dart:74`
   - Code: `color: Colors.grey[600],`
7. `lib/presentation/screens/admin/admin_home_page.dart:117`
   - Code: `backgroundColor: Colors.red,`
8. `lib/presentation/screens/admin/admin_home_page.dart:234`
   - Code: `backgroundColor: Colors.white,`
9. `lib/presentation/screens/admin/admin_home_page.dart:236`
   - Code: `backgroundColor: Colors.white,`
10. `lib/presentation/screens/admin/admin_home_page.dart:339`
   - Code: `color: Colors.black.withValues(alpha: 0.08),`
11. `lib/presentation/screens/admin/bill_details_page.dart:93`
   - Code: `backgroundColor: Colors.black87,`
12. `lib/presentation/screens/admin/bill_details_page.dart:105`
   - Code: `const Icon(Icons.error, color: Colors.red, size: 60),`
13. `lib/presentation/screens/admin/bill_details_page.dart:109`
   - Code: `style: const TextStyle(color: Colors.white),`
14. `lib/presentation/screens/admin/bill_details_page.dart:117`
   - Code: `const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),`
15. `lib/presentation/screens/admin/bill_details_page.dart:121`
   - Code: `style: const TextStyle(color: Colors.white),`
16. `lib/presentation/screens/admin/bill_details_page.dart:131`
   - Code: `icon: const Icon(Icons.close, color: Colors.white, size: 30),`
17. `lib/presentation/screens/admin/bill_details_page.dart:149`
   - Code: `confirmColor: Colors.green,`
18. `lib/presentation/screens/admin/bill_details_page.dart:167`
   - Code: `backgroundColor: Colors.red,`
19. `lib/presentation/screens/admin/bill_details_page.dart:186`
   - Code: `backgroundColor: Colors.green,`
20. `lib/presentation/screens/admin/bill_details_page.dart:194`
   - Code: `backgroundColor: Colors.red,`
21. `lib/presentation/screens/admin/bill_details_page.dart:203`
   - Code: `backgroundColor: Colors.red,`
22. `lib/presentation/screens/admin/bill_details_page.dart:219`
   - Code: `confirmColor: Colors.red,`
23. `lib/presentation/screens/admin/bill_details_page.dart:235`
   - Code: `backgroundColor: Colors.orange,`
24. `lib/presentation/screens/admin/bill_details_page.dart:243`
   - Code: `backgroundColor: Colors.red,`
25. `lib/presentation/screens/admin/bill_details_page.dart:252`
   - Code: `backgroundColor: Colors.red,`
26. `lib/presentation/screens/admin/bill_details_page.dart:268`
   - Code: `confirmColor: Colors.orange,`
27. `lib/presentation/screens/admin/bill_details_page.dart:284`
   - Code: `backgroundColor: Colors.orange,`
28. `lib/presentation/screens/admin/bill_details_page.dart:292`
   - Code: `backgroundColor: Colors.red,`
29. `lib/presentation/screens/admin/bill_details_page.dart:301`
   - Code: `backgroundColor: Colors.red,`
30. `lib/presentation/screens/admin/bill_details_page.dart:334`
   - Code: `style: AppTextStyles.nunitoSemiBold.copyWith(color: Colors.grey[600]),`
31. `lib/presentation/screens/admin/bill_details_page.dart:345`
   - Code: `style: AppTextStyles.nunitoBold.copyWith(color: Colors.white),`
32. `lib/presentation/screens/admin/bill_details_page.dart:362`
   - Code: `backgroundColor: Colors.white,`
33. `lib/presentation/screens/admin/bill_details_page.dart:385`
   - Code: `backgroundColor: Colors.white,`
34. `lib/presentation/screens/admin/bill_details_page.dart:436`
   - Code: `backgroundColor: Colors.white,`
35. `lib/presentation/screens/admin/bill_details_page.dart:452`
   - Code: `color: Colors.black.withValues(alpha: 0.08),`
36. `lib/presentation/screens/admin/bill_details_page.dart:471`
   - Code: `? Colors.green`
37. `lib/presentation/screens/admin/bill_details_page.dart:473`
   - Code: `? Colors.red`
38. `lib/presentation/screens/admin/bill_details_page.dart:474`
   - Code: `: Colors.orange,`
39. `lib/presentation/screens/admin/bill_details_page.dart:486`
   - Code: `color: Colors.white,`
40. `lib/presentation/screens/admin/bill_details_page.dart:498`
   - Code: `color: Colors.white,`
41. `lib/presentation/screens/admin/bill_details_page.dart:520`
   - Code: `Colors.white,`
42. `lib/presentation/screens/admin/bill_details_page.dart:588`
   - Code: `Icon(Icons.phone, size: 14, color: Colors.grey[600]),`
43. `lib/presentation/screens/admin/bill_details_page.dart:594`
   - Code: `color: Colors.grey[700],`
44. `lib/presentation/screens/admin/bill_details_page.dart:602`
   - Code: `Icon(Icons.workspace_premium, size: 14, color: Colors.amber[700]),`
45. `lib/presentation/screens/admin/bill_details_page.dart:608`
   - Code: `color: Colors.amber[700],`
46. `lib/presentation/screens/admin/bill_details_page.dart:648`
   - Code: `Colors.white,`
47. `lib/presentation/screens/admin/bill_details_page.dart:678`
   - Code: `color: Colors.green.withValues(alpha: 0.1),`
48. `lib/presentation/screens/admin/bill_details_page.dart:680`
   - Code: `border: Border.all(color: Colors.green.shade300, width: 2),`
49. `lib/presentation/screens/admin/bill_details_page.dart:684`
   - Code: `Icon(Icons.currency_rupee, size: 32, color: Colors.green.shade700),`
50. `lib/presentation/screens/admin/bill_details_page.dart:690`
   - Code: `color: Colors.green.shade700,`
51. `lib/presentation/screens/admin/bill_details_page.dart:698`
   - Code: `color: Colors.grey[600],`
52. `lib/presentation/screens/admin/bill_details_page.dart:730`
   - Code: `color: Colors.grey[600],`
53. `lib/presentation/screens/admin/bill_details_page.dart:750`
   - Code: `shadowColor: Colors.blue.withValues(alpha: 0.2),`
54. `lib/presentation/screens/admin/bill_details_page.dart:759`
   - Code: `Colors.white,`
55. `lib/presentation/screens/admin/bill_details_page.dart:760`
   - Code: `Colors.blue.withValues(alpha: 0.03),`
56. `lib/presentation/screens/admin/bill_details_page.dart:788`
   - Code: `color: Colors.blue,`
57. `lib/presentation/screens/admin/bill_details_page.dart:797`
   - Code: `color: Colors.grey,`
58. `lib/presentation/screens/admin/bill_details_page.dart:806`
   - Code: `color: status == 'approved' ? Colors.green : Colors.red,`
59. `lib/presentation/screens/admin/bill_details_page.dart:829`
   - Code: `Colors.white,`
60. `lib/presentation/screens/admin/bill_details_page.dart:892`
   - Code: `color: Colors.grey[200],`
61. `lib/presentation/screens/admin/bill_details_page.dart:897`
   - Code: `Icon(Icons.error_outline, color: Colors.grey[400], size: 48),`
62. `lib/presentation/screens/admin/bill_details_page.dart:901`
   - Code: `style: TextStyle(color: Colors.grey[600], fontSize: 14),`
63. `lib/presentation/screens/admin/bill_details_page.dart:927`
   - Code: `color: Colors.white,`
64. `lib/presentation/screens/admin/bill_details_page.dart:942`
   - Code: `valueColor: AlwaysStoppedAnimation<Color>(Colors.white),`
65. `lib/presentation/screens/admin/bill_details_page.dart:951`
   - Code: `backgroundColor: Colors.red.shade600,`
66. `lib/presentation/screens/admin/bill_details_page.dart:952`
   - Code: `foregroundColor: Colors.white,`
67. `lib/presentation/screens/admin/bill_details_page.dart:969`
   - Code: `valueColor: AlwaysStoppedAnimation<Color>(Colors.white),`
68. `lib/presentation/screens/admin/bill_details_page.dart:978`
   - Code: `backgroundColor: Colors.green.shade600,`
69. `lib/presentation/screens/admin/bill_details_page.dart:979`
   - Code: `foregroundColor: Colors.white,`
70. `lib/presentation/screens/admin/bill_details_page.dart:998`
   - Code: `Colors.white,`
71. `lib/presentation/screens/admin/bill_details_page.dart:999`
   - Code: `Colors.orange.withValues(alpha: 0.05),`
72. `lib/presentation/screens/admin/bill_details_page.dart:1004`
   - Code: `color: Colors.orange.withValues(alpha: 0.15),`
73. `lib/presentation/screens/admin/bill_details_page.dart:1019`
   - Code: `Colors.orange.shade400,`
74. `lib/presentation/screens/admin/bill_details_page.dart:1020`
   - Code: `Colors.orange.shade600,`
75. `lib/presentation/screens/admin/bill_details_page.dart:1026`
   - Code: `color: Colors.orange.withValues(alpha: 0.4),`
76. `lib/presentation/screens/admin/bill_details_page.dart:1033`
   - Code: `color: Colors.transparent,`
77. `lib/presentation/screens/admin/bill_details_page.dart:1048`
   - Code: `valueColor: AlwaysStoppedAnimation<Color>(Colors.white),`
78. `lib/presentation/screens/admin/bill_details_page.dart:1055`
   - Code: `color: Colors.white.withValues(alpha: 0.2),`
79. `lib/presentation/screens/admin/bill_details_page.dart:1060`
   - Code: `color: Colors.white,`
80. `lib/presentation/screens/admin/bill_details_page.dart:1073`
   - Code: `color: Colors.white,`
81. `lib/presentation/screens/admin/bill_details_page.dart:1082`
   - Code: `color: Colors.white.withValues(alpha: 0.9),`
82. `lib/presentation/screens/admin/bill_details_page.dart:1104`
   - Code: `Colors.white,`
83. `lib/presentation/screens/admin/bill_details_page.dart:1105`
   - Code: `Colors.green.withValues(alpha: 0.05),`
84. `lib/presentation/screens/admin/bill_details_page.dart:1110`
   - Code: `color: Colors.green.withValues(alpha: 0.15),`
85. `lib/presentation/screens/admin/bill_details_page.dart:1125`
   - Code: `Colors.green.shade400,`
86. `lib/presentation/screens/admin/bill_details_page.dart:1126`
   - Code: `Colors.green.shade600,`
87. `lib/presentation/screens/admin/bill_details_page.dart:1132`
   - Code: `color: Colors.green.withValues(alpha: 0.4),`
88. `lib/presentation/screens/admin/bill_details_page.dart:1139`
   - Code: `color: Colors.transparent,`
89. `lib/presentation/screens/admin/bill_details_page.dart:1154`
   - Code: `valueColor: AlwaysStoppedAnimation<Color>(Colors.white),`
90. `lib/presentation/screens/admin/bill_details_page.dart:1161`
   - Code: `color: Colors.white.withValues(alpha: 0.2),`
91. `lib/presentation/screens/admin/bill_details_page.dart:1166`
   - Code: `color: Colors.white,`
92. `lib/presentation/screens/admin/bill_details_page.dart:1179`
   - Code: `color: Colors.white,`
93. `lib/presentation/screens/admin/bill_details_page.dart:1188`
   - Code: `color: Colors.white.withValues(alpha: 0.9),`
94. `lib/presentation/screens/admin/bill_details_page.dart:1231`
   - Code: `color: Colors.grey[600],`
95. `lib/presentation/screens/admin/diagnostic_page.dart:228`
   - Code: `backgroundColor: Colors.white,`
96. `lib/presentation/screens/admin/diagnostic_page.dart:255`
   - Code: `const Icon(Icons.error, color: Colors.red, size: 64),`
97. `lib/presentation/screens/admin/diagnostic_page.dart:259`
   - Code: `style: const TextStyle(color: Colors.red),`
98. `lib/presentation/screens/admin/diagnostic_page.dart:350`
   - Code: `color: Colors.grey[700],`
99. `lib/presentation/screens/admin/diagnostic_page.dart:449`
   - Code: `style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),`
100. `lib/presentation/screens/admin/diagnostic_page.dart:456`
   - Code: `color: Colors.grey[100],`
101. `lib/presentation/screens/admin/diagnostic_page.dart:490`
   - Code: `style: TextStyle(color: Colors.orange, fontSize: 12),`
102. `lib/presentation/screens/auth/pin_login_page.dart:122`
   - Code: `backgroundColor: Colors.transparent,`
103. `lib/presentation/screens/auth/pin_setup_page.dart:196`
   - Code: `backgroundColor: Colors.transparent,`
104. `lib/presentation/screens/auth/reset_pin_page.dart:329`
   - Code: `backgroundColor: Colors.transparent,`
105. `lib/presentation/screens/bills/add_bill_page.dart:428`
   - Code: `? Colors.white.withValues(alpha: 0.12)`
106. `lib/presentation/screens/bills/add_bill_page.dart:429`
   - Code: `: Colors.black.withValues(alpha: 0.08);`
107. `lib/presentation/screens/cart/cart_page.dart:140`
   - Code: `? Colors.white.withValues(alpha: 0.12)`
108. `lib/presentation/screens/cart/cart_page.dart:141`
   - Code: `: Colors.black.withValues(alpha: 0.08);`
109. `lib/presentation/screens/cart/cart_page.dart:146`
   - Code: `backgroundColor: Colors.white,`
110. `lib/presentation/screens/cart/cart_page.dart:169`
   - Code: `backgroundColor: Colors.white,`
111. `lib/presentation/screens/cart/cart_page.dart:192`
   - Code: `backgroundColor: Colors.white,`
112. `lib/presentation/screens/cart/cart_page.dart:244`
   - Code: `color: Colors.grey[300],`
113. `lib/presentation/screens/cart/cart_page.dart:259`
   - Code: `color: Colors.grey[600],`
114. `lib/presentation/screens/cart/cart_page.dart:353`
   - Code: `color: Colors.grey[600],`
115. `lib/presentation/screens/cart/cart_page.dart:429`
   - Code: `foregroundColor: Colors.redAccent,`
116. `lib/presentation/screens/cart/cart_page.dart:471`
   - Code: `color: Colors.black.withValues(alpha: 0.06),`
117. `lib/presentation/screens/cart/cart_page.dart:487`
   - Code: `color: Colors.grey[600],`
118. `lib/presentation/screens/cart/cart_page.dart:507`
   - Code: `foregroundColor: Colors.white,`
119. `lib/presentation/screens/dashboard/dashboard_page.dart:78`
   - Code: `final shadowColor = Colors.black.withValues(alpha: isDark ? 0.55 : 0.10);`
120. `lib/presentation/screens/dashboard/dashboard_page.dart:81`
   - Code: `final topBorderColor = Colors.black.withValues(`
121. `lib/presentation/screens/dashboard/dashboard_page.dart:437`
   - Code: `isDark ? Colors.white : colorScheme.primary;`
122. `lib/presentation/screens/dashboard/dashboard_page.dart:439`
   - Code: `isDark ? Colors.white.withValues(alpha: 0.55)`
123. `lib/presentation/screens/dashboard/dashboard_page.dart:444`
   - Code: `color: Colors.transparent,`
124. `lib/presentation/screens/dashboard/dashboard_page.dart:447`
   - Code: `splashColor: Colors.white.withValues(alpha: 0.08),`
125. `lib/presentation/screens/dashboard/dashboard_page.dart:448`
   - Code: `highlightColor: Colors.white.withValues(alpha: 0.04),`
126. `lib/presentation/screens/dashboard/dashboard_page.dart:458`
   - Code: `? Colors.white.withValues(alpha: 0.10)`
127. `lib/presentation/screens/dashboard/dashboard_page.dart:460`
   - Code: `: Colors.transparent,`
128. `lib/presentation/screens/dashboard/dashboard_page.dart:487`
   - Code: `colors: [Color(0xFFFFFFFF), Color(0xCCFFFFFF)],`
129. `lib/presentation/screens/home/home_page.dart:120`
   - Code: `background: Color(0xFFF5F0FF),`
130. `lib/presentation/screens/home/home_page.dart:127`
   - Code: `background: Color(0xFFFFF3E0),`
131. `lib/presentation/screens/home/home_page.dart:135`
   - Code: `background: Color(0xFFE3F2FD),`
132. `lib/presentation/screens/home/home_page.dart:142`
   - Code: `background: Color(0xFFE8F5E9),`
133. `lib/presentation/screens/home/home_page.dart:149`
   - Code: `background: Color(0xFFE8F0FE),`
134. `lib/presentation/screens/home/home_page.dart:157`
   - Code: `background: Color(0xFFF3E5F5),`
135. `lib/presentation/screens/home/home_page.dart:1340`
   - Code: `Colors.black.withValues(alpha: 0.10),`
136. `lib/presentation/screens/home/home_page.dart:1341`
   - Code: `Colors.black.withValues(alpha: 0.65),`
137. `lib/presentation/screens/home/home_page.dart:1488`
   - Code: `statusBarColor: Colors.transparent,`
138. `lib/presentation/screens/home/home_page.dart:1522`
   - Code: `color: Colors.black.withValues(`
139. `lib/presentation/screens/home/home_page.dart:2374`
   - Code: `Colors.black.withValues(alpha: 0.10),`
140. `lib/presentation/screens/home/home_page.dart:2375`
   - Code: `Colors.black.withValues(alpha: 0.55),`
141. `lib/presentation/screens/orders/order_detail_page.dart:22`
   - Code: `? Colors.white.withValues(alpha: 0.12)`
142. `lib/presentation/screens/orders/order_detail_page.dart:23`
   - Code: `: Colors.black.withValues(alpha: 0.08);`
143. `lib/presentation/screens/orders/order_detail_page.dart:28`
   - Code: `backgroundColor: Colors.white,`
144. `lib/presentation/screens/orders/order_detail_page.dart:124`
   - Code: `color: Colors.grey[600],`
145. `lib/presentation/screens/orders/order_detail_page.dart:149`
   - Code: `color: Colors.grey[700],`
146. `lib/presentation/screens/orders/order_detail_page.dart:157`
   - Code: `color: Colors.grey[700],`
147. `lib/presentation/screens/orders/order_detail_page.dart:165`
   - Code: `color: Colors.grey[700],`
148. `lib/presentation/screens/orders/order_detail_page.dart:173`
   - Code: `color: Colors.grey[700],`
149. `lib/presentation/screens/orders/order_detail_page.dart:194`
   - Code: `color: Colors.grey[700],`
150. `lib/presentation/screens/orders/order_detail_page.dart:202`
   - Code: `color: Colors.grey[700],`
151. `lib/presentation/screens/orders/order_detail_page.dart:221`
   - Code: `color: Colors.grey[700],`
152. `lib/presentation/screens/orders/order_detail_page.dart:239`
   - Code: `border: Border.all(color: Colors.grey[300]!),`
153. `lib/presentation/screens/orders/order_detail_page.dart:249`
   - Code: `color: Colors.grey[100],`
154. `lib/presentation/screens/orders/order_detail_page.dart:328`
   - Code: `color: Colors.grey[700],`
155. `lib/presentation/screens/orders/order_detail_page.dart:339`
   - Code: `color: Colors.grey[700],`
156. `lib/presentation/screens/orders/order_detail_page.dart:404`
   - Code: `foregroundColor: Colors.white,`
157. `lib/presentation/screens/orders/order_detail_page.dart:636`
   - Code: `return Colors.green.withValues(alpha: 0.15);`
158. `lib/presentation/screens/orders/order_detail_page.dart:638`
   - Code: `return Colors.orange.withValues(alpha: 0.15);`
159. `lib/presentation/screens/orders/order_detail_page.dart:640`
   - Code: `return Colors.red.withValues(alpha: 0.15);`
160. `lib/presentation/screens/orders/order_detail_page.dart:642`
   - Code: `return Colors.blueGrey.withValues(alpha: 0.12);`
161. `lib/presentation/screens/orders/order_detail_page.dart:649`
   - Code: `return Colors.green[800]!;`
162. `lib/presentation/screens/orders/order_detail_page.dart:651`
   - Code: `return Colors.orange[800]!;`
163. `lib/presentation/screens/orders/order_detail_page.dart:653`
   - Code: `return Colors.red[800]!;`
164. `lib/presentation/screens/orders/order_detail_page.dart:655`
   - Code: `return Colors.blueGrey[800]!;`
165. `lib/presentation/screens/orders/orders_page.dart:42`
   - Code: `? Colors.white.withValues(alpha: 0.12)`
166. `lib/presentation/screens/orders/orders_page.dart:43`
   - Code: `: Colors.black.withValues(alpha: 0.08);`
167. `lib/presentation/screens/orders/orders_page.dart:48`
   - Code: `backgroundColor: Colors.white,`
168. `lib/presentation/screens/orders/orders_page.dart:71`
   - Code: `backgroundColor: Colors.white,`
169. `lib/presentation/screens/orders/orders_page.dart:94`
   - Code: `backgroundColor: Colors.white,`
170. `lib/presentation/screens/orders/orders_page.dart:149`
   - Code: `color: Colors.grey[300],`
171. `lib/presentation/screens/orders/orders_page.dart:165`
   - Code: `color: Colors.grey[600],`
172. `lib/presentation/screens/orders/orders_page.dart:197`
   - Code: `color: Colors.transparent,`
173. `lib/presentation/screens/orders/orders_page.dart:210`
   - Code: `color: Colors.black.withValues(alpha: 0.04),`
174. `lib/presentation/screens/orders/orders_page.dart:216`
   - Code: `color: Colors.grey[200]!,`
175. `lib/presentation/screens/orders/orders_page.dart:284`
   - Code: `color: Colors.grey[600],`
176. `lib/presentation/screens/orders/orders_page.dart:408`
   - Code: `color: Colors.grey[600],`
177. `lib/presentation/screens/orders/orders_page.dart:425`
   - Code: `color: Colors.grey[700],`
178. `lib/presentation/screens/orders/orders_page.dart:433`
   - Code: `color: Colors.grey[700],`
179. `lib/presentation/screens/orders/orders_page.dart:442`
   - Code: `color: Colors.grey[700],`
180. `lib/presentation/screens/orders/orders_page.dart:451`
   - Code: `color: Colors.grey[700],`
181. `lib/presentation/screens/orders/orders_page.dart:470`
   - Code: `color: Colors.grey[700],`
182. `lib/presentation/screens/orders/orders_page.dart:478`
   - Code: `color: Colors.grey[700],`
183. `lib/presentation/screens/orders/orders_page.dart:495`
   - Code: `color: Colors.grey[700],`
184. `lib/presentation/screens/orders/orders_page.dart:535`
   - Code: `color: Colors.grey[600],`
185. `lib/presentation/screens/orders/orders_page.dart:584`
   - Code: `foregroundColor: Colors.white,`
186. `lib/presentation/screens/orders/orders_page.dart:870`
   - Code: `return Colors.green.withValues(alpha: 0.15);`
187. `lib/presentation/screens/orders/orders_page.dart:872`
   - Code: `return Colors.orange.withValues(alpha: 0.15);`
188. `lib/presentation/screens/orders/orders_page.dart:874`
   - Code: `return Colors.red.withValues(alpha: 0.15);`
189. `lib/presentation/screens/orders/orders_page.dart:876`
   - Code: `return Colors.blueGrey.withValues(alpha: 0.12);`
190. `lib/presentation/screens/orders/orders_page.dart:883`
   - Code: `return Colors.green[800]!;`
191. `lib/presentation/screens/orders/orders_page.dart:885`
   - Code: `return Colors.orange[800]!;`
192. `lib/presentation/screens/orders/orders_page.dart:887`
   - Code: `return Colors.red[800]!;`
193. `lib/presentation/screens/orders/orders_page.dart:889`
   - Code: `return Colors.blueGrey[800]!;`
194. `lib/presentation/screens/products/product_detail_page.dart:106`
   - Code: `? Colors.white.withValues(alpha: 0.12)`
195. `lib/presentation/screens/products/product_detail_page.dart:107`
   - Code: `: Colors.black.withValues(alpha: 0.08);`
196. `lib/presentation/screens/products/product_detail_page.dart:112`
   - Code: `backgroundColor: Colors.white,`
197. `lib/presentation/screens/products/product_detail_page.dart:302`
   - Code: `? Colors.white`
198. `lib/presentation/screens/products/product_detail_page.dart:303`
   - Code: `: Colors.white.withValues(alpha: 0.5),`
199. `lib/presentation/screens/products/product_detail_page.dart:338`
   - Code: `color: Colors.grey[600],`
200. `lib/presentation/screens/products/product_detail_page.dart:392`
   - Code: `color: Colors.grey[700],`
201. `lib/presentation/screens/products/product_detail_page.dart:436`
   - Code: `color: Colors.black.withValues(alpha: 0.06),`
202. `lib/presentation/screens/products/product_detail_page.dart:465`
   - Code: `foregroundColor: Colors.white,`
203. `lib/presentation/screens/products/product_detail_page.dart:503`
   - Code: `color: Colors.grey[100],`
204. `lib/presentation/screens/products/product_detail_page.dart:505`
   - Code: `border: Border.all(color: Colors.grey[300]!),`
205. `lib/presentation/screens/products/product_detail_page.dart:510`
   - Code: `Icon(icon, size: 14, color: Colors.grey[700]),`
206. `lib/presentation/screens/products/product_detail_page.dart:516`
   - Code: `color: Colors.grey[800],`
207. `lib/presentation/screens/products/product_detail_page.dart:524`
   - Code: `color: Colors.grey[800],`
208. `lib/presentation/screens/products/product_detail_page.dart:566`
   - Code: `color: Colors.white,`
209. `lib/presentation/screens/products/product_detail_page.dart:573`
   - Code: `color: Colors.white,`
210. `lib/presentation/screens/products/product_list_page.dart:28`
   - Code: `backgroundColor: Colors.white,`
211. `lib/presentation/screens/products/product_list_page.dart:110`
   - Code: `color: Colors.grey[300],`
212. `lib/presentation/screens/products/product_list_page.dart:380`
   - Code: `color: Colors.black.withValues(alpha: 0.55),`
213. `lib/presentation/screens/products/product_list_page.dart:396`
   - Code: `color: Colors.white,`
214. `lib/presentation/screens/products/product_list_page.dart:402`
   - Code: `color: Colors.white,`
215. `lib/presentation/screens/products/product_list_page.dart:497`
   - Code: `color: Colors.grey[100],`
216. `lib/presentation/screens/products/product_list_page.dart:499`
   - Code: `border: Border.all(color: Colors.grey[300]!),`
217. `lib/presentation/screens/products/product_list_page.dart:504`
   - Code: `Icon(icon, size: 10, color: Colors.grey[700]),`
218. `lib/presentation/screens/products/product_list_page.dart:510`
   - Code: `color: Colors.grey[800],`
219. `lib/presentation/screens/products/product_list_page.dart:552`
   - Code: `color: Colors.white,`
220. `lib/presentation/screens/products/product_list_page.dart:559`
   - Code: `color: Colors.white,`
221. `lib/presentation/screens/profile/edit_profile_page.dart:408`
   - Code: `? Colors.white.withValues(alpha: 0.12)`
222. `lib/presentation/screens/profile/edit_profile_page.dart:409`
   - Code: `: Colors.black.withValues(alpha: 0.08);`
223. `lib/presentation/screens/spin/daily_spin_page.dart:163`
   - Code: `backgroundColor: Colors.white,`
224. `lib/presentation/screens/splash/splash_page.dart:79`
   - Code: `backgroundColor: Colors.transparent,`

## How to use this file
1. Pick the next numbered item from Phase 1 or Phase 2.
2. Tell me the number (e.g. `Phase 1 #5`).
3. I’ll implement the fix, run lints for the touched file, and you’ll pick the next one.
