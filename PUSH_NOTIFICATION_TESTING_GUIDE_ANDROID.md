# 🤖 Android Push Notification Testing Guide

## Prerequisites

1. **Android Device** (physical device or emulator with Google Play Services)
2. **Google Services JSON** file configured (`google-services.json`)
3. **App installed** on device/emulator
4. **Internet connection** on device

## Step 1: Verify Android Configuration

### 1.1 Check AndroidManifest.xml
✅ Should include:
- Internet permission
- Firebase Messaging service
- Notification channels (Android 8.0+)

### 1.2 Check google-services.json
✅ Should exist at: `android/app/google-services.json`
- Contains your Firebase project configuration
- Required for FCM to work

### 1.3 Verify Build Configuration
✅ Check `android/app/build.gradle`:
- `apply plugin: 'com.google.gms.google-services'`
- Firebase dependencies included

## Step 2: Check Notification Permissions

### 2.1 Android 13+ (API 33+)
Android 13+ requires runtime notification permission:
1. App will show permission dialog on first launch
2. User must tap **"Allow"**
3. Check: **Settings** → **Apps** → **Balaji Points** → **Notifications** → Should be **ON**

### 2.2 Android 12 and Below
- Notifications are enabled by default
- No permission dialog needed
- Can be disabled in Settings

### 2.3 Check Permission Status
1. Open app
2. Check console logs for:
   ```
   ✅ Notification permissions granted
   ✅ Local notifications initialized successfully
   ```

## Step 3: Verify FCM Token

### 3.1 Check Token Registration
1. Open app and login
2. Check console logs (Android Studio Logcat) for:
   ```
   FCM Token obtained: ...
   ✅ FCM token saved to Firestore for user: ...
   ```

### 3.2 Verify Token in Firestore
1. Go to **Firebase Console** → **Firestore Database**
2. Navigate to `users/{userId}`
3. Check that `fcmToken` field exists and has a value
4. Check `platform` field should be `android`

### 3.3 Get Token from Logs
```bash
# In Android Studio Logcat, filter by:
FCM Token obtained
```

## Step 4: Test Notification Sending

### 4.1 Test via Firebase Console (Easiest)
1. Go to **Firebase Console** → **Cloud Messaging**
2. Click **"Send test message"**
3. Enter your FCM token (from Firestore or logs)
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
3. **Expected**:
   - Notification appears in notification tray
   - Local notification is shown (via LocalNotificationService)
4. **Check logs**: Should see "Foreground message received"

### 5.2 Background (App Minimized)
1. Press home button (app goes to background)
2. Send test notification
3. **Expected**:
   - Notification appears in notification tray
   - Notification sound plays (if enabled)
   - Notification icon appears in status bar
4. **Check logs**: Should see "Background FCM Message"

### 5.3 Terminated (App Closed)
1. Swipe away app from recent apps
2. Send test notification
3. **Expected**:
   - Notification appears in notification tray
   - Notification sound plays (if enabled)
4. **Tap notification**: App should open
5. **Check logs**: Should see "App opened from terminated state"

## Step 6: Notification Channels (Android 8.0+)

### 6.1 Default Channel
- **Channel ID**: `balaji_points_default`
- **Name**: "Balaji Points Notifications"
- **Importance**: High
- **Sound**: Enabled
- **Vibration**: Enabled

### 6.2 Important Channel
- **Channel ID**: `balaji_points_important`
- **Name**: "Important Notifications"
- **Importance**: High
- **Sound**: Enabled
- **Vibration**: Enabled
- Used for: Bill approvals, tier upgrades

### 6.3 Check Channel Settings
1. **Settings** → **Apps** → **Balaji Points** → **Notifications**
2. Should see both channels listed
3. Can customize sound, vibration per channel

## Step 7: Troubleshooting

### Issue: No Notifications Appearing

#### Check 1: Permissions (Android 13+)
```bash
# Check Android Settings
Settings → Apps → Balaji Points → Notifications → Should be ON
```

#### Check 2: FCM Token
```bash
# Check Firestore
users/{userId}/fcmToken should exist
```

#### Check 3: Google Services
```bash
# Check device has Google Play Services
Settings → Apps → Google Play Services → Should be installed and updated
```

#### Check 4: Device Connection
```bash
# Ensure device is:
- Connected to internet (WiFi or mobile data)
- Not in Do Not Disturb mode
- Not in Battery Saver mode (may block notifications)
```

#### Check 5: App Logs
```bash
# In Android Studio Logcat, look for:
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
1. Check notification permissions (Step 2)
2. Check if device is in Do Not Disturb mode
3. Check notification channel settings
4. Check if app notifications are enabled in system settings
5. Restart app after granting permissions

### Issue: Foreground Notifications Not Showing

**Solution**: Already handled in code:
- `LocalNotificationService` shows local notifications when app is in foreground
- Check logs for "Foreground message received"

### Issue: Background Notifications Not Working

**Check**:
1. `AndroidManifest.xml` should have:
   ```xml
   <service
       android:name="com.google.firebase.messaging.FirebaseMessagingService"
       android:exported="false">
       <intent-filter>
           <action android:name="com.google.firebase.MESSAGING_EVENT" />
       </intent-filter>
   </service>
   ```

2. Background handler registered in `main.dart`

### Issue: Token Not Saving

**Check**:
1. User document ID format
2. Firestore write permissions
3. Check logs for errors

## Step 8: Verify Notification Payload

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
  },
  "android": {
    "priority": "high",
    "notification": {
      "channelId": "balaji_points_important",
      "sound": "default"
    }
  }
}
```

