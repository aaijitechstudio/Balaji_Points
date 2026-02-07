#!/bin/bash

# Comprehensive Design Token Replacement Script
# This script replaces raw values with DesignToken system

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file.dart>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Error: File not found: $FILE"
    exit 1
fi

echo "Fixing design tokens in: $FILE"

# Create backup
cp "$FILE" "$FILE.backup"

# ============================================================================
# PADDING - EdgeInsets.all()
# ============================================================================

# EdgeInsets.all(32) -> DesignToken.paddingAll3XL (note: 28->28 not in token, closest is 32)
perl -i -pe 's/const\s+EdgeInsets\.all\(32(?:\.0)?\)/DesignToken.paddingAll3XL/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(32(?:\.0)?\)/DesignToken.paddingAll3XL/g' "$FILE"

# EdgeInsets.all(28) -> DesignToken.paddingAll2XL (closest match, or use 32 for 3XL)
perl -i -pe 's/const\s+EdgeInsets\.all\(28(?:\.0)?\)/DesignToken.paddingAll2XL/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(28(?:\.0)?\)/DesignToken.paddingAll2XL/g' "$FILE"

# EdgeInsets.all(24) -> DesignToken.paddingAll2XL
perl -i -pe 's/const\s+EdgeInsets\.all\(24(?:\.0)?\)/DesignToken.paddingAll2XL/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(24(?:\.0)?\)/DesignToken.paddingAll2XL/g' "$FILE"

# EdgeInsets.all(20) -> DesignToken.paddingAllXL
perl -i -pe 's/const\s+EdgeInsets\.all\(20(?:\.0)?\)/DesignToken.paddingAllXL/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(20(?:\.0)?\)/DesignToken.paddingAllXL/g' "$FILE"

# EdgeInsets.all(16) -> DesignToken.paddingAllLG
perl -i -pe 's/const\s+EdgeInsets\.all\(16(?:\.0)?\)/DesignToken.paddingAllLG/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(16(?:\.0)?\)/DesignToken.paddingAllLG/g' "$FILE"

# EdgeInsets.all(12) -> DesignToken.paddingAllMD
perl -i -pe 's/const\s+EdgeInsets\.all\(12(?:\.0)?\)/DesignToken.paddingAllMD/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(12(?:\.0)?\)/DesignToken.paddingAllMD/g' "$FILE"

# EdgeInsets.all(8) -> DesignToken.paddingAllSM
perl -i -pe 's/const\s+EdgeInsets\.all\(8(?:\.0)?\)/DesignToken.paddingAllSM/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(8(?:\.0)?\)/DesignToken.paddingAllSM/g' "$FILE"

# EdgeInsets.all(4) -> DesignToken.paddingAllXS
perl -i -pe 's/const\s+EdgeInsets\.all\(4(?:\.0)?\)/DesignToken.paddingAllXS/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(4(?:\.0)?\)/DesignToken.paddingAllXS/g' "$FILE"

# ============================================================================
# PADDING - EdgeInsets.symmetric(horizontal:)
# ============================================================================

# EdgeInsets.symmetric(horizontal: 24)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*24(?:\.0)?\s*\)/DesignToken.paddingHorizontal2XL/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*horizontal:\s*24(?:\.0)?\s*\)/DesignToken.paddingHorizontal2XL/g' "$FILE"

# EdgeInsets.symmetric(horizontal: 20)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*20(?:\.0)?\s*\)/DesignToken.paddingHorizontalXL/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*horizontal:\s*20(?:\.0)?\s*\)/DesignToken.paddingHorizontalXL/g' "$FILE"

# EdgeInsets.symmetric(horizontal: 16)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*16(?:\.0)?\s*\)/DesignToken.paddingHorizontalLG/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*horizontal:\s*16(?:\.0)?\s*\)/DesignToken.paddingHorizontalLG/g' "$FILE"

# EdgeInsets.symmetric(horizontal: 12)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*12(?:\.0)?\s*\)/DesignToken.paddingHorizontalMD/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*horizontal:\s*12(?:\.0)?\s*\)/DesignToken.paddingHorizontalMD/g' "$FILE"

# EdgeInsets.symmetric(horizontal: 8)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*8(?:\.0)?\s*\)/DesignToken.paddingHorizontalSM/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*horizontal:\s*8(?:\.0)?\s*\)/DesignToken.paddingHorizontalSM/g' "$FILE"

# ============================================================================
# PADDING - EdgeInsets.symmetric(vertical:)
# ============================================================================

# EdgeInsets.symmetric(vertical: 24)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*vertical:\s*24(?:\.0)?\s*\)/DesignToken.paddingVertical2XL/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*vertical:\s*24(?:\.0)?\s*\)/DesignToken.paddingVertical2XL/g' "$FILE"

