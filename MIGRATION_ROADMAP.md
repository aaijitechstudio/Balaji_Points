# 🗓️ Migration Roadmap - Visual Timeline

## 📅 8-Week Migration Schedule

```
Week 1-2: FOUNDATION
┌─────────────────────────────────────────────────────────┐
│  ✅ auth (DONE)                                          │
│  🎯 splash      → Session check & routing               │
│  🎯 dashboard   → Main navigation hub                   │
│  🎯 home        → User dashboard with stats             │
├─────────────────────────────────────────────────────────┤
│  Deliverable: Complete user login → home flow           │
│  Review: 4 screens pass ✅                              │
└─────────────────────────────────────────────────────────┘

Week 3-4: CORE BUSINESS
┌─────────────────────────────────────────────────────────┐
│  🎯 bills       → Submit bills, upload receipts         │
│  🎯 wallet      → View balance, transactions            │
│  🎯 transaction → Transaction details                   │
├─────────────────────────────────────────────────────────┤
│  Deliverable: Complete bill submission flow             │
│  Review: 3 screens pass ✅                              │
└─────────────────────────────────────────────────────────┘

Week 5: USER MANAGEMENT
┌─────────────────────────────────────────────────────────┐
│  🎯 profile     → View/edit profile, avatar upload      │
│  🎯 settings    → Notification preferences              │
├─────────────────────────────────────────────────────────┤
│  Deliverable: User profile management                   │
│  Review: 3 screens pass ✅                              │
└─────────────────────────────────────────────────────────┘

Week 6-7: ADMIN FEATURES
┌─────────────────────────────────────────────────────────┐
│  🎯 admin       → Bill approval, user management        │
│                   Analytics, diagnostics                │
├─────────────────────────────────────────────────────────┤
│  Deliverable: Complete admin panel                      │
│  Review: 4 screens pass ✅                              │
│  Note: Most complex - allocate buffer                   │
└─────────────────────────────────────────────────────────┘

Week 8: ENGAGEMENT
┌─────────────────────────────────────────────────────────┐
│  🎯 spin        → Daily spin wheel                      │
│  🎯 redeem      → Points redemption                     │
│  🎯 notifications → Notification center                 │
├─────────────────────────────────────────────────────────┤
│  Deliverable: Full engagement features                  │
│  Review: 3 screens pass ✅                              │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Priority Matrix

```
                    HIGH PRIORITY
                         ↑
                         │
         ┌───────────────┼───────────────┐
         │   CRITICAL    │   IMPORTANT   │
         │               │               │
         │  • splash     │  • admin      │
SIMPLE   │  • dashboard  │  • profile    │───── COMPLEX
         │  • home       │               │
         │  • bills      │               │
         │               │               │
         ├───────────────┼───────────────┤
         │   NICE TO     │   LOW IMPACT  │
         │   HAVE        │               │
         │  • wallet     │  • spin       │
         │  • transaction│  • redeem     │
         │  • settings   │  • notify     │
         └───────────────┼───────────────┘
                         │
                         ↓
                    LOW PRIORITY
```

---

## 📊 Effort vs Value Analysis

```
High Value │
          │   home     bills
          │     ●        ●
          │              
          │ splash  admin
          │   ●      ●
          │              wallet
Mid Value │              ●
          │                profile
          │                  ●
          │      dashboard
          │         ●          notifications
          │                      ●
Low Value │                  spin  redeem
          │                   ●     ●
          │                         settings
          │                           ●
          └─────┬────────┬────────┬────────┬────────
               Low     Mid    High   Very High
                        EFFORT →
```

**Recommendation:** Start top-left (high value, low effort)
1. splash, dashboard (quick wins)
2. home, bills (high value)
3. wallet, profile (medium value)
4. admin (high effort but essential)
5. engagement features last

---

## 🚀 Quick Start Guide

### Option A: Follow Recommended Order (8 weeks)
```bash
# Week 1-2: Foundation
./scripts/create_feature.sh splash
./scripts/create_feature.sh dashboard
./scripts/create_feature.sh home

# Week 3-4: Core Business
./scripts/create_feature.sh bills
./scripts/create_feature.sh wallet
./scripts/create_feature.sh transactions

# Week 5: User Management
./scripts/create_feature.sh profile
./scripts/create_feature.sh settings

# Week 6-7: Admin
./scripts/create_feature.sh admin

# Week 8: Engagement
./scripts/create_feature.sh spin
./scripts/create_feature.sh redeem
./scripts/create_feature.sh notifications
```

### Option B: Quick MVP (4 weeks)
```bash
# Focus on core user journey only
Week 1: splash, dashboard, home
Week 2: bills, wallet
Week 3: profile, settings
Week 4: admin (basic)
# Skip: spin, redeem, notifications, transaction
```

### Option C: Parallel Development (4 weeks with 2 devs)
```bash
# Developer 1: User features
Week 1-2: splash, dashboard, home, bills
Week 3-4: wallet, transactions, profile, settings

# Developer 2: Admin & engagement
Week 1-2: admin (analysis & domain)
Week 3-4: admin (data & presentation)
          spin, redeem, notifications
