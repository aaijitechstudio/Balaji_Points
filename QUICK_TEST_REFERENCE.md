# Quick Testing Reference Card

## Push Notifications - iOS Testing

---

## 🚀 Quick Start

### 1. Verify FCM Token

```
Firebase Console → Firestore → users/{userId}
Check: fcmToken field exists
```

### 2. Test Bill Approval (Most Common)

```
1. Submit bill as carpenter
2. Approve bill as admin
3. Check iOS device for notification
4. Verify in notification_queue (status: "sent")
```

### 3. Monitor Logs

```bash
firebase functions:log --only processNotificationQueue
```

---

## 📱 Test Each Notification Type

| Notification Type | How to Trigger              | Expected Title            |
| ----------------- | --------------------------- | ------------------------- |
| Bill Approved     | Admin approves bill         | "🎉 Bill Approved!"       |
| Bill Rejected     | Admin rejects bill          | "Bill Rejected"           |
| Points Withdrawn  | Admin withdraws points      | "Points Withdrawn"        |
| Tier Upgraded     | User crosses tier threshold | "🎊 Tier Upgraded!"       |
| Daily Spin        | User performs daily spin    | "🎰 Spin Result"          |
| Offer Redeemed    | User redeems offer          | "Offer Redeemed"          |
| New Offer         | Admin creates new offer     | "🎁 New Offer Available!" |
| Milestone         | User reaches milestone      | "🎯 Milestone Reached!"   |

---

## 🔍 Quick Checks

### Firestore Collections

```
notification_queue → Check status: "sent" or "failed"
notification_logs → Check delivered: true/false
users/{userId} → Check fcmToken exists
```

### Function Status

```bash
firebase functions:list
```

### Watch Logs

```bash
firebase functions:log
```

---

## ✅ Success Indicators

- ✅ Notification appears on iOS device
- ✅ `notification_queue` status = "sent"
- ✅ `notification_logs` delivered = true
- ✅ Function logs show "✅ Notification sent successfully"
- ✅ Tapping notification navigates correctly

---

## 🐛 Quick Troubleshooting

| Issue                   | Check                                                     |
| ----------------------- | --------------------------------------------------------- |
| No notification         | FCM token exists? Notification queued? Function executed? |
| Status "failed"         | Check error field in notification_queue                   |
| Function not triggering | Function deployed? Firestore rules allow writes?          |

---

## 📞 Test Commands

```bash
# List all functions
firebase functions:list

# Watch notification processing
firebase functions:log --only processNotificationQueue

# Watch all logs
firebase functions:log
```

---

**Full Guide:** See `PUSH_NOTIFICATION_TESTING_GUIDE.md`
