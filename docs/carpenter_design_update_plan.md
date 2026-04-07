## Balaji Points – Carpenter App UI Design Plan

### 1. Objectives

- Provide a **light, modern, and consistent UI** for all carpenter-facing screens.
- **Re-use the existing `DesignToken` system** (colors, typography, spacing) instead of ad‑hoc styling.
- Align with **international design standards**:
  - Material Design 3 (layout, motion, components).
  - WCAG 2.1 AA accessibility (contrast, size, readability).
  - Platform guidelines for safe areas and hit targets.

Scope for this plan: **carpenter role only** (not admin).

---

### 2. Design Standards & Principles

#### 2.1 Visual & Interaction Standards

- **Material Design 3 alignment**
  - Use a clear hierarchy of surfaces:
    - `scaffoldBackground` (light neutral).
    - `card` surfaces slightly darker than background.
    - AppBar and bottom navigation as distinct but subtle surfaces.
  - Use elevation and/or borders for separation instead of heavy lines.
  - Respect the 8dp grid for spacing and component placement where practical.

- **Accessibility (WCAG 2.1 AA)**
  - Text contrast ratio:
    - Body text vs. background ≥ 4.5:1.
    - Large text (≥ 18pt regular or 14pt bold) vs. background ≥ 3:1.
  - Text sizes:
    - Body text ≥ 14sp.
    - Labels and secondary text ≥ 12sp, used sparingly.
  - Ensure all actionable elements have:
    - Minimum touch target 48×48dp.
    - Clear focus / pressed / disabled states.

- **Safe Areas & Device Variants**
  - All primary content must be within top and bottom safe areas:
    - `SafeArea(top: true)` wrapping the body.
    - `SafeArea(bottom: true)` or explicit bottom padding for bottom navigation and fixed buttons.
  - Verify layouts on:
    - Notched/rounded devices.
    - Small width devices.
    - Large height devices.

#### 2.2 Component & Layout System

- **Color & Theme via `DesignToken`**
  - Use existing design tokens consistently:
    - Primary, secondary, success, warning, error, neutrals.
  - All screen backgrounds and cards use design tokens; no raw hex literals in widgets.

- **Typography**
  - Define and reuse a small set of text styles:
    - `Title` – page titles / main headers.
    - `Subtitle` – section titles and key labels.
    - `Body` – primary descriptive text.
    - `Caption` – timestamps and minor annotations.
  - Map these to a combination of Nunito weights and sizes defined in a central typography config.

- **Spacing & Layout**
  - Establish a spacing scale (e.g. 4, 8, 12, 16, 24, 32).
  - Use consistent horizontal padding (typically 16dp from screen edges).
  - Cards/panels use uniform internal padding (typically 16dp) and spacing between elements.

- **Buttons**
  - **Primary button**:
    - Full-width where appropriate.
    - Height ~48–52dp.
    - Background: `DesignToken.primary`, text: white.
  - **Secondary / text button**:
    - For less critical or contextual actions.
    - Clear visual distinction from primary.

#### 2.3 Light & Dark Theme Support

- **Dual theme definitions**
  - Define `lightTheme` and `darkTheme` `ThemeData` in a central `theme.dart` (or equivalent).
  - Configure `MaterialApp` with:
    - `theme: lightTheme`
    - `darkTheme: darkTheme`
    - `themeMode: ThemeMode.system` (or user-controlled later).

- **DesignToken pairing**
  - Extend `DesignToken` to have light/dark pairs where needed, e.g.:
    - `backgroundLight` / `backgroundDark`
    - `cardLight` / `cardDark`
    - `textPrimaryLight` / `textPrimaryDark`
    - `textSecondaryLight` / `textSecondaryDark`
    - `borderLight` / `borderDark`
  - Primary/status colors (success, warning, error) may be shared but must be checked for contrast on both light and dark surfaces.

- **Usage guidelines**
  - Screens and widgets must rely on:
    - `Theme.of(context).colorScheme` and
    - `DesignToken` abstractions
    rather than raw `Colors.*` values.
  - Remove or refactor hard-coded colors in UI components, especially:
    - Backgrounds for Scaffold, cards, app bars, bottom bar.
    - Text and icon colors.
    - Snackbars, dialogs, and input fields.

- **Dark mode specifics**
  - Use **dark neutral** backgrounds (not pure black) for primary surfaces.
  - Ensure:
    - Text and icons meet WCAG contrast requirements.
    - Status chips and accent elements remain readable over dark surfaces.
  - Verify all carpenter screens in both light and dark modes on real devices/emulators.

---

### 3. Navigation & Shell (Carpenter Experience)

#### 3.1 Common Scaffold

- All carpenter-facing root screens (Dashboard, Notifications, Daily Spin, Profile, Wallet, Add Bill entry points) share a **common scaffold**:
  - `Scaffold` with:
    - `SafeArea(top: true, bottom: false)` around body.
    - A shared bottom navigation component wrapped with `SafeArea(bottom: true)` or equivalent padding.
  - The app bar and bottom navigation bar are consistent across all tabs.

#### 3.2 App Bar

- Height ~56–64dp, identical across screens.
- Layout:
  - Left: back arrow on secondary pages; app icon or title on root pages.
  - Center: page title.
  - Right: context actions (e.g. notifications icon, settings) as needed.
- Visual behavior:
  - No per-screen random app bar heights.
  - Use light surface color with subtle shadow or bottom divider.

#### 3.3 Bottom Navigation Bar

