# 🚀 ONE-SHOT MIGRATION PLAN - All Features at Once

## ⚠️ CRITICAL RULE: ZERO UI/FUNCTIONALITY CHANGES

**Migration Philosophy:**
- ✅ COPY exact UI from old screens
- ✅ PRESERVE all animations, transitions, effects
- ✅ KEEP all validation logic exactly as-is
- ✅ MAINTAIN all user flows unchanged
- ❌ DO NOT "improve" or "refactor" UI
- ❌ DO NOT change button labels, colors, spacing
- ❌ DO NOT modify business logic

**If old screen has hardcoded values → NEW screen MUST have same hardcoded values**
**Fix violations AFTER migration is confirmed working**

---

## 📋 One-Shot Strategy

### Phase 1: Preparation (Day 1 Morning)
Create ALL feature structures at once

### Phase 2: Migration (Day 1-2)
Migrate ALL screens with EXACT UI/functionality

### Phase 3: Integration (Day 2)
Wire up ALL routes and DI

### Phase 4: Testing (Day 3)
Test EVERY flow - ensure zero regressions

### Phase 5: Cleanup (Day 4)
Fix violations, optimize, cleanup

---

## 📅 DAY-BY-DAY BREAKDOWN

### Day 1 (8 hours): Setup & Initial Migration

#### Hour 1-2: Create ALL Feature Structures
```bash
#!/bin/bash
# Create all 12 features at once

features=(
  "splash"
  "dashboard" 
  "home"
  "bills"
  "wallet"
  "transactions"
  "profile"
  "settings"
  "admin"
  "spin"
  "redeem"
  "notifications"
)

for feature in "${features[@]}"; do
  echo "Creating $feature..."
  ./scripts/create_feature.sh "$feature"
done

echo "✅ All 12 feature structures created"
```

#### Hour 3-4: Migrate Simple Screens (6 screens)
Priority: Screens with minimal logic

```bash
# 1. splash (433 lines) - Session check only
# 2. dashboard (76 lines) - Navigation only  
# 3. redeem (126 lines) - Simple display
# 4. transaction (13 lines) - Very simple
# 5. settings (408 lines) - Simple form
# 6. spin (399 lines) - Game logic
```

**Migration Rule:** COPY-PASTE the entire build() method first, then add BLoC wrapper

#### Hour 5-6: Migrate Medium Screens (5 screens)
Priority: Screens with moderate complexity

```bash
# 7. bills (941 lines) - Form + image upload
# 8. wallet (941 lines) - List display
# 9. notifications (1060 lines) - List + actions
# 10. home page (1760 lines split) - Stats display
# 11. offer item widget
```

#### Hour 7-8: Start Complex Screens (2 screens started)
Priority: Most complex screens

```bash
# 12. profile pages (1902 lines split) - Forms + upload
# 13-16. admin pages (2869 lines split) - Complex workflows
```

---

### Day 2 (8 hours): Complete Migration & Integration

#### Hour 1-3: Complete Complex Screens
```bash
# Finish profile pages (edit_profile_page, profile_page)
# Finish admin pages (4 screens)
```

#### Hour 4-5: Wire Up Dependency Injection
```bash
# Update lib/injection/dependency_injection.dart
# Register ALL:
# - Services (already done)
# - DataSources (12 new)
# - Repositories (12 new)
# - BLoCs (12 new as factories)
```

#### Hour 6-8: Update Routes & Connect Everything
```bash
# Update lib/config/routes.dart
# Wrap ALL routes with BlocProvider
# Test basic navigation flow
```

---

### Day 3 (8 hours): COMPREHENSIVE TESTING

#### Hour 1-2: User Flow Testing
```
Test EVERY user action:

LOGIN FLOW:
□ New user signup with PIN
□ Existing user login with PIN
□ PIN reset flow
□ Remember me functionality
□ Session persistence

HOME FLOW:
□ View dashboard after login
□ See correct role-based content
□ View points/tier information
□ See offers list
□ Offers clickable/details work

BILL FLOW:
□ Navigate to add bill
□ Upload receipt image
□ Fill all form fields
□ Submit bill
□ View bill history
□ See bill status updates

WALLET FLOW:
□ View wallet balance
□ See transaction history
□ Transaction details display
□ Pagination works

PROFILE FLOW:
□ View profile
□ Edit profile fields
□ Upload avatar
□ Save changes
□ Changes reflect immediately

ADMIN FLOW (if admin):
□ View admin dashboard
□ See pending bills list
□ Open bill details
□ Approve bill
□ Reject bill with reason
□ View diagnostics
□ Analytics display

ENGAGEMENT FLOW:
□ Daily spin works
□ Spin animation correct
□ Rewards granted
□ Redeem points
□ View notifications
□ Mark as read works

SETTINGS FLOW:
□ Change notification settings
□ Settings save properly
□ Language switching works
```

