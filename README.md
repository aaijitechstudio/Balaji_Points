# Balaji Points

A comprehensive, role-based points management application built exclusively for **Shree Balaji Plywood and Hardware**. This Flutter application digitally manages carpenter reward points in a simple, secure, and transparent way, enabling seamless tracking of purchases, points accumulation, and reward redemption.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Design System](#design-system)
- [Authentication & Security](#authentication--security)
- [User Roles](#user-roles)
- [Key Functionality](#key-functionality)
- [Setup Instructions](#setup-instructions)
- [Configuration](#configuration)
- [Localization](#localization)
- [Development Guidelines](#development-guidelines)
- [Contact & Support](#contact--support)

---

## 🎯 Overview

**Balaji Points** is a private mobile application designed to revolutionize how Shree Balaji Plywood and Hardware manages its loyalty program for carpenters. The app provides a digital platform where carpenters can:

- **Earn Points**: Submit bills from purchases to earn reward points (1 point per ₹1000 spent)
- **Track Points**: Monitor their point balance, transaction history, and tier status
- **Redeem Rewards**: Exchange accumulated points for various rewards and offers
- **Daily Prizes**: Participate in daily spin-to-win games for additional rewards
- **Leaderboard**: Compete with other carpenters and see top performers

The application features a dual-role system with separate interfaces for **Carpenters** (end users) and **Administrators** (business managers), ensuring secure and efficient point management.

---

## ✨ Features

### For Carpenters

- 🔐 **Secure Authentication**
  - Phone number-based login with OTP verification
  - PIN-based authentication for quick access
  - Secure session management

- 📱 **Points Management**
  - Real-time point balance display
  - Transaction history with detailed records
  - Points earned from bill submissions
  - Visual tier system (Platinum, Gold, Silver, Bronze)

- 📄 **Bill Submission**
  - Upload bill images with camera or gallery
  - Submit bill details (amount, date, vendor, invoice number)
  - Track bill status (Pending, Approved, Rejected)
  - View bill history and status updates

- 🎁 **Rewards & Offers**
  - Browse available offers and rewards
  - Redeem points for rewards
  - View offer details and validity periods
  - Carousel-based offer display

- 🎰 **Daily Spin**
  - Daily spin-to-win game
  - Random prize selection (10-80 points)
  - Visual spin wheel animation
  - 24-hour cooldown between spins

- 🏆 **Leaderboard**
  - Top carpenters ranking
  - Current user position tracking
  - Points-based competition

- 👤 **Profile Management**
  - View and edit profile information
  - Upload profile picture
  - Change PIN
  - View account details and tier status

### For Administrators

- 📊 **Dashboard**
  - Overview of pending bills, offers, users, and daily spin management
  - Tab-based navigation for different management sections

- 📋 **Bill Management**
  - Review and approve/reject pending bills
  - View bill details and images
  - Filter bills by status
  - Bulk operations support

- 👥 **User Management**
  - View all registered carpenters
  - Add new carpenters with phone verification
  - Verify user accounts
  - View user details and transaction history
  - Filter users by status (verified/pending)

- 🎁 **Offer Management**
  - Create, edit, and delete offers
  - Set offer types (Banner, Basic, Full Width)
  - Configure offer validity dates
  - Set points required for redemption
  - Upload offer images

- 🎰 **Daily Spin Management**
  - Configure daily spin prizes
  - View today's eligible carpenters
  - Manage spin wheel settings
  - Track spin history

---

## 🛠 Technology Stack

### Frontend Framework
- **Flutter** (SDK: ^3.9.2)
- **Dart** programming language

### State Management
- **Flutter Riverpod** (^3.0.3) - Reactive state management

### Navigation
- **GoRouter** (^14.0.0) - Declarative routing with deep linking support

### Backend Services
- **Firebase Core** (^4.2.0)
- **Firebase Authentication** (^6.1.1) - Phone-based authentication
- **Cloud Firestore** (^6.0.3) - NoSQL database
- **Firebase Storage** (^13.0.3) - Image and file storage
- **Firebase Cloud Messaging** (^16.0.4) - Push notifications

### UI/UX Libraries
- **Material Design 3** - Modern Material Design components
- **Shimmer** (^3.0.0) - Loading skeleton animations
- **Confetti** (^0.7.0) - Celebration animations
- **Google Fonts** (^6.2.1) - Nunito font family
- **Image Picker** (^1.0.7) - Camera and gallery access

### Security & Storage
- **Flutter Secure Storage** (^9.2.2) - Encrypted local storage
- **Shared Preferences** (^2.3.5) - Simple key-value storage
- **Crypto** (^3.0.7) - Cryptographic functions

### Utilities
- **Intl** (^0.20.0) - Internationalization and date formatting
- **URL Launcher** (^6.3.1) - Open external URLs
- **PIN Code Fields** (^8.0.1) - PIN input widgets
- **Package Info Plus** (^8.1.2) - App version information

---

## 🏗 Architecture

The application follows a **clean architecture** pattern with clear separation of concerns:

### Layer Structure

```
lib/
├── core/              # Core utilities and shared code
│   ├── constants/     # App-wide constants
│   ├── mixins/        # Reusable mixins (back button, form tracking)
│   ├── theme/         # Design tokens and theme configuration
│   └── utils/         # Utility functions
│
├── config/            # Configuration files
│   ├── routes.dart    # Route definitions
│   └── theme.dart     # Legacy theme (backward compatibility)
│
├── presentation/      # UI layer
│   ├── screens/       # Screen widgets
│   ├── widgets/       # Reusable UI components
│   └── providers/     # Riverpod state providers
│
├── services/          # Business logic and API services
│   ├── auth/          # Authentication services
│   ├── bill/          # Bill management services
│   ├── user/          # User management services
│   └── storage/       # Storage services
│
├── l10n/              # Localization files
│   ├── app_en.arb     # English translations
│   ├── app_hi.arb     # Hindi translations
│   └── app_ta.arb     # Tamil translations
│
└── main.dart          # Application entry point
```

### Design Patterns

- **Provider Pattern**: State management with Riverpod
- **Repository Pattern**: Service layer abstraction
- **Singleton Pattern**: Service instances
- **Factory Pattern**: Widget creation
- **Observer Pattern**: State updates and notifications

---

## 📁 Project Structure

### Core Components

#### Design System (`lib/core/theme/design_token.dart`)
Centralized design tokens including:
- **Colors**: Primary, secondary, status colors, gradients
- **Spacing**: Padding, margin, SizedBox heights/widths (4px base unit)
- **Typography**: Text styles, font sizes, font weights
- **Icons**: Standardized icon sizes (XS to 4XL)
- **Buttons**: Heights, padding, minimum widths
- **Border Radius**: Consistent corner radius values
- **Shadows**: Elevation and shadow presets
- **Animations**: Standardized duration constants

#### Authentication Flow
1. **Splash Screen** → App initialization
2. **Login Screen** → Phone number entry
3. **OTP Verification** → Phone authentication
4. **PIN Setup** → First-time PIN creation
5. **PIN Login** → Quick access authentication
6. **Dashboard** → Main application interface

#### Navigation Structure
- **GoRouter** for declarative routing
- Deep linking support
- Route guards for authentication
- Nested navigation for tabs

---

## 🎨 Design System

The application uses a comprehensive **Design Token** system for consistent UI/UX:

### Color Palette
- **Primary**: `#192F6A` (Dark Blue)
- **Secondary**: `#EB5070` (Pink Accent)
- **Background**: `#FFFFFF` (White)
- **Text Dark**: `#1E2A4A` (Dark Navy)
- **Status Colors**: Success (Green), Warning (Amber), Error (Red), Info (Blue)

### Typography
- **Font Family**: Nunito (Variable weight)
- **Font Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)
- **Font Sizes**: 10px to 32px scale

### Spacing System
- **Base Unit**: 4px
- **Scale**: XS (4px) → SM (8px) → MD (12px) → LG (16px) → XL (20px) → 2XL (24px) → 3XL (32px) → 4XL (40px) → 5XL (48px) → 6XL (60px)

### Component Standards
- **Border Radius**: 4px to 24px, with fully rounded option
- **Icon Sizes**: 12px to 64px
- **Button Heights**: 32px to 64px
- **Elevation**: 0 to 16dp

---

## 🔐 Authentication & Security

### Authentication Methods

1. **Phone Authentication**
   - Firebase Phone Auth integration
   - OTP verification via SMS
   - 6-digit OTP code
   - 60-second resend timeout

2. **PIN Authentication**
   - 4-digit PIN for quick access
   - Encrypted storage using Flutter Secure Storage
   - PIN reset functionality with phone verification
   - Session-based authentication

### Security Features

- **Secure Storage**: Sensitive data encrypted locally
- **Session Management**: Automatic session timeout
- **Input Validation**: Comprehensive form validation
- **Image Compression**: Optimized image uploads (max 5MB)
- **Network Security**: HTTPS-only API calls

---

## 👥 User Roles

### Carpenter (End User)
- **Access Level**: Standard user
- **Permissions**:
  - Submit bills
  - View own points and transactions
  - Redeem rewards
  - Participate in daily spin
  - View leaderboard
  - Manage own profile

### Administrator
- **Access Level**: Full system access
- **Permissions**:
  - Approve/reject bills
  - Manage offers
  - View all users
  - Add new carpenters
  - Configure daily spin
  - View analytics and reports

---

## 🚀 Key Functionality

### Points System
- **Conversion Rate**: 1 Point = ₹1000 spent
- **Points Calculation**: Automatic based on approved bill amounts
- **Tier System**:
  - Platinum (Highest tier)
  - Gold
  - Silver
  - Bronze (Default tier)

### Bill Submission Workflow
1. User captures/selects bill image
2. Enters bill details (amount, date, vendor, invoice number, notes)
3. Submits bill for review
4. Admin reviews and approves/rejects
5. Points credited upon approval
6. User receives notification

### Daily Spin Mechanism
- **Eligibility**: Users with approved bills on the current day
- **Prize Range**: 10 to 80 points
- **Cooldown**: 24 hours between spins
- **Animation**: 3-second spin animation
- **Random Selection**: Fair prize distribution

### Offer Management
- **Offer Types**:
  - **Banner**: Full-width promotional offers
  - **Basic**: Standard card-based offers
  - **Full Width**: Expanded offer cards
- **Offer Properties**: Title, description, image, points required, validity dates, active status

---

## 📦 Setup Instructions

### Prerequisites

- **Flutter SDK**: 3.9.2 or higher
- **Dart SDK**: 3.9.2 or higher
- **Android Studio** / **VS Code** with Flutter extensions
- **Firebase Account** with project setup
- **Android SDK** (for Android development)
- **Xcode** (for iOS development, macOS only)

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/aaijitechstudio/Balaji_Points.git
   cd balaji_points
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from Firebase Console
   - Place Android file in `android/app/`
   - Place iOS file in `ios/Runner/`
   - Ensure Firebase project has Authentication, Firestore, Storage, and Cloud Messaging enabled

4. **Generate Localization Files**
   ```bash
   flutter gen-l10n
   ```

5. **Run the Application**
   ```bash
   flutter run
   ```

### Build Instructions

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## ⚙️ Configuration

### App Constants (`lib/core/constants/app_constants.dart`)

Key configuration values:
- **Points Conversion**: 1000 ₹ = 1 Point
- **Support Contacts**: Phone numbers and email
- **Validation Limits**: Name length, phone length, bill amount limits
- **Pagination**: Default page size (20 items)
- **Timeouts**: OTP resend (60s), network (30s)
- **Daily Spin**: 24-hour cooldown

### Environment Variables

Ensure the following are configured:
- Firebase project credentials
- API endpoints (if using custom backend)
- Push notification keys

---

## 🌍 Localization

The application supports **three languages**:

- **English** (`en`) - Default
- **Hindi** (`hi`)
- **Tamil** (`ta`)

### Adding New Translations

1. Edit the corresponding `.arb` file in `lib/l10n/`
2. Add new key-value pairs:
   ```json
   {
     "keyName": "Translation Text",
     "@keyName": {
       "description": "Description of the key"
     }
   }
   ```
3. Run `flutter gen-l10n` to generate localization files

### Usage in Code

```dart
final l10n = AppLocalizations.of(context);
Text(l10n?.welcomeMessage ?? 'Welcome')
```

---

## 💻 Development Guidelines

### Code Style

- Follow **Dart style guide**
- Use **meaningful variable names**
- Add **comments** for complex logic
- Maintain **consistent indentation** (2 spaces)
- Use **const constructors** where possible

### Design Token Usage

**Always use DesignToken for:**
- Colors: `DesignToken.primary`, `DesignToken.secondary`
- Spacing: `DesignToken.spacingLG`, `DesignToken.paddingMD`
- Text Styles: `DesignToken.heading1`, `DesignToken.bodyMedium`
- Icon Sizes: `DesignToken.iconSizeLG`
- Border Radius: `DesignToken.radiusMD`

**Example:**
```dart
Container(
  padding: DesignToken.paddingAllLG,
  decoration: BoxDecoration(
    color: DesignToken.primary,
    borderRadius: DesignToken.borderRadiusMD,
  ),
  child: Text(
    'Hello',
    style: DesignToken.heading3,
  ),
)
```

### State Management

- Use **Riverpod** for all state management
- Create providers in `lib/presentation/providers/`
- Use `ConsumerWidget` or `ConsumerStatefulWidget` for reactive UI

### Navigation

- Use **GoRouter** for all navigation
- Define routes in `lib/config/routes.dart`
- Use `context.push('/route')` for navigation
- Use `context.pop()` for going back

### Error Handling

- Always handle async operations with try-catch
- Show user-friendly error messages
- Log errors for debugging
- Use `LoadingOverlay` for async operations

### Image Handling

- Compress images before upload (max 5MB)
- Use `ImagePicker` for camera/gallery access
- Store images in Firebase Storage
- Display images with proper error handling

---

## 📞 Contact & Support

### Support Information

- **Phone 1**: 96006-09121
- **Phone 2**: 0424-3557187
- **Email**: support@balajipoints.com

### Development Team

For technical issues or feature requests, please contact the development team.

---

## 📄 License

This is a **private application** built exclusively for Shree Balaji Plywood and Hardware. All rights reserved.

---

## 🔄 Version History

- **v1.0.0** - Initial release
  - Core points management functionality
  - Bill submission and approval system
  - Daily spin feature
  - Admin panel
  - Multi-language support (English, Hindi, Tamil)
  - Design token system
  - Android back button handling

---

## 🎯 Future Enhancements

- [ ] Push notification system
- [ ] Advanced analytics dashboard
- [ ] Export transaction reports
- [ ] QR code scanning for bills
- [ ] Social sharing features
- [ ] Referral program
- [ ] In-app chat support
- [ ] Dark mode optimization

---

## 📝 Notes

- The application requires an active internet connection for most features
- Bill images are stored securely in Firebase Storage
- All sensitive data is encrypted using Flutter Secure Storage
- The app follows Material Design 3 guidelines
- Backward compatibility is maintained for legacy theme components

---

**Built with ❤️ for Shree Balaji Plywood and Hardware**