# EdgeInsets.symmetric(vertical: 20)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*vertical:\s*20(?:\.0)?\s*\)/DesignToken.paddingVerticalXL/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*vertical:\s*20(?:\.0)?\s*\)/DesignToken.paddingVerticalXL/g' "$FILE"

# EdgeInsets.symmetric(vertical: 16)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*vertical:\s*16(?:\.0)?\s*\)/DesignToken.paddingVerticalLG/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*vertical:\s*16(?:\.0)?\s*\)/DesignToken.paddingVerticalLG/g' "$FILE"

# EdgeInsets.symmetric(vertical: 12)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*vertical:\s*12(?:\.0)?\s*\)/DesignToken.paddingVerticalMD/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*vertical:\s*12(?:\.0)?\s*\)/DesignToken.paddingVerticalMD/g' "$FILE"

# EdgeInsets.symmetric(vertical: 8)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*vertical:\s*8(?:\.0)?\s*\)/DesignToken.paddingVerticalSM/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*vertical:\s*8(?:\.0)?\s*\)/DesignToken.paddingVerticalSM/g' "$FILE"

# ============================================================================
# SIZEDBOX - HEIGHT (Vertical Spacing)
# ============================================================================

# SizedBox(height: 60)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*60(?:\.0)?\s*\)/SizedBox(height: DesignToken.height6XL)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*60(?:\.0)?\s*\)/SizedBox(height: DesignToken.height6XL)/g' "$FILE"

# SizedBox(height: 48)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*48(?:\.0)?\s*\)/SizedBox(height: DesignToken.height5XL)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*48(?:\.0)?\s*\)/SizedBox(height: DesignToken.height5XL)/g' "$FILE"

# SizedBox(height: 40)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*40(?:\.0)?\s*\)/SizedBox(height: DesignToken.height4XL)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*40(?:\.0)?\s*\)/SizedBox(height: DesignToken.height4XL)/g' "$FILE"

# SizedBox(height: 32)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*32(?:\.0)?\s*\)/SizedBox(height: DesignToken.height3XL)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*32(?:\.0)?\s*\)/SizedBox(height: DesignToken.height3XL)/g' "$FILE"

# SizedBox(height: 24)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*24(?:\.0)?\s*\)/SizedBox(height: DesignToken.height2XL)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*24(?:\.0)?\s*\)/SizedBox(height: DesignToken.height2XL)/g' "$FILE"

# SizedBox(height: 20)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*20(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightXL)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*20(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightXL)/g' "$FILE"

# SizedBox(height: 16)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*16(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightLG)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*16(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightLG)/g' "$FILE"

# SizedBox(height: 12)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*12(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightMD)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*12(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightMD)/g' "$FILE"

# SizedBox(height: 8)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*8(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightSM)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*8(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightSM)/g' "$FILE"

# SizedBox(height: 4)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*4(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightXS)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*4(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightXS)/g' "$FILE"

# ============================================================================
# SIZEDBOX - WIDTH (Horizontal Spacing)
# ============================================================================

# SizedBox(width: 32)
perl -i -pe 's/const\s+SizedBox\(\s*width:\s*32(?:\.0)?\s*\)/SizedBox(width: DesignToken.width3XL)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*width:\s*32(?:\.0)?\s*\)/SizedBox(width: DesignToken.width3XL)/g' "$FILE"

# SizedBox(width: 24)
perl -i -pe 's/const\s+SizedBox\(\s*width:\s*24(?:\.0)?\s*\)/SizedBox(width: DesignToken.width2XL)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*width:\s*24(?:\.0)?\s*\)/SizedBox(width: DesignToken.width2XL)/g' "$FILE"

# SizedBox(width: 20)
perl -i -pe 's/const\s+SizedBox\(\s*width:\s*20(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthXL)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*width:\s*20(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthXL)/g' "$FILE"

# SizedBox(width: 16)
perl -i -pe 's/const\s+SizedBox\(\s*width:\s*16(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthLG)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*width:\s*16(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthLG)/g' "$FILE"

# SizedBox(width: 12)
perl -i -pe 's/const\s+SizedBox\(\s*width:\s*12(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthMD)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*width:\s*12(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthMD)/g' "$FILE"

# SizedBox(width: 8)
perl -i -pe 's/const\s+SizedBox\(\s*width:\s*8(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthSM)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*width:\s*8(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthSM)/g' "$FILE"

# SizedBox(width: 4)
perl -i -pe 's/const\s+SizedBox\(\s*width:\s*4(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthXS)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*width:\s*4(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthXS)/g' "$FILE"

