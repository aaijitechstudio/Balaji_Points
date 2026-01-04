# Push Notification Testing Guide

## Step-by-Step iOS Testing Instructions

**Date:** January 5, 2025
**Platform:** iOS
**Status:** Ready for Testing

---

## 📋 Prerequisites

### 1. iOS Device Setup

- [ ] iOS device with internet connection
- [ ] App installed and running
- [ ] User logged in (carpenter account)
- [ ] Notification permissions granted

### 2. Firebase Console Access

- [ ] Access to Firebase Console: https://console.firebase.google.com/project/balajipoints
- [ ] Firestore Database access
- [ ] Functions monitoring access

### 3. Terminal/Command Line

- [ ] Firebase CLI installed
- [ ] Access to view function logs

---

## 🚀 Step 1: Verify FCM Token Registration

### What to Check:

The app should automatically register for FCM token when launched.

### Steps:

1. **Launch the app** on iOS device
2. **Grant notification permissions** when prompted
3. **Open Firebase Console** → Firestore Database
4. **Navigate to:** `users` collection
5. **Find your user document** (by phone number or user ID)
6. **Verify:** `fcmToken` field exists and has a value

### Expected Result:

```
users/{userId} {
  fcmToken: "dKxYz123...abc" (long string)
  phone: "+91XXXXXXXXXX"
  role: "carpenter"
  ...
}
```

### If Token is Missing:

- Check app logs for FCM errors
- Verify notification permissions are granted
- Restart the app
- Check `lib/services/fcm_service.dart` logs

---

## 🧪 Step 2: Test Bill Approval Notification

### Purpose:

Test the most common notification - when admin approves a bill.

### Steps:

#### 2.1 Prepare Test Bill

1. **Login as Carpenter** (on iOS device)
2. **Submit a test bill:**
   - Go to Bills screen
   - Click "Add Bill" or "Submit Bill"
   - Enter amount: ₹1000
   - Upload bill image (optional)
   - Submit the bill

#### 2.2 Approve Bill (Admin)

1. **Login as Admin** (on web or another device)
2. **Go to Admin Panel** → Pending Bills
3. **Find the test bill** you just submitted
4. **Click "Approve"**

#### 2.3 Monitor Notification Queue

1. **Open Firebase Console** → Firestore Database
2. **Navigate to:** `notification_queue` collection
3. **Watch for new document** (should appear immediately)
4. **Check document fields:**
   ```
   notification_queue/{notificationId} {
     userId: "user_phone_number"
     fcmToken: "token_string"
     type: "billApproved"
     title: "🎉 Bill Approved!"
     body: "Your bill of ₹1000 has been approved. You earned X points!"
     status: "pending" → "processing" → "sent"
     createdAt: Timestamp
   }
   ```

#### 2.4 Check Function Execution

1. **Open Terminal**
2. **Run command:**
   ```bash
   firebase functions:log --only processNotificationQueue
   ```
3. **Look for logs:**
   ```
   Processing notification: {notificationId}
   Type: billApproved, User: {userId}
   ✅ Notification sent successfully: {notificationId}
   ```

#### 2.5 Verify on iOS Device

1. **Check iOS device** for notification
2. **Notification should show:**
   - Title: "🎉 Bill Approved!"
   - Body: "Your bill of ₹1000 has been approved. You earned X points!"
   - Should appear even if app is in background/terminated

#### 2.6 Check Notification Logs

1. **Open Firebase Console** → Firestore Database
2. **Navigate to:** `notification_logs` collection
3. **Find latest log entry:**
   ```
   notification_logs/{logId} {
     notificationId: "{notificationId}"
     userId: "user_phone_number"
     type: "billApproved"
     title: "🎉 Bill Approved!"
     body: "..."
     delivered: true
     sentAt: Timestamp
   }
   ```

### Expected Result:

