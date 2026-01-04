# Push Notification Implementation Plan
## Balaji Points Application

**Date:** January 5, 2025
**Version:** 1.0.0+2
**Status:** Planning Phase

---

## Executive Summary

This document outlines the comprehensive plan for implementing push notifications in the Balaji Points application. The app currently has Firebase Cloud Messaging (FCM) infrastructure partially set up but requires completion and integration with user actions.

---

## 1. Current State Analysis

### 1.1 Existing Infrastructure ✅

**What's Already in Place:**
- ✅ Firebase Cloud Messaging package installed (`firebase_messaging: ^16.0.4`)
- ✅ FCMService class created (`lib/services/fcm_service.dart`)
- ✅ Basic initialization code in `main.dart`
- ✅ Background message handler registered
- ✅ Token management (get, save, delete)
- ✅ Permission request handling (iOS)
- ✅ Message handlers for foreground/background states
- ✅ Token storage in Firestore (`users` collection with `fcmToken` field)

### 1.2 What's Missing ❌

**Gaps Identified:**
- ❌ FCM token not being saved for PIN-based auth users (only Firebase Auth users)
- ❌ No notification sending service/function
- ❌ No integration with user actions (bill approval, tier changes, etc.)
- ❌ No notification UI display (local notifications)
- ❌ No deep linking/navigation from notifications
- ❌ No notification preferences/settings
- ❌ Background handler not properly initialized

---

## 2. User Actions Requiring Push Notifications

### 2.1 Critical Notifications (High Priority)

#### **A. Bill Status Notifications**
1. **Bill Approved** ⭐ HIGHEST PRIORITY
   - **Trigger:** Admin approves a pending bill
   - **When:** After `BillService.approveBill()` succeeds
   - **Recipient:** Carpenter who submitted the bill
   - **Message Template:**
     - Title: "🎉 Bill Approved!"
     - Body: "Your bill of ₹{amount} has been approved. You earned {points} points!"
   - **Data Payload:**
     ```json
     {
       "type": "bill_approved",
       "billId": "...",
       "amount": 100000,
       "points": 100,
       "action": "view_bill"
     }
     ```
   - **Navigation:** Open wallet/bills page

2. **Bill Rejected**
   - **Trigger:** Admin rejects a pending bill
   - **When:** After `BillService.rejectBill()` succeeds
   - **Recipient:** Carpenter who submitted the bill
   - **Message Template:**
     - Title: "Bill Rejected"
     - Body: "Your bill of ₹{amount} has been rejected. Please check and resubmit."
   - **Data Payload:**
     ```json
     {
       "type": "bill_rejected",
       "billId": "...",
       "amount": 100000,
       "action": "view_bill"
     }
     ```

3. **Points Withdrawn** (Admin Action)
   - **Trigger:** Admin withdraws points from approved bill
   - **When:** After `BillService.withdrawBill()` succeeds
   - **Recipient:** Carpenter whose points were withdrawn
   - **Message Template:**
     - Title: "Points Withdrawn"
     - Body: "{points} points have been withdrawn from your account for bill ₹{amount}."
   - **Data Payload:**
     ```json
     {
       "type": "points_withdrawn",
       "billId": "...",
       "points": -100,
       "amount": 100000,
       "action": "view_bill"
     }
     ```

#### **B. Points & Tier Notifications**

4. **Tier Upgraded** ⭐ HIGH PRIORITY
   - **Trigger:** User's tier changes after points update
   - **When:** After any points addition that changes tier
   - **Recipient:** Carpenter whose tier changed
   - **Message Template:**
     - Title: "🎊 Tier Upgraded!"
     - Body: "Congratulations! You've been upgraded to {newTier} tier with {points} points!"
   - **Data Payload:**
     ```json
     {
       "type": "tier_upgraded",
       "oldTier": "Bronze",
       "newTier": "Silver",
       "points": 2500,
       "action": "view_profile"
     }
     ```

5. **Daily Spin Prize Won**
   - **Trigger:** User wins points from daily spin
   - **When:** After `DailySpinProvider.performSpin()` succeeds
   - **Recipient:** Carpenter who spun
   - **Message Template:**
     - Title: "🎰 Spin Result"
     - Body: "You won {points} points from today's spin!"
   - **Data Payload:**
     ```json
     {
       "type": "daily_spin_won",
       "points": 50,
       "action": "view_spin"
     }
     ```

#### **C. Offer Notifications**

