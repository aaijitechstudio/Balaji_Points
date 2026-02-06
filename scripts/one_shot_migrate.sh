#!/bin/bash
# scripts/one_shot_migrate.sh
# Creates all feature structures for one-shot migration

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     🚀 ONE-SHOT MIGRATION - Creating All Features          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

features=(
  "splash"
  "dashboard"
  "home"
  "bills"
  "wallet"
  "transactions"
  "profile"
  "settings"
  "admin"
  "spin"
  "redeem"
  "notifications"
)

total=${#features[@]}
current=0

for feature in "${features[@]}"; do
  ((current++))
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "[$current/$total] Creating: $feature"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  if [ -d "lib/features/$feature" ]; then
    echo "⚠️  lib/features/$feature already exists - skipping"
  else
    ./scripts/create_feature.sh "$feature" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "✅ $feature structure created"
    else
      echo "❌ Failed to create $feature"
    fi
  fi
  echo ""
done

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✅ STRUCTURE CREATION COMPLETE!                           ║"
echo "╠════════════════════════════════════════════════════════════╣"
echo "║  Features created: $total                                     "
echo "║                                                            ║"
echo "║  📋 Next Steps:                                            ║"
echo "║  1. Migrate screens from lib/presentation/screens/        ║"
echo "║     to lib/features/*/presentation/pages/                 ║"
echo "║  2. Create domain layer (entities, use cases)             ║"
echo "║  3. Create data layer (models, repositories)              ║"
echo "║  4. Create BLoCs (events, states, bloc)                   ║"
echo "║  5. Update lib/injection/dependency_injection.dart        ║"
echo "║  6. Update lib/config/routes.dart                         ║"
echo "║  7. Test ALL flows                                        ║"
echo "║                                                            ║"
echo "║  📖 See ONE_SHOT_MIGRATION_PLAN.md for details            ║"
echo "╚════════════════════════════════════════════════════════════╝"