✅ Notification appears on iOS device
✅ Status in `notification_queue` is "sent"
✅ Entry in `notification_logs` with `delivered: true`
✅ Function logs show success

---

## 🧪 Step 3: Test Bill Rejection Notification

### Steps:

#### 3.1 Submit Another Test Bill

1. **On iOS device**, submit another bill (₹500)

#### 3.2 Reject Bill (Admin)

1. **As Admin**, go to Pending Bills
2. **Find the bill** and click "Reject"
3. **Add rejection reason** (optional)

#### 3.3 Verify Notification

1. **Check `notification_queue`** - should have new entry
2. **Check iOS device** - should receive notification:
   - Title: "Bill Rejected"
   - Body: "Your bill of ₹500 has been rejected. Please check and resubmit."

### Expected Result:

✅ Rejection notification appears on device

---

## 🧪 Step 4: Test Points Withdrawal Notification

### Steps:

#### 4.1 Withdraw Points (Admin)

1. **As Admin**, go to Users List
2. **Find a user** with approved bills
3. **Click on user** to view details
4. **Go to "Approved Bills" section**
5. **Click "Withdraw Points"** on any approved bill
6. **Confirm withdrawal**

#### 4.2 Verify Notification

1. **Check `notification_queue`** for new entry
2. **Check iOS device** for notification:
   - Title: "Points Withdrawn"
   - Body: "X points have been withdrawn from your account for bill ₹Y."

### Expected Result:

✅ Withdrawal notification appears on device

---

## 🧪 Step 5: Test Tier Upgrade Notification

### Steps:

#### 5.1 Trigger Tier Upgrade

1. **As Admin**, approve multiple bills for a user
2. **Or** have user perform daily spin multiple times
3. **Continue until user crosses tier threshold:**
   - Bronze → Silver (1000 points)
   - Silver → Gold (2500 points)
   - Gold → Platinum (5000 points)

#### 5.2 Verify Notification

1. **Check `notification_queue`** for tier upgrade notification
2. **Check iOS device** for notification:
   - Title: "🎊 Tier Upgraded!"
   - Body: "Congratulations! You've been upgraded to {tier} tier with {points} points!"

### Expected Result:

✅ Tier upgrade notification appears when tier changes

---

## 🧪 Step 6: Test Daily Spin Notification

### Steps:

#### 6.1 Perform Daily Spin

1. **On iOS device**, go to Daily Spin screen
2. **Click "Spin" button**
3. **Wait for spin result**

#### 6.2 Verify Notification

1. **Check `notification_queue`** for daily spin notification
2. **Check iOS device** for notification:
   - Title: "🎰 Spin Result"
   - Body: "You won {points} points from today's spin!"

### Expected Result:

✅ Daily spin notification appears after spin

---

## 🧪 Step 7: Test Offer Redemption Notification

### Steps:

#### 7.1 Redeem an Offer

1. **On iOS device**, go to Offers screen
2. **Select an offer** to redeem
3. **Click "Redeem"**
4. **Confirm redemption**

#### 7.2 Verify Notification

1. **Check `notification_queue`** for offer redemption notification
2. **Check iOS device** for notification:
   - Title: "Offer Redeemed"
   - Body: "You've successfully redeemed {offerTitle}. {points} points deducted."

### Expected Result:

✅ Offer redemption notification appears

---

## 🧪 Step 8: Test New Offer Broadcast Notification

### Steps:

#### 8.1 Create New Offer (Admin)

1. **As Admin**, go to Offers management
2. **Create a new active offer:**
   - Title: "Test Offer"
   - Points: 500
   - Make it active

#### 8.2 Verify Broadcast

1. **Check `notification_queue`** - should have multiple entries (one per user)
2. **Check iOS device** - should receive notification:
   - Title: "🎁 New Offer Available!"
   - Body: "Test Offer - Redeem for 500 points"

### Expected Result:

✅ All users with FCM tokens receive broadcast notification

---

