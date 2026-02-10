# Design System Guide

## Overview

The Balaji Points app uses a centralized design system with **DesignToken** as the single source of truth for all design decisions. This ensures consistency, maintainability, and easy theming.

## Files Structure

```
lib/core/theme/
├── design_token.dart           # 🎨 ALL design values defined here
├── design_token_extensions.dart # 🔧 Easy access helpers
├── app_theme.dart              # 🎭 Theme configuration (light/dark)
└── README.md                   # 📚 This guide
```

## Quick Start

### Import the Design Token

```dart
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/theme/design_token_extensions.dart';
```

### Using Design Tokens

#### ❌ WRONG (Hardcoded values)
```dart
Container(
  color: Color(0xFF192F6A),
  padding: EdgeInsets.all(16.0),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
  ),
)
```

#### ✅ CORRECT (Using DesignToken)
```dart
Container(
  color: DesignToken.primary,
  padding: DesignToken.paddingAllLG,
  child: Text(
    'Hello',
    style: DesignToken.heading3,
  ),
)
```

#### ✨ BEST (Using Extensions - Most Convenient!)
```dart
Container(
  color: context.colors.primary,
  padding: context.spacing.paddingLG,
  child: Text(
    'Hello',
    style: context.text.heading3,
  ),
)
```

## Available Tokens

### 🎨 Colors

#### Brand Colors
```dart
DesignToken.primary           // Dark blue #192F6A
DesignToken.secondary         // Pink #EB5070
DesignToken.background        // White #FFFFFF
DesignToken.textDark          // Navy text #1E2A4A

// Using extensions
context.colors.primary
context.colors.secondary
```

#### Status Colors
```dart
DesignToken.success   // Green
DesignToken.warning   // Amber
DesignToken.error     // Red
DesignToken.info      // Blue

// Using extensions
context.colors.success
context.colors.error
```

#### Neutral Colors
```dart
DesignToken.grey50    // Lightest
DesignToken.grey100
DesignToken.grey200
// ... through grey900

// Using extensions
context.colors.grey100
context.colors.grey500
```

#### Tier Colors
```dart
DesignToken.tierPlatinum  // Cyan
DesignToken.tierGold      // Gold
DesignToken.tierSilver    // Silver
DesignToken.tierBronze    // Bronze

// Helper method
DesignToken.getTierColor('Gold')  // Returns appropriate color

// Using extensions
context.colors.tierGold
```

#### Gradients
```dart
DesignToken.primaryGradient
DesignToken.secondaryGradient
DesignToken.successGradient

// Using extensions
context.colors.primaryGradient
```

### 📏 Spacing

#### Values (8px scale)
```dart
DesignToken.spacingXS   // 4px
DesignToken.spacingSM   // 8px
DesignToken.spacingMD   // 12px
DesignToken.spacingLG   // 16px
DesignToken.spacingXL   // 20px
DesignToken.spacing2XL  // 24px
DesignToken.spacing3XL  // 32px
DesignToken.spacing4XL  // 40px
DesignToken.spacing5XL  // 48px
DesignToken.spacing6XL  // 60px

// Using extensions
context.spacing.lg   // 16px
context.spacing.xl2  // 24px
```

#### EdgeInsets Presets
```dart
// All sides
DesignToken.paddingAllSM   // 8px all sides
DesignToken.paddingAllLG   // 16px all sides
DesignToken.paddingAllXL   // 20px all sides

// Horizontal only
DesignToken.paddingHorizontalLG

// Vertical only
DesignToken.paddingVerticalLG

// Using extensions
context.spacing.paddingLG
context.spacing.paddingHorizontalMD
```

#### SizedBox Helpers
```dart
// Using extensions (returns SizedBox directly!)
context.spacing.heightMD    // SizedBox(height: 12)
context.spacing.heightLG    // SizedBox(height: 16)
context.spacing.widthXL     // SizedBox(width: 20)

// Example usage
Column(
  children: [
    Text('First'),
    context.spacing.heightLG,  // Perfect for vertical spacing!
    Text('Second'),
  ],
)
```

### ✍️ Typography

