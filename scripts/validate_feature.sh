#!/usr/bin/env bash
# scripts/validate_feature.sh
# Purpose: Validate feature follows clean architecture
# Usage: ./scripts/validate_feature.sh <feature_name>

set -e

FEATURE_NAME="$1"

if [ -z "$FEATURE_NAME" ]; then
  echo "Error: Feature name required"
  echo "Usage: ./scripts/validate_feature.sh <feature_name>"
  exit 1
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FEATURE_PATH="lib/features/$FEATURE_NAME"

if [ ! -d "$FEATURE_PATH" ]; then
  echo -e "${RED}Error: Feature not found at $FEATURE_PATH${NC}"
  exit 1
fi

echo -e "${BLUE}Validating feature: $FEATURE_NAME${NC}"
echo ""

PASS_COUNT=0
FAIL_COUNT=0

check() {
  local name="$1"
  local path="$2"
  
  echo -n "Checking $name... "
  if [ -e "$path" ]; then
    echo -e "${GREEN}✓${NC}"
    ((PASS_COUNT++))
  else
    echo -e "${RED}✗${NC} (missing: $path)"
    ((FAIL_COUNT++))
  fi
}

# Check directory structure
echo -e "${BLUE}Directory Structure:${NC}"
check "data/datasources" "$FEATURE_PATH/data/datasources"
check "data/models" "$FEATURE_PATH/data/models"
check "data/repositories" "$FEATURE_PATH/data/repositories"
check "domain/entities" "$FEATURE_PATH/domain/entities"
check "domain/repositories" "$FEATURE_PATH/domain/repositories"
check "domain/usecases" "$FEATURE_PATH/domain/usecases"
check "presentation/bloc" "$FEATURE_PATH/presentation/bloc"
check "presentation/pages" "$FEATURE_PATH/presentation/pages"
echo ""

# Check required files
echo -e "${BLUE}Required Files:${NC}"
check "Entity" "$FEATURE_PATH/domain/entities/${FEATURE_NAME}.dart"
check "Repository Interface" "$FEATURE_PATH/domain/repositories/${FEATURE_NAME}_repository.dart"
check "Data Model" "$FEATURE_PATH/data/models/${FEATURE_NAME}_model.dart"
check "Data Source" "$FEATURE_PATH/data/datasources/${FEATURE_NAME}_remote_datasource.dart"
check "Repository Impl" "$FEATURE_PATH/data/repositories/${FEATURE_NAME}_repository_impl.dart"
check "BLoC Event" "$FEATURE_PATH/presentation/bloc/${FEATURE_NAME}_event.dart"
check "BLoC State" "$FEATURE_PATH/presentation/bloc/${FEATURE_NAME}_state.dart"
check "BLoC" "$FEATURE_PATH/presentation/bloc/${FEATURE_NAME}_bloc.dart"
echo ""

# Check for anti-patterns
echo -e "${BLUE}Architecture Validation:${NC}"
ANTI_PATTERNS=0

# Check domain layer has no Flutter dependencies
if grep -r "import 'package:flutter" "$FEATURE_PATH/domain" 2>/dev/null; then
  echo -e "${RED}✗${NC} Domain layer has Flutter dependencies"
  ((ANTI_PATTERNS++))
else
  echo -e "${GREEN}✓${NC} Domain layer is framework-independent"
fi

# Check pages use BLoC
PAGE_FILES=$(find "$FEATURE_PATH/presentation/pages" -name "*.dart" 2>/dev/null || echo "")
if [ -n "$PAGE_FILES" ]; then
  if echo "$PAGE_FILES" | xargs grep -l "BlocBuilder\|BlocConsumer\|BlocListener" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Pages use BLoC pattern"
  else
    echo -e "${YELLOW}⚠${NC}  Pages should use BLoC pattern"
  fi
fi

# Check for direct Firestore usage in presentation
if grep -r "FirebaseFirestore\.instance" "$FEATURE_PATH/presentation" 2>/dev/null; then
  echo -e "${RED}✗${NC} Presentation layer has direct Firestore access"
  ((ANTI_PATTERNS++))
else
  echo -e "${GREEN}✓${NC} No direct Firestore access in presentation"
fi

echo ""

# Summary
echo -e "${BLUE}════════════════════════════════════${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}════════════════════════════════════${NC}"
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
if [ "$ANTI_PATTERNS" -gt 0 ]; then
  echo -e "${RED}Anti-patterns: $ANTI_PATTERNS${NC}"
fi
echo ""

if [ "$FAIL_COUNT" -eq 0 ] && [ "$ANTI_PATTERNS" -eq 0 ]; then
  echo -e "${GREEN}✓ Feature is properly structured!${NC}"
  exit 0
else
  echo -e "${YELLOW}⚠ Feature needs attention${NC}"
  exit 1
fi