## 🧪 Step 9: Test Points Milestone Notification

### Steps:

#### 9.1 Reach Milestone

1. **As Admin**, approve bills to reach milestone:
   - 1000 points
   - 2500 points
   - 5000 points
   - etc.

#### 9.2 Verify Notification

1. **Check `notification_queue`** for milestone notification
2. **Check iOS device** for notification:
   - Title: "🎯 Milestone Reached!"
   - Body: "Congratulations! You've reached {points} points!"

### Expected Result:

✅ Milestone notification appears when crossing threshold

---

## 🧪 Step 10: Test Notification Deep Linking

### Purpose:

Verify that tapping a notification navigates to the correct screen.

### Steps:

#### 10.1 Receive Notification

1. **Receive any notification** (e.g., bill approved)
2. **Don't tap it yet** - leave it in notification center

#### 10.2 Tap Notification

1. **Tap the notification** from notification center
2. **App should open** (if closed) or come to foreground
3. **App should navigate** to the correct screen:
   - Bill approved → `/wallet` or `/bills`
   - Bill rejected → `/bills`
   - Points withdrawn → `/wallet`
   - Tier upgraded → `/profile`
   - Daily spin → `/daily-spin`
   - Offer redeemed → `/offers`
   - New offer → `/offers`

### Expected Result:

✅ App opens and navigates to correct screen

---

## 🔍 Step 11: Monitor Function Logs in Real-Time

### Purpose:

Watch function execution in real-time during testing.

### Steps:

#### 11.1 Open Terminal

1. **Open terminal/command line**
2. **Navigate to project directory:**
   ```bash
   cd /Users/jagdishkumar/Documents/Development/ReactNative/Project/BalajiPoints/balaji_points
   ```

#### 11.2 Watch All Function Logs

```bash
firebase functions:log
```

#### 11.3 Watch Specific Function

```bash
# Watch notification processing
firebase functions:log --only processNotificationQueue

# Watch scheduled functions
firebase functions:log --only dailySpinReminder
firebase functions:log --only cleanupNotificationQueue
```

#### 11.4 What to Look For:

- ✅ `Processing notification: {id}` - Function triggered
- ✅ `✅ Notification sent successfully` - Success
- ✅ `❌ Error processing notification` - Error (investigate)

---

## 📊 Step 12: Verify Firestore Collections

### Collections to Check:

#### 12.1 `notification_queue`

**Location:** Firestore → `notification_queue`

**What to Check:**

- New documents appear when notifications are queued
- Status changes: `pending` → `processing` → `sent` (or `failed`)
- All required fields are present

**Query:**

```javascript
// In Firebase Console, order by createdAt descending
notification_queue.orderBy("createdAt", "desc").limit(10);
```

#### 12.2 `notification_logs`

**Location:** Firestore → `notification_logs`

**What to Check:**

- Every notification attempt is logged
- `delivered: true` for successful notifications
- `delivered: false` for failed notifications
- Error messages for failed notifications

**Query:**

```javascript
// In Firebase Console
notification_logs.orderBy("sentAt", "desc").limit(20);
```

#### 12.3 `users`

**Location:** Firestore → `users`

**What to Check:**

- `fcmToken` field exists and is not empty
- `notificationPreferences` field exists (if user has set preferences)

---

## 🐛 Troubleshooting

### Issue 1: No Notification Appears

**Check:**

1. ✅ FCM token exists in `users/{userId}/fcmToken`
2. ✅ Notification queued in `notification_queue`
3. ✅ Function executed (check logs)
4. ✅ Notification status is "sent" (not "failed")
5. ✅ iOS notification permissions granted
6. ✅ APNs configured in Firebase Console

**Solutions:**

- Check function logs for errors
- Verify FCM token is valid
- Check iOS notification settings
- Verify APNs certificate/key in Firebase Console

---

### Issue 2: Notification Status is "failed"

**Check:**

