#!/bin/bash

# Final cleanup for remaining design token violations

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

echo "Final design token cleanup: $FILE"

# EdgeInsets.all(2) -> DesignToken.paddingAllXS (4 is closest, but 2 is smaller)
perl -i -pe 's/const\s+EdgeInsets\.all\(2(?:\.0)?\)/DesignToken.paddingAllXS/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(2(?:\.0)?\)/DesignToken.paddingAllXS/g' "$FILE"

# EdgeInsets.all(14) -> DesignToken.paddingAllMD (12) or LG (16)
perl -i -pe 's/const\s+EdgeInsets\.all\(14(?:\.0)?\)/DesignToken.paddingAllMD/g' "$FILE"
perl -i -pe 's/EdgeInsets\.all\(14(?:\.0)?\)/DesignToken.paddingAllMD/g' "$FILE"

# BorderRadius.circular(3) -> DesignToken.borderRadiusXS (4)
perl -i -pe 's/BorderRadius\.circular\(3(?:\.0)?\)/DesignToken.borderRadiusXS/g' "$FILE"

# BorderRadius.circular(5) -> DesignToken.borderRadiusSM (8)
perl -i -pe 's/BorderRadius\.circular\(5(?:\.0)?\)/DesignToken.borderRadiusSM/g' "$FILE"

# fontSize: 9 -> DesignToken.fontSizeXS (10)
perl -i -pe 's/fontSize:\s*9(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeXS$1/g' "$FILE"

# fontSize: 11 -> DesignToken.fontSizeSM (12)
perl -i -pe 's/fontSize:\s*11(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeSM$1/g' "$FILE"

# fontSize: 13 -> DesignToken.fontSizeMD (14)
perl -i -pe 's/fontSize:\s*13(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeMD$1/g' "$FILE"

# fontSize: 15 -> DesignToken.fontSizeLG (16)
perl -i -pe 's/fontSize:\s*15(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeLG$1/g' "$FILE"

# fontSize: 17 -> DesignToken.fontSizeXL (18)
perl -i -pe 's/fontSize:\s*17(?:\.0)?([,\s])/fontSize: DesignToken.fontSizeXL$1/g' "$FILE"

# fontSize: 22 -> DesignToken.fontSize2XL (20)
perl -i -pe 's/fontSize:\s*22(?:\.0)?([,\s])/fontSize: DesignToken.fontSize2XL$1/g' "$FILE"

# SizedBox(height: 2)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*2(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightXS)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*2(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightXS)/g' "$FILE"

# SizedBox(height: 6)
perl -i -pe 's/const\s+SizedBox\(\s*height:\s*6(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightSM)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*height:\s*6(?:\.0)?\s*\)/SizedBox(height: DesignToken.heightSM)/g' "$FILE"

# SizedBox(width: 2)
perl -i -pe 's/const\s+SizedBox\(\s*width:\s*2(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthXS)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*width:\s*2(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthXS)/g' "$FILE"

# SizedBox(width: 6)
perl -i -pe 's/const\s+SizedBox\(\s*width:\s*6(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthSM)/g' "$FILE"
perl -i -pe 's/SizedBox\(\s*width:\s*6(?:\.0)?\s*\)/SizedBox(width: DesignToken.widthSM)/g' "$FILE"

echo "✅ Final cleanup complete for: $FILE"
