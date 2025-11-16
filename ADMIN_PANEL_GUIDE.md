# Admin Panel Implementation Guide

## Overview

Complete admin panel for managing carpenters, approving accounts, and processing purchase bills.

---

## Features Implemented

### 1. **Admin Home Page** (`/admin`)

- Tabbed interface with 3 sections:
  - **Pending**: Carpenters awaiting approval
  - **Verified**: Approved carpenters list
  - **Bills**: Purchase bill management

### 2. **Pending Carpenters Management**

- View all pending signup requests
- Expandable cards showing:
  - Name, Phone, City, Skill, Referral
  - Request date
- Actions:
  - **Approve**: Creates verified user account
  - **Reject**: Marks request as rejected

### 3. **Verified Users List**

- View all approved carpenters
- Shows:
  - Total points
  - Tier (Bronze/Silver/Gold/Platinum)
  - City, Skill
- **View Details**: Opens detailed view with:
  - Points breakdown
  - All purchase bills
  - Bill status and history

### 4. **Bill Management**

- Filter by status: All, Pending, Approved
- View all bills with:
  - User name and phone
  - Bill amount and calculated points
  - Bill image (if uploaded)
  - Notes
  - Status (Pending/Approved/Rejected)
- Actions:
  - **Approve**: Adds points to user (1000 rs = 1 point)
  - **Reject**: Rejects the bill request

---

## Points Calculation System

### Formula

- **1000 rupees = 1 point**
- Example:
  - ₹5,000 purchase = 5 points
  - ₹15,000 purchase = 15 points
  - ₹23,500 purchase = 23 points (rounded down)

### Tier System

- **Bronze**: 0 - 1,999 points
- **Silver**: 2,000 - 4,999 points
- **Gold**: 5,000 - 9,999 points
- **Platinum**: 10,000+ points

### Points Update Flow

1. Carpenter submits bill with amount
2. System calculates points: `points = amount / 1000` (floored)
3. Admin approves bill
4. Points automatically added to user's total
5. Tier updated if threshold crossed
6. Points history recorded

---

## Firestore Collections

### `bills` Collection

```json
{
  "userId": "firebase-auth-uid",
  "userName": "Ramesh Patel",
  "phone": "9876543210",
  "amount": 15000.0,
  "points": 15,
  "status": "pending" | "approved" | "rejected",
  "billImage": "https://...",
  "notes": "Purchase from store",
  "createdAt": "2024-01-15T10:30:00Z",
  "submittedAt": "2024-01-15T10:30:00Z",
  "approvedAt": "2024-01-16T09:00:00Z",
  "approvedBy": "admin-uid"
}
```

---

## Admin Access

### Setup Admin User

1. Create Firebase Auth account for admin
2. In Firestore → `users` collection:
   - Create document with admin's Firebase Auth UID
   - Set `role: "admin"`
   - Set `status: "verified"`

### Access Admin Panel

- Navigate to `/admin` route
- Or add admin check in app navigation

---

## Carpenter Bill Submission (Future Implementation)

Carpenters will submit bills from their app:

1. Open bill submission form
2. Enter purchase amount
3. Upload bill image (optional)
4. Add notes (optional)
5. Submit → Creates document in `bills` collection with `status: "pending"`
6. Admin reviews and approves/rejects
7. Points automatically updated on approval

---

## Security Rules Update

Add to Firestore Security Rules:

```javascript
// Bills collection
match /bills/{billId} {
  allow read: if request.auth != null &&
              (resource.data.userId == request.auth.uid || isAdmin());
  allow create: if request.auth != null &&
                request.resource.data.userId == request.auth.uid;
  allow update: if isAdmin();
  allow delete: if isAdmin();
}
```

---

## Usage Flow

### Approve New Carpenter:

1. Go to **Pending** tab
2. Expand carpenter card
3. Review details
4. Click **Approve**
5. Confirm → User added to verified list

### Approve Bill:

1. Go to **Bills** tab
2. Filter by "Pending"
3. Expand bill card
4. Review amount, image, notes
5. Click **Approve**
6. Confirm → Points added to user account

### View Carpenter Details:

1. Go to **Verified** tab
2. Expand carpenter card
3. Click **View Details**
4. See points, tier, and all bills

---

## Next Steps (Future Enhancements)

1. **Bill Upload**: Add image upload functionality for carpenters
2. **Notifications**: Push notifications when bill approved/rejected
3. **Export**: Export user data and bills to CSV/PDF
4. **Analytics**: Dashboard with statistics
5. **Search**: Search carpenters by name/phone
6. **Bulk Actions**: Approve/reject multiple items at once
