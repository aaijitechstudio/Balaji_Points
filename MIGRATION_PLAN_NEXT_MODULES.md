# 🗺️ Next Modules Migration Plan - Clean Architecture

## 📊 Current Status

### ✅ Completed
- **Auth Module** (4 screens, ~2,000 lines)
  - Clean Architecture ✅
  - BLoC Pattern ✅
  - All reviews pass ✅
  - Production-ready ✅

### 🎯 Remaining: 12 Features to Migrate

---

## 📈 Feature Analysis

### Complexity Assessment

| Feature | Screens | Lines | Services | Complexity | Priority |
|---------|---------|-------|----------|------------|----------|
| **admin** | 4 | 2,869 | 5 | 🔴 HIGH | P1 |
| **profile** | 2 | 1,902 | 6 | 🟡 MEDIUM | P2 |
| **home** | 2 | 1,760 | 2 | 🟡 MEDIUM | P1 |
| **notifications** | 1 | 1,060 | 1 | 🟢 LOW | P3 |
| **bills** | 1 | 941 | 3 | 🟡 MEDIUM | P1 |
| **wallet** | 1 | 941 | 1 | 🟢 LOW | P2 |
| **splash** | 1 | 433 | 2 | 🟢 LOW | P1 |
| **settings** | 1 | 408 | 1 | 🟢 LOW | P3 |
| **spin** | 1 | 399 | 0 | 🟢 LOW | P3 |
| **redeem** | 1 | 126 | 0 | 🟢 LOW | P3 |
| **dashboard** | 1 | 76 | 0 | 🟢 LOW | P1 |
| **transaction** | 1 | 13 | 0 | 🟢 LOW | P2 |

**Total:** 17 screens, ~11,000 lines of code

---

## 🎯 Migration Strategy

### Phase 1: Core User Flow (Week 1-2)
**Goal:** Critical path for typical user

1. **splash** (½ day)
   - Simple navigation logic
   - Session check → dashboard or login
   - No business logic

2. **dashboard** (½ day)
   - Main navigation hub
   - Role-based routing
   - Minimal logic

3. **home** (2 days)
   - User dashboard with stats
   - Offers display
   - Points/tier info
   - Dependencies: bills, wallet services

### Phase 2: Transaction Features (Week 3-4)
**Goal:** Core business functionality

4. **bills** (2 days)
   - Bill submission
   - Upload receipt
   - Bill history
   - BLoC: BillBloc (states: loading, submitted, error)

5. **wallet** (1.5 days)
   - Points balance
   - Transaction history
   - Redemption tracking
   - BLoC: WalletBloc

6. **transaction** (½ day)
   - Transaction details
   - Simple display logic

### Phase 3: User Management (Week 5)
**Goal:** Profile & settings

7. **profile** (2.5 days)
   - Edit profile
   - View profile
   - Avatar upload
   - Multiple services (user, storage)
   - BLoC: ProfileBloc

8. **settings** (1 day)
   - Notification preferences
   - App settings
   - Simple CRUD

### Phase 4: Admin Features (Week 6-7)
**Goal:** Admin panel functionality

9. **admin** (4 days)
   - Bill approval workflow
   - User management
   - Analytics dashboard
   - Most complex feature
   - BLoC: AdminBloc, BillApprovalBloc

### Phase 5: Engagement Features (Week 8)
**Goal:** User engagement & retention

10. **spin** (1 day)
    - Daily spin wheel
    - Reward logic
    - BLoC: SpinBloc

11. **redeem** (1 day)
    - Points redemption
    - Reward catalog
    - BLoC: RedeemBloc

12. **notifications** (1.5 days)
    - Notification list
    - Mark as read
    - Deep linking
    - BLoC: NotificationBloc

---

## 📋 Detailed Migration Plan

### Week 1-2: Core User Flow

