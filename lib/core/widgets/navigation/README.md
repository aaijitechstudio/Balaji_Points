# BalajiTopNavBar Widget Documentation

## Overview

`BalajiTopNavBar` is a comprehensive, standardized navigation bar widget that follows iOS and Android material design standards. It automatically handles safe areas and provides extensive customization options.

## Features

✅ **Platform-Aware**: Automatically uses iOS/Android appropriate icons  
✅ **Safe Area Handling**: Built-in safe area support  
✅ **Highly Customizable**: 20+ customization options  
✅ **Type-Safe**: Full TypeScript-like type safety  
✅ **Design System Integration**: Uses DesignToken for consistency  
✅ **Preset Configurations**: Common patterns built-in  

## Basic Usage

### Import

```dart
import 'package:balaji_points/core/widgets/navigation/balaji_top_nav_bar.dart';
```

### Simple Example

```dart
Scaffold(
  appBar: BalajiTopNavBar(
    title: 'My Page',
  ),
  body: YourContent(),
)
```

## Common Patterns

### 1. Standard Page with Back Button

```dart
Scaffold(
  appBar: BalajiTopNavBar(
    title: 'Profile Settings',
    onBackPressed: () => Navigator.pop(context),
  ),
  body: YourContent(),
)
```

### 2. Page with Action Buttons

```dart
Scaffold(
  appBar: BalajiTopNavBar(
    title: 'Edit Profile',
    actions: [
      IconButton(
        icon: Icon(Icons.save),
        onPressed: _saveProfile,
      ),
      IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: _showMenu,
      ),
    ],
  ),
  body: YourContent(),
)
```

### 3. No Back Button (Home/Dashboard)

```dart
Scaffold(
  appBar: BalajiTopNavBar(
    title: 'Dashboard',
    showBackButton: false,
    actions: [
      IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () {},
      ),
    ],
  ),
  body: YourContent(),
)
```

### 4. Custom Leading Widget

```dart
Scaffold(
  appBar: BalajiTopNavBar(
    title: 'My App',
    leading: CircleAvatar(
      backgroundImage: NetworkImage(userAvatar),
    ),
    leadingWidth: 56,
  ),
  body: YourContent(),
)
```

### 5. Gradient Background

```dart
Scaffold(
  appBar: BalajiTopNavBar(
    title: 'Premium Section',
    backgroundGradient: LinearGradient(
      colors: DesignToken.primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    iconColor: DesignToken.white,
    titleStyle: TextStyle(color: DesignToken.white),
  ),
  body: YourContent(),
)
```

### 6. Transparent (for Custom Backgrounds)

```dart
Stack(
  children: [
    // Your custom background (image, gradient, etc.)
    CustomBackground(),
    
    Scaffold(
      backgroundColor: Colors.transparent,
      appBar: BalajiTopNavBar(
        title: 'Beautiful Page',
        isTransparent: true,
        iconColor: DesignToken.white,
        titleStyle: TextStyle(color: DesignToken.white),
      ),
      body: YourContent(),
    ),
  ],
)
```

### 7. With Bottom Widget (Search, Tabs, etc.)

```dart
Scaffold(
  appBar: BalajiTopNavBar(
    title: 'Search',
    bottom: SearchBar(),
    bottomHeight: 60,
  ),
  body: YourContent(),
)
```

### 8. Elevated/Shadow

```dart
Scaffold(
  appBar: BalajiTopNavBar(
    title: 'My Page',
    elevation: 4,
    backgroundColor: DesignToken.white,
  ),
  body: YourContent(),
)
```

### 9. With Bottom Border

```dart
Scaffold(
  appBar: BalajiTopNavBar(
    title: 'Settings',
    showBottomBorder: true,
    bottomBorderColor: DesignToken.grey300,
  ),
  body: YourContent(),
)
```

### 10. Custom Title Widget

```dart
Scaffold(
  appBar: BalajiTopNavBar(
    titleWidget: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: DesignToken.amber),
        SizedBox(width: 8),
        Text('Premium'),
      ],
    ),
  ),
  body: YourContent(),
)
```

## Using Presets

The `BalajiTopNavBarPresets` class provides common configurations:

### Standard (Default)

```dart
appBar: BalajiTopNavBarPresets.standard(
  title: 'My Page',
  onBackPressed: () => Navigator.pop(context),
),
```

### Transparent

```dart
appBar: BalajiTopNavBarPresets.transparent(
  title: 'Beautiful Page',
  iconColor: DesignToken.white,
),
```

### Primary Color

```dart
appBar: BalajiTopNavBarPresets.primary(
  title: 'Important Section',
  actions: [
    IconButton(icon: Icon(Icons.save), onPressed: () {}),
  ],
),
```

### Gradient

```dart
appBar: BalajiTopNavBarPresets.gradient(
  title: 'Premium Feature',
  gradient: LinearGradient(
    colors: DesignToken.successGradient,
  ),
),
```

### No Back Button

```dart
appBar: BalajiTopNavBarPresets.noBack(
  title: 'Home',
  actions: [
    IconButton(icon: Icon(Icons.search), onPressed: () {}),
  ],
),
```

### Modal (with Close Button)

```dart
appBar: BalajiTopNavBarPresets.modal(
  title: 'Filter Options',
  onClose: () => Navigator.pop(context),
),
```

### Custom Configuration

