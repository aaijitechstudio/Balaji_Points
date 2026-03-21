# Balaji Points — UI/UX Review (Carpenter role only)

| Field | Value |
|--------|--------|
| **Scope** | **Carpenter role only** — onboarding, shell app, shop/orders, wallet, profile. **Admin** (`/admin/*`) excluded. |
| **Method** | Static codebase review (2026-03-21 **re-review** after drawer/shell/l10n/notification-settings removal). |
| **Primary code** | `routes.dart`, `DashboardPage`, `HomePage`, `CarpenterShellLayout`, key `presentation/screens/*`. |

---

## 1. Executive summary

### 1.1 Strengths

- **Shell IA** is clear: **Home → Wallet → Notifications → Profile** plus a **center FAB** for **add bill** (core loyalty action, thumb-friendly).
- **Visual system** is coherent on carpenter paths: **Nunito**, **DesignToken**, **HomeNavBar**, cards, gradients — readable and on-brand.
- **Wallet tab** label aligns with route: ARB **`earn`** → **“Wallet”** (EN/HI/TA) on the bottom bar; `WalletPage` title uses **`l10n.wallet`**.
- **Deep shell routes** (`/products`, `/cart`, `/about-us`, `/add-bill`, …) **highlight Home** in the bottom bar — reduces “lost” feeling vs a blank selection.
- **Shared bottom scroll padding** exists: **`CarpenterShellLayout.bottomPaddingForScrollView`** (`24 + 98 + safe area`) on **Home, Wallet, Profile, About**.
- **GoRouter error** screen is **localized** (`routeError*` strings) with a sensible **Go home** action.
- **Drawer** is **short**: only **Products**, **Cart**, **About**, **Logout** (no duplicate tab rows).
- **Profile** uses **section headers** (Account / Support / Preferences), **About** link, **My orders** + **Redeem** + **Transactions** entries; legacy bottom-nav bug (middle tab → home) **fixed** → **`/add-bill`** when that bar is shown.
- **Home** “Rankings & daily winner” is **collapsible** (`HomeLayoutPrefs`); **Semantics** on FAB and tab items.
- **Splash** uses a **~750 ms** minimum brand delay (no longer a fixed **3 s** wait before auth).
- **Add bill** still guards **incomplete profile** before submit — good for data quality.

### 1.2 Gaps & risks (current)

| Area | Issue | Impact |
|------|--------|--------|
| **Shop flows** | **`product_list_page.dart`**, **`product_detail_page.dart`**, **`cart_page.dart`**: many **hardcoded English** strings (empty state, errors, SnackBars: “Added to cart”, “Please log in…”, “No Product Added”, etc.). | Poor **HI/TA** experience; inconsistent with rest of app. |
| **Notifications** | **`notifications_page.dart`**: empty state, errors, delete flows, dialogs largely **English** (`No Notifications`, `Delete All`, `Notification deleted`, …). | Same as above. |
| **Bottom inset** | **`CarpenterShellLayout`** **not** used on **Cart**, **Orders**, **Order detail** — they use **`98 + padding.bottom`** only (no **+24** margin like the helper). **Notifications** list uses **`padding.bottom: 120`**. **Add bill** uses **ad-hoc** values (`+160`, `margin bottom: 80`). | Slight **inconsistency**; risk of content **too tight** or **too loose** vs Home/Wallet/About. |
| **Home content** | Product **hero** titles/subtitles and **category chips** (`Bedroom`, `Kitchen`, …) remain **English-only** in code. | Localized section chrome but **English** story inside carousel. |
| **Offers** | `HomePage` maps Firestore offers with **English** CTA fallbacks (`View Offer`, `Learn More`) when not localized in data. | Minor unless all offers are localized server-side. |
| **Redeem / Transactions** | Routed and linked from profile; **UI is still placeholder / English-heavy** (`redeem_page.dart`, `transaction_page.dart`). | Confusing if users expect full flows. |
| **Notification prefs** | **In-app notification settings screen removed**; **`NotificationService`** still reads **`notificationPreferences`** in Firestore. | Users rely on **OS settings** + defaults; document for support. |
| **Dead code** | **`BottomNavWrapper`** (`lib/presentation/widgets/common/bottom_nav_wrapper.dart`) appears **unused**; hardcoded **“Earn”** / wrong nav if ever reintroduced. | Confusing for future refactors. |

### 1.3 Recommended focus (next iterations)