#### Day 1-2: Splash & Dashboard
```bash
# 1. Splash (Simple)
./scripts/create_feature.sh splash
# Migrate: splash_page.dart
# Domain: Session entity, check_session use case
# Data: Wrap SessionService
# Presentation: SplashBloc (2 states: checking, ready)

# 2. Dashboard (Simple)
./scripts/create_feature.sh dashboard  
# Migrate: dashboard_page.dart
# Domain: User role navigation
# Presentation: Navigation logic only (no BLoC needed)
```

#### Day 3-5: Home/Dashboard
```bash
./scripts/create_feature.sh home
# Migrate: home_page.dart, offer_item.dart
# Domain: 
#   - User stats entity
#   - Offer entity
#   - get_user_stats use case
#   - get_offers use case
# Data:
#   - Wrap UserService
#   - Wrap OfferService
# Presentation:
#   - HomeBloc (loading, loaded, error states)
#   - Display user points, tier, offers
```

**Deliverable:** User can login → see dashboard → view home screen
**Review:** All 3 screens pass architecture review

---

### Week 3-4: Transaction Features

#### Day 6-8: Bills Module
```bash
./scripts/create_feature.sh bills
# Migrate: add_bill_page.dart
# Domain:
#   - Bill entity (id, amount, shopName, receipt, status)
#   - add_bill use case
#   - get_bills use case
#   - upload_receipt use case
# Data:
#   - BillRemoteDataSource (wrap BillService)
#   - BillRepository implementation
#   - Handle image upload via StorageService
# Presentation:
#   - BillBloc
#   - Events: SubmitBill, UploadReceipt, LoadBills
#   - States: Initial, Loading, Submitted, Error
```

#### Day 9-10: Wallet Module
```bash
./scripts/create_feature.sh wallet
# Migrate: wallet_page.dart
# Domain:
#   - Transaction entity
#   - get_balance use case
#   - get_transactions use case
# Data:
#   - Wrap existing wallet/transaction logic
# Presentation:
#   - WalletBloc (loading, loaded, error)
```

#### Day 11: Transaction Details
```bash
./scripts/create_feature.sh transactions
# Simple detail view - minimal logic
# Reuse wallet domain/data layer
```

**Deliverable:** User can submit bills, view wallet, see transactions
**Review:** 3 screens pass review

---

### Week 5: User Management

#### Day 12-14: Profile Module
```bash
./scripts/create_feature.sh profile
# Migrate: profile_page.dart, edit_profile_page.dart
# Domain:
#   - User profile entity (extended from auth)
#   - update_profile use case
#   - upload_avatar use case
# Data:
#   - Wrap UserService
#   - Wrap StorageService for avatar
# Presentation:
#   - ProfileBloc
#   - Events: LoadProfile, UpdateProfile, UploadAvatar
#   - States: Loading, Loaded, Updating, Success, Error
```

#### Day 15: Settings Module
```bash
./scripts/create_feature.sh settings
# Migrate: notification_settings_page.dart
# Simple preferences - may not need full feature structure
# Could be part of profile module
```

**Deliverable:** User can view/edit profile, manage settings
**Review:** 2-3 screens pass review

---

### Week 6-7: Admin Features

#### Day 16-20: Admin Module (Most Complex)
```bash
./scripts/create_feature.sh admin
# Migrate: 
#   - admin_home_page.dart
#   - bill_details_page.dart  
#   - diagnostic_page.dart
#   - admin_add_bill_page.dart
# Domain:
#   - Bill approval workflow
#   - User management entities
#   - approve_bill use case
#   - reject_bill use case
#   - get_pending_bills use case
#   - manage_users use case
# Data:
#   - Wrap BillService (admin operations)
#   - Wrap UserService (admin operations)
# Presentation:
#   - AdminBloc (dashboard stats)
#   - BillApprovalBloc (approval workflow)
#   - UserManagementBloc
#   - Multiple complex screens
```

**Deliverable:** Admin can approve bills, manage users
**Review:** 4 screens pass review
**Note:** This is the most complex - allocate extra buffer time