6. **New Offer Available**
   - **Trigger:** Admin creates a new offer
   - **When:** New offer added to `offers` collection
   - **Recipient:** All carpenters (or specific tier)
   - **Message Template:**
     - Title: "🎁 New Offer Available!"
     - Body: "{offerTitle} - Redeem for {points} points"
   - **Data Payload:**
     ```json
     {
       "type": "new_offer",
       "offerId": "...",
       "offerTitle": "...",
       "points": 500,
       "action": "view_offers"
     }
     ```

7. **Offer Redeemed Successfully**
   - **Trigger:** User successfully redeems an offer
   - **When:** After `OfferService.redeemOffer()` succeeds
   - **Recipient:** Carpenter who redeemed
   - **Message Template:**
     - Title: "Offer Redeemed"
     - Body: "You've successfully redeemed {offerTitle}. {points} points deducted."
   - **Data Payload:**
     ```json
     {
       "type": "offer_redeemed",
       "offerId": "...",
       "offerTitle": "...",
       "points": -500,
       "action": "view_offers"
     }
     ```

### 2.2 Informational Notifications (Medium Priority)

8. **Daily Spin Reminder**
   - **Trigger:** Scheduled notification (daily at 9 AM)
   - **When:** User hasn't spun today
   - **Recipient:** All carpenters
   - **Message Template:**
     - Title: "🎰 Daily Spin Available"
     - Body: "Don't forget to spin the wheel today and win points!"

9. **Points Milestone**
   - **Trigger:** User reaches significant point milestones (1000, 5000, 10000, etc.)
   - **When:** Points cross milestone thresholds
   - **Recipient:** Carpenter who reached milestone
   - **Message Template:**
     - Title: "🎯 Milestone Reached!"
     - Body: "Congratulations! You've reached {points} points!"

10. **Bill Submission Confirmation**
    - **Trigger:** User submits a new bill
    - **When:** After `BillService.submitBill()` succeeds
    - **Recipient:** Carpenter who submitted
    - **Message Template:**
      - Title: "Bill Submitted"
      - Body: "Your bill of ₹{amount} has been submitted and is pending approval."

### 2.3 Admin Notifications (Low Priority - Future)

11. **New Bill Submitted** (Admin)
    - **Trigger:** Carpenter submits a new bill
    - **Recipient:** All admins
    - **Message Template:**
      - Title: "New Bill Pending"
      - Body: "{carpenterName} submitted a bill of ₹{amount}"

12. **Daily Summary** (Admin)
    - **Trigger:** Scheduled (end of day)
    - **Recipient:** All admins
    - **Message Template:**
      - Title: "Daily Summary"
      - Body: "{count} bills approved today, {totalPoints} points distributed"

---

## 3. Technical Implementation Requirements

### 3.1 FCM Token Management Fix

**Current Issue:**
- FCM token is only saved for Firebase Auth users
- PIN-based auth users don't have tokens saved

**Solution Required:**
- Update `FCMService._saveTokenToFirestore()` to work with PIN-based auth
- Use phone number or userId from SessionService instead of Firebase Auth
- Store token in `users` collection using phone number as document ID

**Location:** `lib/services/fcm_service.dart` (line 72-89)

### 3.2 Notification Sending Service

**New Service Required:** `NotificationService`

**Responsibilities:**
1. Send notifications to individual users (by FCM token)
2. Send notifications to user groups (by tier, role, etc.)
3. Send broadcast notifications (all users)
4. Handle notification templates
5. Queue notifications for retry on failure
6. Log notification delivery status

**Implementation Approach:**
- **Option A:** Cloud Functions (Recommended)
  - Create Firebase Cloud Functions to send notifications
  - Triggered by Firestore triggers or HTTP calls
  - Better security, no API keys in app

- **Option B:** Server-side API
  - Create Node.js/Python backend
  - Use FCM Admin SDK
  - Requires server infrastructure

- **Option C:** Client-side (Not Recommended)
  - Use FCM REST API from Flutter app
  - Security risk (API keys exposed)
  - Limited functionality

**Recommended:** Option A (Cloud Functions)

### 3.3 Local Notification Display

**Package Required:** `flutter_local_notifications`

**Purpose:**
- Display notifications when app is in foreground
- Show local notifications for scheduled reminders
- Handle notification actions/buttons

**Implementation:**
- Initialize local notifications plugin
- Show local notification when FCM message received in foreground
- Custom notification channels for different types

### 3.4 Deep Linking & Navigation

