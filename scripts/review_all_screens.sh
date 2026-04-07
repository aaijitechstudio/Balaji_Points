#!/usr/bin/env bash
# scripts/review_all_screens.sh
# Purpose: Review all Flutter screens in the project
# Usage: ./scripts/review_all_screens.sh

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

REVIEW_SCRIPT="$ROOT_DIR/scripts/review_screen.sh"

if [ ! -f "$REVIEW_SCRIPT" ]; then
  echo -e "${RED}❌ Error: review_screen.sh not found${NC}"
  exit 1
fi

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${CYAN}🔍 Reviewing All Flutter Screens${NC}                            ${BLUE}║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Find all screen files
SCREEN_FILES=$(find lib/presentation/screens -type f -name "*.dart" | sort)

if [ -z "$SCREEN_FILES" ]; then
  echo -e "${YELLOW}⚠️  No screen files found in lib/presentation/screens${NC}"
  exit 0
fi

TOTAL_SCREENS=0
PASSED_SCREENS=0
FAILED_SCREENS=0

# Clean previous review notes
NOTES_FILE="docs/reviews/screen_notes.md"
mkdir -p "$(dirname "$NOTES_FILE")"
cat > "$NOTES_FILE" << 'HEADER_EOF'
# Flutter Screen Architecture Review Report

Generated: $(date '+%Y-%m-%d %H:%M:%S')

This report contains the results of automated architecture reviews for all Flutter screens.

## Summary

HEADER_EOF

echo -e "${CYAN}Found screens:${NC}"
echo "$SCREEN_FILES" | nl
echo ""

# Review each screen
for SCREEN_FILE in $SCREEN_FILES; do
  ((TOTAL_SCREENS++))
  SCREEN_NAME=$(basename "$SCREEN_FILE" .dart)
  
  echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}Reviewing [$TOTAL_SCREENS]: $SCREEN_NAME${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
  
  if bash "$REVIEW_SCRIPT" "$SCREEN_FILE"; then
    ((PASSED_SCREENS++))
    echo -e "${GREEN}✅ $SCREEN_NAME PASSED${NC}"
  else
    ((FAILED_SCREENS++))
    echo -e "${RED}❌ $SCREEN_NAME FAILED${NC}"
  fi
  
  echo ""
done

# Update summary in notes
{
  echo "**Total Screens Reviewed:** $TOTAL_SCREENS"
  echo "**Passed:** $PASSED_SCREENS ✅"
  echo "**Failed:** $FAILED_SCREENS ❌"
  echo "**Pass Rate:** $(awk "BEGIN {printf \"%.1f%%\", ($PASSED_SCREENS/$TOTAL_SCREENS)*100}")"
  echo ""
  echo "---"
  echo ""
} >> "$NOTES_FILE"

# Final summary
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${CYAN}📊 Final Summary${NC}                                            ${BLUE}║${NC}"
echo -e "${BLUE}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║${NC}  Total Screens:  ${YELLOW}$TOTAL_SCREENS${NC}"
echo -e "${BLUE}║${NC}  ${GREEN}✅ Passed:        $PASSED_SCREENS${NC}"
echo -e "${BLUE}║${NC}  ${RED}❌ Failed:        $FAILED_SCREENS${NC}"
echo -e "${BLUE}║${NC}  Pass Rate:      $(awk "BEGIN {printf \"%.1f%%\", ($PASSED_SCREENS/$TOTAL_SCREENS)*100}")"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📝 Detailed report saved to: $NOTES_FILE${NC}"

if [ "$FAILED_SCREENS" -gt 0 ]; then
  echo ""
  echo -e "${RED}❌ Some screens failed review. Please fix the issues and re-run.${NC}"
  exit 1
else
  echo ""
  echo -e "${GREEN}🎉 All screens passed architecture review!${NC}"
  exit 0
fi
