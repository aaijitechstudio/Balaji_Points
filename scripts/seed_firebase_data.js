/**
 * Firebase Database Seeder Script
 *
 * This script populates your Firebase Firestore with dummy test data:
 * - Test users (carpenters with various tiers)
 * - Offers (promotional offers with banners)
 * - Points history (transactions)
 * - Daily spin records
 *
 * Usage:
 * 1. Install Firebase Admin SDK: npm install firebase-admin
 * 2. Download service account key from Firebase Console
 * 3. Update serviceAccountPath below
 * 4. Run: node seed_firebase_data.js
 */

const admin = require('firebase-admin');

// ===== CONFIGURATION =====
const serviceAccountPath = './serviceAccountKey.json'; // Update this path
const shouldClearExistingData = false; // Set to true to clear before seeding

// Initialize Firebase Admin
try {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('✅ Firebase Admin initialized successfully');
} catch (error) {
  console.error('❌ Error initializing Firebase Admin:', error.message);
  console.log('\n📝 Instructions:');
  console.log('1. Go to Firebase Console > Project Settings > Service Accounts');
  console.log('2. Click "Generate new private key"');
  console.log('3. Save as serviceAccountKey.json in this directory');
  process.exit(1);
}

const db = admin.firestore();

// ===== HELPER FUNCTIONS =====

function randomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randomElement(array) {
  return array[randomInt(0, array.length - 1)];
}

function randomDate(daysAgo) {
  const date = new Date();
  date.setDate(date.getDate() - randomInt(0, daysAgo));
  return admin.firestore.Timestamp.fromDate(date);
}

function getTier(points) {
  if (points >= 10000) return 'Platinum';
  if (points >= 5000) return 'Gold';
  if (points >= 2000) return 'Silver';
  return 'Bronze';
}

// ===== TEST DATA GENERATORS =====

function generateTestUsers(count = 50) {
  const firstNames = [
    'Rajesh', 'Amit', 'Suresh', 'Ramesh', 'Vijay', 'Prakash', 'Dinesh',
    'Manoj', 'Santosh', 'Ashok', 'Ravi', 'Kumar', 'Anil', 'Sanjay',
    'Rahul', 'Pradeep', 'Deepak', 'Mahesh', 'Ganesh', 'Krishna',
    'Vikas', 'Sachin', 'Rohit', 'Ajay', 'Vinod', 'Naveen', 'Pavan',
    'Sunil', 'Arun', 'Kiran', 'Mohan', 'Kishore', 'Bala', 'Surya',
    'Anand', 'Naresh', 'Venkat', 'Gopal', 'Hari', 'Shyam'
  ];

  const lastNames = [
    'Kumar', 'Sharma', 'Singh', 'Patel', 'Reddy', 'Rao', 'Nair',
    'Iyer', 'Gupta', 'Verma', 'Joshi', 'Desai', 'Mehta', 'Shah',
    'Pillai', 'Das', 'Bose', 'Roy', 'Mukherjee', 'Chatterjee',
    'Malhotra', 'Kapoor', 'Chopra', 'Sethi', 'Bansal', 'Agarwal'
  ];

  const cities = [
    'Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata', 'Hyderabad',
    'Pune', 'Ahmedabad', 'Surat', 'Jaipur', 'Lucknow', 'Kanpur',
    'Nagpur', 'Indore', 'Bhopal', 'Visakhapatnam', 'Patna', 'Vadodara'
  ];

  const skills = [
    'Furniture Making', 'Door Installation', 'Window Fitting',
    'Cabinet Making', 'Flooring', 'Ceiling Work', 'General Carpentry',
    'Kitchen Fitting', 'Staircase Building', 'Wood Carving'
  ];

  const users = [];

  for (let i = 0; i < count; i++) {
    const firstName = randomElement(firstNames);
    const lastName = randomElement(lastNames);
    const totalPoints = randomInt(0, 15000);
    const tier = getTier(totalPoints);

    // Generate phone number (Indian format)
    const phone = `${randomInt(7000000000, 9999999999)}`;

    const user = {
      uid: `test_user_${i + 1}`,
      firstName,
      lastName,
      phone: `+91${phone}`,
      role: 'carpenter',
      status: 'verified',
      totalPoints,
      tier,
      city: randomElement(cities),
      skill: randomElement(skills),
      verifiedAt: randomDate(90),
      verifiedBy: 'admin',
      createdAt: randomDate(180),
      updatedAt: randomDate(7),
      // Optional: Add profile image URL
      profileImage: i % 3 === 0 ? `https://i.pravatar.cc/150?img=${i + 1}` : '',
    };

    users.push(user);
  }

  return users;
}

