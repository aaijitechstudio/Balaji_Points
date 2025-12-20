#!/bin/bash

# Script to create a release keystore for Flutter Android app

echo "========================================="
echo "Create Release Keystore for Flutter"
echo "========================================="
echo ""

# Set variables
KEYSTORE_PATH="../android/app/release-keystore.jks"
ALIAS="balaji-points-release"

echo "This script will create a release keystore for signing your Android app."
echo ""
echo "You will be asked for:"
echo "  1. Keystore password (remember this!)"
echo "  2. Key password (can be same as keystore password)"
echo "  3. Your details (Name, Organization, etc.)"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Generate keystore
keytool -genkey -v \
  -keystore "$KEYSTORE_PATH" \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storetype JKS

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "✅ Keystore created successfully!"
    echo "========================================="
    echo ""
    echo "Keystore location: $KEYSTORE_PATH"
    echo "Alias: $ALIAS"
    echo ""
    echo "⚠️  IMPORTANT: Keep this keystore file and passwords safe!"
    echo "   You'll need them to publish updates to your app."
    echo ""
    echo "Next steps:"
    echo "1. Run: ./scripts/setup_release_signing.sh"
    echo "2. This will create key.properties and configure signing"
    echo ""
else
    echo ""
    echo "❌ Failed to create keystore"
    exit 1
fi
