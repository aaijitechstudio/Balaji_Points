# 📋 Manual Testing Checklist

**Before Production Deployment**

---

## Pre-Testing Setup

- [ ] Build release APK: `flutter build apk --release`
- [ ] Install APK on physical device
- [ ] Clear app data (Settings → Apps → Balaji Points → Storage → Clear Data)
- [ ] Ensure device has internet connection

---

## 1. Authentication Flow ✅

### First-Time User (PIN Setup)
- [ ] Open app (should show login screen)
- [ ] Enter valid 10-digit phone number (e.g., 9876543210)
- [ ] Tap "Continue with PIN"
- [ ] **Verify:** Navigates to PIN Setup screen
- [ ] Enter first name, last name (optional)
- [ ] Set 4-digit PIN (e.g., 1234)
- [ ] Confirm PIN by entering again
- [ ] **Verify:** Account created successfully
- [ ] **Verify:** Redirected to home/wallet screen
- [ ] **Verify:** Welcome message shown

### Existing User (PIN Login)
- [ ] Logout from current session
- [ ] Enter same phone number as before
- [ ] **Verify:** Navigates to PIN Login screen (NOT PIN Setup)
- [ ] Enter correct PIN
- [ ] **Verify:** Logged in successfully
- [ ] **Verify:** User data loaded (name, points)

### Wrong PIN
- [ ] Enter wrong PIN 3 times
- [ ] **Verify:** Error message shown
- [ ] **Verify:** Account NOT locked (can try again)

### Session Persistence
- [ ] Login with "Remember Me" checked
- [ ] Close app completely
- [ ] Reopen app
- [ ] **Verify:** Auto-logged in (no login screen)

---

## 2. Wallet Screen ✅

### Points Display
- [ ] Open wallet screen
- [ ] **Verify:** Total points displayed correctly
- [ ] **Verify:** Tier badge shown (Bronze/Silver/Gold)
- [ ] **Verify:** Pending bills count correct
- [ ] **Verify:** Approved bills count correct

### Refresh
- [ ] Pull down to refresh
- [ ] **Verify:** Loading indicator shown
- [ ] **Verify:** Data refreshes

### Recent Bills List
- [ ] **Verify:** Recent 10 bills shown
- [ ] **Verify:** Bill status displayed (Pending/Approved/Rejected)
- [ ] **Verify:** Bill amounts shown
- [ ] **Verify:** Dates formatted correctly
- [ ] Tap on a bill
- [ ] **Verify:** Navigates to bill details

---

## 3. Bill Submission ✅

### Take Photo
- [ ] Tap "Submit Bill" button
- [ ] Grant camera permissions (if requested)
- [ ] Tap "Take Photo"
- [ ] **Verify:** Camera opens
- [ ] Take photo of a bill
- [ ] **Verify:** Photo preview shown
- [ ] Enter bill amount (e.g., 1500)
- [ ] Enter store name (optional)
- [ ] Enter bill number (optional)
- [ ] Add notes (optional)
- [ ] Tap "Submit"
- [ ] **Verify:** Loading indicator shown
- [ ] **Verify:** Success message shown
- [ ] **Verify:** Navigates back to wallet
- [ ] **Verify:** New bill appears in pending list

### Select from Gallery
- [ ] Tap "Submit Bill" → "Choose from Gallery"
- [ ] Select image from gallery
- [ ] **Verify:** Image preview shown
- [ ] Complete submission
- [ ] **Verify:** Submission successful

### Validation
- [ ] Try submitting without photo
- [ ] **Verify:** Error: "Please select an image"
- [ ] Try submitting with amount = 0
- [ ] **Verify:** Error: "Amount must be greater than 0"
- [ ] Try submitting with amount > 50000
- [ ] **Verify:** Warning or validation

---

## 4. Bill Details (Carpenter) ✅

### Pending Bill
- [ ] Open a pending bill
- [ ] **Verify:** Status badge shows "Pending"
- [ ] **Verify:** Bill image displayed
- [ ] **Verify:** Amount shown
- [ ] **Verify:** Submission date shown
- [ ] **Verify:** Store name shown (if provided)
- [ ] Tap image to zoom
- [ ] **Verify:** Image viewer opens
- [ ] Pinch to zoom
- [ ] **Verify:** Zoom works

### Approved Bill
- [ ] Open an approved bill
- [ ] **Verify:** Status badge shows "Approved" (green)
- [ ] **Verify:** Points earned shown
- [ ] **Verify:** Approval date shown

### Rejected Bill
- [ ] Open a rejected bill
- [ ] **Verify:** Status badge shows "Rejected" (red)
- [ ] **Verify:** Rejection reason shown