# ============================================================================
# BORDER RADIUS - BorderRadius.circular()
# ============================================================================

# BorderRadius.circular(24)
perl -i -pe 's/BorderRadius\.circular\(24(?:\.0)?\)/DesignToken.borderRadius2XL/g' "$FILE"

# BorderRadius.circular(20)
perl -i -pe 's/BorderRadius\.circular\(20(?:\.0)?\)/DesignToken.borderRadiusXL/g' "$FILE"

# BorderRadius.circular(16)
perl -i -pe 's/BorderRadius\.circular\(16(?:\.0)?\)/DesignToken.borderRadiusLG/g' "$FILE"

# BorderRadius.circular(12)
perl -i -pe 's/BorderRadius\.circular\(12(?:\.0)?\)/DesignToken.borderRadiusMD/g' "$FILE"

# BorderRadius.circular(8)
perl -i -pe 's/BorderRadius\.circular\(8(?:\.0)?\)/DesignToken.borderRadiusSM/g' "$FILE"

# BorderRadius.circular(4)
perl -i -pe 's/BorderRadius\.circular\(4(?:\.0)?\)/DesignToken.borderRadiusXS/g' "$FILE"

# ============================================================================
# BORDER RADIUS - Radius.circular() (for individual corners)
# ============================================================================

# Radius.circular(24) -> Radius.circular(DesignToken.radius2XL)
perl -i -pe 's/Radius\.circular\(24(?:\.0)?\)/Radius.circular(DesignToken.radius2XL)/g' "$FILE"

# Radius.circular(20) -> Radius.circular(DesignToken.radiusXL)
perl -i -pe 's/Radius\.circular\(20(?:\.0)?\)/Radius.circular(DesignToken.radiusXL)/g' "$FILE"

# Radius.circular(16) -> Radius.circular(DesignToken.radiusLG)
perl -i -pe 's/Radius\.circular\(16(?:\.0)?\)/Radius.circular(DesignToken.radiusLG)/g' "$FILE"

# Radius.circular(12) -> Radius.circular(DesignToken.radiusMD)
perl -i -pe 's/Radius\.circular\(12(?:\.0)?\)/Radius.circular(DesignToken.radiusMD)/g' "$FILE"

# Radius.circular(8) -> Radius.circular(DesignToken.radiusSM)
perl -i -pe 's/Radius\.circular\(8(?:\.0)?\)/Radius.circular(DesignToken.radiusSM)/g' "$FILE"

# Radius.circular(4) -> Radius.circular(DesignToken.radiusXS)
perl -i -pe 's/Radius\.circular\(4(?:\.0)?\)/Radius.circular(DesignToken.radiusXS)/g' "$FILE"

# ============================================================================
# FONT SIZES
# ============================================================================

# fontSize: 32 -> fontSize: DesignToken.fontSize5XL
perl -i -pe 's/fontSize:\s*32(?:\.0)?([,\s])/fontSize: DesignToken.fontSize5XL$1/g' "$FILE"

# fontSize: 28 -> fontSize: DesignToken.fontSize4XL
perl -i -pe 's/fontSize:\s*28(?:\.0)?([,\s])/fontSize: DesignToken.fontSize4XL$1/g' "$FILE"

# fontSize: 24 -> fontSize: DesignToken.fontSize3XL
perl -i -pe 's/fontSize:\s*24(?:\.0)?([,\s])/fontSize: DesignToken.fontSize3XL$1/g' "$FILE"

# fontSize: 20 -> fontSize: DesignToken.fontSize2XL
perl -i -pe 's/fontSize:\s*20(?:\.0)?([,\s])/fontSize: DesignToken.fontSize2XL$1/g' "$FILE"

# fontSize: 18 -> fontSize: DesignToken.fontSizeXL
perl -i -pe 's/fontSize:\s*18(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeXL$1/g' "$FILE"

# fontSize: 16 -> fontSize: DesignToken.fontSizeLG
perl -i -pe 's/fontSize:\s*16(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeLG$1/g' "$FILE"

# fontSize: 14 -> fontSize: DesignToken.fontSizeMD
perl -i -pe 's/fontSize:\s*14(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeMD$1/g' "$FILE"

# fontSize: 12 -> fontSize: DesignToken.fontSizeSM
perl -i -pe 's/fontSize:\s*12(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeSM$1/g' "$FILE"

# fontSize: 10 -> fontSize: DesignToken.fontSizeXS
perl -i -pe 's/fontSize:\s*10(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeXS$1/g' "$FILE"

echo "✅ Design token replacement complete for: $FILE"
echo "   Backup saved to: $FILE.backup"