1. **P0**: **l10n** for **products**, **cart**, **product detail**, **notifications** (user-visible strings + SnackBars).  
2. **P1**: Unify **bottom padding** on **Cart, Orders, Order detail, Notifications** with **`CarpenterShellLayout`** (or document one formula and apply everywhere).  
3. **P2**: **Home** product hero + category labels → **ARB** (or simplify to fewer, localized buckets).  
4. **P2**: **Add bill** — **stepped** layout on narrow screens; align fixed CTA inset with shell math.  
5. **P3**: **Remove or repurpose** **`BottomNavWrapper`**; finish **Redeem/Transactions** UX or hide until ready.

---

## 2. Carpenter route inventory

### 2.1 Pre-shell

| Route | Screen |
|-------|--------|
| `/splash` | `SplashPage` |
| `/onboarding` | `OnboardingPage` |
| `/login` | `LoginPage` |
| `/pin-setup` | `PINSetupPage` |
| `/pin-login` | `PINLoginPage` |
| `/pin-reset` | `ResetPINPage` |

### 2.2 Shell (`ShellRoute` + `DashboardPage`)

| Route | Screen | Tab highlight |
|-------|--------|----------------|
| `/` | `HomePage` | Home |
| `/wallet` | `WalletPage` | Wallet |
| `/notifications` | `NotificationsPage` | Notifications |
| `/profile` | `ProfilePage` | Profile |
| `/add-bill` | `AddBillPage` | Home (parent) |
| `/about-us` | `AboutUsPage` | Home |
| `/products` | `ProductListPage` | Home |
| `/cart` | `CartPage` | Home |
| `/product-detail/:id` | `ProductDetailPage` | Home |
| `/orders` | `OrdersPage` | Home |
| `/order-detail/:id` | `OrderDetailPage` | Home |
| `/edit-profile` | `EditProfilePage` | Home |
| `/redeem` | `RedeemPage` | Home |
| `/transactions` | `TransactionPage` | Home |

### 2.3 Outside shell (carpenter-relevant)

| Route | Screen | Note |
|-------|--------|------|
| `/daily-spin` | `DailySpinPage` | No bottom bar — confirm product still exposes entry from home/offers. |

**Removed from carpenter UX:** `/notification-settings` (no route, no menu entries).

---

## 3. Shell: bottom bar & FAB

**File:** `lib/presentation/screens/dashboard/dashboard_page.dart`

- **FAB**: Opens **`/add-bill`**; **`Semantics`** (label + hint).  
- **Tabs**: **`Semantics`** per item (`button`, `selected`, `label`).  
- **Double-tap to exit** on Android root — appropriate.  
- **`PopScope`**: inner stack **`pop`** before exit — OK for deep links.

---

## 4. Drawer (`HomePage`)

1. Header (avatar, name, phone)  
2. **Products** (localized title/subtitle)  
3. **Cart**  
4. Divider  
5. **About**  
6. Spacer  
7. Version + **Logout**

**Tradeoff:** No in-app notification category toggles — users use **OS notification settings**; server may still honor **`notificationPreferences`** if present.

---

## 5. Layout & bottom safe area

| Mechanism | Screens |
|-----------|---------|
| **`CarpenterShellLayout.bottomPaddingForScrollView`** | `HomePage`, `WalletPage`, `ProfilePage`, `AboutUsPage`; drawer footer uses helper **+ 8**. |
| **`98 + MediaQuery.padding.bottom`** (no +24) | `CartPage`, `OrdersPage`, `OrderDetailPage` |
| **Fixed `120`** bottom on list | `NotificationsPage` (`ListView` padding) |
| **Ad-hoc** | `AddBillPage` (e.g. `+160`, `marginBottom: 80`) |

**Recommendation:** migrate Cart / Orders / Order detail / Notifications to **`CarpenterShellLayout`** for one visual rhythm.

---

## 6. Localization hotspots (carpenter)

| Location | Examples | Priority |
|----------|----------|----------|
| `product_list_page.dart` | `No Product Added`, `Error loading products`, login/cart SnackBars | P0 |
| `product_detail_page.dart` | Same pattern | P0 |
| `cart_page.dart` | Checkout / empty / errors if any English | P0 |
| `notifications_page.dart` | Empty state, delete dialogs, errors | P0 |
| `home_page.dart` | Hero + category titles; offer action text from code | P1 |
| `orders/*` | Confirm any remaining English labels | P1 |