```

---

## 📈 Progress Tracking

### Migration Scorecard

| Feature | Status | Screens | Review | Tested | Notes |
|---------|--------|---------|--------|--------|-------|
| auth | ✅ DONE | 4/4 | ✅ | ✅ | Production ready |
| splash | 🔲 TODO | 0/1 | - | - | - |
| dashboard | 🔲 TODO | 0/1 | - | - | - |
| home | 🔲 TODO | 0/2 | - | - | - |
| bills | 🔲 TODO | 0/1 | - | - | - |
| wallet | 🔲 TODO | 0/1 | - | - | - |
| transaction | 🔲 TODO | 0/1 | - | - | - |
| profile | 🔲 TODO | 0/2 | - | - | - |
| settings | 🔲 TODO | 0/1 | - | - | - |
| admin | 🔲 TODO | 0/4 | - | - | - |
| spin | 🔲 TODO | 0/1 | - | - | - |
| redeem | 🔲 TODO | 0/1 | - | - | - |
| notifications | 🔲 TODO | 0/1 | - | - | - |

**Overall Progress:** 4/21 screens (19%)

### Legend
- ✅ DONE - Fully migrated and tested
- 🚧 IN PROGRESS - Currently being worked on
- 🔲 TODO - Not started
- ⏸️ BLOCKED - Waiting on dependency

---

## 🎯 Next Immediate Steps

### This Week: Splash + Dashboard (2 features, 2 screens)

#### Monday-Tuesday: Splash Module
```bash
# 1. Create structure
./scripts/create_feature.sh splash

# 2. Implement
# Domain: 
#   - Session entity
#   - check_session use case
# Data:
#   - Wrap SessionService
# Presentation:
#   - SplashBloc (checking → ready/error)
#   - Migrate splash_page.dart

# 3. Review
./scripts/review_screen.sh lib/features/splash/presentation/pages/splash_page.dart

# 4. Test
flutter run
# Should: Check session → route to dashboard or login
```

#### Wednesday: Dashboard Module
```bash
# 1. Create structure  
./scripts/create_feature.sh dashboard

# 2. Implement
# Domain:
#   - Navigation logic (may not need BLoC)
# Presentation:
#   - Migrate dashboard_page.dart
#   - Role-based routing (admin/carpenter/user)

# 3. Review
./scripts/review_screen.sh lib/features/dashboard/presentation/pages/dashboard_page.dart

# 4. Test
flutter run
# Should: Navigate based on user role
```

#### Thursday-Friday: Home Module
```bash
# 1. Create structure
./scripts/create_feature.sh home

# 2. Implement
# Domain:
#   - UserStats entity (points, tier, bills)
#   - Offer entity
#   - get_user_stats use case
#   - get_offers use case
# Data:
#   - Wrap UserService, OfferService
# Presentation:
#   - HomeBloc (loading, loaded, error)
#   - Migrate home_page.dart, offer_item.dart

# 3. Review
./scripts/review_screen.sh lib/features/home/presentation/pages/home_page.dart

# 4. Test
flutter run
# Should: Display user stats, offers, tier info
```

---

## 📝 Daily Checklist Template

```markdown
### Date: [DATE] - Feature: [NAME]

#### Morning (Setup)
- [ ] Review existing code
- [ ] Identify dependencies
- [ ] Create feature structure
- [ ] Define entities

#### Afternoon (Implementation)
- [ ] Create use cases
- [ ] Implement data layer
- [ ] Create BLoC
- [ ] Migrate UI

#### Evening (Quality)
- [ ] Run review script
- [ ] Fix violations
- [ ] Test functionality
- [ ] Update progress

#### Blockers
- [ ] List any issues encountered
```

---

## 🎊 Milestones

### Milestone 1: User Journey Complete (Week 2)
- ✅ User can login
- ✅ User sees dashboard
- ✅ User views home with stats
- **Celebrate!** 🎉

### Milestone 2: Core Features Complete (Week 4)
- ✅ User can submit bills
- ✅ User can view wallet
- ✅ User can see transactions
- **Celebrate!** 🎉

### Milestone 3: User Management Complete (Week 5)
- ✅ User can edit profile
- ✅ User can manage settings
- **Celebrate!** 🎉

### Milestone 4: Admin Complete (Week 7)
- ✅ Admin can approve bills
- ✅ Admin can manage users
- **Celebrate!** 🎉

### Milestone 5: Full App Migrated (Week 8)
- ✅ All features migrated
- ✅ All reviews pass
- ✅ Production ready
- **LAUNCH!** 🚀

---

## 📞 Support & Resources

### When Stuck
1. Reference auth module: `lib/features/auth/`
2. Check documentation: `AUTH_CLEANUP_COMPLETE.md`
3. Review patterns: `MIGRATION_PLAN_NEXT_MODULES.md`
4. Ask for help (create issue/discussion)

### Useful Commands
```bash
# Create feature
./scripts/create_feature.sh <name>

# Review screen
./scripts/review_screen.sh <path>

# Check compilation
flutter analyze lib/features/<name>/

# Run app
flutter run

# Check specific violations
grep -r "EdgeInsets.all([0-9]" lib/features/<name>/
```

---

## 🎯 Success Metrics

After each feature:
- ✅ Review script passes
- ✅ 0 compilation errors
- ✅ All flows tested manually
- ✅ Performance maintained
- ✅ Minimal logging

After full migration:
- ✅ 100% clean architecture
- ✅ 21/21 screens pass review
- ✅ Consistent BLoC pattern
- ✅ Easy to maintain
- ✅ Ready for new features

---

**Let's get started! Next: Splash + Dashboard this week! 🚀**
