#!/bin/bash

# Fix fontSize in copyWith and TextStyle patterns

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file.dart>"
    exit 1
fi

FILE="$1"

echo "Fixing copyWith and TextStyle fontSize in: $FILE"

# copyWith(fontSize: 20)
perl -i -pe 's/copyWith\(fontSize:\s*20\)/copyWith(fontSize: DesignToken.fontSize2XL)/g' "$FILE"

# copyWith(fontSize: 18)
perl -i -pe 's/copyWith\(fontSize:\s*18\)/copyWith(fontSize: DesignToken.fontSizeXL)/g' "$FILE"

# copyWith(fontSize: 16)
perl -i -pe 's/copyWith\(fontSize:\s*16\)/copyWith(fontSize: DesignToken.fontSizeLG)/g' "$FILE"

# copyWith(fontSize: 14)
perl -i -pe 's/copyWith\(fontSize:\s*14\)/copyWith(fontSize: DesignToken.fontSizeMD)/g' "$FILE"

# copyWith(fontSize: 12)
perl -i -pe 's/copyWith\(fontSize:\s*12\)/copyWith(fontSize: DesignToken.fontSizeSM)/g' "$FILE"

# TextStyle(fontSize: 16)
perl -i -pe 's/TextStyle\(fontSize:\s*16\)/TextStyle(fontSize: DesignToken.fontSizeLG)/g' "$FILE"

# TextStyle(fontSize: 14)
perl -i -pe 's/TextStyle\(fontSize:\s*14\)/TextStyle(fontSize: DesignToken.fontSizeMD)/g' "$FILE"

# TextStyle(fontSize: 12)
perl -i -pe 's/TextStyle\(fontSize:\s*12\)/TextStyle(fontSize: DesignToken.fontSizeSM)/g' "$FILE"

# TextStyle(..., fontSize: 16)
perl -i -pe 's/(TextStyle\([^)]*),\s*fontSize:\s*16/$1, fontSize: DesignToken.fontSizeLG/g' "$FILE"

# TextStyle(..., fontSize: 14)
perl -i -pe 's/(TextStyle\([^)]*),\s*fontSize:\s*14/$1, fontSize: DesignToken.fontSizeMD/g' "$FILE"

# TextStyle(..., fontSize: 12)
perl -i -pe 's/(TextStyle\([^)]*),\s*fontSize:\s*12/$1, fontSize: DesignToken.fontSizeSM/g' "$FILE"

echo "✅ copyWith/TextStyle fontSize fix complete for: $FILE"