#### Hour 3-4: UI Verification Checklist
```
For EACH screen, verify:

VISUAL ELEMENTS:
□ All colors match old screen
□ All spacing matches old screen
□ All fonts match old screen
□ All icons match old screen
□ All images display correctly
□ All animations work (if any)
□ Loading indicators show
□ Error messages display

INTERACTIONS:
□ All buttons clickable
□ All forms submittable
□ All validations work
□ All navigation works
□ All gestures work (swipe, etc)
□ All dialogs/modals work

STATES:
□ Loading state shows correctly
□ Success state shows correctly
□ Error state shows correctly
□ Empty state shows correctly
□ Offline state shows correctly
```

#### Hour 5-6: Edge Cases & Error Testing
```
Test error scenarios:

NETWORK ERRORS:
□ Offline mode handling
□ Slow network (loading states)
□ Failed uploads retry
□ Timeout handling

VALIDATION ERRORS:
□ Empty fields show errors
□ Invalid phone number rejected
□ Invalid PIN rejected
□ File size limits enforced

PERMISSION ERRORS:
□ Camera permission denied
□ Storage permission denied
□ Notification permission denied

SESSION ERRORS:
□ Expired session redirects to login
□ Invalid token handling
□ Concurrent login handling
```

#### Hour 7-8: Performance & Regression Testing
```
PERFORMANCE:
□ App startup time same as before
□ Screen transitions smooth
□ List scrolling smooth
□ Image loading not blocking
□ No memory leaks

REGRESSIONS:
□ Old functionality still works
□ No new crashes
□ No new ANR (Android Not Responding)
□ No console errors
□ All third-party integrations work
```

---

### Day 4 (8 hours): Cleanup & Polish

#### Hour 1-3: Run Review Scripts & Fix Violations
```bash
# Review ALL screens
for file in lib/features/*/presentation/pages/*.dart; do
  echo "Reviewing $file..."
  ./scripts/review_screen.sh "$file"
done

# Collect all violations
# Fix design tokens
# Fix localization
# Re-review until all pass
```

#### Hour 4-5: Cleanup Old Files
```bash
# ONLY after confirming everything works
# Backup first!
cp -r lib/presentation/screens lib/presentation/screens.backup

# Remove old screens
rm -rf lib/presentation/screens/

# Verify app still works
flutter run
```

#### Hour 6-7: Documentation & Handoff
```bash
# Update README
# Document new architecture
# Create migration notes
# List any known issues
```

#### Hour 8: Final Verification
```bash
# One more complete app test
# Verify on multiple devices
# Check logs for errors
# Performance profiling
```

---

## 🛠️ MIGRATION TEMPLATES

### Template 1: Simple Screen (No BLoC)
For screens with just navigation (dashboard)

```dart
// OLD CODE
class DashboardPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(/* ... */);
  }
}

// NEW CODE - NO CHANGES, just move file
// lib/features/dashboard/presentation/pages/dashboard_page.dart
class DashboardPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(/* ... EXACT SAME CODE ... */);
  }
}
```

### Template 2: Screen with Service Calls → BLoC

```dart
// OLD CODE
class BillsPage extends StatefulWidget {
  @override
  _BillsPageState createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final _billService = BillService();
  bool _loading = false;
  
  Future<void> _submitBill() async {
    setState(() => _loading = true);
    try {
      await _billService.submitBill(/* ... */);
      // Show success
    } catch (e) {
      // Show error
    } finally {
      setState(() => _loading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading 
        ? CircularProgressIndicator()
        : Column(/* form widgets */),
    );
  }
}

// NEW CODE
class BillsPage extends StatefulWidget {
  @override
  _BillsPageState createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  // Remove service, add form controllers (keep as-is)
  
  void _submitBill() {
    // Instead of calling service:
    context.read<BillBloc>().add(SubmitBillEvent(/* ... */));
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillBloc, BillState>(
      listener: (context, state) {
        if (state is BillSubmittedState) {
          // Show success (EXACT SAME as old code)
        }
        if (state is BillErrorState) {
          // Show error (EXACT SAME as old code)
        }
      },
      builder: (context, state) {
        final isLoading = state is BillLoadingState;
        
        // PASTE OLD build() body here, replace:
        // _loading → isLoading
        return Scaffold(
          body: isLoading
            ? CircularProgressIndicator()
            : Column(/* EXACT SAME form widgets */),
        );
      },
    );
  }
}
```

