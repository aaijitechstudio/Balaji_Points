## Balaji Points – Carpenter Design Update Execution Plan

### 1. Objectives & Constraints

- **Primary objective**: Implement the new carpenter UI design (as defined in `carpenter_design_update_plan.md`) while:
  - Maintaining **all existing features and flows**.
  - Avoiding regressions in **business logic, data, navigation, or permissions**.
  - Preserving current behavior for notifications, bill submission, wallet, and auth.
- **Hard constraint**: Design changes must be **view‑layer only** wherever possible.
  - No changes to:
    - Repository APIs.
    - BLoC / Riverpod provider contracts and events.
    - Firestore / Firebase interaction logic.
    - Navigation paths and route names.

---

### 2. Scope

- **Included**
  - All **carpenter-facing screens**:
    - Splash, Auth (login, PIN setup/login/reset).
    - Dashboard / Home.
    - Add Bill (carpenter and any shared add‑bill flows that carpenters use).
    - Daily Spin.
    - Notifications list and Notification Settings.
    - Profile and Edit Profile.
    - Wallet / History / Redeem UI visible to carpenters.
  - Theme, typography, spacing, and component styling via `DesignToken` and `ThemeData`.
  - Light and dark mode correctness.

- **Excluded (for this design update)**  
  - Admin-specific screens and flows.
  - Core data models, Firestore collections, and Cloud Functions logic.
  - Auth logic (PIN verification, session handling) beyond visual layout.

---

### 3. Architectural Approach (Zero-Feature-Impact Focus)

1. **View-layer refactor only**
   - Move layout/styling concerns into:
     - Theming (`ThemeData`, `ColorScheme`).
     - Shared UI components (cards, app bars, nav bar, inputs).
   - Do **not** change:
     - BLoC events/states and provider signatures.
     - Method names, return types, or side-effects in services/repositories.
     - Routing paths (e.g. `/add-bill`, `/notifications`).

2. **Theming & Tokens**
   - Introduce/extend a central `theme.dart`:
     - `ThemeData lightTheme`, `ThemeData darkTheme`.
   - Extend `DesignToken` with light/dark pairs and reference them in themes.
   - Replace raw `Colors.*` in UI with:
     - `Theme.of(context).colorScheme` or
     - `DesignToken` abstractions.

3. **Shared Components**
   - Create reusable widgets for:
     - AppBar (carpenter shell).
     - Bottom navigation bar.
     - Card layouts (bills, notifications, wallet entries, offers).
     - Standard input fields (where consistent).
   - Use these components in screens **without altering their logic**:
     - Keep callbacks, parameters, and state management identical.

4. **Incremental, screen-by-screen rollout**
   - Update one screen (or small group) at a time.
   - After each screen refactor:
     - Run widget and integration tests (where available).
     - Manually verify all existing interactions on that screen.

---

### 4. Implementation Phases & Order

#### Phase 0 – Foundation (No Behavior Changes)

1. **Theme and Color System**
   - Add `lightTheme` and `darkTheme` using `ColorScheme` and `DesignToken`.
   - Wire them into `BalajiPointsApp`:
     - `theme`, `darkTheme`, `themeMode: ThemeMode.system`.
   - Confirm app still runs and looks the same (no behavior changes).

2. **Shared Layout Components**
   - Implement:
     - Common scaffold wrapper (handles `SafeArea` & layout).
     - Shared bottom nav bar widget (no nav logic changes).
     - Shared card widget(s) (pure visual).
   - Initially, **do not use** these in existing screens; just add them.

#### Phase 1 – Dashboard & Navigation Shell

1. Replace `DashboardPage` scaffold with the **shared scaffold**:
   - Keep existing body widgets and navigation callbacks intact.
   - Only adjust:
     - Padding.
     - AppBar configuration (title, actions).
2. Introduce the shared bottom navigation bar into the carpenter shell:
   - Ensure tab selection logic uses existing state/GoRouter calls.
   - Verify:
     - All nav items still go to the same routes.
     - Deep links and back navigation are unchanged.

Regression checks (Phase 1):
- Launch app as carpenter:
  - Can reach dashboard.
  - Bottom navigation works as before (all tabs & back button).

#### Phase 2 – Add Bill Screen

1. Apply shared scaffold and card patterns to `AddBillPage`:
   - Restructure layout visually using new card and button styles.
   - Keep:
     - `_billService.submitBill` call and parameters unchanged.
     - Image picker logic identical (only container UI changes).
2. Convert validation to inline errors **without changing rules**:
   - Same conditions; only where/how errors are shown changes.