---

### Week 8: Engagement Features

#### Day 21: Spin Module
```bash
./scripts/create_feature.sh spin
# Migrate: daily_spin_page.dart
# Domain:
#   - Spin result entity
#   - spin_wheel use case (daily limit check)
# Data:
#   - Spin logic + Firebase update
# Presentation:
#   - SpinBloc (idle, spinning, result, error)
```

#### Day 22: Redeem Module
```bash
./scripts/create_feature.sh redeem
# Migrate: redeem_page.dart
# Domain:
#   - Reward entity
#   - redeem_points use case
# Presentation:
#   - RedeemBloc
```

#### Day 23-24: Notifications Module
```bash
./scripts/create_feature.sh notifications
# Migrate: notifications_page.dart
# Domain:
#   - Notification entity
#   - get_notifications use case
#   - mark_as_read use case
# Data:
#   - Wrap NotificationService
# Presentation:
#   - NotificationBloc
```

**Deliverable:** Full engagement loop working
**Review:** 3 screens pass review

---

## 🔄 Migration Workflow (Per Feature)

### Step 1: Analyze (30 min)
```bash
# Understand current implementation
- Review existing screen code
- Identify services used
- Map out data flow
- List all state variables
```

### Step 2: Domain Layer (1-2 hours)
```bash
# Create pure business logic
1. Define entities (pure Dart classes)
2. Define repository interfaces
3. Create use cases (one per user action)
```

### Step 3: Data Layer (1-2 hours)
```bash
# Implement data access
1. Create models (entities + JSON/Firestore conversion)
2. Create remote data source (wrap existing services)
3. Implement repository (connect datasource to domain)
```

### Step 4: Presentation Layer (2-4 hours)
```bash
# Migrate UI with BLoC
1. Define events (user actions)
2. Define states (UI states)
3. Create BLoC (map events → states)
4. Migrate screen(s) to use BLoC
5. Replace direct service calls with events
```

### Step 5: Integration (30 min)
```bash
# Connect everything
1. Register in dependency_injection.dart
2. Update routes.dart with BlocProvider
3. Test all flows
```

### Step 6: Review & Fix (1 hour)
```bash
# Quality assurance
1. Run review script
2. Fix violations
3. Re-review until pass
4. Test functionality
```

---

## ⚠️ Common Challenges & Solutions

### Challenge 1: Service Dependencies
**Issue:** Multiple features use same service
**Solution:** 
- Keep existing services as-is
- Wrap them in data sources
- Share via DI (singleton services)

### Challenge 2: Riverpod to BLoC Migration
**Issue:** Existing code uses Riverpod providers
**Solution:**
- Keep Riverpod for now (locale, theme)
- Use BLoC for feature state only
- Gradual migration

### Challenge 3: Complex State Management
**Issue:** Screens with multiple states (loading, error, success)
**Solution:**
- Use sealed classes or Equatable for states
- Handle all states in BlocBuilder
- Clear error/success states after shown

### Challenge 4: Image Upload
**Issue:** Receipts, avatars need storage
**Solution:**
- Create upload use case in domain
- Data source handles StorageService
- Return Either<Failure, String> (URL)

### Challenge 5: Real-time Updates
**Issue:** Admin needs real-time bill updates
**Solution:**
- Stream use cases (Stream<Either<Failure, List<Bill>>>)
- BLoC.emit for each stream update
- Use StreamSubscription (dispose properly)

---

## 📊 Time Estimates

| Phase | Features | Screens | Est. Time |
|-------|----------|---------|-----------|
| Phase 1 | splash, dashboard, home | 4 | 2 weeks |
| Phase 2 | bills, wallet, transaction | 3 | 2 weeks |
| Phase 3 | profile, settings | 3 | 1 week |
| Phase 4 | admin | 4 | 2 weeks |
| Phase 5 | spin, redeem, notifications | 3 | 1 week |
| **Total** | **12 features** | **17 screens** | **8 weeks** |