---

## 5. Profile Screen ✅

### View Profile
- [ ] Tap profile icon/menu
- [ ] **Verify:** Name displayed
- [ ] **Verify:** Phone number displayed
- [ ] **Verify:** Profile picture shown (if uploaded)
- [ ] **Verify:** Total points shown
- [ ] **Verify:** Member since date shown

### Edit Profile
- [ ] Tap "Edit Profile"
- [ ] Change first name
- [ ] Change last name
- [ ] **Verify:** Save button enabled
- [ ] Tap "Save"
- [ ] **Verify:** Profile updated successfully
- [ ] **Verify:** Changes reflected immediately

### Change Profile Picture
- [ ] Tap profile picture
- [ ] Select "Take Photo" or "Choose from Gallery"
- [ ] Select/take photo
- [ ] **Verify:** Image uploads
- [ ] **Verify:** New profile picture shown

### Reset PIN
- [ ] Go to Settings → Reset PIN
- [ ] Enter old PIN
- [ ] Enter new PIN
- [ ] Confirm new PIN
- [ ] **Verify:** PIN reset successfully
- [ ] Logout and login
- [ ] **Verify:** New PIN works

---

## 6. Admin Functions ✅ (If Admin User)

### Pending Bills List
- [ ] Login as admin
- [ ] Go to Admin → Pending Bills
- [ ] **Verify:** All pending bills listed
- [ ] **Verify:** Carpenter names shown
- [ ] **Verify:** Amounts shown
- [ ] **Verify:** Submission dates shown
- [ ] Tap on a bill
- [ ] **Verify:** Bill details open

### Approve Bill
- [ ] Open pending bill
- [ ] **Verify:** Carpenter details shown
- [ ] **Verify:** Bill image displayed
- [ ] Tap "Approve"
- [ ] **Verify:** Confirmation dialog shown
- [ ] **Verify:** Points calculation shown (amount × 0.05)
- [ ] Tap "Confirm"
- [ ] **Verify:** Bill approved successfully
- [ ] **Verify:** Removed from pending list
- [ ] **Verify:** Appears in history
- [ ] Check carpenter's wallet
- [ ] **Verify:** Points added correctly

### Reject Bill
- [ ] Open pending bill
- [ ] Tap "Reject"
- [ ] **Verify:** Reason dialog shown
- [ ] Enter rejection reason
- [ ] Tap "Reject"
- [ ] **Verify:** Bill rejected successfully
- [ ] **Verify:** Removed from pending list
- [ ] Check carpenter's view
- [ ] **Verify:** Bill shows as rejected with reason

### Submit Bill for Carpenter (Admin)
- [ ] Go to Admin → Add Bill
- [ ] Select carpenter from list
- [ ] **Verify:** Carpenter list loads
- [ ] Take/select photo
- [ ] Enter bill details
- [ ] Tap "Submit"
- [ ] **Verify:** Bill submitted for carpenter
- [ ] Check carpenter's wallet
- [ ] **Verify:** Bill appears in their pending list

### Admin Dashboard
- [ ] Open admin dashboard
- [ ] **Verify:** Total pending bills count
- [ ] **Verify:** Today's submissions count
- [ ] **Verify:** Total carpenters count
- [ ] **Verify:** Statistics displayed correctly

---

## 7. Notifications ✅

### Bill Approved Notification
- [ ] Have admin approve a bill
- [ ] **Verify:** Notification received (if FCM configured)
- [ ] Tap notification
- [ ] **Verify:** Opens bill details
- [ ] Go to Notifications screen
- [ ] **Verify:** Notification listed
- [ ] **Verify:** "Bill Approved" title
- [ ] **Verify:** Amount and points shown

### Bill Rejected Notification
- [ ] Have admin reject a bill
- [ ] **Verify:** Notification received
- [ ] **Verify:** Rejection reason in notification

### Mark as Read
- [ ] Tap on unread notification
- [ ] **Verify:** Notification marked as read
- [ ] **Verify:** Visual indicator changes

---

## 8. Navigation & Back Button ✅

### Navigation Bar
- [ ] Tap each tab (Wallet, Bills, Profile)
- [ ] **Verify:** Correct screen shown
- [ ] **Verify:** Active tab highlighted

### Back Navigation
- [ ] Navigate deep into app (Home → Bills → Bill Details)
- [ ] Press back button
- [ ] **Verify:** Returns to previous screen
- [ ] Continue pressing back
- [ ] **Verify:** Returns to home
- [ ] Press back on home
- [ ] **Verify:** Exit confirmation dialog shown
- [ ] Tap "Stay"
- [ ] **Verify:** Dialog closes
- [ ] Press back again → "Exit"
- [ ] **Verify:** App closes