#### Heading Styles
```dart
DesignToken.heading1  // 32px, Bold
DesignToken.heading2  // 28px, Bold
DesignToken.heading3  // 24px, Bold
DesignToken.heading4  // 20px, Bold
DesignToken.heading5  // 18px, SemiBold
DesignToken.heading6  // 16px, SemiBold

// Using extensions
context.text.heading1
context.text.heading3
```

#### Body Text Styles
```dart
DesignToken.bodyLarge   // 16px
DesignToken.bodyMedium  // 14px
DesignToken.bodySmall   // 12px

// Using extensions
context.text.bodyMedium
```

#### Label Styles
```dart
DesignToken.labelLarge   // 14px, Medium weight
DesignToken.labelMedium  // 12px, Medium weight
DesignToken.labelSmall   // 10px, Medium weight

// Using extensions
context.text.labelLarge
```

#### Font Sizes
```dart
DesignToken.fontSizeXS   // 10px
DesignToken.fontSizeSM   // 12px
DesignToken.fontSizeMD   // 14px
DesignToken.fontSizeLG   // 16px
DesignToken.fontSizeXL   // 18px
DesignToken.fontSize2XL  // 20px
DesignToken.fontSize3XL  // 24px
DesignToken.fontSize4XL  // 28px
DesignToken.fontSize5XL  // 32px

// Using extensions
context.text.lg   // 16px
context.text.xl3  // 24px
```

#### Font Weights
```dart
DesignToken.textRegular    // 400
DesignToken.textMedium     // 500
DesignToken.textSemiBold   // 600
DesignToken.textBold       // 700

// Using extensions
context.text.bold
context.text.semiBold
```

### 🔲 Border Radius

```dart
DesignToken.radiusXS    // 4px
DesignToken.radiusSM    // 8px
DesignToken.radiusMD    // 12px
DesignToken.radiusLG    // 16px
DesignToken.radiusXL    // 20px
DesignToken.radius2XL   // 24px
DesignToken.radiusRound // 999px (fully rounded)

// BorderRadius presets
DesignToken.borderRadiusMD   // BorderRadius.all(Radius.circular(12))
DesignToken.borderRadiusLG
DesignToken.borderRadiusRound

// Using extensions
context.radius.md         // 12.0
context.radius.borderLG   // BorderRadius object
```

### 🎯 Icon Sizes

```dart
DesignToken.iconSizeXS   // 12px
DesignToken.iconSizeSM   // 16px
DesignToken.iconSizeMD   // 20px
DesignToken.iconSizeLG   // 24px
DesignToken.iconSizeXL   // 32px
DesignToken.iconSize2XL  // 40px
DesignToken.iconSize3XL  // 48px
DesignToken.iconSize4XL  // 64px

// Using extensions
context.icons.lg   // 24px
context.icons.xl2  // 40px
```

### 🎚️ Elevation & Shadows

```dart
DesignToken.elevationSM   // 2.0
DesignToken.elevationMD   // 4.0
DesignToken.elevationLG   // 8.0
DesignToken.elevationXL   // 12.0

// Shadow presets
DesignToken.shadowSM   // List<BoxShadow>
DesignToken.shadowMD
DesignToken.shadowLG
DesignToken.shadowXL

// Using extensions
context.elevation.md
context.elevation.shadowLG
```

### ⏱️ Animation Durations

```dart
DesignToken.animationDurationFast      // 200ms
DesignToken.animationDurationNormal    // 300ms
DesignToken.animationDurationSlow      // 500ms
DesignToken.animationDurationVerySlow  // 1000ms
```

## Helper Methods

### Get Status Color
```dart
DesignToken.getStatusColor('approved')  // Returns success color
DesignToken.getStatusColor('pending')   // Returns warning color
DesignToken.getStatusColor('rejected')  // Returns error color
```

### Get Transaction Color
```dart
DesignToken.getTransactionColor('earned')   // Returns pointsEarned (green)
DesignToken.getTransactionColor('spent')    // Returns pointsSpent (red)
DesignToken.getTransactionColor('pending')  // Returns pointsPending (amber)
```