**With buffer:** 10 weeks (2.5 months)

---

## ✅ Success Criteria (Per Feature)

1. **Architecture**
   - ✅ Clean Architecture (Domain → Data → Presentation)
   - ✅ BLoC pattern implemented
   - ✅ Repository pattern used
   - ✅ No direct service calls in UI

2. **Code Quality**
   - ✅ All screens pass review script
   - ✅ 0 design token violations
   - ✅ 0 localization violations
   - ✅ Proper error handling

3. **Functionality**
   - ✅ All existing features work
   - ✅ No regressions
   - ✅ Same UI/UX
   - ✅ Performance maintained

4. **Testing**
   - ✅ Manual testing complete
   - ✅ No console errors
   - ✅ Minimal logging

---

## 🚀 Getting Started

### Immediate Next Steps

1. **Choose Next Feature** (Recommend: splash + dashboard)
   ```bash
   # Simple features to build confidence
   ./scripts/create_feature.sh splash
   ./scripts/create_feature.sh dashboard
   ```

2. **Follow Auth Pattern**
   - Use auth module as template
   - Copy structure
   - Adapt to feature needs

3. **Track Progress**
   - Check off completed features
   - Document issues
   - Update estimates

### Commands Reference

```bash
# Create feature structure
./scripts/create_feature.sh <feature_name>

# Review screen
./scripts/review_screen.sh lib/features/<feature>/presentation/pages/<screen>.dart

# Test compilation
flutter analyze lib/features/<feature>/

# Run app
flutter run
```

---

## 📝 Migration Checklist Template

Use for each feature:

```markdown
## Feature: [NAME]

### Analysis ✅
- [ ] Reviewed existing screens
- [ ] Identified services used
- [ ] Mapped data flow
- [ ] Listed all states

### Domain Layer ✅
- [ ] Created entities
- [ ] Defined repository interface
- [ ] Created use cases

### Data Layer ✅
- [ ] Created models
- [ ] Created remote data source
- [ ] Implemented repository

### Presentation Layer ✅
- [ ] Defined events
- [ ] Defined states
- [ ] Created BLoC
- [ ] Migrated screens

### Integration ✅
- [ ] Updated DI
- [ ] Updated routes
- [ ] Tested flows

### Quality ✅
- [ ] Review script passes
- [ ] No violations
- [ ] Manual testing done
- [ ] Documentation updated
```

---

## 🎯 Priority Order (Recommended)

### Week 1-2: Foundation
1. ✅ **auth** (DONE)
2. 🎯 **splash** - Session check, routing
3. 🎯 **dashboard** - Main hub
4. 🎯 **home** - User dashboard

### Week 3-4: Core Features
5. 🎯 **bills** - Critical for business
6. 🎯 **wallet** - Points management
7. 🎯 **transaction** - History view

### Week 5: User Features
8. 🎯 **profile** - User management
9. 🎯 **settings** - Preferences

### Week 6-7: Admin
10. 🎯 **admin** - Most complex

### Week 8: Engagement
11. 🎯 **spin** - Daily engagement
12. 🎯 **redeem** - Rewards
13. 🎯 **notifications** - Communication

---

## 📚 Resources

- **Auth Module:** Reference implementation in `lib/features/auth/`
- **Scripts:** `./scripts/create_feature.sh`, `./scripts/review_screen.sh`
- **Documentation:** 
  - `AUTH_CLEANUP_COMPLETE.md` - Completed example
  - `SCREEN_REVIEW_GUIDE.md` - Review standards
  - `docs/architecture/` - Architecture patterns

---

## 🎊 End Goal

After 8-10 weeks:
- ✅ All 13 features migrated
- ✅ 100% clean architecture compliance
- ✅ Consistent BLoC pattern
- ✅ All reviews passing
- ✅ Production-ready codebase
- ✅ Easy to maintain & test
- ✅ Ready for new features

**Let's build this! 🚀**
