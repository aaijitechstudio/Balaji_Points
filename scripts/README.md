# Firebase Database Seeder

Quick script to populate your Balaji Points Firebase database with test data.

## 🚀 Quick Start

```bash
# 1. Get service account key from Firebase Console
# 2. Save as serviceAccountKey.json in this folder
# 3. Install dependencies
npm install

# 4. Run the seeder
npm run seed
```

## 📊 What Gets Created?

- **50 test users** (carpenters with varying points & tiers)
- **20 offers** (with banners & descriptions)
- **~1000 points transactions** (earned, redeemed, bonus, penalty)
- **~300 spin records** (daily spin wheel history)

## 📖 Full Documentation

See **[SEED_DATA_GUIDE.md](../SEED_DATA_GUIDE.md)** for detailed instructions.

## ⚠️ Security Note

**NEVER commit `serviceAccountKey.json` to Git!**

It's already in `.gitignore` - keep it that way.