### Get Tier Color
```dart
DesignToken.getTierColor('Platinum')  // Returns tierPlatinum
DesignToken.getTierColor('Gold')      // Returns tierGold
DesignToken.getTierColor('Silver')    // Returns tierSilver
DesignToken.getTierColor('Bronze')    // Returns tierBronze
```

## Real-World Examples

### Example 1: Card Widget
```dart
Container(
  padding: DesignToken.paddingAllLG,
  decoration: BoxDecoration(
    color: DesignToken.white,
    borderRadius: DesignToken.borderRadiusMD,
    boxShadow: DesignToken.shadowMD,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Title', style: DesignToken.heading4),
      SizedBox(height: DesignToken.heightSM),
      Text('Description', style: DesignToken.bodyMedium),
    ],
  ),
)
```

### Example 2: Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: DesignToken.primary,
    padding: DesignToken.buttonPaddingLG,
    shape: RoundedRectangleBorder(
      borderRadius: DesignToken.borderRadiusMD,
    ),
  ),
  onPressed: () {},
  child: Text(
    'Continue',
    style: DesignToken.textBold.copyWith(
      fontSize: DesignToken.fontSizeLG,
      color: DesignToken.white,
    ),
  ),
)
```

### Example 3: Status Badge
```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: DesignToken.paddingSM,
    vertical: DesignToken.paddingXS,
  ),
  decoration: BoxDecoration(
    color: DesignToken.getStatusColor(status),
    borderRadius: DesignToken.borderRadiusSM,
  ),
  child: Text(
    status.toUpperCase(),
    style: DesignToken.labelSmall.copyWith(
      color: DesignToken.white,
    ),
  ),
)
```

### Example 4: Using Extensions (Cleanest!)
```dart
Container(
  padding: context.spacing.paddingLG,
  decoration: BoxDecoration(
    color: context.colors.white,
    borderRadius: context.radius.borderMD,
    boxShadow: context.elevation.shadowMD,
  ),
  child: Column(
    children: [
      Text('Title', style: context.text.heading4),
      context.spacing.heightSM,  // ✨ Perfect spacing!
      Text('Body', style: context.text.bodyMedium),
    ],
  ),
)
```

## Benefits

### ✅ Single Source of Truth
- Edit `design_token.dart` only to change entire app design
- No searching for hardcoded values

### ✅ Consistency
- Same spacing, colors, typography everywhere
- Professional, cohesive design

### ✅ Easy Theming
- Light/Dark mode support built-in
- Add new themes easily

### ✅ Maintainability
- Type-safe constants (no magic numbers)
- Clear naming conventions
- Easy to understand

### ✅ Developer Experience
- Autocomplete in IDE
- Less typing with extensions
- Quick to implement new screens

## Migration Checklist

When creating new components or updating existing ones:

- [ ] Import design token files
- [ ] Replace hardcoded colors with `DesignToken.*`
- [ ] Replace hardcoded spacing with `DesignToken.spacing*`
- [ ] Replace hardcoded font sizes with `DesignToken.fontSize*`
- [ ] Replace hardcoded font weights with `DesignToken.text*`
- [ ] Use `DesignToken.borderRadius*` for rounded corners
- [ ] Use `DesignToken.elevation*` and `shadowe*` for depth
- [ ] Consider using extensions (`context.*`) for cleaner code

## Need to Change Design?

### Change Primary Color
```dart
// In design_token.dart
static const Color primary = Color(0xFF192F6A); // Change this hex value
```
✨ That's it! Entire app updates automatically.

### Change Spacing Scale
```dart
// In design_token.dart
static const double spacingLG = 16.0; // Change to 18.0 or any value
```
✨ All spacing using `spacingLG` updates everywhere!

### Change Typography
```dart
// In design_token.dart
static const TextStyle heading1 = TextStyle(
  fontFamily: fontFamily,
  fontSize: 32.0,  // Change this
  fontWeight: FontWeight.w700,
  color: textDark,
);
```
✨ All H1 headings update app-wide!

## Questions?

Check these files:
- `design_token.dart` - See all available tokens
- `design_token_extensions.dart` - See extension helpers
- `app_theme.dart` - See how theme is configured

**Remember**: Always use design tokens, never hardcode design values!
