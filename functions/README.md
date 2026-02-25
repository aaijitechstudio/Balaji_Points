# Firebase Cloud Functions

## Balaji Points - Push Notifications

This directory contains Cloud Functions for processing push notifications.

## Functions

1. **processNotificationQueue** (implemented) – Firestore trigger: when a document is added to `notification_queue`, sends the FCM message to the device and updates the document status to `sent` or `failed`.

Other functions (dailySpinReminder, sendNotification, cleanupNotificationQueue) can be added later.

## Why push wasn’t working

- The app only **queues** notifications in Firestore (`notification_queue`). Without this Cloud Function, nothing was reading the queue and sending FCM messages, so carpenters and admins never received push notifications for bill approve/reject or new bills.

## Setup and deploy

1. **Blaze plan** – Cloud Functions require Firebase Blaze (pay-as-you-go). Enable it in Firebase Console if needed.

2. **Install and deploy:**

```bash
cd functions
npm install
firebase deploy --only functions
```

3. **Carpenter (bill approve/reject)**  
   - The carpenter’s FCM token must be stored on their **user** document in Firestore.  
   - Token is saved when they open the app and log in (and on app startup after login).  
   - The app finds the user by the bill’s `carpenterId` (phone number): it looks up `users` by doc ID, then by `phone`, then by `carpenterId`.  
   - Ensure the carpenter has opened the app at least once after logging in so their token is saved.

4. **Admin (new pending bill)**  
   - Admin notifications use `_sendNotificationToAllAdmins`: all `users` docs with `role == 'admin'` and a non-empty `fcmToken` receive the notification.  
   - The admin must log in on the app at least once so their FCM token is written to their admin user document (same as carpenter).

## Testing

```bash
# Run emulators locally
firebase emulators:start --only functions,firestore

# View function logs after deploy
firebase functions:log
```
