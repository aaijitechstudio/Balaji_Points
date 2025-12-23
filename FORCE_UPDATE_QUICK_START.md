# Force Update - Quick Start Guide

## 🚀 Quick Implementation Checklist

### Step 1: Firebase Setup (5 minutes)
1. Open Firebase Console → Firestore Database
2. Create collection: `app_version`
3. Create document: `current`
4. Add initial data:
   ```json
   {
     "minimumVersion": "1.0.0",
     "minimumBuildNumber": 2,
     "latestVersion": "1.0.0",
     "latestBuildNumber": 2,
     "forceUpdate": false,
     "enabled": true,
     "updateMessage": "A new version is available. Please update to continue.",
     "playStoreUrl": "https://play.google.com/store/apps/details?id=com.balaji.points",
     "lastUpdated": [Server Timestamp]
   }
   ```

### Step 2: Create Service (30 minutes)
- Create `lib/services/app_version_service.dart`
- Implement version fetching and comparison
- Add caching (1 hour)

### Step 3: Create Dialog Widget (30 minutes)
- Create `lib/presentation/widgets/force_update_dialog.dart`
- Design non-dismissible dialog for force updates
- Add Play Store deep linking

### Step 4: Integrate in App (15 minutes)
- Add version check in `main.dart` or `app.dart`
- Check on app start and resume
- Show dialog if update required

### Step 5: Test (30 minutes)
- Test with different versions
- Test force vs optional update
- Test error scenarios

---

## 📋 When Releasing New Version

### For Critical Updates (Force Update)
1. Update Firestore `current` document:
   ```json
   {
     "minimumVersion": "1.0.1",
     "minimumBuildNumber": 3,
     "latestVersion": "1.0.1",
     "latestBuildNumber": 3,
     "forceUpdate": true,
     "updateMessage": "Critical security update. Please update now."
   }
   ```

2. Deploy new version to Play Store
3. Monitor update adoption

### For Regular Updates (Optional)
1. Update Firestore:
   ```json
   {
     "latestVersion": "1.0.1",
     "latestBuildNumber": 3,
     "forceUpdate": false
   }
   ```

2. Deploy to Play Store
3. Users will see optional update prompt

---

## 🔧 Firestore Rules

```javascript
match /app_version/{document} {
  allow read: if true;
  allow write: if false; // Update via Firebase Console only
}
```

---

## 📱 Play Store URL Format

```
https://play.google.com/store/apps/details?id=com.balaji.points
```

Deep link (try first):
```
market://details?id=com.balaji.points
```

---

## ⚠️ Important Notes

1. **Always increment build number** in `pubspec.yaml` when releasing
2. **Test force update** in staging before enabling in production
3. **Monitor Firestore reads** - use caching to reduce costs
4. **Keep messages clear** and user-friendly
5. **Don't block users** if version check fails (graceful degradation)

---

## 🐛 Troubleshooting

**Users not updating?**
- Check `forceUpdate` is set to `true`
- Verify build number is correct
- Check Play Store URL is correct

**App blocked incorrectly?**
- Verify version comparison logic
- Check Firestore data is correct
- Clear app cache and retry

**Play Store not opening?**
- Verify package name matches
- Check device has Play Store installed
- Test deep link format

---

## 📊 Monitoring

Track these metrics:
- Version check success rate
- Update dialog display count
- "Update Now" button clicks
- Update completion rate
- Error rates

---

**Ready to implement?** See `FORCE_UPDATE_IMPLEMENTATION_PLAN.md` for detailed guide.