**Already localized:** drawer products, profile section labels, route error page, many profile strings, home section headers (ARB).

---

## 7. Screen-by-screen (short notes)

| Screen | UX note |
|--------|---------|
| **Splash** | Short brand delay + auth; OK. |
| **Onboarding** | First install gate before login — OK if copy matches product. |
| **Login / PIN** | Strong visual hierarchy; keep SnackBars short. |
| **Home** | Dense; collapsible rankings helps; consider localizing hero/category. |
| **Wallet** | Pull-to-refresh + shell padding — good reference. |
| **Notifications** | Needs **l10n** + padding alignment with shell. |
| **Add bill** | Profile gate good; long form — **steps** on small phones still open. |
| **Products / cart / detail** | **l10n** + optional cart badge on **HomeNavBar** when inside shop (home already has cart in app bar). |
| **Orders** | Entry from profile OK; padding consistency. |
| **Profile** | Sections + About; Redeem/Transactions visible — ensure pages match quality bar. |
| **About** | Good SaaS-style structure + shell padding. |
| **Daily spin** | Off-shell — back affordance and entry path should be obvious if live. |

---

## 8. Accessibility & ergonomics

- **Touch:** FAB and tabs adequate; dense home lists — keep **minimum 48dp** where possible.  
- **Contrast:** Offers / hero images — keep text on **gradients** or **scrims**.  
- **Dynamic type:** Test **Profile**, **Add bill**, **product** titles at **large text scale**.  
- **Screen reader:** FAB + tabs have **Semantics** — extend to critical list tiles where missing.

---

## 9. Carpenter backlog (updated)

### P0
- [ ] **l10n**: products, cart, product detail, notifications (all user-visible strings).  

### P1
- [ ] **Bottom padding**: Cart, Orders, Order detail, Notifications → **`CarpenterShellLayout`**.  
- [ ] **Home**: Localize or reduce English in **hero** + **category** chips.  

### P2
- [ ] **Add bill**: Multi-step or sticky CTA math aligned with shell.  
- [ ] **Redeem / Transactions**: Real UX or **temporarily hide** from profile until ready.  
- [ ] **Remove** unused **`BottomNavWrapper`** or refactor to match current shell.  

### P3
- [ ] **Cart badge** on **HomeNavBar** when browsing **products** (optional).  
- [ ] **Daily spin**: Confirm carpenter entry and navigation clarity.  

---

## 10. Appendix — key files

| Topic | Path |
|--------|------|
| Routes | `lib/config/routes.dart` |
| Shell padding helper | `lib/core/layout/carpenter_shell_layout.dart` |
| Shell / tabs / FAB | `lib/presentation/screens/dashboard/dashboard_page.dart` |
| Home + drawer | `lib/presentation/screens/home/home_page.dart` |
| Home rankings pref | `lib/services/home_layout_prefs.dart` |
| Wallet | `lib/presentation/screens/wallet/wallet_page.dart` |
| Notifications | `lib/presentation/screens/notifications/notifications_page.dart` |
| Profile | `lib/presentation/screens/profile/profile_page.dart` |
| Products / cart | `lib/presentation/screens/products/*`, `cart/cart_page.dart` |
| Orders | `lib/presentation/screens/orders/*` |
| About | `lib/presentation/screens/info/about_us_page.dart` |
| Add bill | `lib/presentation/screens/bills/add_bill_page.dart` |
| Redeem / transactions | `redeem/redeem_page.dart`, `transaction/transaction_page.dart` |
| Push prefs (no UI) | `lib/services/notification_service.dart` (`notificationPreferences`) |
| Legacy (unused?) | `lib/presentation/widgets/common/bottom_nav_wrapper.dart` |

---

## 11. Revision history

| Version | Date | Note |
|---------|------|------|
| 1.0 | 2026-03-21 | Initial (included admin). |
| 2.0 | 2026-03-21 | Carpenter-only scope. |
| 2.1 | 2026-03-21 | Shell padding, drawer trim, l10n batch, Wallet tab, rankings collapse, splash, redeem/transactions routes, Semantics. |
| 2.2 | 2026-03-21 | Notification settings screen **removed** from carpenter UX. |
| **3.0** | **2026-03-21** | **Full re-review**: reflects current routes, padding audit, l10n gaps (shop + notifications), risks, updated backlog. |

---

*End of carpenter-scoped report.*
