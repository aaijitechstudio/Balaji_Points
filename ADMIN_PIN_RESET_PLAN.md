# Admin PIN Reset Feature - Implementation Plan

## Overview

Allow admin users to set/reset PINs for any carpenter when they forget their PIN. This bypasses the security checks required for regular users (current PIN verification, phone matching).

## Requirements

### Functional Requirements

1. **Admin-only access**: Only users with `role == 'admin'` can reset PINs for other users
2. **UI Location**: Add "Reset PIN" button in the `UserDetailsDialog` (admin panel)
3. **PIN Input**: Admin enters a new 4-digit PIN for the carpenter
4. **Confirmation**: Show confirmation dialog before resetting
5. **Success/Error Feedback**: Show appropriate messages after operation
6. **Security**: Verify admin status before allowing PIN reset

### Technical Requirements

1. Update `PinAuthService.resetPin()` to properly handle admin override
2. Add admin verification in the service layer
3. Create PIN reset dialog component for admin
4. Add localization strings for admin PIN reset
5. Ensure proper error handling and logging

## Implementation Steps

### Step 1: Update PinAuthService.resetPin() Method

**File**: `lib/services/pin_auth_service.dart`

**Current State**: The method has `isAdmin` parameter but logic is incomplete.

**Changes Needed**:

- Accept `isAdmin` parameter (default: false)
- When `isAdmin == true`:
  - Skip phone ownership verification
  - Skip current PIN verification
  - Allow resetting PIN for any user
- Add admin verification check (verify calling user is actually admin)
- Log admin PIN reset operations for audit trail

**Method Signature**:

```dart
Future<bool> resetPin({
  required String phone,
  required String newPin,
  String? loggedInPhone,
  String? currentPin,
  bool isAdmin = false,
}) async
```

**Security Checks**:

1. If `isAdmin == true`, verify the calling user is actually an admin (using `UserService.isAdmin()`)
2. If admin verification fails, deny the operation
3. Log all admin PIN reset attempts (success and failure)

### Step 2: Create Admin PIN Reset Dialog

**File**: `lib/presentation/widgets/admin/users_list.dart`

**New Component**: `AdminResetPINDialog`

**Features**:

- Input field for new 4-digit PIN
- Confirm PIN field
- Validation (4 digits, numeric only, must match)
- Loading state during operation
- Success/error feedback
- Close button

**UI Design**:

- Modal dialog
- Title: "Reset PIN for [Carpenter Name]"
- Phone number display (read-only)
- Two PIN input fields (New PIN, Confirm PIN)
- Reset button (disabled during loading)
- Cancel button

### Step 3: Add Reset PIN Button to UserDetailsDialog

**File**: `lib/presentation/widgets/admin/users_list.dart`

**Location**: Add button before the "Danger Zone" section

**Button Design**:

- Icon: `Icons.lock_reset` or `Icons.vpn_key`
- Text: "Reset PIN"
- Color: Primary color (blue)
- Style: Outlined or filled button

**Flow**:

1. User clicks "Reset PIN" button
2. Show `AdminResetPINDialog`
3. Admin enters new PIN
4. On confirm, call `PinAuthService.resetPin()` with `isAdmin: true`
5. Show success/error message
6. Close dialog on success

### Step 4: Add Localization Strings

**File**: `lib/l10n/app_en.arb`

**New Strings**:

```json
"adminResetPin": "Reset PIN",
"adminResetPinTitle": "Reset PIN for {carpenterName}",
"@adminResetPinTitle": {
  "placeholders": {
    "carpenterName": {
      "type": "String"
    }
  }
},
"adminResetPinSubtitle": "Enter a new 4-digit PIN for this carpenter.",
"adminResetPinConfirm": "Are you sure you want to reset the PIN for {carpenterName}?",
"@adminResetPinConfirm": {
  "placeholders": {
    "carpenterName": {
      "type": "String"
    }
  }
},
"adminResetPinSuccess": "PIN reset successfully for {carpenterName}",
"@adminResetPinSuccess": {
  "placeholders": {
    "carpenterName": {
      "type": "String"
    }
  }
},
"adminResetPinFailed": "Failed to reset PIN. Please try again.",
"adminNotAuthorized": "You are not authorized to perform this action.",
"enterNewPinForCarpenter": "Enter new 4-digit PIN",
"confirmNewPinForCarpenter": "Confirm new 4-digit PIN",
```