### Template 3: List Screen with Pagination

```dart
// OLD CODE
class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  List<Transaction> _transactions = [];
  bool _loading = true;
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
  
  Future<void> _loadTransactions() async {
    final service = WalletService();
    final txns = await service.getTransactions();
    setState(() {
      _transactions = txns;
      _loading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_loading) return CircularProgressIndicator();
    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (ctx, i) => TransactionTile(_transactions[i]),
    );
  }
}

// NEW CODE
class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadTransactionsEvent());
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        if (state is WalletLoadingState) {
          return CircularProgressIndicator();
        }
        
        if (state is WalletLoadedState) {
          final transactions = state.transactions;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (ctx, i) => TransactionTile(transactions[i]),
          );
        }
        
        return Text('Error'); // Same as old error state
      },
    );
  }
}
```

---

## 📊 FEATURE-BY-FEATURE MIGRATION GUIDE

### 1. Splash Module (30 min)

**Files:** `splash_page.dart`

**Domain:**
```dart
// lib/features/splash/domain/usecases/check_session_usecase.dart
class CheckSessionUseCase {
  Future<Either<Failure, User?>> call() async {
    // Wrap SessionService.getSessionData()
  }
}
```

**BLoC:**
```dart
// States: SplashCheckingState, SplashReadyState(User? user)
// Events: CheckSessionEvent
// Logic: Check session → emit ready with user or null
```

**UI Migration:**
- COPY splash_page.dart build() method EXACTLY
- Add BlocListener for navigation
- When SplashReadyState → navigate to dashboard or login

---

### 2. Dashboard Module (30 min)

**Files:** `dashboard_page.dart`

**UI Migration:**
- NO BLoC needed (pure navigation)
- COPY dashboard_page.dart EXACTLY
- Keep all role-based routing logic unchanged

---

### 3. Home Module (2 hours)

**Files:** `home_page.dart`, `offer_item.dart`

**Domain:**
```dart
// Entities: UserStats, Offer
// UseCases: GetUserStatsUseCase, GetOffersUseCase
```

**Data:**
```dart
// Wrap UserService.getUserStats()
// Wrap OfferService.getOffers()
```

**BLoC:**
```dart
// HomeBloc
// States: Loading, Loaded(stats, offers), Error
// Events: LoadHomeData, RefreshHomeData
```

**UI Migration:**
- COPY home_page.dart build() EXACTLY
- Wrap in BlocBuilder<HomeBloc, HomeState>
- Replace direct service calls with bloc events
- KEEP all animations, gestures, custom painters

---

### 4. Bills Module (2 hours)

**Files:** `add_bill_page.dart`

**Domain:**
```dart
// Entity: Bill
// UseCases: SubmitBillUseCase, UploadReceiptUseCase, GetBillsUseCase
```

**Data:**
```dart
// Wrap BillService.submitBill()
// Wrap StorageService.uploadImage()
```

**BLoC:**
```dart
// BillBloc
// States: Initial, Uploading, Submitting, Submitted, Error
// Events: UploadReceipt, SubmitBill, LoadBills
```

**UI Migration:**
- COPY add_bill_page.dart build() EXACTLY
- Keep all form controllers
- Keep all validation logic
- Replace service calls with bloc events
- KEEP image picker flow unchanged

---

### 5. Wallet Module (1.5 hours)

**Files:** `wallet_page.dart`

**Domain:**
```dart
// Entity: Transaction, Balance
// UseCases: GetBalanceUseCase, GetTransactionsUseCase
```

**Data:**
```dart
// Wrap WalletService/TransactionService
```

**BLoC:**
```dart
// WalletBloc
// States: Loading, Loaded(balance, transactions), Error
// Events: LoadWallet, RefreshWallet
```

