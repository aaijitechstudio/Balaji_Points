#!/bin/bash

# Deploy Firebase Cloud Functions
# Balaji Points - Push Notifications

echo "🚀 Deploying Firebase Cloud Functions..."
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

# Check if logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged in to Firebase. Please login first:"
    echo "   firebase login"
    exit 1
fi

# Navigate to functions directory
cd functions

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Run lint (if configured)
if [ -f ".eslintrc.js" ]; then
    echo "🔍 Running ESLint..."
    npm run lint || echo "⚠️  Lint warnings (continuing deployment)..."
fi

# Go back to project root
cd ..

# Deploy functions
echo ""
echo "🚀 Deploying functions to Firebase..."
firebase deploy --only functions

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 View functions in Firebase Console:"
echo "   https://console.firebase.google.com/project/balajipoints/functions"
echo ""
echo "📝 View logs:"
echo "   firebase functions:log"