**Requirements:**
- Navigate to specific screens when notification is tapped
- Handle notification data payload
- Support app state: foreground, background, terminated

**Implementation:**
- Update `FCMService._handleMessageNavigation()` (currently empty)
- Use GoRouter to navigate based on notification type
- Handle deep link routing

### 3.5 Background Handler Fix

**Current Issue:**
- Background handler exists but may not be properly initialized

**Fix Required:**
- Ensure `firebaseMessagingBackgroundHandler` is registered in `main.dart`
- Verify handler has proper Firebase initialization
- Test background message delivery

---

## 4. Firestore Structure Updates

### 4.1 User Document Schema

**Current:**
```javascript
users/{phoneNumber} {
  fcmToken: string,  // Already exists but not populated for PIN users
  lastTokenUpdate: timestamp
}
```

**Required Updates:**
- Ensure `fcmToken` is saved for all users (PIN-based auth)
- Add `notificationPreferences` object:
  ```javascript
  notificationPreferences: {
    billApproved: true,
    billRejected: true,
    tierUpgraded: true,
    dailySpin: true,
    newOffers: true,
    pointsWithdrawn: true,
    enabled: true  // Master switch
  }
  ```

### 4.2 Notification Log Collection (Optional)

**New Collection:** `notification_logs`

**Purpose:** Track sent notifications for analytics

**Schema:**
```javascript
notification_logs/{notificationId} {
  userId: string,
  type: string,
  title: string,
  body: string,
  sentAt: timestamp,
  delivered: boolean,
  opened: boolean,
  openedAt: timestamp
}
```

---

## 5. Implementation Phases

### Phase 1: Foundation (Week 1)
**Priority: CRITICAL**

1. ✅ Fix FCM token saving for PIN-based auth users
2. ✅ Complete background message handler setup
3. ✅ Add local notifications package and setup
4. ✅ Test basic notification delivery

**Deliverables:**
- FCM tokens saved for all users
- Notifications received in all app states
- Basic notification display working

### Phase 2: Core Notifications (Week 2)
**Priority: HIGH**

1. ✅ Implement NotificationService (Cloud Functions recommended)
2. ✅ Integrate bill approval notification
3. ✅ Integrate bill rejection notification
4. ✅ Integrate points withdrawal notification
5. ✅ Add deep linking/navigation

**Deliverables:**
- Bill status notifications working
- Users receive notifications when bills are approved/rejected
- Navigation from notifications working

### Phase 3: Enhanced Notifications (Week 3)
**Priority: MEDIUM**

1. ✅ Tier upgrade notifications
2. ✅ Daily spin notifications
3. ✅ Offer redemption notifications
4. ✅ Notification preferences UI

**Deliverables:**
- All core user action notifications working
- Users can manage notification preferences

### Phase 4: Advanced Features (Week 4)
**Priority: LOW**

1. ✅ New offer broadcast notifications
2. ✅ Daily spin reminders (scheduled)
3. ✅ Points milestone notifications
4. ✅ Notification analytics/logging

**Deliverables:**
- All notification types implemented
- Analytics and logging in place

---

## 6. Notification Message Templates

### 6.1 Bill Approval
```
Title: "🎉 Bill Approved!"
Body: "Your bill of ₹{amount} has been approved. You earned {points} points!"
Priority: High
Sound: success.mp3
```

### 6.2 Bill Rejection
```
Title: "Bill Rejected"
Body: "Your bill of ₹{amount} has been rejected. Please check and resubmit."
Priority: Normal
Sound: default
```

### 6.3 Points Withdrawn
```
Title: "Points Withdrawn"
Body: "{points} points have been withdrawn from your account for bill ₹{amount}."
Priority: High
Sound: alert.mp3
```

### 6.4 Tier Upgraded
```
Title: "🎊 Tier Upgraded!"
Body: "Congratulations! You've been upgraded to {newTier} tier with {points} points!"
Priority: High
Sound: celebration.mp3
```

### 6.5 Daily Spin Won
```
Title: "🎰 Spin Result"
Body: "You won {points} points from today's spin!"
Priority: Normal
Sound: default
```

### 6.6 Offer Redeemed
```
Title: "Offer Redeemed"
Body: "You've successfully redeemed {offerTitle}. {points} points deducted."
Priority: Normal
Sound: default
```

### 6.7 New Offer Available
```
Title: "🎁 New Offer Available!"
Body: "{offerTitle} - Redeem for {points} points"
Priority: Normal
Sound: default
```

---

## 7. Technical Setup Requirements