**UI Migration:**
- COPY wallet_page.dart build() EXACTLY
- Wrap in BlocBuilder
- Keep all list rendering logic

---

### 6. Transactions Module (30 min)

**Files:** `transaction_page.dart`

**UI Migration:**
- Very simple detail view
- May not need dedicated BLoC
- Can reuse WalletBloc
- COPY transaction_page.dart EXACTLY

---

### 7. Profile Module (2.5 hours)

**Files:** `profile_page.dart`, `edit_profile_page.dart`

**Domain:**
```dart
// Entity: UserProfile (extends User)
// UseCases: GetProfileUseCase, UpdateProfileUseCase, UploadAvatarUseCase
```

**Data:**
```dart
// Wrap UserService.updateProfile()
// Wrap StorageService.uploadAvatar()
```

**BLoC:**
```dart
// ProfileBloc
// States: Loading, Loaded(profile), Updating, Updated, Error
// Events: LoadProfile, UpdateProfile, UploadAvatar
```

**UI Migration:**
- COPY both pages EXACTLY
- Keep all form validation
- Keep image picker flow
- Replace service calls with events

---

### 8. Settings Module (1 hour)

**Files:** `notification_settings_page.dart`

**Domain:**
```dart
// Entity: Settings
// UseCases: GetSettingsUseCase, UpdateSettingsUseCase
```

**Data:**
```dart
// Wrap NotificationService settings methods
```

**BLoC:**
```dart
// SettingsBloc (or part of ProfileBloc)
// States: Loading, Loaded(settings), Saving, Saved, Error
// Events: LoadSettings, UpdateSettings
```

**UI Migration:**
- COPY settings page EXACTLY
- Wrap in BlocBuilder
- Keep all toggle/checkbox logic

---

### 9. Admin Module (4 hours) ⚠️ MOST COMPLEX

**Files:**
- `admin_home_page.dart`
- `bill_details_page.dart`
- `diagnostic_page.dart`
- `admin_add_bill_page.dart`

**Domain:**
```dart
// Entities: AdminStats, PendingBill, BillApproval
// UseCases: 
//   - GetAdminStatsUseCase
//   - GetPendingBillsUseCase
//   - ApproveBillUseCase
//   - RejectBillUseCase
//   - GetDiagnosticsUseCase
```

**Data:**
```dart
// Wrap BillService admin methods
// Wrap UserService admin methods
```

**BLoCs:**
```dart
// AdminBloc (dashboard stats)
// BillApprovalBloc (approval workflow)
// DiagnosticsBloc (system info)
```

**UI Migration:**
- COPY all 4 screens EXACTLY
- Keep all approval workflows unchanged
- Keep all analytics/charts as-is
- Replace service calls with bloc events
- PRESERVE all admin-specific logic

---

### 10. Spin Module (1 hour)

**Files:** `daily_spin_page.dart`

**Domain:**
```dart
// Entity: SpinResult
// UseCases: SpinWheelUseCase (with daily limit check)
```

**Data:**
```dart
// Spin logic + Firestore update
```

**BLoC:**
```dart
// SpinBloc
// States: Idle, Spinning, Result(reward), Error, Exhausted
// Events: SpinWheel
```

**UI Migration:**
- COPY daily_spin_page.dart EXACTLY
- KEEP all animations (wheel spin)
- KEEP all game logic
- Replace spin trigger with bloc event

---

### 11. Redeem Module (1 hour)

**Files:** `redeem_page.dart`

**Domain:**
```dart
// Entity: Reward
// UseCases: GetRewardsUseCase, RedeemPointsUseCase
```

**Data:**
```dart
// Redeem logic + points deduction
```

**BLoC:**
```dart
// RedeemBloc
// States: Loading, Loaded(rewards), Redeeming, Redeemed, Error
// Events: LoadRewards, RedeemPoints
```

**UI Migration:**
- COPY redeem_page.dart EXACTLY
- Wrap in BlocBuilder
- Keep redemption flow unchanged

---

### 12. Notifications Module (1.5 hours)

**Files:** `notifications_page.dart`

**Domain:**
```dart
// Entity: Notification
// UseCases: GetNotificationsUseCase, MarkAsReadUseCase
```

**Data:**
```dart
// Wrap NotificationService
```

