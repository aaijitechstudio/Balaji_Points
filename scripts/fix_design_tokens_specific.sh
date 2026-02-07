#!/bin/bash

# Fix very specific remaining patterns

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file.dart>"
    exit 1
fi

FILE="$1"

echo "Fixing specific patterns in: $FILE"

# fontSize: 22 (not in token, closest: 20 = fontSize2XL or 24 = fontSize3XL)
# Using 20 as closer
perl -i -pe 's/fontSize:\s*22([,\s)])/fontSize: DesignToken.fontSize2XL$1/g' "$FILE"

# BorderRadius.circular(14) (not in token, closest: 12 = MD or 16 = LG)
# Using 12 as closer
perl -i -pe 's/BorderRadius\.circular\(14\)/DesignToken.borderRadiusMD/g' "$FILE"

# fontSize: 18 -> fontSize: DesignToken.fontSizeXL
perl -i -pe 's/(\s+)fontSize:\s*18([,\s)])/$1fontSize: DesignToken.fontSizeXL$2/g' "$FILE"

# SizedBox(width: 44) (not in token, closest: 40 = height4XL)
perl -i -pe 's/SizedBox\(width:\s*44\)/SizedBox(width: DesignToken.height4XL)/g' "$FILE"

# SizedBox(height: 80) (not in token, need to add comment or use raw)
# Leave as is with comment that it's intentional

# EdgeInsets.only patterns - these need careful handling
# EdgeInsets.only(bottom: 12) -> should use DesignToken values
perl -i -pe 's/const\s+EdgeInsets\.only\(\s*bottom:\s*12\s*\)/const EdgeInsets.only(bottom: DesignToken.paddingMD)/g' "$FILE"
perl -i -pe 's/EdgeInsets\.only\(\s*bottom:\s*12\s*\)/EdgeInsets.only(bottom: DesignToken.paddingMD)/g' "$FILE"

# EdgeInsets.only(right: 24)
perl -i -pe 's/const\s+EdgeInsets\.only\(\s*right:\s*24\s*\)/const EdgeInsets.only(right: DesignToken.padding2XL)/g' "$FILE"
perl -i -pe 's/EdgeInsets\.only\(\s*right:\s*24\s*\)/EdgeInsets.only(right: DesignToken.padding2XL)/g' "$FILE"

# EdgeInsets.only(top: 8)
perl -i -pe 's/const\s+EdgeInsets\.only\(\s*top:\s*8\s*\)/const EdgeInsets.only(top: DesignToken.paddingSM)/g' "$FILE"
perl -i -pe 's/EdgeInsets\.only\(\s*top:\s*8\s*\)/EdgeInsets.only(top: DesignToken.paddingSM)/g' "$FILE"

# EdgeInsets.symmetric(horizontal: 16, vertical: 8)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*16,\s*vertical:\s*8\s*\)/const EdgeInsets.symmetric(horizontal: DesignToken.paddingLG, vertical: DesignToken.paddingSM)/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*horizontal:\s*16,\s*vertical:\s*8\s*\)/EdgeInsets.symmetric(horizontal: DesignToken.paddingLG, vertical: DesignToken.paddingSM)/g' "$FILE"

# EdgeInsets.symmetric(horizontal: 4)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*4\s*\)/const EdgeInsets.symmetric(horizontal: DesignToken.paddingXS)/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*horizontal:\s*4\s*\)/EdgeInsets.symmetric(horizontal: DesignToken.paddingXS)/g' "$FILE"

# EdgeInsets.symmetric(vertical: 16, horizontal: 20)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*vertical:\s*16,\s*horizontal:\s*20\s*\)/const EdgeInsets.symmetric(vertical: DesignToken.paddingLG, horizontal: DesignToken.paddingXL)/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*vertical:\s*16,\s*horizontal:\s*20\s*\)/EdgeInsets.symmetric(vertical: DesignToken.paddingLG, horizontal: DesignToken.paddingXL)/g' "$FILE"

# EdgeInsets.symmetric(vertical: 12, horizontal: 20)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*vertical:\s*12,\s*horizontal:\s*20\s*\)/const EdgeInsets.symmetric(vertical: DesignToken.paddingMD, horizontal: DesignToken.paddingXL)/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*vertical:\s*12,\s*horizontal:\s*20\s*\)/EdgeInsets.symmetric(vertical: DesignToken.paddingMD, horizontal: DesignToken.paddingXL)/g' "$FILE"

# EdgeInsets.symmetric(horizontal: 12, vertical: 4)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*12,\s*vertical:\s*4\s*\)/const EdgeInsets.symmetric(horizontal: DesignToken.paddingMD, vertical: DesignToken.paddingXS)/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*horizontal:\s*12,\s*vertical:\s*4\s*\)/EdgeInsets.symmetric(horizontal: DesignToken.paddingMD, vertical: DesignToken.paddingXS)/g' "$FILE"

# EdgeInsets.symmetric(horizontal: 16, vertical: 10)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*horizontal:\s*16,\s*vertical:\s*10\s*\)/const EdgeInsets.symmetric(horizontal: DesignToken.paddingLG, vertical: DesignToken.paddingSM)/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*horizontal:\s*16,\s*vertical:\s*10\s*\)/EdgeInsets.symmetric(horizontal: DesignToken.paddingLG, vertical: DesignToken.paddingSM)/g' "$FILE"

# EdgeInsets.symmetric(vertical: 18)
perl -i -pe 's/const\s+EdgeInsets\.symmetric\(\s*vertical:\s*18\s*\)/const EdgeInsets.symmetric(vertical: DesignToken.paddingLG)/g' "$FILE"
perl -i -pe 's/EdgeInsets\.symmetric\(\s*vertical:\s*18\s*\)/EdgeInsets.symmetric(vertical: DesignToken.paddingLG)/g' "$FILE"

echo "✅ Specific pattern fix complete for: $FILE"