### 7.1 Firebase Cloud Functions Setup

**Required:**
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Initialize Functions: `firebase init functions`
3. Create notification sending function
4. Deploy: `firebase deploy --only functions`

**Function Structure:**
```javascript
// functions/index.js
exports.sendNotification = functions.https.onCall(async (data, context) => {
  // Verify admin authentication
  // Get user FCM token from Firestore
  // Send notification via FCM Admin SDK
  // Return success/failure
});
```

### 7.2 Android Configuration

**Already Configured:**
- ✅ `google-services.json` present
- ✅ Firebase Messaging dependency in `build.gradle.kts`

**Additional Requirements:**
- Notification channels setup (Android 8.0+)
- Notification icons (small and large)
- Sound files for custom notifications

### 7.3 iOS Configuration (If needed in future)

**Requirements:**
- APNs certificate or key in Firebase Console
- Push notification capability enabled in Xcode
- Notification permissions handling (already in code)

---

## 8. Integration Points

### 8.1 BillService Integration

**File:** `lib/services/bill_service.dart`

**Integration Points:**
1. **Line ~485** - After `batch.commit()` in `approveBill()`
   - Call notification service to send "Bill Approved" notification

2. **Line ~554** - After `rejectBill()` succeeds
   - Call notification service to send "Bill Rejected" notification

3. **Line ~712** - After `batch.commit()` in `withdrawBill()`
   - Call notification service to send "Points Withdrawn" notification

### 8.2 OfferService Integration

**File:** `lib/services/offer_service.dart`

**Integration Points:**
1. **Line ~330** - After `batch.commit()` in `redeemOffer()`
   - Call notification service to send "Offer Redeemed" notification

### 8.3 DailySpinProvider Integration

**File:** `lib/presentation/providers/daily_spin_provider.dart`

**Integration Points:**
1. **Line ~238** - After `batch.commit()` in `performSpin()`
   - Call notification service to send "Daily Spin Won" notification
   - Check for tier upgrade and send notification if applicable

### 8.4 Tier Change Detection

**Implementation:**
- Add tier comparison logic in all points update operations
- Compare old tier vs new tier
- Send tier upgrade notification if changed

**Locations:**
- `BillService.approveBill()` - Line ~353
- `BillService.withdrawBill()` - Line ~634
- `DailySpinProvider.performSpin()` - Line ~173
- `OfferService.redeemOffer()` - Check tier after points deduction

---

## 9. Notification Preferences

### 9.1 User Settings UI

**New Screen:** Notification Settings Page

**Features:**
- Toggle switches for each notification type
- Master enable/disable switch
- Preview notification sounds
- Test notification button

**Location:** Add to Profile/Settings section

### 9.2 Firestore Rules Update

**Required Rule Addition:**
```javascript
// Allow users to update their notification preferences
allow update: if request.resource.data.phone == resource.data.phone
              && request.resource.data.keys().hasAll(['notificationPreferences']);
```

---

## 10. Testing Requirements

### 10.1 Test Scenarios

1. **Token Management**
   - ✅ Token saved on app launch
   - ✅ Token updated on refresh
   - ✅ Token deleted on logout
   - ✅ Token saved for PIN-based auth users

2. **Notification Delivery**
   - ✅ Foreground notifications display
   - ✅ Background notifications display
   - ✅ Terminated app notifications work
   - ✅ Notification tap navigation works

3. **Notification Types**
   - ✅ Bill approved notification
   - ✅ Bill rejected notification
   - ✅ Points withdrawn notification
   - ✅ Tier upgraded notification
   - ✅ Daily spin notification
   - ✅ Offer redeemed notification

4. **Edge Cases**
   - ✅ User with no FCM token (graceful failure)
   - ✅ Multiple devices (token updates)
   - ✅ Notification preferences disabled
   - ✅ Network failure handling

---

## 11. Security Considerations

### 11.1 API Key Protection

**Critical:**
- ❌ Never expose FCM server key in client code
- ✅ Use Cloud Functions for sending notifications
- ✅ Implement authentication in Cloud Functions
- ✅ Verify admin role before sending notifications

### 11.2 User Privacy

**Requirements:**
- ✅ Users can opt-out of notifications
- ✅ Respect notification preferences
- ✅ Don't send notifications if user disabled them
- ✅ Clear token on logout

---

## 12. Performance Considerations

### 12.1 Batch Notifications

**Scenario:** Sending to multiple users (e.g., new offer)