1. **Open `notification_queue`** document
2. **Check `error` field** for error message
3. **Check function logs** for detailed error

**Common Errors:**

- `Missing required notification fields` - Check notification data
- `Invalid FCM token` - Token expired, need to refresh
- `Permission denied` - Check Firestore rules

**Solutions:**

- Fix the error in notification data
- Refresh FCM token
- Check Firestore security rules

---

### Issue 3: Function Not Triggering

**Check:**

1. ✅ Function is deployed and active
2. ✅ Firestore rules allow writes to `notification_queue`
3. ✅ Document is being created in `notification_queue`

**Solutions:**

- Verify function deployment: `firebase functions:list`
- Check Firestore rules for `notification_queue`
- Verify document creation in Firestore Console

---

### Issue 4: Notification Appears But No Deep Link

**Check:**

1. ✅ Notification data includes `screen` field
2. ✅ App handles notification tap
3. ✅ Navigation routes are correct

**Solutions:**

- Check `FCMService` handles notification tap
- Verify `GoRouter` routes match `screen` values
- Check app logs for navigation errors

---

## ✅ Testing Checklist

### Basic Functionality

- [ ] FCM token registered
- [ ] Bill approval notification works
- [ ] Bill rejection notification works
- [ ] Points withdrawal notification works

### Advanced Features

- [ ] Tier upgrade notification works
- [ ] Daily spin notification works
- [ ] Offer redemption notification works
- [ ] New offer broadcast works
- [ ] Points milestone notification works

### User Experience

- [ ] Notifications appear in foreground
- [ ] Notifications appear in background
- [ ] Notifications appear when app terminated
- [ ] Tapping notification navigates correctly
- [ ] Notification preferences work

### Monitoring

- [ ] Function logs show successful execution
- [ ] `notification_queue` shows correct status
- [ ] `notification_logs` records all notifications
- [ ] No errors in function logs

---

## 📝 Testing Notes Template

Use this template to record your testing:

```
Date: ___________
Tester: ___________
Device: ___________
iOS Version: ___________

Test Results:
- Bill Approval: [ ] Pass [ ] Fail - Notes: ___________
- Bill Rejection: [ ] Pass [ ] Fail - Notes: ___________
- Points Withdrawal: [ ] Pass [ ] Fail - Notes: ___________
- Tier Upgrade: [ ] Pass [ ] Fail - Notes: ___________
- Daily Spin: [ ] Pass [ ] Fail - Notes: ___________
- Offer Redemption: [ ] Pass [ ] Fail - Notes: ___________
- New Offer Broadcast: [ ] Pass [ ] Fail - Notes: ___________
- Points Milestone: [ ] Pass [ ] Fail - Notes: ___________
- Deep Linking: [ ] Pass [ ] Fail - Notes: ___________

Issues Found:
1. ___________
2. ___________

Overall Status: [ ] Ready [ ] Needs Fixes
```

---

## 🎯 Quick Test Commands

### View Function Status

```bash
firebase functions:list
```

### Watch Function Logs

```bash
firebase functions:log --only processNotificationQueue
```

### Check Firestore (Browser)

```
https://console.firebase.google.com/project/balajipoints/firestore
```

### Test Manual Notification (HTTP Callable)

```bash
# From Flutter app or Postman
POST https://us-central1-balajipoints.cloudfunctions.net/sendNotification
Body: {
  "data": {
    "userId": "user_phone_number",
    "title": "Test Notification",
    "body": "This is a test",
    "type": "general"
  }
}
```

---

## 📚 Additional Resources

- **Firebase Console:** https://console.firebase.google.com/project/balajipoints
- **Function Logs:** `firebase functions:log`
- **Firestore Console:** Firebase Console → Firestore Database
- **Documentation:** See `PUSH_NOTIFICATIONS_COMPLETE_IMPLEMENTATION.md`

---

**Last Updated:** January 5, 2025
**Status:** Ready for Testing
