# Android Back Button Implementation Plan

## Balaji Points App

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Screen Categories](#screen-categories)
3. [Implementation Strategy](#implementation-strategy)
4. [Screen-by-Screen Plan](#screen-by-screen-plan)
5. [Special Cases](#special-cases)
6. [Technical Implementation Details](#technical-implementation-details)

---

## 🎯 Overview

### Current Navigation Structure

- **Router**: GoRouter (declarative routing)
- **Main Entry**: Splash → Login → PIN Auth → Dashboard
- **Dashboard**: Bottom Navigation (Home, Wallet, Profile)
- **Admin Panel**: Tab-based navigation

### Back Button Behavior Requirements

1. **Prevent accidental exits** from critical screens
2. **Handle dialogs/modals** properly
3. **Manage nested navigation** (Dashboard tabs, Admin tabs)
4. **Confirm destructive actions** before allowing back
5. **Maintain user data** during form navigation

---

## 📱 Screen Categories

### Category 1: Entry/Auth Screens (No Back Button)

- **SplashPage** - Auto-navigates, should not allow back
- **LoginPage** - Entry point, back should exit app (with confirmation)

### Category 2: Auth Flow Screens (Standard Back)

- **PINSetupPage** - Back to login
- **PINLoginPage** - Back to login
- **ResetPINPage** - Back to PIN login

### Category 3: Main App Screens (Dashboard Navigation)

- **DashboardPage** - Bottom nav container
  - **HomePage** - Tab 0
  - **WalletPage** - Tab 1
  - **ProfilePage** - Tab 2 (standalone or in dashboard)

### Category 4: Secondary Screens (Standard Back)

- **EditProfilePage** - Back to profile/home
- **DailySpinPage** - Back to home
- **AddBillPage** - Back to home/wallet (with unsaved changes check)

### Category 5: Admin Screens (Tab Navigation)

- **AdminHomePage** - Tab container
  - **PendingBillsList** - Tab 0
  - **OffersManagement** - Tab 1
  - **UsersList** - Tab 2
  - **DailySpinManagement** - Tab 3

---

## 🛠️ Implementation Strategy

### 1. Use WillPopScope (Flutter 2.x) or PopScope (Flutter 3.x+)

```dart
// For Flutter 3.x+
PopScope(
  canPop: false,
  onPopInvoked: (didPop) {
    if (!didPop) {
      _handleBackButton();
    }
  },
  child: Scaffold(...),
)
```

### 2. Create Back Button Handler Mixin/Utility

- Centralized logic for common scenarios
- Reusable across screens
- Consistent UX patterns

### 3. Dialog/Modal Handling

- Check if dialog is open → close dialog first
- Check if bottom sheet is open → close bottom sheet first
- Then handle screen back navigation

### 4. Form State Management

- Track unsaved changes
- Show confirmation dialog before allowing back
- Save draft state if needed

---

## 📄 Screen-by-Screen Plan

### 1. SplashPage (`/splash`)

**Current Behavior**: Auto-navigates after 3 seconds
**Back Button Plan**:

- ❌ **Disable back button** - Prevent user from skipping splash
- If back pressed → Show "Please wait..." snackbar
- Alternative: Allow back only after navigation completes

**Implementation**:

```dart
PopScope(
  canPop: false, // Always prevent back
  child: Scaffold(...),
)
```

---

### 2. LoginPage (`/login`)

**Current Behavior**: Entry point for authentication
**Back Button Plan**:

- ✅ **Show exit confirmation** - "Do you want to exit the app?"
- If confirmed → Exit app
- If cancelled → Stay on login

**Implementation**:

```dart
PopScope(
  canPop: false,
  onPopInvoked: (didPop) async {
    if (!didPop) {
      final shouldExit = await _showExitConfirmation();
      if (shouldExit == true && mounted) {
        // Exit app
        SystemNavigator.pop();
      }
    }
  },
)
```

---

### 3. PINSetupPage (`/pin-setup`)

**Current Behavior**: Has AppBar with BackButton
**Back Button Plan**:

- ✅ **Standard back navigation** - Go back to login
- ⚠️ **Check for unsaved form data** - If PIN fields have input, show confirmation
- If form has data → "Discard changes?" dialog
- If form empty → Direct back to login

**Implementation**:

```dart
PopScope(
  canPop: _canPop(),
  onPopInvoked: (didPop) async {
    if (!didPop) {
      if (_hasFormData()) {
        final shouldDiscard = await _showDiscardDialog();
        if (shouldDiscard == true && mounted) {
          context.pop();
        }
      } else {
        context.pop();
      }
    }
  },
)
```

---

### 4. PINLoginPage (`/pin-login`)

**Current Behavior**: Has AppBar with BackButton
**Back Button Plan**:

- ✅ **Standard back navigation** - Go back to login
- No form data to preserve (PIN is sensitive, don't save)

**Implementation**:

```dart
PopScope(
  canPop: true, // Allow direct back
  child: Scaffold(...),
)
```

---

### 5. ResetPINPage (`/pin-reset`)

**Current Behavior**: Multi-step form (phone check → PIN reset)
**Back Button Plan**:

- ✅ **Smart back navigation** based on step:
  - If on PIN entry step → Go back to phone verification step
  - If on phone verification step → Go back to PIN login
- ⚠️ **Check for unsaved form data** - Show confirmation if PIN fields have input

**Implementation**:

```dart
PopScope(
  canPop: false,
  onPopInvoked: (didPop) async {
    if (!didPop) {
      if (_phoneChecked && _hasPinData()) {
        // On PIN entry step - ask to discard
        final shouldDiscard = await _showDiscardDialog();
        if (shouldDiscard == true && mounted) {
          setState(() {
            _phoneChecked = false;
            _pinController.clear();
            _confirmPinController.clear();
          });
        }
      } else {
        // On phone step - go back to PIN login
        context.pop();
      }
    }
  },
)
```

---

### 6. DashboardPage (`/`)

**Current Behavior**: Bottom navigation with 3 tabs
**Back Button Plan**:

- ✅ **Double-tap to exit** - First back press shows "Press back again to exit"
- ⏱️ **2-second window** - If second back press within 2 seconds → Exit app
- If timeout → Reset counter

**Implementation**:

```dart
DateTime? _lastBackPress;

PopScope(
  canPop: false,
  onPopInvoked: (didPop) async {
    if (!didPop) {
      final now = DateTime.now();
      if (_lastBackPress == null ||
          now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
        _lastBackPress = now;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Exit app
        SystemNavigator.pop();
      }
    }
  },
)
```

---

### 7. HomePage (Tab 0 in Dashboard)

**Current Behavior**: Shows offers, top carpenters, user profile
**Back Button Plan**:

- ✅ **Handled by DashboardPage** - Back button goes to Dashboard handler
- No special handling needed (parent handles it)

**Implementation**:

- No PopScope needed (parent DashboardPage handles)

---

### 8. WalletPage (Tab 1 in Dashboard)

**Current Behavior**: Shows wallet balance, transactions
**Back Button Plan**:

- ✅ **Handled by DashboardPage** - Back button goes to Dashboard handler
- No special handling needed

**Implementation**:

- No PopScope needed (parent DashboardPage handles)

---

### 9. ProfilePage (`/profile` or Tab 2)

**Current Behavior**: Can be standalone route or dashboard tab
**Back Button Plan**:

- **If in Dashboard** → Handled by DashboardPage
- **If standalone route** → Back to home/dashboard
- ✅ **Standard navigation** - No special handling

**Implementation**:

```dart
// Only if standalone
if (widget.showBottomNav == false) {
  PopScope(
    canPop: true,
    child: Scaffold(...),
  )
}
```

---

### 10. EditProfilePage (`/edit-profile`)

**Current Behavior**: Form with image picker, text fields
**Back Button Plan**:

- ⚠️ **Check for unsaved changes** - Compare current form state with saved data
- If changes detected → Show "Discard changes?" dialog
- If no changes → Direct back
- ⚠️ **Special case**: `isFirstTime=true` → Prevent back (force completion)

**Implementation**:

```dart
PopScope(
  canPop: !widget.isFirstTime && !_hasUnsavedChanges(),
  onPopInvoked: (didPop) async {
    if (!didPop) {
      if (widget.isFirstTime) {
        // Prevent back on first-time setup
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please complete your profile')),
        );
      } else if (_hasUnsavedChanges()) {
        final shouldDiscard = await _showDiscardDialog();
        if (shouldDiscard == true && mounted) {
          context.pop();
        }
      } else {
        context.pop();
      }
    }
  },
)
```

---

### 11. DailySpinPage (`/daily-spin`)

**Current Behavior**: Spin wheel with animation
**Back Button Plan**:

- ⚠️ **Check if spinning** - If animation in progress, prevent back
- If spinning → Show "Please wait..." message
- If not spinning → Standard back to home

**Implementation**:

```dart
PopScope(
  canPop: !_isSpinning,
  onPopInvoked: (didPop) async {
    if (!didPop) {
      if (_isSpinning) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please wait for spin to complete')),
        );
      } else {
        context.pop();
      }
    }
  },
)
```

---

### 12. AddBillPage (`/add-bill`)

**Current Behavior**: Form with image picker, date picker, multiple fields
**Back Button Plan**:

- ⚠️ **Check for unsaved form data** - Any field filled?
- If form has data → Show "Discard bill?" confirmation
- If form empty → Direct back
- ⚠️ **Check for image** - If image selected, include in confirmation message

**Implementation**:

```dart
PopScope(
  canPop: !_hasFormData(),
  onPopInvoked: (didPop) async {
    if (!didPop) {
      if (_hasFormData()) {
        final shouldDiscard = await _showDiscardBillDialog();
        if (shouldDiscard == true && mounted) {
          context.pop();
        }
      } else {
        context.pop();
      }
    }
  },
)
```

---

### 13. AdminHomePage (`/admin`)

**Current Behavior**: Tab controller with 4 tabs
**Back Button Plan**:

- ✅ **Double-tap to exit** - Same as DashboardPage
- ⚠️ **Check for unsaved changes in active tab**:
  - PendingBillsList → Check if any bill is being edited
  - OffersManagement → Check if offer form is open
  - UsersList → Check if user details dialog is open
  - DailySpinManagement → Check if settings are being edited

**Implementation**:

```dart
DateTime? _lastBackPress;

PopScope(
  canPop: false,
  onPopInvoked: (didPop) async {
    if (!didPop) {
      // Check if any tab has unsaved changes
      if (_hasActiveChanges()) {
        final shouldDiscard = await _showDiscardDialog();
        if (shouldDiscard != true) return;
      }

      // Double-tap to exit
      final now = DateTime.now();
      if (_lastBackPress == null ||
          now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
        _lastBackPress = now;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Press back again to exit')),
        );
      } else {
        SystemNavigator.pop();
      }
    }
  },
)
```

---

## 🎭 Special Cases

### Case 1: Dialogs and Modals

**Problem**: Back button should close dialog first, not screen
**Solution**:

- Use `Navigator.of(context).canPop()` to check if dialog is open
- If dialog open → Close dialog
- If no dialog → Handle screen back

**Implementation Pattern**:

```dart
PopScope(
  canPop: false,
  onPopInvoked: (didPop) async {
    if (!didPop) {
      // Check for open dialogs
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        return;
      }

      // Check for bottom sheets
      if (Scaffold.of(context).isDrawerOpen) {
        Navigator.of(context).pop();
        return;
      }

      // Handle screen back
      _handleScreenBack();
    }
  },
)
```

---

### Case 2: Bottom Sheets

**Problem**: Back button should close bottom sheet first
**Solution**:

- Check `Scaffold.of(context).isDrawerOpen` or track bottom sheet state
- Close bottom sheet before handling screen back

---

### Case 3: Image Picker

**Problem**: Image picker opens system UI, back button behavior unclear
**Solution**:

- Image picker handles its own back button
- No special handling needed in app code

---

### Case 4: Form Validation Errors

**Problem**: Should back button work when form has validation errors?
**Solution**:

- ✅ **Allow back** - User can navigate away even with errors
- Show discard confirmation if form has any input

---

### Case 5: Loading States

**Problem**: Should back button work during API calls?
**Solution**:

- ⚠️ **Prevent back during critical operations**:
  - PIN creation/reset
  - Bill submission
  - Profile save
- ✅ **Allow back during non-critical loading**:
  - Data fetching
  - Image upload (can cancel)

---

### Case 6: Nested Navigation

**Problem**: Dashboard tabs + Admin tabs - how to handle back?
**Solution**:

- **Dashboard tabs**: Back handled by DashboardPage (double-tap exit)
- **Admin tabs**: Back handled by AdminHomePage (double-tap exit)
- Tabs themselves don't handle back (parent handles)

---

## 🔧 Technical Implementation Details

### 1. Create Back Button Handler Utility

**File**: `lib/core/utils/back_button_handler.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackButtonHandler {
  // Show exit confirmation dialog
  static Future<bool?> showExitConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App?'),
        content: Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }

  // Show discard changes dialog
  static Future<bool?> showDiscardDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Discard Changes?'),
        content: Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Discard'),
          ),
        ],
      ),
    );
  }

  // Exit app
  static void exitApp() {
    SystemNavigator.pop();
  }
}
```

---

### 2. Create Reusable PopScope Wrapper

**File**: `lib/presentation/widgets/back_button_wrapper.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/back_button_handler.dart';

class BackButtonWrapper extends StatelessWidget {
  final Widget child;
  final bool canPop;
  final VoidCallback? onBack;
  final bool showDiscardDialog;
  final bool Function()? hasUnsavedChanges;
  final bool isFirstTime;
  final bool doubleTapToExit;

  const BackButtonWrapper({
    super.key,
    required this.child,
    this.canPop = true,
    this.onBack,
    this.showDiscardDialog = false,
    this.hasUnsavedChanges,
    this.isFirstTime = false,
    this.doubleTapToExit = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop && !isFirstTime,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _handleBack(context);
        }
      },
      child: child,
    );
  }

  Future<void> _handleBack(BuildContext context) async {
    // Check for dialogs first
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    // Handle custom back callback
    if (onBack != null) {
      onBack!();
      return;
    }

    // Check for unsaved changes
    if (showDiscardDialog && hasUnsavedChanges != null && hasUnsavedChanges!()) {
      final shouldDiscard = await BackButtonHandler.showDiscardDialog(context);
      if (shouldDiscard == true && context.mounted) {
        context.pop();
      }
      return;
    }

    // First-time setup prevention
    if (isFirstTime) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete your profile')),
      );
      return;
    }

    // Default: pop navigation
    if (context.mounted) {
      context.pop();
    }
  }
}
```

---

### 3. Double-Tap Exit Mixin

**File**: `lib/core/mixins/double_tap_exit_mixin.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin DoubleTapExitMixin<T extends StatefulWidget> on State<T> {
  DateTime? _lastBackPress;

  Future<bool> handleDoubleTapExit() async {
    final now = DateTime.now();

    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false; // Don't exit
    } else {
      SystemNavigator.pop(); // Exit app
      return true; // Exit
    }
  }
}
```

---

### 4. Form State Tracker Mixin

**File**: `lib/core/mixins/form_state_tracker_mixin.dart`

```dart
mixin FormStateTrackerMixin<T extends StatefulWidget> on State<T> {
  Map<String, dynamic>? _initialFormState;
  Map<String, dynamic>? _currentFormState;

  void initializeFormState(Map<String, dynamic> initialState) {
    _initialFormState = Map.from(initialState);
    _currentFormState = Map.from(initialState);
  }

  void updateFormState(String key, dynamic value) {
    _currentFormState?[key] = value;
  }

  bool hasUnsavedChanges() {
    if (_initialFormState == null || _currentFormState == null) {
      return false;
    }
    return _initialFormState.toString() != _currentFormState.toString();
  }

  void resetFormState() {
    _currentFormState = _initialFormState != null
        ? Map.from(_initialFormState!)
        : null;
  }
}
```

---

## 📝 Implementation Checklist

### Phase 1: Core Infrastructure

- [ ] Create `BackButtonHandler` utility class
- [ ] Create `BackButtonWrapper` widget
- [ ] Create `DoubleTapExitMixin`
- [ ] Create `FormStateTrackerMixin`
- [ ] Add localization strings for dialogs

### Phase 2: Entry/Auth Screens

- [ ] Implement SplashPage back button (disable)
- [ ] Implement LoginPage back button (exit confirmation)
- [ ] Implement PINSetupPage back button (discard check)
- [ ] Implement PINLoginPage back button (standard)
- [ ] Implement ResetPINPage back button (multi-step)

### Phase 3: Main App Screens

- [ ] Implement DashboardPage back button (double-tap exit)
- [ ] Implement EditProfilePage back button (unsaved changes)
- [ ] Implement DailySpinPage back button (spinning check)
- [ ] Implement AddBillPage back button (unsaved changes)

### Phase 4: Admin Screens

- [ ] Implement AdminHomePage back button (double-tap + tab checks)
- [ ] Review admin tab widgets for unsaved changes

### Phase 5: Dialog/Modal Handling

- [ ] Test dialog back button behavior
- [ ] Test bottom sheet back button behavior
- [ ] Ensure proper dialog closing before screen navigation

### Phase 6: Testing

- [ ] Test all navigation flows
- [ ] Test form discard scenarios
- [ ] Test double-tap exit
- [ ] Test with dialogs open
- [ ] Test on different Android versions

---

## 🎨 UX Considerations

### 1. Confirmation Dialogs

- **Style**: Material Design 3
- **Buttons**: "Cancel" (left) and "Discard/Exit" (right, colored)
- **Message**: Clear and concise

### 2. Snackbar Messages

- **Duration**: 2 seconds for "Press back again"
- **Style**: Consistent with app theme
- **Position**: Bottom center

### 3. Loading States

- **Prevent back** during critical operations
- **Show loading indicator** if operation is in progress
- **Allow cancellation** for non-critical operations

### 4. First-Time Setup

- **Prevent back** on mandatory setup screens
- **Show helpful message** explaining why back is disabled
- **Provide alternative** (skip option if applicable)

---

## 🔍 Edge Cases to Handle

1. **Rapid back button presses** - Debounce handling
2. **Multiple dialogs stacked** - Close in reverse order
3. **Form with file upload in progress** - Show cancel option
4. **Network request in progress** - Allow back but show warning
5. **Deep link navigation** - Handle back from deep links
6. **Tab switching during back press** - Prevent tab switch confusion

---

## 📚 References

- [Flutter PopScope Documentation](https://api.flutter.dev/flutter/widgets/PopScope-class.html)
- [GoRouter Navigation](https://pub.dev/packages/go_router)
- [Material Design Navigation Patterns](https://material.io/design/navigation/understanding-navigation.html)

---

## ✅ Next Steps

1. **Review this plan** with team
2. **Prioritize screens** for implementation
3. **Create utility classes** first
4. **Implement screen by screen** with testing
5. **Gather user feedback** on back button behavior

---

**Document Version**: 1.0
**Last Updated**: 2025-01-21
**Author**: Development Team