### Step 5: Update PinAuthService with Admin Verification

**File**: `lib/services/pin_auth_service.dart`

**Changes**:

1. Import `UserService` for admin verification
2. In `resetPin()`, when `isAdmin == true`:
   - Verify calling user is admin using `UserService.isAdmin()`
   - If not admin, log warning and return false
   - If admin, proceed with PIN reset (skip security checks)
3. Add detailed logging for admin operations

**Code Structure**:

```dart
Future<bool> resetPin({
  required String phone,
  required String newPin,
  String? loggedInPhone,
  String? currentPin,
  bool isAdmin = false,
}) async {
  try {
    // ... existing phone normalization ...

    // Admin verification
    if (isAdmin) {
      final userService = UserService();
      final isActuallyAdmin = await userService.isAdmin();
      if (!isActuallyAdmin) {
        AppLogger.warning('PIN reset denied: User is not admin');
        return false;
      }
      // Admin can reset any user's PIN - skip security checks
      AppLogger.info('Admin PIN reset for phone $normalized');
    } else {
      // Regular user reset - apply security checks
      // ... existing security checks ...
    }

    // Proceed with PIN reset
    // ... existing reset logic ...
  } catch (e, st) {
    // ... error handling ...
  }
}
```

### Step 6: Error Handling

**Scenarios to Handle**:

1. Admin verification fails → Show "Not authorized" message
2. User not found → Show "User not found" message
3. Network error → Show "Network error" message
4. Invalid PIN format → Show validation error
5. PIN mismatch → Show "PINs do not match" message

### Step 7: Testing Checklist

- [ ] Admin can reset PIN for any carpenter
- [ ] Non-admin users cannot access admin PIN reset
- [ ] PIN validation works (4 digits, numeric)
- [ ] Confirmation PIN must match new PIN
- [ ] Success message shows after successful reset
- [ ] Error messages show for failures
- [ ] Dialog closes after successful reset
- [ ] Logging works for audit trail
- [ ] Phone number is displayed correctly
- [ ] Carpenter name is displayed correctly

## Security Considerations

1. **Admin Verification**: Always verify admin status server-side (in service layer)
2. **Audit Logging**: Log all admin PIN reset operations with:
   - Admin phone number
   - Target user phone number
   - Timestamp
   - Success/failure status
3. **Input Validation**: Validate PIN format (4 digits, numeric only)
4. **Error Messages**: Don't reveal sensitive information in error messages
5. **Rate Limiting**: Consider rate limiting for PIN reset operations (future enhancement)

## UI/UX Considerations

1. **Clear Labeling**: Make it clear this is an admin-only action
2. **Confirmation**: Require confirmation before resetting PIN
3. **Feedback**: Show clear success/error messages
4. **Loading State**: Show loading indicator during operation
5. **Accessibility**: Ensure dialog is keyboard accessible

## Files to Modify

1. `lib/services/pin_auth_service.dart` - Update `resetPin()` method
2. `lib/presentation/widgets/admin/users_list.dart` - Add dialog and button
3. `lib/l10n/app_en.arb` - Add localization strings
4. `lib/l10n/app_ta.arb` - Add Tamil translations (if needed)
5. `lib/l10n/app_hi.arb` - Add Hindi translations (if needed)

## Future Enhancements

1. **PIN History**: Track PIN reset history for audit purposes
2. **Temporary PIN**: Generate temporary PIN that expires after first use
3. **Email Notification**: Notify carpenter when PIN is reset by admin
4. **Bulk PIN Reset**: Allow resetting PINs for multiple carpenters at once
5. **PIN Strength**: Enforce stronger PIN requirements (future)

## Implementation Order

1. ✅ Update `PinAuthService.resetPin()` with admin verification
2. ✅ Add localization strings
3. ✅ Create `AdminResetPINDialog` component
4. ✅ Add "Reset PIN" button to `UserDetailsDialog`
5. ✅ Test all scenarios
6. ✅ Update documentation