---

## 9. Edge Cases ✅

### Network Issues
- [ ] Turn off WiFi and mobile data
- [ ] Try to submit bill
- [ ] **Verify:** Error message: "No internet connection"
- [ ] Turn on internet
- [ ] Try again
- [ ] **Verify:** Works correctly

### Low Storage
- [ ] (If possible) Fill device storage
- [ ] Try to submit bill with photo
- [ ] **Verify:** Appropriate error message

### Large Image
- [ ] Select very large image (10+ MB)
- [ ] **Verify:** Image compression works
- [ ] **Verify:** Upload succeeds

### Long Text
- [ ] Enter very long notes (500+ chars)
- [ ] **Verify:** Text field handles it
- [ ] **Verify:** Submission works

### Rapid Tapping
- [ ] Rapidly tap "Submit" button multiple times
- [ ] **Verify:** Only one submission created
- [ ] **Verify:** Button disabled during submission

### Session Expiry
- [ ] Login to app
- [ ] Leave app idle for long time (or change system time)
- [ ] Try to perform action
- [ ] **Verify:** Session handled gracefully

---

## 10. Performance ✅

### App Launch
- [ ] Close app completely
- [ ] Launch app
- [ ] **Verify:** Splash screen shows
- [ ] **Verify:** App loads in < 3 seconds

### Screen Transitions
- [ ] Navigate between screens
- [ ] **Verify:** Transitions smooth
- [ ] **Verify:** No lag or stuttering

### Image Loading
- [ ] Scroll through bills list with images
- [ ] **Verify:** Images load smoothly
- [ ] **Verify:** Placeholders shown while loading

### Animations
- [ ] Observe login screen animations
- [ ] **Verify:** Floating elements animate smoothly
- [ ] **Verify:** No janky animations

---

## 11. Logging Verification ✅

### Check Logs (via adb logcat or IDE)

**Debug Build:**
- [ ] **Verify:** Debug logs visible (Logger.d)
- [ ] **Verify:** Info logs visible (Logger.i)
- [ ] **Verify:** Error logs visible with stack traces (Logger.e)

**Release Build:**
- [ ] **Verify:** Debug logs NOT visible (auto-disabled)
- [ ] **Verify:** Info logs still visible
- [ ] **Verify:** Error logs still visible

**Important Events Logged:**
- [ ] User login → `Logger.i('User logged in')`
- [ ] Bill submission → `Logger.i('Bill submitted')`
- [ ] Bill approval → `Logger.i('Bill approved')`
- [ ] Errors → `Logger.e('Error', error: e, stackTrace: st)`

**No Console Spam:**
- [ ] **Verify:** No excessive debug prints
- [ ] **Verify:** No emoji spam in production
- [ ] **Verify:** Only meaningful logs

---

## 12. Language/Localization ✅

### Switch Language
- [ ] On login screen, change language (EN/HI/TA)
- [ ] **Verify:** All text changes
- [ ] Navigate through app
- [ ] **Verify:** All screens translated
- [ ] Submit bill
- [ ] **Verify:** Success/error messages translated

---

## ✅ Sign-Off Checklist

**Before marking as complete, ensure:**

- [ ] All critical user flows tested
- [ ] No crashes or ANRs observed
- [ ] UI looks identical to old version
- [ ] All features work as expected
- [ ] Logging is appropriate (not spammy)
- [ ] Performance is acceptable
- [ ] No sensitive data in logs
- [ ] Release APK built successfully
- [ ] APK tested on multiple devices (if possible)

---

## 🐛 Bug Reporting Template

If you find issues, report them with:

```
**Title:** [Brief description]

**Steps to Reproduce:**
1. Step one
2. Step two
3. ...

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happened

**Screenshots:**
[If applicable]

**Device Info:**
- Model: [e.g., Samsung Galaxy S21]
- Android Version: [e.g., 13]
- App Version: [e.g., 1.0.3]

**Logs:**
[Paste relevant logs from logcat]
```

---

## 📊 Test Results Summary

**Date Tested:** _______________  
**Tester Name:** _______________  
**Device Used:** _______________  
**Android Version:** _______________  
**App Version:** _______________  

**Overall Status:** 
- [ ] ✅ PASS - Ready for production
- [ ] ⚠️ PASS with minor issues - Can deploy with notes
- [ ] ❌ FAIL - Requires fixes before deployment

**Notes:**
```


```

---

**Good luck with testing! 🚀**