function generateOffers(count = 20) {
  const offerTitles = [
    '50% Off on Premium Plywood',
    'Buy 10 Get 1 Free - Veneer Sheets',
    'Mega Discount on Hardwood',
    'Special Deal: Door Hinges Pack',
    'Festive Offer: 40% Off on Tools',
    'Limited Time: Free Delivery',
    'Summer Sale: Laminate Sheets',
    'Clearance: Wood Adhesives',
    'New Arrival: Imported Timber',
    'Combo Offer: Screws & Nails',
    'Wholesale Rate: MDF Boards',
    'Flash Sale: Paint & Varnish',
    'Diwali Special: Hardware Kit',
    'Monsoon Offer: Waterproof Ply',
    'Anniversary Sale: All Products',
    'Weekend Deal: Power Tools',
    'Bundle Offer: Complete Kit',
    'Early Bird: Morning Discounts',
    'Loyalty Bonus: Extra Points',
    'Referral Reward: Cash Voucher'
  ];

  const descriptions = [
    'Get amazing discounts on premium quality plywood',
    'Stock up now and save big on your next project',
    'Limited period offer - don\'t miss out',
    'Exclusive deal for verified carpenters only',
    'Earn double points on this purchase',
    'Quality products at unbeatable prices',
    'Special pricing for bulk orders',
    'Free installation guide included',
    'Best value for money guaranteed',
    'Premium quality at wholesale rates'
  ];

  const offers = [];

  for (let i = 0; i < count; i++) {
    const points = randomInt(50, 500);
    const isActive = i < 15; // First 15 offers are active

    const offer = {
      id: `offer_${i + 1}`,
      title: offerTitles[i % offerTitles.length],
      description: randomElement(descriptions),
      points,
      bannerUrl: `https://picsum.photos/seed/offer${i}/800/400`,
      isActive,
      validUntil: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + randomInt(7, 90) * 24 * 60 * 60 * 1000)
      ),
      createdAt: randomDate(30),
      updatedAt: randomDate(7),
      category: randomElement(['Plywood', 'Hardware', 'Tools', 'Accessories', 'Timber']),
      discount: `${randomInt(10, 70)}%`,
      minPurchase: randomInt(1000, 5000),
    };

    offers.push(offer);
  }

  return offers;
}

function generatePointsHistory(userId, count = 20) {
  const transactionTypes = ['earned', 'redeemed', 'bonus', 'penalty'];

  const descriptions = {
    earned: [
      'Purchase at Balaji Plywood Store',
      'Bill payment completed',
      'Monthly target achieved',
      'Product purchase bonus',
      'Bulk order reward',
    ],
    redeemed: [
      'Redeemed for cash voucher',
      'Gift card redemption',
      'Product exchange',
      'Special discount used',
      'Loyalty reward claimed',
    ],
    bonus: [
      'Referral bonus',
      'Birthday special points',
      'Festive bonus',
      'Loyalty bonus',
      'Daily spin reward',
    ],
    penalty: [
      'Points adjustment',
      'Cancelled order',
      'Return processed',
      'Correction applied',
    ],
  };

  const history = [];

  for (let i = 0; i < count; i++) {
    const type = randomElement(transactionTypes);
    const points = type === 'earned' || type === 'bonus'
      ? randomInt(10, 500)
      : -randomInt(10, 300);

    const entry = {
      userId,
      points,
      type,
      description: randomElement(descriptions[type]),
      date: randomDate(90),
      billNumber: type === 'earned' ? `BL${randomInt(10000, 99999)}` : null,
      balanceAfter: randomInt(100, 10000),
      metadata: {
        store: 'Balaji Plywood & Hardware',
        location: randomElement(['Main Branch', 'Warehouse', 'Online']),
        processedBy: 'System',
      },
    };

    history.push(entry);
  }

  // Sort by date (newest first)
  return history.sort((a, b) => b.date.toMillis() - a.date.toMillis());
}

function generateDailySpins(userId, count = 30) {
  const spins = [];

  for (let i = 0; i < count; i++) {
    const pointsWon = randomElement([10, 20, 50, 100, 200, 500]);
    const date = new Date();
    date.setDate(date.getDate() - i);

    const spin = {
      userId,
      date: admin.firestore.Timestamp.fromDate(date),
      pointsWon,
      hasSpunToday: i === 0,
      spinCount: 1,
      createdAt: admin.firestore.Timestamp.fromDate(date),
    };

    spins.push(spin);
  }

  return spins;
}

// ===== SEEDING FUNCTIONS =====

async function clearCollection(collectionName) {
  console.log(`🗑️  Clearing ${collectionName} collection...`);
  const snapshot = await db.collection(collectionName).get();
  const batch = db.batch();

  snapshot.docs.forEach(doc => {
    batch.delete(doc.ref);
  });

  await batch.commit();
  console.log(`✅ Cleared ${snapshot.size} documents from ${collectionName}`);
}

