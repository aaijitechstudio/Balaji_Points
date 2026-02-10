# Leaderboard Top 3 - Verification Guide

## 🔍 How to Verify Top 3 Carpenters are Correct

### Step 1: Check Firebase Data
1. Open Firebase Console
2. Go to Firestore Database
3. Check `users` collection
4. Filter by `role == 'carpenter'`
5. Sort by `points` field (descending)
6. Note the top 3 names and their points

### Step 2: Check App Logs
When you run the app, look for these logs in the console:

```
=== REPOSITORY LOG ===
Carpenters sorted by points:
  total: X
  top3: [
    "Name1: XXX pts",
    "Name2: XXX pts", 
    "Name3: XXX pts"
  ]

users (carpenters success):
  count: X
  top3_names: ["Name1", "Name2", "Name3"]
  top3_points: [XXX, XXX, XXX]

=== BLOC LOG ===
HomeBloc: Leaderboard data received:
  topCarpenters_count: X
  top3_names: ["Name1", "Name2", "Name3"]
  top3_points: [XXX, XXX, XXX]
  top3_ranks: [1, 2, 3]

=== PODIUM DISPLAY ===
1st: Name1 - XXX pts (Rank: 1)
2nd: Name2 - XXX pts (Rank: 2)
3rd: Name3 - XXX pts (Rank: 3)
```

### Step 3: Verify UI Display
The podium should show (left to right):
```
   🥈           🥇           🥉
  2ND         1ST          3RD
(shorter)   (tallest)   (shortest)
```

**IMPORTANT**: The visual layout is:
- **LEFT**: 2nd place (silver medal)
- **CENTER**: 1st place (gold medal, tallest)
- **RIGHT**: 3rd place (bronze medal)

This is standard podium display order used in Olympics and competitions.

---

## 🔄 Data Flow

```
Firebase Firestore
  ↓
  Query: role == 'carpenter'
  ↓
HomeRepository.loadTopCarpenters()
  ↓
  Fetch all carpenters
  ↓
  Sort by points: b.points - a.points (descending)
  ↓
  Assign ranks: 1, 2, 3, ...
  ↓
  Return top 20
  ↓
HomeBloc
  ↓
  Emit state with topCarpenters list
  ↓
LeaderboardPreview widget
  ↓
  Take first 3: topCarpenters.take(3)
  ↓
PodiumDisplay widget
  ↓
  Display in podium order:
    [0] = 1st place (center)
    [1] = 2nd place (left)
    [2] = 3rd place (right)
```

---

## 🐛 Common Issues & Solutions

### Issue 1: Wrong Order Displayed
**Symptoms**: Names don't match Firebase order
**Causes**:
- Repository not sorting correctly
- BLoC modifying order
- Widget displaying wrong indices

**Check**:
1. Look at logs to see where order breaks
2. Verify Firebase has correct data
3. Check if points field is actually integer (not string)

### Issue 2: Old Data Displayed
**Symptoms**: Points don't match current Firebase values
**Causes**:
- Cache not cleared
- App not refreshing

**Solution**:
- Pull to refresh on home page
- Check last refresh timestamp in logs
- Force close and reopen app

### Issue 3: Missing Carpenters
**Symptoms**: Less than 3 carpenters shown
**Causes**:
- Not enough carpenters with role='carpenter' in Firebase
- Names are empty (skipped in query)

**Solution**:
- Check Firebase for carpenter count
- Verify firstName/lastName fields exist
- Check logs for "count" value

---

## 📝 Code Reference

### Repository Sorting (home_repository.dart:86)
```dart
// Sort by points descending (highest first)
carpenters.sort((a, b) => b.points.compareTo(a.points));
```

### Rank Assignment (home_repository.dart:89-91)
```dart
// Assign ranks based on sorted order
for (int i = 0; i < carpenters.length; i++) {
  carpenters[i] = carpenters[i].copyWith(rank: i + 1);
}
```

### Podium Display (podium_display.dart:34-36)
```dart
final first = topCarpenters[0];  // Highest points
final second = topCarpenters[1]; // 2nd highest
final third = topCarpenters[2];  // 3rd highest
```

---

## ✅ Expected Behavior

### If Firebase has:
| Name | Points | Rank |
|------|--------|------|
| John | 3200   | 1    |
| Sarah| 2450   | 2    |
| Mike | 1800   | 3    |

### Logs should show:
```
top3_names: ["John", "Sarah", "Mike"]
top3_points: [3200, 2450, 1800]
top3_ranks: [1, 2, 3]
```

### Podium should display:
```
     🥈              🥇              🥉
    Sarah          John            Mike
   2,450 pts     3,200 pts       1,800 pts
   ┌──────┐      ┌──────┐       ┌──────┐
   │  2   │      │  1   │       │  3   │
   │ 85px │      │110px │       │ 70px │
   └──────┘      └──────┘       └──────┘
    (LEFT)       (CENTER)        (RIGHT)
```

---

## 🧪 Manual Test Steps

1. **Open app** and go to Home page
2. **Check console logs** for data flow
3. **Compare** Firebase data with logs
4. **Verify** podium matches expectations
5. **Pull to refresh** to ensure data updates
6. **Take screenshot** if issue persists

---

## 📸 What to Send if Issue Persists

1. Screenshot of Firebase data (users collection, sorted by points)
2. Screenshot of app console logs showing:
   - Repository log
   - BLoC log
   - Podium display log
3. Screenshot of UI showing the podium
4. Describe what's wrong (e.g., "Shows wrong name in 1st place")

---

**Current Status**: Debugging logs added ✅  
**Build**: Successful ✅  
**Next**: Run app and check logs