**BLoC:**
```dart
// NotificationBloc
// States: Loading, Loaded(notifications), Marking, Marked, Error
// Events: LoadNotifications, MarkAsRead, MarkAllAsRead
```

**UI Migration:**
- COPY notifications_page.dart EXACTLY
- Wrap in BlocBuilder
- Keep swipe-to-delete (if any)
- Keep mark-as-read logic

---

## 🔌 DEPENDENCY INJECTION - Complete Setup

```dart
// lib/injection/dependency_injection.dart

Future<void> setupDependencyInjection() async {
  // ============================================
  // SERVICES (Already registered)
  // ============================================
  getIt.registerLazySingleton(() => PinAuthService());
  getIt.registerLazySingleton(() => SessionService());
  getIt.registerLazySingleton(() => FCMService());
  getIt.registerLazySingleton(() => UserService());
  getIt.registerLazySingleton(() => BillService());
  getIt.registerLazySingleton(() => StorageService());
  getIt.registerLazySingleton(() => OfferService());
  getIt.registerLazySingleton(() => NotificationService());

  // ============================================
  // SPLASH FEATURE
  // ============================================
  getIt.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(
      sessionService: getIt<SessionService>(),
    ),
  );
  getIt.registerFactory(() => SplashBloc(
    repository: getIt<SplashRepository>(),
  ));

  // ============================================
  // HOME FEATURE
  // ============================================
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      userService: getIt<UserService>(),
      offerService: getIt<OfferService>(),
    ),
  );
  getIt.registerFactory(() => HomeBloc(
    repository: getIt<HomeRepository>(),
  ));

  // ============================================
  // BILLS FEATURE
  // ============================================
  getIt.registerLazySingleton<BillRepository>(
    () => BillRepositoryImpl(
      billService: getIt<BillService>(),
      storageService: getIt<StorageService>(),
    ),
  );
  getIt.registerFactory(() => BillBloc(
    repository: getIt<BillRepository>(),
  ));

  // ============================================
  // WALLET FEATURE
  // ============================================
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(
      userService: getIt<UserService>(),
    ),
  );
  getIt.registerFactory(() => WalletBloc(
    repository: getIt<WalletRepository>(),
  ));

  // ============================================
  // PROFILE FEATURE
  // ============================================
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      userService: getIt<UserService>(),
      storageService: getIt<StorageService>(),
    ),
  );
  getIt.registerFactory(() => ProfileBloc(
    repository: getIt<ProfileRepository>(),
  ));

  // ============================================
  // SETTINGS FEATURE
  // ============================================
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      notificationService: getIt<NotificationService>(),
    ),
  );
  getIt.registerFactory(() => SettingsBloc(
    repository: getIt<SettingsRepository>(),
  ));

  // ============================================
  // ADMIN FEATURE
  // ============================================
  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(
      billService: getIt<BillService>(),
      userService: getIt<UserService>(),
    ),
  );
  getIt.registerFactory(() => AdminBloc(
    repository: getIt<AdminRepository>(),
  ));
  getIt.registerFactory(() => BillApprovalBloc(
    repository: getIt<AdminRepository>(),
  ));

  // ============================================
  // SPIN FEATURE
  // ============================================
  getIt.registerLazySingleton<SpinRepository>(
    () => SpinRepositoryImpl(
      userService: getIt<UserService>(),
    ),
  );
  getIt.registerFactory(() => SpinBloc(
    repository: getIt<SpinRepository>(),
  ));

  // ============================================
  // REDEEM FEATURE
  // ============================================
  getIt.registerLazySingleton<RedeemRepository>(
    () => RedeemRepositoryImpl(
      userService: getIt<UserService>(),
    ),
  );
  getIt.registerFactory(() => RedeemBloc(
    repository: getIt<RedeemRepository>(),
  ));

  // ============================================
  // NOTIFICATIONS FEATURE
  // ============================================
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(
      notificationService: getIt<NotificationService>(),
    ),
  );
  getIt.registerFactory(() => NotificationsBloc(
    repository: getIt<NotificationsRepository>(),
  ));
}
```

---

## 🔀 ROUTES - Complete Setup

