#!/bin/bash

# Script to get SHA-1 and SHA-256 fingerprints for Firebase configuration

echo "========================================="
echo "Firebase SHA Fingerprints"
echo "========================================="
echo ""

# Get debug keystore SHA-1 and SHA-256
echo "🔧 DEBUG Keystore Fingerprints:"
echo "----------------------------"
DEBUG_OUTPUT=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -E "SHA1:|SHA256:")

if [ -n "$DEBUG_OUTPUT" ]; then
    echo "$DEBUG_OUTPUT"
else
    echo "❌ Debug keystore not found at ~/.android/debug.keystore"
fi

echo ""

# Get release keystore SHA-1 and SHA-256 if it exists
RELEASE_KEYSTORE="../android/app/release-keystore.jks"
if [ -f "$RELEASE_KEYSTORE" ]; then
    echo "🚀 RELEASE Keystore Fingerprints:"
    echo "----------------------------"

    # Check if key.properties exists to get the password
    if [ -f "../android/key.properties" ]; then
        STORE_PASS=$(grep "storePassword=" ../android/key.properties | cut -d'=' -f2)
        KEY_PASS=$(grep "keyPassword=" ../android/key.properties | cut -d'=' -f2)
        ALIAS=$(grep "keyAlias=" ../android/key.properties | cut -d'=' -f2)

        RELEASE_OUTPUT=$(keytool -list -v -keystore "$RELEASE_KEYSTORE" -alias "$ALIAS" -storepass "$STORE_PASS" -keypass "$KEY_PASS" 2>/dev/null | grep -E "SHA1:|SHA256:")

        if [ -n "$RELEASE_OUTPUT" ]; then
            echo "$RELEASE_OUTPUT"
        else
            echo "⚠️  Could not read release keystore. Please check passwords in key.properties"
        fi
    else
        echo "⚠️  key.properties not found. Please enter release keystore password:"
        read -s STORE_PASS
        echo ""

        RELEASE_OUTPUT=$(keytool -list -v -keystore "$RELEASE_KEYSTORE" -alias balaji-points-release -storepass "$STORE_PASS" 2>/dev/null | grep -E "SHA1:|SHA256:")

        if [ -n "$RELEASE_OUTPUT" ]; then
            echo "$RELEASE_OUTPUT"
        else
            echo "❌ Could not read release keystore with provided password"
        fi
    fi
else
    echo "⚠️  RELEASE Keystore not found"
    echo "----------------------------"
    echo "To create a release keystore, run:"
    echo "  ./scripts/create_release_keystore.sh"
fi

echo ""
echo "========================================="
echo "📋 Instructions:"
echo "========================================="
echo "1. Copy ALL fingerprints above (both DEBUG and RELEASE)"
echo "2. Go to Firebase Console: https://console.firebase.google.com"
echo "3. Select your project: balajipoints"
echo "4. Go to Project Settings (gear icon)"
echo "5. Scroll down to 'Your apps' section"
echo "6. Click on your Android app (com.example.balaji_points)"
echo "7. Click 'Add fingerprint' button"
echo "8. Add each SHA-1 and SHA-256 fingerprint (4 total: 2 debug + 2 release)"
echo "9. Download the new google-services.json file"
echo "10. Replace android/app/google-services.json with the new file"
echo ""
echo "⚠️  IMPORTANT: You need BOTH debug and release fingerprints!"
echo "   - Debug: for development/testing"
echo "   - Release: for production builds"
echo ""
echo "After updating, rebuild your app:"
echo "  flutter clean && flutter pub get && flutter run"
echo "========================================="