**Solution:**
- Use FCM topic messaging for broadcasts
- Or batch API calls in Cloud Functions
- Limit to 1000 recipients per batch

### 12.2 Rate Limiting

**Considerations:**
- Don't spam users with too many notifications
- Implement cooldown periods
- Group related notifications

---

## 13. Monitoring & Analytics

### 13.1 Metrics to Track

1. **Delivery Metrics**
   - Notification sent count
   - Delivery success rate
   - Delivery failure reasons

2. **Engagement Metrics**
   - Notification open rate
   - Time to open
   - Action taken after opening

3. **User Metrics**
   - Users with FCM tokens
   - Users with notifications enabled
   - Notification preference distribution

### 13.2 Logging

**Implementation:**
- Log all notification sends to Firestore
- Track delivery status
- Monitor errors and failures

---

## 14. Cost Estimation

### 14.1 Firebase Cloud Messaging

**Free Tier:**
- Unlimited notifications
- No cost for FCM service

### 14.2 Cloud Functions

**Pricing:**
- First 2 million invocations/month: Free
- $0.40 per million invocations after

**Estimated Usage:**
- ~100 notifications/day = ~3,000/month
- Well within free tier

### 14.3 Firestore

**Additional Reads/Writes:**
- Token storage: Minimal
- Notification logs: Optional
- Negligible cost impact

**Total Estimated Cost:** $0 (within free tiers)

---

## 15. Implementation Checklist

### Phase 1: Foundation
- [ ] Fix FCM token saving for PIN-based auth
- [ ] Complete background handler initialization
- [ ] Add `flutter_local_notifications` package
- [ ] Setup local notification channels
- [ ] Test basic notification delivery
- [ ] Verify token storage in Firestore

### Phase 2: Core Notifications
- [ ] Setup Firebase Cloud Functions
- [ ] Create NotificationService (Cloud Function)
- [ ] Integrate bill approval notification
- [ ] Integrate bill rejection notification
- [ ] Integrate points withdrawal notification
- [ ] Implement deep linking/navigation
- [ ] Test all notification flows

### Phase 3: Enhanced Features
- [ ] Tier upgrade detection and notification
- [ ] Daily spin notification
- [ ] Offer redemption notification
- [ ] Notification preferences UI
- [ ] Firestore rules for preferences

### Phase 4: Advanced Features
- [ ] New offer broadcast notifications
- [ ] Scheduled notifications (daily reminders)
- [ ] Points milestone notifications
- [ ] Notification analytics/logging
- [ ] Admin notification dashboard (optional)

---

## 16. Dependencies to Add

### 16.1 Required Packages

```yaml
dependencies:
  flutter_local_notifications: ^17.2.3  # For local notification display
  # firebase_messaging: ^16.0.4  # Already added ✅
```

### 16.2 Optional Packages

```yaml
dependencies:
  timezone: ^0.9.4  # For scheduled notifications
  flutter_native_timezone: ^2.0.0  # For timezone detection
```

---

## 17. Files to Create/Modify

### 17.1 New Files to Create

1. **`lib/services/notification_service.dart`**
   - Service to call Cloud Functions for sending notifications
   - Handle notification preferences
   - Queue notifications

2. **`lib/presentation/screens/settings/notification_settings_page.dart`**
   - UI for notification preferences
   - Toggle switches for each type

3. **`functions/index.js`** (Cloud Functions)
   - FCM notification sending function
   - Authentication and validation

4. **`functions/package.json`** (Cloud Functions)
   - Dependencies for Cloud Functions

### 17.2 Files to Modify

1. **`lib/services/fcm_service.dart`**
   - Fix token saving for PIN-based auth
   - Complete navigation handler
   - Add local notification display

2. **`lib/services/bill_service.dart`**
   - Add notification calls after bill approval/rejection/withdrawal

3. **`lib/services/offer_service.dart`**
   - Add notification call after offer redemption

4. **`lib/presentation/providers/daily_spin_provider.dart`**
   - Add notification call after spin
   - Add tier upgrade detection

5. **`lib/main.dart`**
   - Ensure background handler is properly registered
   - Initialize local notifications

6. **`pubspec.yaml`**
   - Add `flutter_local_notifications` package

7. **`firestore.rules`**
   - Add rules for notification preferences

---

## 18. Notification Priority Matrix