- Applies to all carpenter tabs (e.g. Home, Spin, Wallet, Notifications, Profile).
- Requirements:
  - Height ~72dp to ensure comfortable tap targets.
  - Each item:
    - Icon (24dp) and label (12–14sp), stacked.
    - Minimum tap area 48×48dp.
  - Active state:
    - Icon and label in `DesignToken.primary`.
    - Optional pill/underline indicator.
  - Inactive state:
    - Neutral text/icon (e.g. `DesignToken.textMuted`).
  - Placed **above** the bottom gesture area via SafeArea or padding.

---

### 4. Screen-by-Screen Design Plan (Carpenter Role)

#### 4.1 Splash (`SplashPage`)

- **Goal**: Clean, branded entry screen.
- Layout:
  - Centered logo + app name and short tagline.
  - Progress indicator near bottom.
- Visual:
  - Light background with primary accent in logo or text.
  - No clutter; keep it minimal.

#### 4.2 Auth Flow

Screens:
- `LoginPage`, `PINLoginPage`, `PINSetupPage`, `ResetPINPage`.

Design guidelines:
- Consistent **auth layout pattern**:
  - Top: logo/app name and brief description.
  - Middle: form (phone / PIN / confirmation).
  - Bottom: primary CTA and supporting links (e.g. “Forgot PIN?”).
- Inputs:
  - Use a single, shared `InputDecoration` style across all forms.
  - Real-time validation where possible; errors shown directly below fields.
- Buttons:
  - One clear primary button per screen.
  - Secondary actions as text buttons with reduced emphasis.

#### 4.3 Dashboard (`DashboardPage`)

- **Goal**: At-a-glance overview and quick access to core actions.
- Layout:
  - Top **summary card**:
    - Greeting (first name).
    - Tier badge (Bronze/Silver/Gold).
    - Total points (large number).
  - Primary action:
    - “Add Bill” prominent near top of content.
  - Sections:
    - Recent bills / activity list.
    - Optional offers/featured promotions.
- Visual:
  - Use a slightly elevated card for the summary area.
  - Use standard card style for lists with status chips and timestamps.

#### 4.4 Add Bill (`AddBillPage`)

- **Goal**: Simple, guided flow to upload a bill and its details.
- Structure:
  1. Bill image:
     - Card with placeholder “Upload bill image”.
     - Tap to show bottom sheet: “Choose from Gallery” / “Take Photo”.
  2. Details:
     - Amount (required).
     - Date (required or default to today).
     - Store name (optional).
     - Bill number (optional), clearly marked.
  3. Notes (optional).
- Behavior:
  - Inline field validation with clear error states.
  - Loading state during upload; disable button to prevent duplicates.
- Primary action:
  - “Submit bill” button pinned near bottom with safe-area padding.

#### 4.5 Daily Spin (`DailySpinPage`)

- **Goal**: Engaging but focused experience for daily rewards.
- Layout:
  - Header with title and short explanation.
  - Central spin component (wheel or card) in a card container.
  - Large “Spin now” button.
  - Optional history list for recent results.
- Visual:
  - Maintain light background with primary as accent, not as full background.
  - Provide animated feedback for spin result (e.g. points earned card, subtle motion).

#### 4.6 Notifications (`NotificationsPage`)

- **Goal**: Clear, readable list of important events.
- Layout:
  - AppBar: “Notifications”.
  - List of notification cards:
    - Icon representing type (bill approved, bill rejected, offer, spin, tier).
    - Title, short body, timestamp.
    - Unread state indicator (bold title or colored dot).
- Interaction:
  - Tap to open related screen (bills, offers, wallet, etc.), using existing deep-link routes.
  - Optional “Mark all as read” action.

#### 4.7 Notification Settings (`NotificationSettingsPage`)

- **Goal**: Easy control over what the carpenter is notified about.
- Layout:
  - Group switches by category:
    - General.
    - Bills (approved/rejected).
    - Offers/promotions.
    - Daily Spin.
  - Each row has:
    - Title.
    - One-line description.
    - Trailing switch.
- Visual:
  - Light list with clear section headers.
  - Match spacing and card/list treatment from other screens.

#### 4.8 Profile & Edit Profile (`ProfilePage`, `EditProfilePage`)

- ProfilePage:
  - Top card:
    - Avatar.
    - Name and phone.
    - Tier and points summary.
  - Action list:
    - Edit profile.
    - Notification settings.
    - Wallet / history.
    - Logout.
- EditProfilePage:
  - Avatar with edit icon overlay; tap opens image picker (gallery).
  - Name fields and any additional profile fields with consistent input styling.
  - Primary “Save changes” button anchored at bottom with safe-area padding.
  - Clear success/failure feedback.

#### 4.9 Wallet / History / Redeem (if exposed to carpenter)

- Wallet:
  - Summary card with current points (and optional currency equivalent).
  - Filter or tabs for earned/redeemed/pending.
- History:
  - Use standard card layout for each entry:
    - Type icon, title, points, timestamp.
- Redeem/offers:
  - Offer cards with image, title, points required, and brief description.
  - Disabled state when user has insufficient points.

---

### 5. Implementation Roadmap (Carpenter Role)

1. **Shared Shell & Navigation**
   - Implement common scaffold, safe-area use, and bottom navigation component.
   - Normalize AppBar style across carpenter root screens.
2. **Design System Enforcement**
   - Centralize typography and card components.
   - Replace ad-hoc styling with `DesignToken`-backed components.
3. **High-Impact Screens**
   - Update Dashboard, Add Bill, Daily Spin, Notifications to new layout and components.
4. **Secondary Screens**
   - Update Profile, Edit Profile, Notification Settings, Wallet/History/Redeem.
5. **Accessibility & QA**
   - Check color contrast and text sizes.
   - Confirm tap target sizes and safe-area behavior on a range of devices.

This document should guide all design work on the `design-update` branch for carpenter-facing screens, ensuring consistency with international design standards while respecting the existing `DesignToken` theme.

