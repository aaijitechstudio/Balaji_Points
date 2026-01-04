# Firebase Cloud Functions Setup Guide

## Balaji Points - Push Notifications

**Date:** January 5, 2025
**Purpose:** Process notification queue and send FCM notifications

---

## Prerequisites

1. **Node.js** (v18 or higher) installed
2. **Firebase CLI** installed globally
3. **Firebase project** with Firestore and Cloud Functions enabled
4. **Billing enabled** on Firebase project (Cloud Functions require Blaze plan)

---

## Setup Steps

### Step 1: Install Firebase CLI

```bash
npm install -g firebase-tools
```

### Step 2: Login to Firebase

```bash
firebase login
```

### Step 3: Initialize Functions (if not already done)

```bash
cd /Users/jagdishkumar/Documents/Development/ReactNative/Project/BalajiPoints/balaji_points
firebase init functions
```

**When prompted:**

- Select JavaScript as language
- Use ESLint: Yes
- Install dependencies: Yes

### Step 4: Install Dependencies

```bash
cd functions
npm install
```

### Step 5: Deploy Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Or deploy specific function
firebase deploy --only functions:processNotificationQueue
firebase deploy --only functions:dailySpinReminder
```

---

## Functions Overview

### 1. `processNotificationQueue`

**Type:** Firestore Trigger
**Trigger:** When a document is created in `notification_queue` collection

**What it does:**

- Processes notifications from the queue
- Sends FCM notification to user's device
- Updates notification status (pending → processing → sent/failed)
- Logs to `notification_logs` collection

**Usage:**

- Automatically triggered when app queues a notification
- No manual intervention needed

---

### 2. `dailySpinReminder`

**Type:** Scheduled (Cron)
**Schedule:** Daily at 9:00 AM IST (3:30 AM UTC)

**What it does:**

- Checks all users who haven't spun today
- Sends reminder notification to eligible users
- Respects notification preferences
- Only sends to users with FCM tokens

**Usage:**

- Runs automatically on schedule
- Can be manually triggered for testing

---

### 3. `sendNotification`

**Type:** HTTP Callable
**Endpoint:** `https://<region>-<project-id>.cloudfunctions.net/sendNotification`

**What it does:**

- Manually send a notification to a specific user
- Useful for testing or admin actions

**Usage:**

```javascript
// From Flutter app or admin panel
const sendNotification = firebase.functions().httpsCallable("sendNotification");
await sendNotification({
  userId: "user123",
  title: "Test Notification",
  body: "This is a test",
  type: "general",
});
```

---

### 4. `cleanupNotificationQueue`

**Type:** Scheduled (Cron)
**Schedule:** Daily at 2:00 AM IST

**What it does:**

- Removes old notification queue entries (older than 7 days)
- Keeps database clean and reduces storage costs

**Usage:**

- Runs automatically on schedule

---

## Testing Functions Locally

### 1. Start Firebase Emulators

```bash
firebase emulators:start --only functions,firestore
```

### 2. Test Notification Processing

```bash
# In another terminal, add a test notification to queue
# This will trigger the processNotificationQueue function
```

### 3. Test Scheduled Functions

```bash
# Manually trigger scheduled function
firebase functions:shell
> dailySpinReminder()
```

---

## Deployment

### Deploy All Functions

```bash
firebase deploy --only functions
```

### Deploy Specific Function

```bash
firebase deploy --only functions:processNotificationQueue
firebase deploy --only functions:dailySpinReminder
firebase deploy --only functions:sendNotification
firebase deploy --only functions:cleanupNotificationQueue
```

### View Function Logs

```bash
firebase functions:log
firebase functions:log --only processNotificationQueue
```

---

## Monitoring

### View Function Status

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Navigate to Functions section
3. View execution logs, errors, and metrics

### Key Metrics to Monitor

- **Execution Count:** Number of times function ran
- **Execution Time:** Average execution time
- **Error Rate:** Percentage of failed executions
- **Memory Usage:** Function memory consumption

---

## Troubleshooting

### Function Not Triggering

1. **Check Firestore Rules:**

   - Ensure `notification_queue` collection allows writes
   - Check rules in `firestore.rules`

2. **Check Function Logs:**

   ```bash
   firebase functions:log
   ```

3. **Verify Trigger:**
   - Check if document is being created in `notification_queue`
   - Verify function is deployed

### FCM Not Sending

1. **Check FCM Token:**

   - Verify token is valid in user document
   - Token might be expired (refresh required)

2. **Check FCM Service Account:**

   - Ensure Firebase Admin SDK is properly initialized
   - Check service account permissions

3. **Check Notification Payload:**
   - Verify title and body are not empty
   - Check data payload structure

### Scheduled Function Not Running

1. **Check Timezone:**

   - Verify timezone is set correctly (Asia/Kolkata)
   - Check cron expression

2. **Check Billing:**

   - Scheduled functions require Blaze plan
   - Verify billing is enabled

3. **Check Function Status:**
   - Go to Firebase Console → Functions
   - Verify function is deployed and enabled

---

## Cost Estimation

### Cloud Functions Pricing

- **Invocations:** First 2 million/month: FREE
- **Compute Time:** First 400,000 GB-seconds/month: FREE
- **Networking:** First 5 GB/month: FREE

### Estimated Usage

- **Notification Processing:** ~100-500/day = ~15,000/month (FREE)
- **Daily Spin Reminder:** 1/day = 30/month (FREE)
- **Cleanup:** 1/day = 30/month (FREE)

**Total Estimated Cost:** $0 (within free tier)

---

## Security Considerations

### 1. Service Account Permissions

- Cloud Functions use Firebase Admin SDK
- Has full access to Firestore and FCM
- Keep service account key secure
- Never commit service account key to git

### 2. Function Authentication

- `sendNotification` function can be called by anyone
- Add authentication if needed:
  ```javascript
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Must be authenticated"
    );
  }
  ```

### 3. Input Validation

- All functions validate input data
- Invalid data is rejected with appropriate errors

---

## Next Steps

1. **Deploy Functions:**

   ```bash
   firebase deploy --only functions
   ```

2. **Test Notification Flow:**

   - Create a test notification in app
   - Verify it's processed by Cloud Function
   - Check notification appears on device

3. **Monitor Performance:**

   - Check Firebase Console for function metrics
   - Monitor error rates
   - Optimize if needed

4. **Set Up Alerts:**
   - Configure error alerts in Firebase Console
   - Set up monitoring for function failures

---

## Function Code Structure

```
functions/
├── index.js          # Main functions file
├── package.json      # Dependencies
├── .eslintrc.js      # ESLint configuration
└── .gitignore        # Git ignore rules
```

---

## Support

For issues or questions:

1. Check Firebase Console logs
2. Review function code in `functions/index.js`
3. Check Firestore rules
4. Verify FCM configuration

---

**Last Updated:** January 5, 2025
**Status:** Ready for Deployment