### Check Cloud Functions
The `processNotificationQueue` function should send notifications with:
- `notification.title`
- `notification.body`
- `data` payload for navigation
- `android.priority` (high/normal)
- `android.notification.channelId`

## Step 9: Testing on Emulator vs Physical Device

### Emulator Testing
✅ **Works**:
- FCM tokens
- Foreground notifications
- Background notifications (if Google Play Services installed)

⚠️ **Limitations**:
- May have delays
- Battery optimization may affect notifications

### Physical Device Testing
✅ **Recommended**:
- More reliable
- Real-world conditions
- Better for testing battery optimization impact

## Step 10: Manual Testing Checklist

- [ ] App installed on Android device/emulator
- [ ] Notification permissions granted (Android 13+)
- [ ] FCM token saved in Firestore
- [ ] Google Play Services installed and updated
- [ ] Test notification sent from Firebase Console
- [ ] Notification appears in foreground
- [ ] Notification appears in background
- [ ] Notification appears when app terminated
- [ ] Tapping notification opens app
- [ ] Notification appears in notification list screen
- [ ] Notification channels created (Android 8.0+)
- [ ] Sound plays when notification arrives
- [ ] Vibration works (if enabled)

## Step 11: Using Android Studio Logcat

### Filter Logs
1. Open **Android Studio**
2. Go to **Logcat** tab
3. Filter by:
   - `FCM`
   - `Notification`
   - `Firebase`
   - `BalajiPoints`

### Key Log Messages to Look For
```
✅ FCM Token obtained: ...
✅ FCM token saved to Firestore for user: ...
✅ Local notifications initialized successfully
✅ Notification channels created
Foreground message received: ...
Background FCM Message: ...
```

## Step 12: Testing Different Notification Types

### Bill Approved
1. Submit bill as carpenter
2. Approve as admin
3. **Expected**: Notification with "Bill Approved" title

### Bill Rejected
1. Submit bill as carpenter
2. Reject as admin
3. **Expected**: Notification with "Bill Rejected" title

### Daily Spin Reminder
1. Wait for scheduled reminder (9 AM IST)
2. **Expected**: Notification with "Daily Spin Available" title

### New Offer Available
1. Admin creates new offer
2. **Expected**: Broadcast notification to all carpenters

## Common Issues & Solutions

### "No notifications appearing"
→ Check permissions, FCM token, Google Play Services, internet connection

### "Notifications in list but no alert"
→ Check notification settings, Do Not Disturb mode, channel settings

### "Foreground notifications not showing"
→ Already handled - check logs for "Foreground message received"

### "Background notifications not working"
→ Check AndroidManifest.xml, background handler registration

### "Token not saving"
→ Check user document ID format, Firestore permissions, logs for errors

### "Notifications delayed"
→ Check battery optimization settings, Do Not Disturb mode, internet connection

## Step 13: Battery Optimization

### Check Battery Settings
1. **Settings** → **Battery** → **Battery Optimization**
2. Find **Balaji Points**
3. Set to **"Don't optimize"** (recommended for reliable notifications)

### Why This Matters
- Battery optimization can delay or block background notifications
- Setting to "Don't optimize" ensures notifications arrive immediately

## Step 14: Network Testing

### Test on WiFi
1. Connect device to WiFi
2. Send test notification
3. Should arrive immediately

### Test on Mobile Data
1. Disable WiFi, use mobile data
2. Send test notification
3. Should arrive immediately

### Test Offline
1. Disable internet
2. Send test notification
3. Should arrive when internet reconnects (FCM queues messages)

## Next Steps

1. **Test with real bill approval** (most realistic)
2. **Check Firebase Console logs** for any errors
3. **Check Android Studio Logcat** for app logs
4. **Verify notification channels** are working (Android 8.0+)
5. **Test on different Android versions** if possible

## Quick Test Commands

### Get FCM Token from Logs
```bash
# In Android Studio Logcat, search for:
FCM Token obtained
```

### Check Notification Channels
```bash
# In Android Studio Logcat, search for:
Notification channels created
```

### Monitor Notification Events
```bash
# In Android Studio Logcat, filter by:
Notification
```

## Summary

Android push notifications should work out of the box with proper configuration. The main things to check:

1. ✅ **Permissions** (Android 13+)
2. ✅ **FCM Token** saved in Firestore
3. ✅ **Google Play Services** installed
4. ✅ **Internet connection**
5. ✅ **Notification channels** (Android 8.0+)
6. ✅ **Battery optimization** settings

If notifications appear in the list but not as alerts, check system notification settings and Do Not Disturb mode.

