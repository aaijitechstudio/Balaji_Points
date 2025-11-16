# Phone Authentication Setup Guide

## Overview

This guide explains how to set up Phone Number Authentication with OTP verification in Firebase for the Balaji Points app.

---

## Step 1: Enable Phone Authentication in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **balajipoints**
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Phone** provider
5. Click **Enable** toggle
6. Click **Save**

---

## Step 2: Configure Phone Authentication (Optional - for production)

### For Testing (Development):

- Use **Test phone numbers** in Firebase Console
- Go to **Authentication** → **Sign-in method** → **Phone** → **Phone numbers for testing**
- Add test phone numbers with test OTP codes (e.g., `+919876543210` with code `123456`)

### For Production:

1. **App Verification:**

   - iOS: Add reCAPTCHA Enterprise (automatic with Firebase SDK)
   - Android: Add SHA-1/SHA-256 fingerprints in Firebase Console

2. **Android SHA Fingerprint:**

   ```bash
   # Get SHA-1
   cd android
   ./gradlew signingReport
   # Copy SHA-1 and SHA-256 from output
   ```

3. **Add SHA to Firebase:**
   - Go to Project Settings → Your Android App
   - Add SHA-1 and SHA-256 fingerprints

---

## Step 3: iOS Configuration

### Add Capabilities:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target
3. Go to **Signing & Capabilities**
4. Add **Push Notifications** capability (if not already added)

### Update Info.plist:

Add phone authentication support:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

---

## Step 4: Android Configuration

### Update AndroidManifest.xml:

Ensure internet permission is present:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### Update build.gradle:

Ensure minimum SDK version is 21+:

```gradle
minSdkVersion 21
```

---

## Step 5: Test Phone Authentication Flow

### Test Flow:

1. User enters phone number (10 digits, e.g., `9876543210`)
2. App sends OTP via Firebase
3. User receives SMS with 6-digit code
4. User enters OTP code
5. Firebase verifies code
6. User is authenticated

### Test Phone Numbers:

Use Firebase Console test numbers or real phone numbers (requires SMS charges).

---

## Step 6: Authentication Flow in App

### Signup Flow:

1. User fills signup form → Creates document in `pending_users` collection
2. Status: `pending` → Waiting for admin approval

### Login Flow:

1. User enters phone number → Checks if user exists in `users` collection with `status: verified`
2. If verified → Send OTP → Verify OTP → Login
3. If not verified → Show message "Account pending approval"

### Admin Approval Flow:

1. Admin reviews `pending_users` collection
2. Admin approves user → Creates document in `users` collection
3. User can now login with phone + OTP

---

## Step 7: Verification After OTP Login

When user successfully verifies OTP:

1. Firebase Auth creates user with phone number
2. App checks if user exists in `users` collection
3. If not exists → Creates user from `pending_users` data
4. User is logged in and navigated to home

---

## Troubleshooting

### Issue: "Invalid phone number format"

- **Solution**: Ensure phone number includes country code (+91 for India)

### Issue: "SMS not received"

- **Solution**:
  - Check phone number format
  - Use test phone numbers during development
  - Check Firebase quota limits

### Issue: "Too many requests"

- **Solution**: Implement rate limiting or wait before retrying

### Issue: "Verification failed"

- **Solution**:
  - Check Firebase Authentication is enabled
  - Verify SHA fingerprints for Android
  - Check network connectivity

---

## Security Considerations

1. **Rate Limiting**: Implement client-side rate limiting for OTP requests
2. **ReCAPTCHA**: Automatically handled by Firebase SDK
3. **Phone Verification**: Only verified users can login
4. **Firestore Rules**: Ensure proper security rules for user data

---

## Next Steps

1. Implement admin panel for user approval
2. Add push notifications for approval status
3. Add phone number update functionality
4. Implement account recovery flow
