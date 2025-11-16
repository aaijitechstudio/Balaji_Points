# Firestore Cloud Database Setup Guide

## Step-by-Step Firebase Firestore Setup

### Prerequisites

- Firebase project already created (balajipoints)
- FlutterFire CLI installed (or Firebase Console access)
- Flutter project with Firebase initialized

---

## 1. Enable Firestore Database in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **balajipoints**
3. Navigate to **Build** → **Firestore Database**
4. Click **Create Database**
5. Choose **Start in test mode** (for development) or **Production mode** (with security rules)
6. Select your preferred **Cloud Firestore location** (e.g., `us-central1`)
7. Click **Enable**

---

## 2. Configure Security Rules

Go to **Firestore Database** → **Rules** tab and add:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Pending users collection - readable by admin, writable by anyone
    match /pending_users/{phoneNumber} {
      allow read: if isAdmin();
      allow write: if true; // Anyone can create pending user
      allow update, delete: if isAdmin(); // Only admin can update/delete
    }

    // Verified users collection - readable by all authenticated users
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if isAdmin(); // Only admin can create verified users
      allow update: if request.auth.uid == userId || isAdmin();
      allow delete: if isAdmin();
    }

    // User points and daily spin data
    match /user_points/{userId} {
      allow read: if request.auth != null;
      allow write: if isAdmin() || request.auth.uid == userId;
    }

    // Daily spin records
    match /daily_spins/{spinId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 3. Database Collections Structure

### Collection: `pending_users`

**Document ID**: Phone Number (e.g., `9876543210`)

```json
{
  "firstName": "Ramesh",
  "lastName": "Patel",
  "phone": "9876543210",
  "role": "carpenter",
  "status": "pending",
  "createdAt": "2024-01-15T10:30:00Z",
  "city": "Erode", // Optional
  "skill": "Cabinet Making", // Optional
  "referral": "REF123" // Optional
}
```

### Collection: `users`

**Document ID**: Firebase Auth UID

```json
{
  "uid": "firebase-auth-uid",
  "firstName": "Ramesh",
  "lastName": "Patel",
  "phone": "9876543210",
  "role": "carpenter",
  "status": "verified",
  "verifiedAt": "2024-01-16T09:00:00Z",
  "verifiedBy": "admin-uid",
  "totalPoints": 1250,
  "tier": "Silver",
  "city": "Erode",
  "skill": "Cabinet Making",
  "referral": "REF123",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

### Collection: `user_points`

**Document ID**: User ID

```json
{
  "userId": "firebase-auth-uid",
  "totalPoints": 1250,
  "tier": "Silver",
  "lastUpdated": "2024-01-16T09:00:00Z",
  "pointsHistory": [
    {
      "points": 100,
      "reason": "Purchase reward",
      "date": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### Collection: `daily_spins`

**Document ID**: Auto-generated

```json
{
  "userId": "firebase-auth-uid",
  "phone": "9876543210",
  "spinnerDate": "2024-01-16",
  "spunAt": "2024-01-16T10:30:00Z",
  "pointsWon": 50
}
```

---

## 4. Indexes Required

Firestore may require indexes for queries. Create indexes in **Firestore** → **Indexes**:

1. **daily_spins** collection:

   - Fields: `phone` (Ascending), `spinnerDate` (Ascending)
   - Query Scope: Collection

2. **users** collection:
   - Fields: `status` (Ascending), `totalPoints` (Descending)
   - Query Scope: Collection

---

## 5. Admin User Setup

To create the first admin user, manually add a document to `users` collection:

1. Create a user account in Firebase Authentication (email/password or phone)
2. Go to Firestore → `users` collection
3. Create a document with the user's Firebase Auth UID as document ID
4. Add fields:
   ```json
   {
     "uid": "admin-uid-here",
     "role": "admin",
     "firstName": "Admin",
     "lastName": "User",
     "phone": "admin-phone",
     "status": "verified",
     "createdAt": "2024-01-01T00:00:00Z"
   }
   ```

---

## 6. Testing Firestore Connection

Use Firebase Console to:

1. Navigate to **Firestore Database** → **Data** tab
2. Click **Start collection**
3. Create a test collection and document
4. Verify data appears in your Flutter app

---

## 7. Admin Verification Flow

**Manual Process (via Firebase Console)**:

1. Go to `pending_users` collection
2. Review the pending user document
3. Copy the user data
4. Create a new document in `users` collection with Firebase Auth UID
5. Delete or update status in `pending_users` to `approved` or delete the document

**Automated Process (via Admin Panel - To be implemented)**:

- Admin approves user → Document moves from `pending_users` to `users`
- User receives notification (via FCM - Future implementation)

---

## Security Best Practices

1. **Never expose Admin credentials in client code**
2. **Use Firebase Security Rules** to protect sensitive data
3. **Validate phone numbers** before creating documents
4. **Use server timestamps** (`FieldValue.serverTimestamp()`) for dates
5. **Implement rate limiting** for signup attempts
6. **Use Firebase App Check** in production (future enhancement)

---

## Troubleshooting

### Issue: "Permission denied" errors

- **Solution**: Check Firestore Security Rules and ensure they match your access patterns

### Issue: Missing indexes

- **Solution**: Check Firestore Console → Indexes for missing composite indexes

### Issue: Cannot read/write data

- **Solution**: Verify Firebase initialization in your app and check authentication state

---

## Next Steps

1. Implement phone authentication (OTP verification)
2. Create admin panel for user verification
3. Add push notifications for approval status
4. Implement points tracking system
5. Add daily spin validation
