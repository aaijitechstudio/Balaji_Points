# PIN Reset Security Fix Plan

## 🔴 Security Issue Identified

**Problem**: Users can reset PIN for ANY phone number without verification

- The `resetPin()` method in `pin_auth_service.dart` accepts any phone number
- No ownership verification is performed
- Anyone can reset another user's PIN by entering their phone number

**Current Flow**:

1. User enters any phone number
2. System checks if phone exists (but doesn't verify ownership)
3. User can reset PIN without any authentication

## ✅ Solution Options (Without OTP)

### Option 1: Session + Current PIN Verification (Recommended)

**Approach**: Only allow PIN reset for logged-in users with current PIN verification

- Check if user is logged in via `SessionService`
- Verify the phone number matches the logged-in user's phone
- Require current PIN verification before allowing reset
- **Pros**: Simple, secure, no additional infrastructure needed
- **Cons**: User must be logged in (knows current PIN) to reset

### Option 2: Admin-Only Reset for Non-Logged-In Users

**Approach**: Disable PIN reset for non-logged-in users

- Regular users can only reset their own PIN when logged in
- If user forgot PIN and can't log in, they must contact admin
- Admins can reset any user's PIN from admin panel
- **Pros**: Most secure, prevents unauthorized resets
- **Cons**: Users who forgot PIN need admin help

### Option 3: Security Questions (Not Recommended)

**Approach**: Use security questions for verification

- **Pros**: Works without OTP
- **Cons**: Not implemented in app, requires additional setup

## 🎯 Recommended Implementation: Session + Current PIN Verification

**Final Approach (No OTP Required)**:

1. **For Logged-In Users**:

   - Verify phone number matches logged-in user's phone (from session)
   - Require current PIN verification before allowing reset
   - If current PIN is correct, allow new PIN setup
   - **This works for users who want to change their PIN**

2. **For Non-Logged-In Users** (Forgot PIN scenario):

   - **Disable PIN reset** - Show message to contact admin
   - Admins can reset PINs from admin panel
   - **This prevents unauthorized PIN resets**

3. **For Admins**:
   - Admins can reset PINs from admin panel (already secure via admin check)
   - Admin reset doesn't require current PIN (admin privilege)

## 📋 Implementation Steps

### Step 1: Update `resetPin()` method

- Add phone number verification against logged-in user
- Add current PIN verification parameter
- Add admin override parameter

### Step 2: Update `reset_pin_page.dart`

- Check if user is logged in
- If logged in: Verify phone matches session + require current PIN
- If not logged in: Require OTP verification (or disable feature)

### Step 3: Add OTP verification (if needed)

- Re-enable OTP service for PIN reset flow only
- Or implement alternative verification method

### Step 4: Update Firestore Rules

- Ensure PIN reset operations are properly secured
- Add validation rules if needed

## 🔒 Security Checks to Implement

1. ✅ Verify phone number matches logged-in user (if logged in)
2. ✅ Verify current PIN before allowing reset (if logged in)
3. ✅ Verify OTP before allowing reset (if not logged in)
4. ✅ Admin verification for admin-initiated resets
5. ✅ Rate limiting to prevent brute force attacks
6. ✅ Log all PIN reset attempts for audit

## 📝 Files to Modify

1. `lib/services/pin_auth_service.dart` - Add verification to `resetPin()`
2. `lib/presentation/screens/auth/reset_pin_page.dart` - Add verification flow
3. `lib/services/session_service.dart` - Already has session methods
4. `lib/services/phone_auth_service.dart` - May need to re-enable OTP for reset

## ⚠️ Breaking Changes

- Users who forgot their PIN and are not logged in will need admin help or OTP
- PIN reset flow will be more secure but slightly more complex
