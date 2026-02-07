#!/bin/bash

# Fix edge case design token violations
# Handles non-standard values that need manual mapping

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

echo "Fixing edge case design tokens in: $FILE"

# ============================================================================
# EDGE CASES - Non-standard values
# ============================================================================

# EdgeInsets.all(6) -> DesignToken.paddingAllXS (closest: 4) or SM (8)
# Using SM (8) as closer
perl -i -pe 's/const\s+EdgeInsets\.all\(6(?:\.0)?\)/DesignToken.paddingAllSM/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(6(?:\.0)?\)/DesignToken.paddingAllSM/g' "$FILE"

# EdgeInsets.all(10) -> DesignToken.paddingAllSM (8) or MD (12)
# Using SM as closer
perl -i -pe 's/const\s+EdgeInsets\.all\(10(?:\.0)?\)/DesignToken.paddingAllSM/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(10(?:\.0)?\)/DesignToken.paddingAllSM/g' "$FILE"

# EdgeInsets.all(18) -> DesignToken.paddingAllLG (16) or XL (20)
# Using LG as closer
perl -i -pe 's/const\s+EdgeInsets\.all\(18(?:\.0)?\)/DesignToken.paddingAllLG/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(18(?:\.0)?\)/DesignToken.paddingAllLG/g' "$FILE"

# EdgeInsets.all(40) -> DesignToken.padding4XL
perl -i -pe 's/const\s+EdgeInsets\.all\(40(?:\.0)?\)/const EdgeInsets.all(DesignToken.padding4XL)/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(40(?:\.0)?\)/EdgeInsets.all(DesignToken.padding4XL)/g' "$FILE"

# EdgeInsets.symmetric(horizontal: 6)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*6(?:\.0)?\s*\)/DesignToken.paddingHorizontalSM/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*horizontal:\s*6(?:\.0)?\s*\)/DesignToken.paddingHorizontalSM/g' "$FILE"

# EdgeInsets.symmetric(horizontal: 10)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*10(?:\.0)?\s*\)/DesignToken.paddingHorizontalMD/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*horizontal:\s*10(?:\.0)?\s*\)/DesignToken.paddingHorizontalMD/g' "$FILE"

# EdgeInsets.symmetric(vertical: 6)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*vertical:\s*6(?:\.0)?\s*\)/DesignToken.paddingVerticalSM/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*vertical:\s*6(?:\.0)?\s*\)/DesignToken.paddingVerticalSM/g' "$FILE"

# EdgeInsets.symmetric(vertical: 10)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*vertical:\s*10(?:\.0)?\s*\)/DesignToken.paddingVerticalMD/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*vertical:\s*10(?:\.0)?\s*\)/DesignToken.paddingVerticalMD/g' "$FILE"

# SizedBox(height: 6)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*6(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightSM)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*6(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightSM)/g' "$FILE"

# SizedBox(height: 10)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*10(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightSM)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*10(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightSM)/g' "$FILE"

# SizedBox(height: 30)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*30(?:\.0)?\s*\)/SizedBox(height: DesignToken.height3XL)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*30(?:\.0)?\s*\)/SizedBox(height: DesignToken.height3XL)/g' "$FILE"

# SizedBox(height: 40)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*40(?:\.0)?\s*\)/SizedBox(height: DesignToken.height4XL)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*40(?:\.0)?\s*\)/SizedBox(height: DesignToken.height4XL)/g' "$FILE"

# SizedBox(width: 6)
perl -i -pe 's/const\s+SizedBox\(\s*width:\s*6(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthSM)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*width:\s*6(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthSM)/g' "$FILE"

# SizedBox(width: 10)
perl -i -pe 's/const\s+SizedBox\(\s*width:\s*10(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthSM)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*width:\s*10(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthSM)/g' "$FILE"

# BorderRadius.circular(10)
perl -i -pe 's/BorderRadius\.circular\(10(?:\.0)?\)/DesignToken.borderRadiusSM/g' "$FILE"

# BorderRadius.circular(6)
perl -i -pe 's/BorderRadius\.circular\(6(?:\.0)?\)/DesignToken.borderRadiusSM/g' "$FILE"

# BorderRadius.circular(15)
perl -i -pe 's/BorderRadius\.circular\(15(?:\.0)?\)/DesignToken.borderRadiusMD/g' "$FILE"

# BorderRadius.circular(18)
perl -i -pe 's/BorderRadius\.circular\(18(?:\.0)?\)/DesignToken.borderRadiusLG/g' "$FILE"

# BorderRadius.circular(30)
perl -i -pe 's/BorderRadius\.circular\(30(?:\.0)?\)/BorderRadius.circular(DesignToken.radius3XL)/g' "$FILE"

# Radius.circular(10)
perl -i -pe 's/Radius\.circular\(10(?:\.0)?\)/Radius.circular(DesignToken.radiusSM)/g' "$FILE"

# Radius.circular(6)
perl -i -pe 's/Radius\.circular\(6(?:\.0)?\)/Radius.circular(DesignToken.radiusSM)/g' "$FILE"

# Radius.circular(15)
perl -i -pe 's/Radius\.circular\(15(?:\.0)?\)/Radius.circular(DesignToken.radiusMD)/g' "$FILE"

# Radius.circular(30)
perl -i -pe 's/Radius\.circular\(30(?:\.0)?\)/Radius.circular(DesignToken.radius3XL)/g' "$FILE"

# fontSize: 15 -> DesignToken.fontSizeLG (16 is closest)
perl -i -pe 's/fontSize:\s*15(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeLG$1/g' "$FILE"

# fontSize: 22 -> DesignToken.fontSize2XL (20 is closest)
perl -i -pe 's/fontSize:\s*22(?:\.0)?([,\s])/fontSize: DesignToken.fontSize2XL$1/g' "$FILE"

# fontSize: 26 -> DesignToken.fontSize3XL (24 is closest)
perl -i -pe 's/fontSize:\s*26(?:\.0)?([,\s])/fontSize: DesignToken.fontSize3XL$1/g' "$FILE"

# fontSize: 30 -> DesignToken.fontSize4XL (28 is closest)
perl -i -pe 's/fontSize:\s*30(?:\.0)?([,\s])/fontSize: DesignToken.fontSize4XL$1/g' "$FILE"

# fontSize: 36 -> DesignToken.fontSize5XL (32 is closest)
perl -i -pe 's/fontSize:\s*36(?:\.0)?([,\s])/fontSize: DesignToken.fontSize5XL$1/g' "$FILE"

# fontSize: 11 -> DesignToken.fontSizeXS (10) or SM (12)
perl -i -pe 's/fontSize:\s*11(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeSM$1/g' "$FILE"

# fontSize: 13 -> DesignToken.fontSizeSM (12) or MD (14)
perl -i -pe 's/fontSize:\s*13(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeMD$1/g' "$FILE"

echo "✅ Edge case design token replacement complete for: $FILE"
