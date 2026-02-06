#!/usr/bin/env bash
# Verification script for migration status

echo "🔍 Migration Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Count features
FEATURES=$(find lib/features -maxdepth 1 -type d ! -name features | wc -l | tr -d ' ')
echo "✅ Features created: $FEATURES"

# Count screens in new architecture
NEW_SCREENS=$(find lib/features/*/presentation/pages -name "*.dart" 2>/dev/null | wc -l | tr -d ' ')
echo "✅ Screens in new architecture: $NEW_SCREENS"

# Count screens in old architecture (backup)
OLD_SCREENS=$(find lib/presentation/screens -name "*_page.dart" 2>/dev/null | wc -l | tr -d ' ')
echo "📦 Screens in old architecture (backup): $OLD_SCREENS"

# Check services registered
echo ""
echo "🔧 Services registered in DI:"
grep -E "registerLazySingleton.*Service" lib/injection/dependency_injection.dart | wc -l | xargs echo "  Count:"

# Check build status
echo ""
echo "🏗️  Build Status:"
if flutter build apk --debug --target-platform android-arm64 > /dev/null 2>&1; then
    echo "  ✅ BUILD SUCCESSFUL"
else
    echo "  ❌ BUILD FAILED"
fi

# Check for errors
echo ""
echo "🔍 Code Analysis:"
ERRORS=$(flutter analyze --no-pub 2>&1 | grep "error •" | wc -l | tr -d ' ')
WARNINGS=$(flutter analyze --no-pub 2>&1 | grep "warning •" | wc -l | tr -d ' ')
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$ERRORS" -eq 0 ]; then
    echo "✅ Migration Status: SUCCESSFUL"
else
    echo "⚠️  Migration Status: Has errors"
fi
