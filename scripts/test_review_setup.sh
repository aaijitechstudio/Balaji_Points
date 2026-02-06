#!/usr/bin/env bash
# Test script to verify the review system is set up correctly

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Testing Screen Review System Setup...${NC}"
echo ""

# Test 1: Check if review scripts exist
echo -n "1. Checking review_screen.sh exists... "
if [ -f "scripts/review_screen.sh" ]; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC}"
  exit 1
fi

echo -n "2. Checking review_all_screens.sh exists... "
if [ -f "scripts/review_all_screens.sh" ]; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC}"
  exit 1
fi

# Test 2: Check if scripts are executable
echo -n "3. Checking scripts are executable... "
if [ -x "scripts/review_screen.sh" ] && [ -x "scripts/review_all_screens.sh" ]; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${YELLOW}⚠${NC} (run: chmod +x scripts/review*.sh)"
fi

# Test 3: Check documentation exists
echo -n "4. Checking documentation exists... "
DOCS_OK=true
[ ! -f "docs/architecture/SCREEN_REVIEW_GUIDE.md" ] && DOCS_OK=false
[ ! -f "docs/architecture/QUICK_REFERENCE.md" ] && DOCS_OK=false
[ ! -f "docs/architecture/ARCHITECTURE_SUMMARY.md" ] && DOCS_OK=false

if [ "$DOCS_OK" = true ]; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC}"
  exit 1
fi

# Test 4: Check DesignToken exists
echo -n "5. Checking DesignToken class exists... "
if [ -f "lib/core/theme/design_token.dart" ]; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${YELLOW}⚠${NC} (DesignToken not found)"
fi

# Test 5: Check localization files exist
echo -n "6. Checking localization files exist... "
LOC_OK=true
[ ! -f "lib/l10n/app_localizations.dart" ] && LOC_OK=false

if [ "$LOC_OK" = true ]; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${YELLOW}⚠${NC}"
fi

# Test 6: Try running review on a sample file
echo -n "7. Testing review script execution... "
SAMPLE_FILE=$(find lib/presentation/screens -name "*.dart" -type f | head -1)

if [ -n "$SAMPLE_FILE" ]; then
  if scripts/review_screen.sh "$SAMPLE_FILE" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} (script runs without errors)"
  else
    echo -e "${YELLOW}⚠${NC} (script ran but found issues - this is expected)"
  fi
else
  echo -e "${YELLOW}⚠${NC} (no screen files found to test)"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Setup verification complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "  1. Run: ./scripts/review_all_screens.sh"
echo "  2. Review the output and fix any issues"
echo "  3. Create AppImages constants if needed"
echo ""
