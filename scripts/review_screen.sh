#!/usr/bin/env bash
# scripts/review_screen.sh
# Purpose: Review Flutter screens against strict architecture guidelines
# Usage: ./scripts/review_screen.sh <path_to_screen_file>
# Architecture Rules:
#   1. All icons use AppImages (local assets)
#   2. All static text comes from localization (AppLocalizations)
#   3. All design values/styles come from DesignToken (not hardcoded)
#   4. Proper BLoC/State/Event architecture
#   5. Current Firebase methods
#   6. International industry standard architecture

set +e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# --------------------------------------------------
# Helpers (SAFE WITH set -e)
# --------------------------------------------------
has() {
  grep -qE "$1" "$2" && return 0 || return 1
}

has_not() {
  grep -qE "$1" "$2" && return 1 || return 0
}

# --------------------------------------------------
# Colors
# --------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

SCREEN_FILE="$1"

if [ -z "$SCREEN_FILE" ]; then
  echo -e "${RED}❌ Error: No file specified${NC}"
  echo "Usage: ./scripts/review_screen.sh <path_to_screen_file>"
  exit 1
fi

if [ ! -f "$SCREEN_FILE" ]; then
  echo -e "${RED}❌ Error: File not found: $SCREEN_FILE${NC}"
  exit 1
fi

SCREEN_NAME=$(basename "$SCREEN_FILE" .dart)
NOTES_FILE="docs/reviews/screen_notes.md"

mkdir -p "$(dirname "$NOTES_FILE")"
touch "$NOTES_FILE"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${CYAN}🔍 Flutter Screen Architecture Review${NC}                    ${BLUE}║${NC}"
echo -e "${BLUE}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║${NC}  📄 Screen: ${YELLOW}$SCREEN_NAME${NC}"
echo -e "${BLUE}║${NC}  📁 File:   ${SCREEN_FILE}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

FAIL_COUNT=0
PASS_COUNT=0
WARNING_COUNT=0
ISSUE_LIST=()

fail() {
  echo -e "${RED}❌ FAIL: $1${NC}"
  ((FAIL_COUNT++))
  ISSUE_LIST+=("FAIL: $1")
}

warn() {
  echo -e "${YELLOW}⚠️  WARN: $1${NC}"
  ((WARNING_COUNT++))
  ISSUE_LIST+=("WARN: $1")
}

pass() {
  ((PASS_COUNT++))
}

info() {
  echo -e "${CYAN}ℹ️  INFO: $1${NC}"
}