Regression checks (Phase 2):
- Submitting valid and invalid bills behaves exactly as before:
  - Same Firestore writes.
  - Same notifications to admin (Cloud Functions pipeline unchanged).

#### Phase 3 – Daily Spin Screen

1. Migrate layout to shared scaffold and standardized card styles.
2. Keep:
   - Spin trigger logic and reward logic identical.
   - Any Firestore updates or FCM notifications unchanged.

Regression checks:
- Daily spin can still be performed once per period as before.
- Rewards, points update, and notifications (if any) behave identically.

#### Phase 4 – Notifications & Notification Settings

1. **NotificationsPage**:
   - Swap list items to shared notification card visuals.
   - Keep:
     - Firestore query streams.
     - `onTap` navigation to `/notifications` or specific flows.
2. **NotificationSettingsPage**:
   - Restructure into sections and rows, using shared styles.
   - Keep:
     - Reads/writes to `notificationPreferences` in Firestore the same.

Regression checks:
- Notifications still appear as before.
- Toggling any setting still updates the same Firestore fields and filters.

#### Phase 5 – Profile & Edit Profile

1. **ProfilePage**:
   - Introduce summary card and standard action list.
   - Retain:
     - Navigation targets (Edit Profile, Wallet, Notification Settings).
     - Logout behavior and FCM token deletion.
2. **EditProfilePage**:
   - Apply shared form styling and avatar picker improvements.
   - Keep:
     - `StorageService` and `UserService` logic as is (image upload, profile update).

Regression checks:
- Editing profile still updates Firestore and images correctly.
- Logout still cleans up session and FCM tokens as before.

#### Phase 6 – Wallet / History / Redeem (if applicable)

1. Apply shared card and layout patterns to wallet/history/redeem screens.
2. Keep all queries, calculations, and redeem flows intact.

Regression checks:
- Wallet balances and history entries match pre‑design behavior.
- Redeem flows (points deduction, offer data, notifications) remain unchanged.

#### Phase 7 – Auth Flow (Login, PIN)

1. Apply unified auth layout to:
   - `LoginPage`, `PINLoginPage`, `PINSetupPage`, `ResetPINPage`.
2. Do not change:
   - PIN validation rules.
   - Session saving (`SessionService`) and FCM token initialization.
   - Navigation after successful login or setup.

Regression checks:
- All existing auth flows still succeed/fail under the same conditions as before.

---

### 5. Non-Functional Safeguards (Ensuring Zero Feature Impact)

1. **No public API changes**
   - Do not change:
     - Method signatures in services, repositories, or BLoCs.
     - Event/state class names or fields.
     - Route names or navigation structure.

2. **Visual-only refactors**
   - Confine changes for each step to:
     - Widget composition (layout).
     - Styling (colors, borders, radius, padding, typography).
   - Avoid moving business logic between layers or introducing new logic paths.

3. **Small, focused commits**
   - One screen (or small group) per commit where possible.
   - Clear commit messages indicating “UI only / no logic change”.

4. **Testing before and after each phase**
   - Manual test checklist per screen:
     - All buttons still work.
     - All fields validate as before.
     - Back navigation and deep links behave the same.
   - Run existing widget/integration tests after each major phase.

---

### 6. QA & Validation Strategy

1. **Cross-device UI checks**
   - Test on:
     - Small phone (e.g. ~5\" display).
     - Large phone (~6.5+\").
     - Device with notch / hole‑punch.
   - Verify safe areas, app bar, and bottom nav for each.

2. **Light & Dark mode**
   - For each updated screen:
     - Check light mode for correct surfaces/contrast.
     - Check dark mode: no illegible text or invisible icons.

3. **Feature parity comparison**
   - For critical flows (bill upload, spin, redeem, auth), compare:
     - Firestore writes (documents created/updated).
     - Navigation sequences.
     - User feedback (snackbars, dialogs, toasts).

4. **Regression sign-off**
   - Only mark a phase as complete when:
     - All existing behavior is verified unchanged.
     - Visual acceptance meets the design doc.

---

### 7. Branching & Rollout

- Use the `design-update` branch for all design work.
- Keep changes **rebased/merged regularly** from `development` to avoid drift.
- When all phases are completed and verified:
  - Create a PR from `design-update` → `development`.
  - Include:
    - Link to `carpenter_design_update_plan.md`.
    - Link to this execution plan.
    - Summary of screens touched and confirmation of “no feature changes”.

This plan is designed to implement the new carpenter UI while **guaranteeing zero impact** on current features and behavior, by strictly separating visual refactors from business logic and by enforcing thorough regression checks at each step.

