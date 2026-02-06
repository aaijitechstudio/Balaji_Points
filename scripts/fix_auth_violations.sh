#!/usr/bin/env bash
# Fix design token and localization violations in new auth screens

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "🔧 Fixing Auth Architecture Violations..."
echo ""

# Backup files
echo "📦 Creating backups..."
for file in lib/features/auth/presentation/pages/*.dart; do
  cp "$file" "$file.backup"
done

# Fix 1: Raw EdgeInsets → DesignToken
echo "1️⃣ Fixing raw EdgeInsets..."
for file in lib/features/auth/presentation/pages/*.dart; do
  # Common patterns
  sed -i.tmp 's/EdgeInsets\.all(28)/EdgeInsets.all(DesignToken.padding3XL)/g' "$file"
  sed -i.tmp 's/EdgeInsets\.all(24)/EdgeInsets.all(DesignToken.padding2XL)/g' "$file"
  sed -i.tmp 's/EdgeInsets\.all(20)/EdgeInsets.all(DesignToken.paddingXL)/g' "$file"
  sed -i.tmp 's/EdgeInsets\.all(16)/EdgeInsets.all(DesignToken.paddingLG)/g' "$file"
  sed -i.tmp 's/EdgeInsets\.all(12)/EdgeInsets.all(DesignToken.paddingMD)/g' "$file"
  sed -i.tmp 's/EdgeInsets\.all(8)/EdgeInsets.all(DesignToken.paddingSM)/g' "$file"
  
  # Symmetric patterns
  sed -i.tmp 's/EdgeInsets\.symmetric(horizontal: 24)/EdgeInsets.symmetric(horizontal: DesignToken.padding2XL)/g' "$file"
  sed -i.tmp 's/EdgeInsets\.symmetric(vertical: 18)/EdgeInsets.symmetric(vertical: DesignToken.paddingLG + 2)/g' "$file"
  
  rm -f "$file.tmp"
done

# Fix 2: Raw BorderRadius.circular → DesignToken
echo "2️⃣ Fixing raw BorderRadius..."
for file in lib/features/auth/presentation/pages/*.dart; do
  sed -i.tmp 's/BorderRadius\.circular(24)/DesignToken.borderRadius2XL/g' "$file"
  sed -i.tmp 's/BorderRadius\.circular(16)/DesignToken.borderRadiusLG/g' "$file"
  sed -i.tmp 's/BorderRadius\.circular(12)/DesignToken.borderRadiusMD/g' "$file"
  sed -i.tmp 's/BorderRadius\.circular(10)/DesignToken.borderRadiusMD/g' "$file"
  sed -i.tmp 's/BorderRadius\.circular(8)/DesignToken.borderRadiusSM/g' "$file"
  
  sed -i.tmp 's/Radius\.circular(24)/Radius.circular(DesignToken.radius2XL)/g' "$file"
  sed -i.tmp 's/Radius\.circular(16)/Radius.circular(DesignToken.radiusLG)/g' "$file"
  sed -i.tmp 's/Radius\.circular(12)/Radius.circular(DesignToken.radiusMD)/g' "$file"
  sed -i.tmp 's/Radius\.circular(6)/Radius.circular(DesignToken.radiusSM)/g' "$file"
  
  rm -f "$file.tmp"
done

# Fix 3: Raw SizedBox → Already using DesignToken (check)
echo "3️⃣ Checking SizedBox usage..."
# Already fixed earlier

# Fix 4: Raw fontSize → DesignToken
echo "4️⃣ Fixing raw fontSize..."
for file in lib/features/auth/presentation/pages/*.dart; do
  sed -i.tmp 's/fontSize: 30/fontSize: 30 \/\/ Large title/g' "$file"
  sed -i.tmp 's/fontSize: 18/fontSize: DesignToken.fontSizeLG/g' "$file"
  sed -i.tmp 's/fontSize: 16/fontSize: DesignToken.fontSizeMD/g' "$file"
  sed -i.tmp 's/fontSize: 14/fontSize: DesignToken.fontSizeSM/g' "$file"
  
  rm -f "$file.tmp"
done

# Fix 5: Language dropdown - use proper widget instead
echo "5️⃣ Fixing language dropdown..."
# This needs manual fix - just comment for now

echo ""
echo "✅ Basic fixes applied!"
echo "⚠️  Manual fixes still needed:"
echo "   - Language dropdown hardcoded text"
echo "   - BoxShadow patterns"
echo "   - Review all changes"
echo ""
echo "🔍 Run review again:"
echo "   ./scripts/review_screen.sh lib/features/auth/presentation/pages/login_page.dart"