# --------------------------------------------------
# Step 1 — Clean Architecture & Layering
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 1: Clean Architecture & Layering Validation${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

LAYERING_FAIL=0

# Check if it's a screen file (should be in presentation/screens)
if [[ "$SCREEN_FILE" != *"presentation/screens"* ]]; then
  warn "File not in presentation/screens directory"
fi

# Forbidden: Direct data layer imports
if has "import.*\/data\/(repositories|models|datasources)" "$SCREEN_FILE"; then
  fail "Forbidden /data/ layer import detected - screens should only use domain layer"
  LAYERING_FAIL=1
fi

# Forbidden: Direct repository imports
if has "import.*(\/repository\/|\/repo\/|Repository)" "$SCREEN_FILE"; then
  fail "Forbidden repository import - use BLoC/Cubit instead"
  LAYERING_FAIL=1
fi

# Forbidden: Direct API/HTTP client imports
if has "import.*(\/api\/|ApiClient|http\.dart|dio\.dart)" "$SCREEN_FILE"; then
  fail "Forbidden API/HTTP client import - use BLoC/Cubit"
  LAYERING_FAIL=1
fi

# Forbidden: Direct database imports
if has "import.*(supabase|hive|sqflite|shared_preferences)" "$SCREEN_FILE"; then
  fail "Forbidden database library import - use services/repositories through BLoC"
  LAYERING_FAIL=1
fi

# Forbidden: Direct Firebase Firestore operations in screens
if has "FirebaseFirestore\.instance|\.collection\(|\.doc\(|\.get\(\)|\.set\(|\.update\(|\.delete\(" "$SCREEN_FILE"; then
  fail "Direct Firestore operations in screen - use BLoC/Service layer"
  LAYERING_FAIL=1
fi

# Check for proper service imports (only UI-related services allowed)
if has "import.*\/services\/" "$SCREEN_FILE"; then
  # Check if it's an approved UI-only service
  if ! has "user_service|session_service|auth_service|storage_service" "$SCREEN_FILE"; then
    warn "Service import detected - verify it's UI-appropriate"
  fi
fi

# Forbidden: Direct API calls in code
if has "http\.get\(|http\.post\(|dio\.get\(|dio\.post\(|\.fetch\(" "$SCREEN_FILE"; then
  fail "Direct HTTP calls detected - use BLoC/Cubit"
  LAYERING_FAIL=1
fi

# Forbidden: context.read<Bloc>().state in build() method
if has "context\.read<.*>\(\)\.state" "$SCREEN_FILE"; then
  if grep -A 10 "Widget build" "$SCREEN_FILE" | grep -q "context\.read.*\.state"; then
    fail "context.read<Bloc>().state in build() - use BlocBuilder/BlocConsumer"
    LAYERING_FAIL=1
  fi
fi

if [ "$LAYERING_FAIL" -eq 0 ]; then
  echo -e "${GREEN}✅ Clean architecture & layering correct${NC}"
  pass
fi

# --------------------------------------------------
# Step 2 — BLoC Architecture Validation
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 2: BLoC/Cubit Architecture Validation${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

BLOC_FAIL=0

# Check if screen uses state management
if has "StatefulWidget|State<" "$SCREEN_FILE"; then
  info "StatefulWidget detected - checking for proper state management"
  
  # If using BLoC, must have proper widgets
  if has "Bloc|Cubit" "$SCREEN_FILE"; then
    if has_not "BlocBuilder|BlocListener|BlocConsumer|BlocProvider" "$SCREEN_FILE"; then
      fail "BLoC/Cubit imported but no BlocBuilder/BlocListener/BlocConsumer"
      BLOC_FAIL=1
    else
      pass
    fi
  else
    warn "StatefulWidget without BLoC - verify if local state is appropriate"
  fi
fi

# Check for proper event dispatching
if has "context\.read<.*Bloc>.*\.add\(" "$SCREEN_FILE"; then
  pass
  info "Proper BLoC event dispatching found"
fi

# Check for direct state manipulation (anti-pattern)
if has "setState.*Bloc|\.state\s*=" "$SCREEN_FILE"; then
  fail "Direct BLoC state manipulation - use events instead"
  BLOC_FAIL=1
fi

# Check for proper BLoC imports
if has "import.*bloc" "$SCREEN_FILE"; then
  if has_not "import 'package:flutter_bloc/flutter_bloc.dart'" "$SCREEN_FILE"; then
    fail "BLoC used but flutter_bloc not imported"
    BLOC_FAIL=1
  fi
fi

if [ "$BLOC_FAIL" -eq 0 ]; then
  echo -e "${GREEN}✅ BLoC architecture properly implemented${NC}"
fi

# --------------------------------------------------
# Step 3 — Design Token Validation (HARD RULE)
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 3: Design Token Validation (MANDATORY)${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

DESIGN_FAIL=0

# Check for DesignToken import
if has_not "import.*design_token\.dart|DesignToken" "$SCREEN_FILE"; then
  if has "EdgeInsets|SizedBox|TextStyle|Color|BorderRadius|BoxShadow|fontSize|fontWeight" "$SCREEN_FILE"; then
    warn "Design elements used but DesignToken not imported"
  fi
fi

# Forbidden: Raw spacing values
if has "EdgeInsets\.(all|only|symmetric)\(\s*[0-9]" "$SCREEN_FILE"; then
  fail "Raw EdgeInsets values - use DesignToken.paddingAll* or DesignToken.padding*"
  DESIGN_FAIL=1
fi

if has "SizedBox\((width|height):\s*[0-9]" "$SCREEN_FILE"; then
  fail "Raw SizedBox values - use DesignToken.height* or DesignToken.width*"
  DESIGN_FAIL=1
fi

if has "Padding\([^)]*padding:\s*const\s*EdgeInsets\.(all|only|symmetric)\(\s*[0-9]" "$SCREEN_FILE"; then
  fail "Raw Padding values - use DesignToken padding constants"
  DESIGN_FAIL=1
fi

# Forbidden: Raw font sizes
if has "fontSize:\s*[0-9]" "$SCREEN_FILE"; then
  fail "Raw fontSize - use DesignToken.fontSize* or DesignToken text styles"
  DESIGN_FAIL=1
fi

# Forbidden: Raw font weights
if has "fontWeight:\s*FontWeight\." "$SCREEN_FILE"; then
  fail "Raw fontWeight - use DesignToken text styles (heading*, body*, label*)"
  DESIGN_FAIL=1
fi

# Forbidden: Raw border radius
if has "BorderRadius\.circular\(\s*[0-9]" "$SCREEN_FILE"; then
  fail "Raw BorderRadius.circular - use DesignToken.borderRadius*"
  DESIGN_FAIL=1
fi

if has "Radius\.circular\(\s*[0-9]" "$SCREEN_FILE"; then
  fail "Raw Radius.circular - use DesignToken.radius*"
  DESIGN_FAIL=1
fi

# Forbidden: Raw elevation
if has "elevation:\s*[0-9]" "$SCREEN_FILE"; then
  fail "Raw elevation - use DesignToken.elevation*"
  DESIGN_FAIL=1
fi

# Forbidden: Raw box shadows (allow if using DesignToken colors)
if has "BoxShadow\(" "$SCREEN_FILE"; then
  # If BoxShadow exists, check if color is from DesignToken
  if grep -A2 "BoxShadow(" "$SCREEN_FILE" | grep -q "color: DesignToken"; then
    pass "BoxShadow with DesignToken colors (acceptable)"
  else
    fail "Raw BoxShadow - color must use DesignToken"
    DESIGN_FAIL=1
  fi
fi

# Forbidden: Raw color literals
if has "Color\(0x" "$SCREEN_FILE"; then
  fail "Raw Color(0x...) literal - use DesignToken colors"
  DESIGN_FAIL=1
fi

# Forbidden: Flutter Colors class usage
if has "Colors\.(red|blue|green|grey|gray|black|white|yellow|orange|purple|pink|brown|cyan|amber|indigo|lime|teal|deepOrange)" "$SCREEN_FILE"; then
  if has_not "errorBuilder|debugFillProperties" "$SCREEN_FILE"; then
    fail "Raw Colors.* usage - use DesignToken colors"
    DESIGN_FAIL=1
  fi
fi

# Check for Theme.of(context) usage (should use DesignToken instead)
if has "Theme\.of\(context\)\.textTheme|Theme\.of\(context\)\.colorScheme" "$SCREEN_FILE"; then
  warn "Theme.of(context) usage - prefer DesignToken for consistency"
fi

# Check for proper TextStyle usage
if has "TextStyle\(" "$SCREEN_FILE"; then
  if has_not "DesignToken\.(heading|body|label|text)" "$SCREEN_FILE"; then
    fail "TextStyle() without DesignToken - use DesignToken text styles"
    DESIGN_FAIL=1
  fi
fi

# Forbidden: copyWith for color changes (use design tokens)
if has "\.copyWith\([^)]*color:\s*" "$SCREEN_FILE"; then
  warn "TextStyle.copyWith(color:...) found - prefer using design token directly"
fi

if [ "$DESIGN_FAIL" -eq 0 ]; then
  echo -e "${GREEN}✅ All design values use DesignToken${NC}"
  pass
else
  fail "Design token violations found - ALL values must use DesignToken"
fi

# --------------------------------------------------
# Step 4 — Asset Management (STRICT)
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 4: Asset Management Validation (MANDATORY)${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

ASSET_FAIL=0

# Check for Icon usage
if has "Icon\(Icons\." "$SCREEN_FILE"; then
  # Allow only in errorBuilder or fallback
  if ! grep -q "errorBuilder.*Icons\.|fallback.*Icons\." "$SCREEN_FILE"; then
    warn "Icons.* detected - prefer using custom icon assets"
  fi
fi

# Check for hardcoded image paths
if has "Image\.asset\(['\"]assets/" "$SCREEN_FILE"; then
  fail "Hardcoded Image.asset() path - create AppImages class in constants"
  ASSET_FAIL=1
fi

if has "AssetImage\(['\"]assets/" "$SCREEN_FILE"; then
  fail "Hardcoded AssetImage() path - create AppImages class in constants"
  ASSET_FAIL=1
fi

# Check for network images without error handling
if has "Image\.network\(" "$SCREEN_FILE"; then
  if has_not "errorBuilder" "$SCREEN_FILE"; then
    warn "Image.network without errorBuilder - add error handling"
  fi
fi

# Check for cached network images (recommended)
if has "Image\.network\(" "$SCREEN_FILE"; then
  info "Consider using cached_network_image for better performance"
fi

if [ "$ASSET_FAIL" -eq 0 ]; then
  echo -e "${GREEN}✅ Asset management follows best practices${NC}"
  pass
else
  fail "Asset management violations - use constants for all asset paths"
fi

# --------------------------------------------------
# Step 5 — Localization Validation (STRICT)
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 5: Localization Validation (MANDATORY)${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

L10N_FAIL=0

# Check for localization import
if has_not "import.*app_localizations|import.*l10n" "$SCREEN_FILE"; then
  if has "Text\(" "$SCREEN_FILE"; then
    fail "Text widgets found but no localization import"
    L10N_FAIL=1
  fi
fi

# Check for hardcoded strings in Text widgets
if grep -E 'Text\s*\(\s*["\047][^$]' "$SCREEN_FILE" | grep -qv "errorBuilder\|semanticLabel\|//\|/\*"; then
  fail "Hardcoded Text('...') found - ALL text must use AppLocalizations"
  L10N_FAIL=1
fi

# Check for hardcoded strings in common UI elements
if has 'hintText:\s*["\047][^$]' "$SCREEN_FILE"; then
  fail "Hardcoded hintText - use localization"
  L10N_FAIL=1
fi

if has 'labelText:\s*["\047][^$]' "$SCREEN_FILE"; then
  fail "Hardcoded labelText - use localization"
  L10N_FAIL=1
fi

if has 'title:\s*["\047][^$]' "$SCREEN_FILE"; then
  fail "Hardcoded title - use localization"
  L10N_FAIL=1
fi

# Check for SnackBar/Dialog with hardcoded text
if has 'SnackBar\([^)]*Text\(["\047]' "$SCREEN_FILE"; then
  fail "SnackBar with hardcoded text - use localization"
  L10N_FAIL=1
fi

if has 'AlertDialog\([^)]*title:.*Text\(["\047]' "$SCREEN_FILE"; then
  fail "AlertDialog with hardcoded title - use localization"
  L10N_FAIL=1
fi

# Check that AppLocalizations is actually used
if has "Text\(" "$SCREEN_FILE"; then
  if has_not "AppLocalizations\.of\(context\)|l10n\." "$SCREEN_FILE"; then
    fail "Text widgets found but AppLocalizations not used"
    L10N_FAIL=1
  else
    pass
    info "Proper localization usage detected"
  fi
fi

# Check for proper localization context
if has "AppLocalizations\.of\(context\)" "$SCREEN_FILE"; then
  if has_not "final.*l10n\s*=\s*AppLocalizations\.of\(context\)" "$SCREEN_FILE"; then
    info "Consider storing AppLocalizations.of(context) in a local variable 'l10n'"
  fi
fi

if [ "$L10N_FAIL" -eq 0 ]; then
  echo -e "${GREEN}✅ All text properly localized${NC}"
  pass
else
  fail "Localization violations - ALL user-facing text must be localized"
fi

# --------------------------------------------------
# Step 6 — Firebase Integration
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 6: Firebase Integration Best Practices${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

FIREBASE_FAIL=0

# Check for direct Firestore usage (should be in repository)
if has "FirebaseFirestore\.instance" "$SCREEN_FILE"; then
  fail "Direct FirebaseFirestore.instance in screen - use repository/service layer"
  FIREBASE_FAIL=1
fi

# Check for proper StreamBuilder usage
if has "StreamBuilder" "$SCREEN_FILE"; then
  pass
  info "StreamBuilder found - verify proper error handling"
  
  if has_not "hasError|error:" "$SCREEN_FILE"; then
    warn "StreamBuilder without error handling"
  fi
fi

# Check for FutureBuilder usage
if has "FutureBuilder" "$SCREEN_FILE"; then
  pass
  info "FutureBuilder found - verify proper loading/error states"
  
  if has_not "ConnectionState" "$SCREEN_FILE"; then
    warn "FutureBuilder should check ConnectionState"
  fi
fi

# Check for Timestamp handling
if has "Timestamp" "$SCREEN_FILE"; then
  if has_not "toDate\(\)" "$SCREEN_FILE"; then
    warn "Timestamp found - ensure proper conversion to DateTime"
  fi
fi

if [ "$FIREBASE_FAIL" -eq 0 ]; then
  echo -e "${GREEN}✅ Firebase integration follows best practices${NC}"
  pass
fi

# --------------------------------------------------
# Step 7 — Widget Composition
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 7: Widget Composition & Reusability${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

WIDGET_FAIL=0

# Check for proper widget extraction
if has "class.*Widget.*build" "$SCREEN_FILE"; then
  # Count build methods
  BUILD_COUNT=$(grep -c "Widget build" "$SCREEN_FILE")
  if [ "$BUILD_COUNT" -gt 5 ]; then
    warn "Multiple build methods ($BUILD_COUNT) - consider extracting to separate widgets"
  fi
fi

# Check for shared widget usage
if has "ElevatedButton|TextButton|OutlinedButton" "$SCREEN_FILE"; then
  info "Standard Flutter buttons found - consider using custom branded widgets"
fi

# Check for proper const usage
if has "const\s+Text\(|const\s+Icon\(|const\s+SizedBox\(" "$SCREEN_FILE"; then
  pass
  info "Good const usage for performance"
fi

# Check for build method size (warning if too large)
BUILD_SIZE=$(grep -A 200 "Widget build" "$SCREEN_FILE" | wc -l | tr -d ' ')
if [ "$BUILD_SIZE" -gt 150 ] 2>/dev/null; then
  warn "Large build method detected - consider breaking into smaller widgets"
fi

echo -e "${GREEN}✅ Widget composition checked${NC}"

# --------------------------------------------------
# Step 8 — Responsive Design
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 8: Responsive Design (MANUAL CHECK REQUIRED)${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

RESPONSIVE_FAIL=0

# Check for MediaQuery usage
if has "MediaQuery\.of\(context\)\.size" "$SCREEN_FILE"; then
  pass
  info "MediaQuery usage found - good for responsive design"
fi

# Check for LayoutBuilder
if has "LayoutBuilder" "$SCREEN_FILE"; then
  pass
  info "LayoutBuilder usage found - good for adaptive layouts"
fi

# Check for hardcoded sizes
if has "width:\s*[0-9]{3,}|height:\s*[0-9]{3,}" "$SCREEN_FILE"; then
  warn "Large hardcoded size values - verify responsiveness"
  RESPONSIVE_FAIL=1
fi

echo -e "${YELLOW}⚠️  MANUAL: Test on multiple screen sizes (320x568, 428x926, tablets)${NC}"
echo -e "${YELLOW}⚠️  MANUAL: Test with 200% text scale${NC}"

# --------------------------------------------------
# Step 9 — Accessibility
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 9: Accessibility (WCAG 2.1 AA)${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

A11Y_FAIL=0

# Check for Semantics usage
if has "Semantics\(|semanticsLabel:" "$SCREEN_FILE"; then
  pass
  info "Semantics found - good for accessibility"
else
  if has "Image\(|Icon\(" "$SCREEN_FILE"; then
    warn "Images/Icons without semanticsLabel - add for screen readers"
  fi
fi

# Check for accessible tap targets (manual check)
echo -e "${YELLOW}⚠️  MANUAL: Verify all tap targets are ≥ 48x48 dp${NC}"

# Check for form accessibility
if has "TextFormField|TextField" "$SCREEN_FILE"; then
  if has_not "labelText:|label:" "$SCREEN_FILE"; then
    warn "Form fields should have labels for accessibility"
    A11Y_FAIL=1
  fi
fi

# Check for proper focus management
if has "FocusNode|FocusScope" "$SCREEN_FILE"; then
  pass
  info "Focus management found - good for keyboard navigation"
fi

if [ "$A11Y_FAIL" -eq 0 ]; then
  echo -e "${GREEN}✅ Accessibility basics implemented${NC}"
  pass
fi

# --------------------------------------------------
# Step 10 — Lifecycle & Resource Management
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 10: Lifecycle & Resource Management${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

LIFECYCLE_FAIL=0

# Check for controllers that need disposal
if has "TextEditingController|ScrollController|AnimationController|TabController|PageController" "$SCREEN_FILE"; then
  if has_not "dispose\(\)" "$SCREEN_FILE"; then
    fail "Controllers detected without dispose() method"
    LIFECYCLE_FAIL=1
  else
    pass
    info "Proper controller disposal found"
  fi
fi

# Check for StreamSubscription disposal
if has "StreamSubscription" "$SCREEN_FILE"; then
  if has_not "cancel\(\)|dispose\(\)" "$SCREEN_FILE"; then
    fail "StreamSubscription without cancel() in dispose()"
    LIFECYCLE_FAIL=1
  fi
fi

# Check for Timer disposal
if has "Timer\." "$SCREEN_FILE"; then
  if has_not "cancel\(\)" "$SCREEN_FILE"; then
    warn "Timer detected - ensure it's cancelled in dispose()"
  fi
fi

# Check for proper initState/dispose pairing
if has "initState\(\)" "$SCREEN_FILE"; then
  if has_not "dispose\(\)" "$SCREEN_FILE"; then
    warn "initState without dispose - verify no resources need cleanup"
  fi
fi

if [ "$LIFECYCLE_FAIL" -eq 0 ]; then
  echo -e "${GREEN}✅ Lifecycle management correct${NC}"
  pass
fi

# --------------------------------------------------
# Step 11 — Error Handling
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 11: Error Handling & Edge Cases${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

ERROR_FAIL=0

# Check for try-catch blocks
if has "try\s*\{" "$SCREEN_FILE"; then
  pass
  info "Error handling found"
  
  if has_not "catch" "$SCREEN_FILE"; then
    fail "try block without catch"
    ERROR_FAIL=1
  fi
fi

# Check for null safety
if has "\?\.|!\." "$SCREEN_FILE"; then
  pass
  info "Null-aware operators used"
fi

# Check for empty state handling
if has "isEmpty|length\s*==\s*0" "$SCREEN_FILE"; then
  pass
  info "Empty state check found"
fi

# Check for loading states
if has "CircularProgressIndicator|LinearProgressIndicator|loading|isLoading" "$SCREEN_FILE"; then
  pass
  info "Loading state handling found"
fi

if [ "$ERROR_FAIL" -eq 0 ]; then
  echo -e "${GREEN}✅ Error handling implemented${NC}"
  pass
fi

# --------------------------------------------------
# Step 12 — Performance
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 12: Performance Optimization${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

PERF_FAIL=0

# Check for unnecessary rebuilds
if has "setState\(\(\)\s*\{\s*\}\)" "$SCREEN_FILE"; then
  warn "Empty setState() call - causes unnecessary rebuild"
  PERF_FAIL=1
fi

# Check for ListView without optimization
if has "ListView\(" "$SCREEN_FILE"; then
  if has_not "ListView\.builder|ListView\.separated" "$SCREEN_FILE"; then
    warn "ListView without .builder - consider using ListView.builder for large lists"
  fi
fi

# Check for const constructors
CONST_COUNT=$(grep -c "const\s\+[A-Z]" "$SCREEN_FILE")
if [ "$CONST_COUNT" -gt 3 ]; then
  pass
  info "Good use of const constructors ($CONST_COUNT found)"
fi

# Check for heavy operations in build
if grep -A 50 "Widget build" "$SCREEN_FILE" | grep -qE "for\s*\(.*in.*\)|while\s*\(|\.map\(|\.where\("; then
  warn "Loop/iteration in build method - consider moving to initState or using computed properties"
fi

echo -e "${GREEN}✅ Performance checked${NC}"

# --------------------------------------------------
# Step 13 — Code Quality
# --------------------------------------------------
echo -e "\n${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Step 13: Code Quality & Best Practices${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"

QUALITY_FAIL=0

# Check for proper naming conventions
if has "class\s+[a-z]" "$SCREEN_FILE"; then
  fail "Class name should start with uppercase"
  QUALITY_FAIL=1
fi

# Check for magic numbers
if grep -v "const\s" "$SCREEN_FILE" | grep -q "[^0-9][0-9]\{2,\}[^0-9]"; then
  warn "Magic numbers detected - consider using named constants"
fi

# Check for TODO comments
TODO_COUNT=$(grep -c "TODO:" "$SCREEN_FILE" 2>/dev/null || echo "0")
if [ "$TODO_COUNT" -gt 0 ] 2>/dev/null; then
  warn "$TODO_COUNT TODO comments found - track in issue tracker"
fi

# Check for debug statements
if has "print\(|debugPrint\(" "$SCREEN_FILE"; then
  warn "Debug print statements found - remove for production"
fi

# Check for proper documentation
if has "class.*extends\s*(StatefulWidget|StatelessWidget)" "$SCREEN_FILE"; then
  if has_not "\/\/\/|\/\*\*" "$SCREEN_FILE"; then
    warn "Missing doc comments for widget class"
  fi
fi

echo -e "${GREEN}✅ Code quality checked${NC}"

# --------------------------------------------------
# Summary
# --------------------------------------------------
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${CYAN}📊 Review Summary${NC}                                         ${BLUE}║${NC}"
echo -e "${BLUE}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║${NC}  Screen: ${YELLOW}$SCREEN_NAME${NC}"
echo -e "${BLUE}║${NC}  ${GREEN}✅ Passed: $PASS_COUNT${NC}"
echo -e "${BLUE}║${NC}  ${RED}❌ Failed: $FAIL_COUNT${NC}"
echo -e "${BLUE}║${NC}  ${YELLOW}⚠️  Warnings: $WARNING_COUNT${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

# Log to notes file
{
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "## Screen Review: $SCREEN_NAME"
  echo "**Date:** $(date '+%Y-%m-%d %H:%M:%S')"
  echo "**File:** $SCREEN_FILE"
  echo ""
  if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "**Status:** ❌ FAIL"
    echo "**Failures:** $FAIL_COUNT"
    echo "**Warnings:** $WARNING_COUNT"
    echo "**Passed:** $PASS_COUNT"
    echo ""
    echo "### Critical Issues:"
    for issue in "${ISSUE_LIST[@]}"; do
      echo "- $issue"
    done
  else
    echo "**Status:** ✅ PASS"
    echo "**Passed Checks:** $PASS_COUNT"
    echo "**Warnings:** $WARNING_COUNT"
  fi
  echo ""
  echo "### Manual Checks Required:"
  echo "- [ ] Test on small screen (320x568)"
  echo "- [ ] Test on large screen (428x926, tablets)"
  echo "- [ ] Test with 200% text scale"
  echo "- [ ] Verify all tap targets ≥ 48x48 dp"
  echo "- [ ] Test with screen reader (TalkBack/VoiceOver)"
  echo "- [ ] Verify network error scenarios"
  echo "- [ ] Test loading states"
  echo "- [ ] Test empty states"
  echo ""
} >> "$NOTES_FILE"

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo ""
  echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║${NC}  ❌ ${RED}OVERALL RESULT: FAIL${NC}                                    ${RED}║${NC}"
  echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${CYAN}🔧 Action Items:${NC}"
  echo "  1. ✅ Fix all FAIL items listed above"
  echo "  2. 📝 Review all WARN items"
  echo "  3. 🎨 Ensure all design values use DesignToken"
  echo "  4. 🌍 Ensure all text uses AppLocalizations"
  echo "  5. 🏗️  Ensure proper BLoC architecture"
  echo "  6. 🔥 Use Firebase through repository layer"
  echo "  7. ♿ Verify accessibility compliance"
  echo ""
  echo -e "${YELLOW}📝 Review notes saved to: $NOTES_FILE${NC}"
  exit 1
else
  echo ""
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║${NC}  ✅ ${GREEN}OVERALL RESULT: PASS${NC}                                    ${GREEN}║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  if [ "$WARNING_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Note: $WARNING_COUNT warnings to review${NC}"
  fi
  echo -e "${CYAN}📝 Review notes saved to: $NOTES_FILE${NC}"
  echo -e "${GREEN}🎉 Screen meets architecture standards!${NC}"
  exit 0
fi