```dart
// lib/config/routes.dart

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    
    routes: [
      // ============================================
      // SPLASH
      // ============================================
      GoRoute(
        path: '/splash',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<SplashBloc>()..add(CheckSessionEvent()),
          child: const SplashPage(),
        ),
      ),

      // ============================================
      // AUTH (Already done)
      // ============================================
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AuthBloc>(),
          child: const LoginPage(),
        ),
      ),
      // ... other auth routes

      // ============================================
      // DASHBOARD
      // ============================================
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(), // No BLoC
      ),

      // ============================================
      // HOME
      // ============================================
      GoRoute(
        path: '/home',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(LoadHomeDataEvent()),
          child: const HomePage(),
        ),
      ),

      // ============================================
      // BILLS
      // ============================================
      GoRoute(
        path: '/bills/add',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<BillBloc>(),
          child: const AddBillPage(),
        ),
      ),

      // ============================================
      // WALLET
      // ============================================
      GoRoute(
        path: '/wallet',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<WalletBloc>()..add(LoadWalletEvent()),
          child: const WalletPage(),
        ),
      ),

      // ============================================
      // TRANSACTIONS
      // ============================================
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionPage(),
      ),

      // ============================================
      // PROFILE
      // ============================================
      GoRoute(
        path: '/profile',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<ProfileBloc>()..add(LoadProfileEvent()),
          child: const ProfilePage(),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => BlocProvider.value(
          value: context.read<ProfileBloc>(), // Reuse existing bloc
          child: const EditProfilePage(),
        ),
      ),

      // ============================================
      // SETTINGS
      // ============================================
      GoRoute(
        path: '/settings',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<SettingsBloc>()..add(LoadSettingsEvent()),
          child: const NotificationSettingsPage(),
        ),
      ),

      // ============================================
      // ADMIN
      // ============================================
      GoRoute(
        path: '/admin',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AdminBloc>()..add(LoadAdminStatsEvent()),
          child: const AdminHomePage(),
        ),
      ),
      GoRoute(
        path: '/admin/bills/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => getIt<BillApprovalBloc>()
              ..add(LoadBillDetailsEvent(id)),
            child: const BillDetailsPage(),
          );
        },
      ),
      GoRoute(
        path: '/admin/diagnostics',
        builder: (context, state) => const DiagnosticPage(),
      ),
      GoRoute(
        path: '/admin/bills/add',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<BillBloc>(),
          child: const AdminAddBillPage(),
        ),
      ),

      // ============================================
      // SPIN
      // ============================================
      GoRoute(
        path: '/spin',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<SpinBloc>(),
          child: const DailySpinPage(),
        ),
      ),

      // ============================================
      // REDEEM
      // ============================================
      GoRoute(
        path: '/redeem',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<RedeemBloc>()..add(LoadRewardsEvent()),
          child: const RedeemPage(),
        ),
      ),

      // ============================================
      // NOTIFICATIONS
      // ============================================
      GoRoute(
        path: '/notifications',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<NotificationsBloc>()
            ..add(LoadNotificationsEvent()),
          child: const NotificationsPage(),
        ),
      ),
    ],
  );
});
```

---

## ✅ COMPREHENSIVE TESTING CHECKLIST

### Pre-Migration Baseline
```bash
# Document current app behavior
□ Record screen videos of ALL flows
□ Take screenshots of ALL screens
□ Document all known bugs/issues
□ Note performance metrics (startup time, etc)
```

### Post-Migration Verification

#### Critical Paths (MUST WORK)
```
□ User can login (new & existing)
□ User can see home/dashboard
□ User can submit bill with receipt
□ User can view wallet/transactions
□ Admin can approve/reject bills
□ Notifications work
□ Profile edit works
```

#### Screen-by-Screen Verification

**For EACH of the 21 screens:**
```
□ Screen loads without errors
□ All UI elements visible
□ All buttons work
□ All forms validate correctly
□ All API calls work
□ Loading states show
□ Error states show
□ Success states show
□ Navigation works
□ Back button works
```

#### Regression Testing
```
□ Compare with baseline videos/screenshots
□ Verify NO visual differences
□ Verify NO behavioral differences
□ Verify NO new bugs introduced
□ Verify performance same or better
```

---

## 🚨 ROLLBACK STRATEGY

### Before Migration
```bash
# Create backup branch
git checkout -b backup-before-migration
git push origin backup-before-migration

# Tag current state
git tag -a v1.0-pre-migration -m "Before clean architecture migration"
git push origin v1.0-pre-migration
```

