#!/bin/bash

# Disk Space Cleanup Script for iOS Build
# This script cleans up build artifacts and caches to free disk space

echo "🧹 Starting disk space cleanup..."
echo ""

# Check current disk space
echo "📊 Current disk space:"
df -h / | tail -1
echo ""

# Clean Xcode DerivedData
echo "1️⃣  Cleaning Xcode DerivedData..."
if [ -d ~/Library/Developer/Xcode/DerivedData ]; then
    SIZE_BEFORE=$(du -sh ~/Library/Developer/Xcode/DerivedData 2>/dev/null | cut -f1)
    rm -rf ~/Library/Developer/Xcode/DerivedData/*
    echo "   ✅ Cleaned Xcode DerivedData (was: $SIZE_BEFORE)"
else
    echo "   ℹ️  DerivedData not found"
fi
echo ""

# Clean Flutter build
echo "2️⃣  Cleaning Flutter build artifacts..."
cd /Users/jagdishkumar/Documents/Development/ReactNative/Project/BalajiPoints/balaji_points
flutter clean > /dev/null 2>&1
echo "   ✅ Flutter clean completed"
echo ""

# Clean iOS build artifacts
echo "3️⃣  Cleaning iOS build artifacts..."
rm -rf build/ ios/Pods ios/.symlinks ios/Flutter/Flutter.framework ios/Flutter/Flutter.podspec 2>/dev/null
echo "   ✅ iOS build artifacts cleaned"
echo ""

# Clean Xcode Archives (optional - uncomment if needed)
# echo "4️⃣  Cleaning Xcode Archives..."
# if [ -d ~/Library/Developer/Xcode/Archives ]; then
#     SIZE_BEFORE=$(du -sh ~/Library/Developer/Xcode/Archives 2>/dev/null | cut -f1)
#     find ~/Library/Developer/Xcode/Archives -type d -mtime +30 -exec rm -rf {} + 2>/dev/null
#     echo "   ✅ Cleaned old Xcode Archives (was: $SIZE_BEFORE)"
# else
#     echo "   ℹ️  Archives not found"
# fi
# echo ""

# Clean system caches (be careful with this)
echo "4️⃣  Cleaning system caches (safe to remove)..."
# Clean Flutter pub cache (optional - will need to re-download packages)
# rm -rf ~/.pub-cache/hosted 2>/dev/null
# echo "   ✅ Cleaned pub cache"

# Clean CocoaPods cache
if command -v pod &> /dev/null; then
    pod cache clean --all > /dev/null 2>&1
    echo "   ✅ Cleaned CocoaPods cache"
fi
echo ""

# Show final disk space
echo "📊 Final disk space:"
df -h / | tail -1
echo ""

echo "✅ Cleanup complete!"
echo ""
echo "💡 Next steps:"
echo "   1. Run: cd ios && pod install"
echo "   2. Run: flutter pub get"
echo "   3. Try building again: flutter run"