```dart
appBar: BalajiTopNavBarPresets.custom(
  title: 'Custom',
  leading: YourLeadingWidget(),
  backgroundColor: DesignToken.navyBackground,
  elevation: 2,
),
```

## All Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `titleText` | `String?` | `null` | Title text to display |
| `titleWidget` | `Widget?` | `null` | Custom title widget (overrides titleText) |
| `titleStyle` | `TextStyle?` | Theme default | Text style for title |
| `centerTitle` | `bool` | `true` | Whether to center the title |
| `showBackButton` | `bool?` | Auto-detect | Show back button |
| `leading` | `Widget?` | `null` | Custom leading widget |
| `leadingWidth` | `double?` | `56.0` | Width of leading widget |
| `onBackPressed` | `VoidCallback?` | `Navigator.pop` | Back button callback |
| `actions` | `List<Widget>?` | `null` | Action buttons (right side) |
| `backgroundColor` | `Color?` | Theme default | Background color |
| `backgroundGradient` | `Gradient?` | `null` | Gradient background |
| `elevation` | `double` | `0` | Elevation/shadow |
| `showBottomBorder` | `bool` | `false` | Show bottom border line |
| `bottomBorderColor` | `Color?` | `grey300` | Bottom border color |
| `height` | `double?` | `kToolbarHeight` | Custom height |
| `iconColor` | `Color?` | Theme default | Icon color |
| `automaticStatusBarColor` | `bool` | `true` | Auto status bar brightness |
| `statusBarBrightness` | `Brightness?` | Auto | Status bar brightness |
| `applySafeArea` | `bool` | `true` | Apply safe area |
| `bottom` | `Widget?` | `null` | Bottom widget (tabs, search) |
| `bottomHeight` | `double?` | `null` | Height of bottom widget |
| `isTransparent` | `bool` | `false` | Transparent background |
| `flexibleSpace` | `double?` | `null` | Flexible space height |

## Real-World Examples

### Example 1: User Profile Page

```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBar(
        title: 'My Profile',
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => context.push('/edit-profile'),
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: ProfileContent(),
    );
  }
}
```

### Example 2: Settings Page with Sections

```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBarPresets.standard(
        title: 'Settings',
        centerTitle: false,
      ),
      body: SettingsContent(),
    );
  }
}
```

### Example 3: Premium Feature with Gradient

```dart
class PremiumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBar(
        title: '⭐ Premium Features',
        backgroundGradient: LinearGradient(
          colors: [
            DesignToken.tierGold,
            DesignToken.amberShade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        iconColor: DesignToken.white,
        titleStyle: context.text.heading5.copyWith(
          color: DesignToken.white,
          fontWeight: FontWeight.w700,
        ),
        elevation: 4,
      ),
      body: PremiumContent(),
    );
  }
}
```

### Example 4: Search Page with Search Bar

```dart
class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBar(
        title: 'Search',
        bottom: Padding(
          padding: context.spacing.paddingHorizontalLG,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        bottomHeight: 72,
      ),
      body: SearchResults(),
    );
  }
}
```

### Example 5: Modal Bottom Sheet

```dart
void _showFilterSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      children: [
        BalajiTopNavBarPresets.modal(
          title: 'Filter Options',
          onClose: () => Navigator.pop(context),
          actions: [
            TextButton(
              onPressed: _clearFilters,
              child: Text('Clear'),
            ),
          ],
        ),
        Expanded(child: FilterContent()),
      ],
    ),
  );
}
```

### Example 6: Image Background Page

```dart
class HeroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Image.network(
          backgroundUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        
        // Content
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: BalajiTopNavBarPresets.transparent(
            title: 'Hero Section',
            iconColor: DesignToken.white,
            titleStyle: context.text.heading4.copyWith(
              color: DesignToken.white,
              shadows: [
                Shadow(
                  color: DesignToken.black54,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          body: YourContent(),
        ),
      ],
    );
  }
}
```

## Migration Guide

### Before (Standard AppBar)

```dart
Scaffold(
  appBar: AppBar(
    title: Text('My Page'),
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.save),
        onPressed: _save,
      ),
    ],
  ),
  body: Content(),
)
```

### After (BalajiTopNavBar)

```dart
Scaffold(
  appBar: BalajiTopNavBar(
    title: 'My Page',
    onBackPressed: () => Navigator.pop(context),
    actions: [
      IconButton(
        icon: Icon(Icons.save),
        onPressed: _save,
      ),
    ],
  ),
  body: Content(),
)
```

## Benefits

✅ **Consistency**: Same look across all screens  
✅ **Safe Area**: Automatic handling for notched devices  
✅ **Platform Aware**: iOS/Android appropriate styling  
✅ **Less Code**: Presets reduce boilerplate  
✅ **Type Safe**: Full compile-time checking  
✅ **Flexible**: 20+ customization options  
✅ **Maintainable**: Change navigation style app-wide  

## Tips

1. **Use Presets First**: Start with presets, customize only if needed
2. **Design Token Colors**: Always use DesignToken colors for consistency
3. **Safe Area**: Leave `applySafeArea: true` (default) for proper spacing
4. **Back Button**: Let it auto-detect, override only when necessary
5. **Elevation**: Use elevation instead of shadow for Material Design compliance
6. **Testing**: Test on both iOS and Android for platform differences

## Questions?

- See existing usage in feature pages
- Check design tokens: `lib/core/theme/design_token.dart`
- Review presets: `BalajiTopNavBarPresets` class