### If Migration Fails
```bash
# Option 1: Revert commits
git reset --hard HEAD~N  # N = number of migration commits
git push origin main --force

# Option 2: Restore from backup
git checkout backup-before-migration
git branch -D main
git checkout -b main
git push origin main --force

# Option 3: Keep old screens temporarily
# Don't delete lib/presentation/screens/ until confirmed working
# Can switch routes back to old files if needed
```

---

## 📊 SUCCESS METRICS

### Must Pass
- ✅ 0 compilation errors
- ✅ 0 runtime crashes
- ✅ All 21 screens functional
- ✅ All user flows work
- ✅ Performance maintained

### Should Pass (Can fix after)
- ⚠️ Architecture review passes
- ⚠️ No design token violations
- ⚠️ No localization violations

### Nice to Have
- 💡 Improved performance
- 💡 Cleaner code
- 💡 Better error handling

---

## 🎯 EXECUTION PLAN

### Day 1: MIGRATE ALL
```bash
# Morning: Setup
./scripts/one_shot_migrate.sh

# Afternoon: Migrate screens
# Follow templates above
# COPY-PASTE UI, don't modify

# Evening: Wire up DI & routes
# Test basic navigation
```

### Day 2: INTEGRATE & TEST
```bash
# Morning: Complete any remaining screens
# Afternoon: Integration testing
# Evening: Fix critical bugs
```

### Day 3: VERIFY & TEST
```bash
# All day: Comprehensive testing
# Use checklist above
# Document any issues
```

### Day 4: CLEANUP
```bash
# Morning: Fix review violations
# Afternoon: Final testing
# Evening: Delete old files, documentation
```

---

## 🚀 ONE-SHOT MIGRATION SCRIPT

Create this script to automate structure creation:

```bash
#!/bin/bash
# scripts/one_shot_migrate.sh

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     🚀 ONE-SHOT MIGRATION - Creating All Features          ║"
echo "╚════════════════════════════════════════════════════════════╝"

features=(
  "splash:splash_page"
  "dashboard:dashboard_page"
  "home:home_page,offer_item"
  "bills:add_bill_page"
  "wallet:wallet_page"
  "transactions:transaction_page"
  "profile:profile_page,edit_profile_page"
  "settings:notification_settings_page"
  "admin:admin_home_page,bill_details_page,diagnostic_page,admin_add_bill_page"
  "spin:daily_spin_page"
  "redeem:redeem_page"
  "notifications:notifications_page"
)

for feature_info in "${features[@]}"; do
  IFS=':' read -r feature screens <<< "$feature_info"
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Creating: $feature"
  echo "Screens: $screens"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  ./scripts/create_feature.sh "$feature"
  
  echo "✅ $feature structure created"
done

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✅ ALL 12 FEATURES CREATED!                               ║"
echo "╠════════════════════════════════════════════════════════════╣"
echo "║  Next Steps:                                               ║"
echo "║  1. Migrate screens (use templates)                        ║"
echo "║  2. Update dependency_injection.dart                       ║"
echo "║  3. Update routes.dart                                     ║"
echo "║  4. Test everything                                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
```

---

## 📋 FINAL CHECKLIST

Before declaring migration complete:

### Code Quality
- [ ] All 21 screens migrated
- [ ] 0 compilation errors
- [ ] 0 runtime errors
- [ ] All BLoCs created
- [ ] All routes updated
- [ ] DI fully wired

### Functionality
- [ ] All auth flows work
- [ ] All user flows work
- [ ] All admin flows work
- [ ] All engagement features work
- [ ] Image uploads work
- [ ] Form validations work
- [ ] Error handling works

### Architecture
- [ ] Clean architecture implemented
- [ ] BLoC pattern consistent
- [ ] Repository pattern used
- [ ] No direct service calls in UI
- [ ] Proper error handling

### Testing
- [ ] Manual testing complete
- [ ] All critical paths verified
- [ ] No regressions found
- [ ] Performance acceptable
- [ ] Logs clean

### Cleanup
- [ ] Old files removed
- [ ] Documentation updated
- [ ] Code committed
- [ ] Tagged release

---

**Ready? Let's do this ONE-SHOT migration! 🚀**

**Remember: COPY UI EXACTLY. Fix violations AFTER confirming functionality!**