| Notification Type | Priority | Frequency | User Impact |
|------------------|----------|-----------|-------------|
| Bill Approved | HIGH | Per bill | Very High - User needs to know immediately |
| Bill Rejected | HIGH | Per bill | High - User needs to resubmit |
| Points Withdrawn | HIGH | Rare | High - Important account change |
| Tier Upgraded | HIGH | Rare | Very High - Achievement moment |
| Daily Spin Won | MEDIUM | Daily | Medium - Engagement |
| Offer Redeemed | MEDIUM | Per redemption | Low - Confirmation |
| New Offer | LOW | Per new offer | Medium - Marketing |
| Daily Reminder | LOW | Daily | Low - Engagement |

---

## 19. Success Metrics

### 19.1 Key Performance Indicators (KPIs)

1. **Adoption Rate**
   - % of users with FCM tokens registered
   - Target: >90% within 1 month

2. **Delivery Rate**
   - % of notifications successfully delivered
   - Target: >95%

3. **Engagement Rate**
   - % of notifications opened
   - Target: >60% for critical notifications

4. **User Satisfaction**
   - Users enabling/disabling notifications
   - Target: <10% opt-out rate

---

## 20. Risk Assessment

### 20.1 Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Token not saved for PIN users | High | Medium | Fix token saving logic |
| Notifications not delivered | High | Low | Implement retry logic |
| Background handler fails | Medium | Low | Proper error handling |
| Cloud Functions quota exceeded | Low | Very Low | Monitor usage |

### 20.2 User Experience Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Too many notifications (spam) | High | Medium | Implement preferences, rate limiting |
| Users disable all notifications | Medium | Low | Make notifications valuable |
| Notification fatigue | Medium | Medium | Smart scheduling, grouping |

---

## 21. Timeline Estimate

### Phase 1: Foundation (3-5 days)
- Fix FCM token management
- Setup local notifications
- Basic testing

### Phase 2: Core Notifications (5-7 days)
- Cloud Functions setup
- Integrate bill notifications
- Deep linking implementation

### Phase 3: Enhanced Features (3-5 days)
- Tier, spin, offer notifications
- Preferences UI

### Phase 4: Advanced Features (3-5 days)
- Scheduled notifications
- Analytics
- Polish and testing

**Total Estimated Time:** 14-22 days (2-3 weeks)

---

## 22. Next Steps

### Immediate Actions (This Week)

1. **Review and Approve Plan**
   - Review this document
   - Prioritize notification types
   - Approve implementation approach

2. **Setup Cloud Functions** (If approved)
   - Install Firebase CLI
   - Initialize functions project
   - Create basic notification function

3. **Fix FCM Token Management**
   - Update `FCMService` to work with PIN-based auth
   - Test token saving for all users

4. **Add Local Notifications Package**
   - Add `flutter_local_notifications` to `pubspec.yaml`
   - Initialize in `main.dart`
   - Test basic notification display

### Short-term (Next 2 Weeks)

5. Implement Phase 1 & 2
6. Test with real users
7. Gather feedback
8. Iterate and improve

---

## 23. Conclusion

The Balaji Points application has a solid foundation for push notifications with FCM already integrated. The main work involves:

1. **Completing the infrastructure** (token management, local notifications)
2. **Creating notification sending service** (Cloud Functions recommended)
3. **Integrating with user actions** (bill approval, tier changes, etc.)
4. **Adding user controls** (preferences, settings)

**Recommended Approach:** Start with Phase 1 (Foundation) and Phase 2 (Core Notifications) focusing on bill approval/rejection notifications as they are the most critical user-facing actions.

**Estimated Effort:** 2-3 weeks for full implementation with testing.

---

## Appendix A: Notification Data Payload Examples

### Bill Approved
```json
{
  "notification": {
    "title": "🎉 Bill Approved!",
    "body": "Your bill of ₹100000 has been approved. You earned 100 points!"
  },
  "data": {
    "type": "bill_approved",
    "billId": "abc123",
    "amount": 100000,
    "points": 100,
    "action": "view_bill",
    "screen": "/wallet"
  }
}
```

### Tier Upgraded
```json
{
  "notification": {
    "title": "🎊 Tier Upgraded!",
    "body": "Congratulations! You've been upgraded to Silver tier with 2500 points!"
  },
  "data": {
    "type": "tier_upgraded",
    "oldTier": "Bronze",
    "newTier": "Silver",
    "points": 2500,
    "action": "view_profile",
    "screen": "/profile"
  }
}
```

---

**Document Version:** 1.0
**Last Updated:** January 5, 2025
**Author:** AI Assistant
**Status:** Ready for Review

