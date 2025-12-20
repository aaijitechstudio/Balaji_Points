#!/bin/bash

# Script to set up release signing configuration

echo "========================================="
echo "Setup Release Signing Configuration"
echo "========================================="
echo ""

KEYSTORE_PATH="release-keystore.jks"
KEY_PROPERTIES="../android/key.properties"
ALIAS="balaji-points-release"

# Check if keystore exists
if [ ! -f "../android/app/$KEYSTORE_PATH" ]; then
    echo "❌ Release keystore not found!"
    echo ""
    echo "Please run: ./scripts/create_release_keystore.sh first"
    exit 1
fi

echo "Enter your keystore password:"
read -s STORE_PASSWORD
echo ""

echo "Enter your key password (press Enter if same as keystore password):"
read -s KEY_PASSWORD
echo ""

# If key password is empty, use store password
if [ -z "$KEY_PASSWORD" ]; then
    KEY_PASSWORD="$STORE_PASSWORD"
fi

# Create key.properties file
cat > "$KEY_PROPERTIES" << EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$ALIAS
storeFile=$KEYSTORE_PATH
EOF

echo "✅ Created key.properties file"
echo ""

# Add key.properties to gitignore if not already there
if ! grep -q "key.properties" ../android/.gitignore 2>/dev/null; then
    echo "key.properties" >> ../android/.gitignore
    echo "✅ Added key.properties to .gitignore"
fi

if ! grep -q "*.keystore" ../android/.gitignore 2>/dev/null; then
    echo "*.keystore" >> ../android/.gitignore
    echo "*.jks" >> ../android/.gitignore
    echo "✅ Added keystore files to .gitignore"
fi

echo ""
echo "========================================="
echo "✅ Release signing setup complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Run: ./scripts/get_sha1.sh"
echo "2. Copy the RELEASE fingerprints"
echo "3. Add them to Firebase Console"
echo "4. Download new google-services.json"
echo ""
