# 📱 iOS Push Notification Testing Guide

## Prerequisites

1. **iOS Device** (not simulator - push notifications don't work on simulator)
2. **Apple Developer Account** with proper certificates
3. **APNs Certificate/Key** configured in Firebase Console
4. **App installed on physical device** via Xcode or TestFlight

## Step 1: Verify iOS Configuration

### 1.1 Check Info.plist

✅ Already configured:

- `UIBackgroundModes` includes `remote-notification`
- Camera and Photo Library permissions set

### 1.2 Check AppDelegate.swift

✅ Already configured:

- Basic setup is correct

### 1.3 Verify APNs in Firebase Console

1. Go to **Firebase Console** → **Project Settings** → **Cloud Messaging**
2. Under **Apple app configuration**, verify:
   - APNs Authentication Key is uploaded, OR
   - APNs Certificates are uploaded
3. If missing, upload your APNs key/certificate

## Step 2: Check Notification Permissions

### 2.1 First Launch

When app launches for the first time:

- iOS will show permission dialog
- User must tap **"Allow"** for notifications to work

### 2.2 Check Permission Status

1. Open app
2. Check console logs for:
   ```
   ✅ Notification permissions granted
   ✅ iOS foreground notification presentation options set
   ```

### 2.3 If Permissions Denied

1. Go to **Settings** → **Balaji Points** → **Notifications**
2. Enable **Allow Notifications**
3. Enable **Sounds** and **Badges**

## Step 3: Verify FCM Token

### 3.1 Check Token Registration

1. Open app and login
2. Check console logs for:
   ```
   FCM Token obtained: ...
   ✅ FCM token saved to Firestore for user: ...
   ```

### 3.2 Verify Token in Firestore

1. Go to **Firebase Console** → **Firestore Database**
2. Navigate to `users/{userId}`
3. Check that `fcmToken` field exists and has a value
4. Check `platform` field should be `ios`

## Step 4: Test Notification Sending

### 4.1 Test via Firebase Console (Easiest)

1. Go to **Firebase Console** → **Cloud Messaging**
2. Click **"Send test message"**
3. Enter your FCM token (from Firestore)
4. Enter:
   - **Notification title**: "Test Notification"
   - **Notification text**: "This is a test message"
5. Click **"Test"**

### 4.2 Test via Bill Approval (Real Scenario)

1. **As Carpenter**: Submit a bill
2. **As Admin**: Approve the bill
3. **Check**: Notification should appear on carpenter's device

### 4.3 Test via Cloud Functions

1. Go to **Firebase Console** → **Functions**
2. Find `processNotificationQueue` function
3. Check logs for notification processing

## Step 5: Test Different App States

### 5.1 Foreground (App Open)

1. Open app and keep it in foreground
2. Send test notification
3. **Expected**: Notification banner should appear at top
4. **Check logs**: Should see "Foreground message received"

### 5.2 Background (App Minimized)

1. Press home button (app goes to background)
2. Send test notification
3. **Expected**: Notification banner should appear
4. **Check logs**: Should see "Background FCM Message"

### 5.3 Terminated (App Closed)

1. Swipe up to close app completely
2. Send test notification
3. **Expected**: Notification banner should appear
4. **Tap notification**: App should open
5. **Check logs**: Should see "App opened from terminated state"

## Step 6: Troubleshooting

### Issue: No Notifications Appearing

#### Check 1: Permissions

```bash
# Check iOS Settings
Settings → Balaji Points → Notifications → Should be ON
```

#### Check 2: FCM Token

```bash
# Check Firestore
users/{userId}/fcmToken should exist
```

#### Check 3: APNs Configuration

```bash
# Check Firebase Console
Project Settings → Cloud Messaging → Apple app configuration
Should have APNs key or certificate
```

#### Check 4: Device Connection

```bash
# Ensure device is:
- Connected to internet
- Not in Do Not Disturb mode
- Not in Focus mode that blocks notifications
```

#### Check 5: App Logs

```bash
# Look for these logs:
✅ Notification permissions granted
✅ FCM Token obtained
✅ FCM token saved to Firestore
Foreground message received (if app in foreground)
Background FCM Message (if app in background)
```

### Issue: Notifications in List but No Alert

This means:

- ✅ Notifications are being received
- ✅ Stored in Firestore correctly
- ❌ But not showing as alerts

**Solution**:

1. Check notification permissions (Step 2.3)
2. Check if device is in Do Not Disturb mode
3. Check if app has notification permissions enabled
4. Restart app after granting permissions

### Issue: Foreground Notifications Not Showing

**Solution**: Already fixed in code:

- `setForegroundNotificationPresentationOptions` is now set
- Local notifications are shown via `LocalNotificationService`

## Step 7: Verify Notification Payload

### Correct Payload Format

```json
{
  "notification": {
    "title": "Bill Approved",
    "body": "Your bill has been approved"
  },
  "data": {
    "type": "billApproved",
    "screen": "/bills"
  }
}
```

### Check Cloud Functions

The `processNotificationQueue` function should send notifications with:

- `notification.title`
- `notification.body`
- `data` payload for navigation

## Step 8: Manual Testing Checklist

- [ ] App installed on physical iOS device
- [ ] Notification permissions granted
- [ ] FCM token saved in Firestore
- [ ] APNs configured in Firebase Console
- [ ] Test notification sent from Firebase Console
- [ ] Notification appears in foreground
- [ ] Notification appears in background
- [ ] Notification appears when app terminated
- [ ] Tapping notification opens app
- [ ] Notification appears in notification list screen

## Common Issues & Solutions

### "No notifications appearing"

→ Check permissions, APNs config, FCM token

### "Notifications in list but no alert"

→ Check iOS notification settings, Do Not Disturb mode

### "Foreground notifications not showing"

→ Already fixed - should work now

### "Background notifications not working"

→ Check UIBackgroundModes in Info.plist (already configured)

### "Token not saving"

→ Check user document ID format, check logs for errors

## Next Steps

1. **Test with real bill approval** (most realistic)
2. **Check Firebase Console logs** for any errors
3. **Check Xcode console** for app logs
4. **Verify APNs certificate** is valid and not expired
