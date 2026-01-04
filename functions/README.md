# Firebase Cloud Functions

## Balaji Points - Push Notifications

This directory contains Cloud Functions for processing push notifications.

## Functions

1. **processNotificationQueue** - Processes notifications from queue and sends via FCM
2. **dailySpinReminder** - Scheduled daily reminder for users who haven't spun
3. **sendNotification** - HTTP callable function for manual notifications
4. **cleanupNotificationQueue** - Scheduled cleanup of old queue entries

## Setup

```bash
# Install dependencies
npm install

# Deploy functions
firebase deploy --only functions
```

## Testing

```bash
# Run emulators locally
firebase emulators:start --only functions,firestore

# Test in shell
firebase functions:shell
```

## Documentation

See `CLOUD_FUNCTIONS_SETUP_GUIDE.md` for detailed setup and deployment instructions.