async function seedUsers(users) {
  console.log(`\n👥 Seeding ${users.length} test users...`);
  const batch = db.batch();

  users.forEach(user => {
    const userRef = db.collection('users').doc(user.uid);
    batch.set(userRef, user);
  });

  await batch.commit();
  console.log(`✅ Successfully added ${users.length} users`);

  return users;
}

async function seedOffers(offers) {
  console.log(`\n🎁 Seeding ${offers.length} offers...`);
  const batch = db.batch();

  offers.forEach(offer => {
    const offerRef = db.collection('offers').doc(offer.id);
    batch.set(offerRef, offer);
  });

  await batch.commit();
  console.log(`✅ Successfully added ${offers.length} offers`);
}

async function seedPointsHistory(users) {
  console.log(`\n💰 Seeding points history for users...`);
  let totalEntries = 0;

  // Add points history for each user (in batches of 500 to avoid Firestore limits)
  for (const user of users) {
    const history = generatePointsHistory(user.uid, randomInt(10, 30));

    // Split into batches
    for (let i = 0; i < history.length; i += 500) {
      const batch = db.batch();
      const chunk = history.slice(i, i + 500);

      chunk.forEach(entry => {
        const historyRef = db.collection('points_history').doc();
        batch.set(historyRef, entry);
      });

      await batch.commit();
      totalEntries += chunk.length;
    }
  }

  console.log(`✅ Successfully added ${totalEntries} points history entries`);
}

async function seedDailySpins(users) {
  console.log(`\n🎰 Seeding daily spin records...`);
  let totalSpins = 0;

  // Add spin history for active users (30-40% of users)
  const activeUsers = users.slice(0, Math.floor(users.length * 0.4));

  for (const user of activeUsers) {
    const spins = generateDailySpins(user.uid, randomInt(5, 30));

    const batch = db.batch();
    spins.forEach(spin => {
      const spinRef = db.collection('daily_spins').doc();
      batch.set(spinRef, spin);
    });

    await batch.commit();
    totalSpins += spins.length;
  }

  console.log(`✅ Successfully added ${totalSpins} spin records for ${activeUsers.length} users`);
}

async function seedUserPoints(users) {
  console.log(`\n📊 Creating user_points collection...`);
  const batch = db.batch();

  users.forEach(user => {
    const pointsRef = db.collection('user_points').doc(user.uid);
    batch.set(pointsRef, {
      userId: user.uid,
      totalPoints: user.totalPoints,
      tier: user.tier,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      pointsHistory: [], // Will be populated from points_history collection
    });
  });

  await batch.commit();
  console.log(`✅ Successfully created user_points for ${users.length} users`);
}

// ===== MAIN EXECUTION =====

async function main() {
  console.log('🚀 Starting Firebase Database Seeding...\n');
  console.log('=' .repeat(50));

  try {
    // Clear existing data if requested
    if (shouldClearExistingData) {
      console.log('\n⚠️  Clearing existing data...');
      await clearCollection('users');
      await clearCollection('offers');
      await clearCollection('points_history');
      await clearCollection('daily_spins');
      await clearCollection('user_points');
      console.log('✅ All collections cleared\n');
    }

    // Generate test data
    console.log('📝 Generating test data...');
    const users = generateTestUsers(50);
    const offers = generateOffers(20);
    console.log('✅ Test data generated\n');

    // Seed data to Firestore
    await seedUsers(users);
    await seedOffers(offers);
    await seedPointsHistory(users);
    await seedDailySpins(users);
    await seedUserPoints(users);

    // Summary
    console.log('\n' + '='.repeat(50));
    console.log('🎉 SEEDING COMPLETED SUCCESSFULLY!');
    console.log('=' .repeat(50));
    console.log(`\n📊 Summary:`);
    console.log(`   👥 Users: ${users.length}`);
    console.log(`   🎁 Offers: ${offers.length}`);
    console.log(`   💰 Points History: ~${users.length * 20} entries`);
    console.log(`   🎰 Daily Spins: ~${Math.floor(users.length * 0.4) * 15} records`);
    console.log(`\n📱 You can now test the app with dummy data!`);
    console.log(`\n🔑 Test Phone Numbers (configure in Firebase Console):`);
    console.log(`   +919876543210 → OTP: 123456`);
    console.log(`   +919876543211 → OTP: 123456`);
    console.log(`   +919876543212 → OTP: 123456`);

  } catch (error) {
    console.error('\n❌ Error seeding database:', error);
    process.exit(1);
  } finally {
    console.log('\n👋 Closing Firebase connection...');
    await admin.app().delete();
    console.log('✅ Done!');
  }
}

// Run the seeder
main().catch(console.error);
