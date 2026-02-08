# Balaji Points - Project Architecture Documentation

**Version:** 1.0.3+5  
**Last Updated:** February 8, 2026  
**Architecture:** Clean Architecture with BLoC Pattern  
**Platform:** Flutter (SDK ^3.9.2)

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Overview](#architecture-overview)
3. [Project Structure](#project-structure)
4. [Features](#features)
5. [Technology Stack](#technology-stack)
6. [Core Components](#core-components)
7. [Data Flow](#data-flow)
8. [State Management](#state-management)
9. [Navigation](#navigation)
10. [Authentication](#authentication)
11. [Backend Integration](#backend-integration)
12. [Logging System](#logging-system)
13. [Dependency Injection](#dependency-injection)
14. [Design Patterns](#design-patterns)
15. [Best Practices](#best-practices)

---

## 🎯 Project Overview

### What is Balaji Points?

**Balaji Points** is a comprehensive rewards and loyalty management system designed for carpenters. The application allows carpenters to:

- Submit bills and earn points for purchases
- Track their points balance and tier status
- Redeem points for offers and rewards
- Participate in daily spin games
- View transaction history and notifications
- Manage their profile and settings

### User Roles

1. **Carpenter (Regular User)**
   - Submit bills with images
   - View points and balance
   - Redeem offers
   - Participate in daily spin
   - View notifications and history

2. **Admin**
   - Approve/reject bills
   - Manage offers and rewards
   - View all users and transactions
   - Monitor system diagnostics
   - Manage carpenter verifications

### Key Features

- 📱 **Bill Submission**: Upload bill images and submit for approval
- 💰 **Points System**: Earn and track points based on purchases
- 🎁 **Offers & Rewards**: Browse and redeem available offers
- 🎡 **Daily Spin**: Play daily spin game to win bonus points
- 📊 **Dashboard**: Comprehensive overview of points, tier, and activity
- 🔔 **Notifications**: Real-time push notifications for updates
- 👤 **Profile Management**: Update profile information and settings
- 🔐 **PIN Authentication**: Secure login with 4-digit PIN
- 🌍 **Multi-language**: Support for English, Hindi, and Tamil

---

## 🏗️ Architecture Overview

### Clean Architecture

The application follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Pages   │  │  Widgets │  │   BLoC   │  │  Events  │   │
│  │          │  │          │  │          │  │  States  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                         Domain Layer                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │ Entities │  │UseCases  │  │Repository│                  │
│  │          │  │          │  │Interfaces│                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                          Data Layer                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │  Models  │  │Repository│  │DataSource│                  │
│  │          │  │   Impl   │  │(Remote)  │                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

### Architecture Layers

#### 1. **Presentation Layer**
- **Pages**: Screen widgets (e.g., HomePage, LoginPage)
- **Widgets**: Reusable UI components
- **BLoC**: Business Logic Components for state management
- **Events**: User actions and system events
- **States**: Different UI states (loading, loaded, error)

#### 2. **Domain Layer**
- **Entities**: Core business objects (User, Bill, Offer)
- **Use Cases**: Business logic operations (LoginUseCase, SubmitBillUseCase)
- **Repository Interfaces**: Abstract contracts for data operations

#### 3. **Data Layer**
- **Models**: Data transfer objects (DTOs)
- **Repository Implementations**: Concrete implementations
- **Data Sources**: Remote (Firebase), Local (SharedPreferences)

---

## 📁 Project Structure

```
balaji_points/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # App configuration
│   ├── firebase_options.dart        # Firebase configuration
│   │
│   ├── config/                      # Configuration files
│   │   ├── routes.dart              # Navigation routes (GoRouter)
│   │   └── theme.dart               # App theme configuration
│   │
│   ├── core/                        # Shared/Core components
│   │   ├── constants/               # App constants
│   │   │   └── app_constants.dart
│   │   ├── error/                   # Error handling
│   │   │   ├── exceptions.dart      # Custom exceptions
│   │   │   └── failures.dart        # Failure types
│   │   ├── mixins/                  # Reusable mixins
│   │   │   ├── double_tap_exit_mixin.dart
│   │   │   └── form_state_tracker_mixin.dart
│   │   ├── providers/               # Global Riverpod providers
│   │   │   ├── auth_provider.dart
│   │   │   ├── loading_provider.dart
│   │   │   ├── locale_provider.dart
│   │   │   ├── theme_provider.dart
│   │   │   └── daily_spin_provider.dart
│   │   ├── theme/                   # Theme system
│   │   │   ├── app_theme.dart
│   │   │   └── design_token.dart
│   │   ├── utils/                   # Utility classes
│   │   │   ├── app_logger.dart      # Comprehensive logging
│   │   │   ├── navigation_logger.dart
│   │   │   └── back_button_handler.dart
│   │   └── widgets/                 # Shared widgets
│   │       ├── common/
│   │       │   ├── bottom_nav_wrapper.dart
│   │       │   └── wooden_texture.dart
│   │       ├── loading/
│   │       │   ├── loading_overlay.dart
│   │       │   └── shimmer_loading.dart
│   │       └── navigation/
│   │           └── home_nav_bar.dart
│   │
│   ├── features/                    # Feature modules
│   │   ├── admin/                   # Admin management
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── admin_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── admin_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── admin_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── admin_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── admin_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── approve_bill_usecase.dart
│   │   │   │       └── reject_bill_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── admin_bloc.dart
│   │   │       │   ├── admin_event.dart
│   │   │       │   └── admin_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── admin_home_page.dart
│   │   │       │   ├── admin_add_bill_page.dart
│   │   │       │   ├── bill_details_page.dart
│   │   │       │   └── diagnostic_page.dart
│   │   │       └── widgets/
│   │   │           ├── pending_bills_list.dart
│   │   │           ├── bill_management_widget.dart
│   │   │           ├── users_list.dart
│   │   │           └── offers_management.dart
│   │   │
│   │   ├── auth/                    # Authentication
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart
│   │   │   │       ├── logout_usecase.dart
│   │   │   │       ├── setup_pin_usecase.dart
│   │   │   │       └── reset_pin_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── auth_bloc.dart
│   │   │       │   ├── auth_event.dart
│   │   │       │   └── auth_state.dart
│   │   │       └── pages/
│   │   │           ├── login_page.dart
│   │   │           ├── pin_login_page.dart
│   │   │           ├── pin_setup_page.dart
│   │   │           └── reset_pin_page.dart
│   │   │
│   │   ├── bills/                   # Bill management
│   │   ├── dashboard/               # Dashboard
│   │   ├── home/                    # Home screen
│   │   ├── notifications/           # Notifications
│   │   ├── profile/                 # User profile
│   │   ├── redeem/                  # Offer redemption
│   │   ├── settings/                # App settings
│   │   ├── spin/                    # Daily spin game
│   │   ├── splash/                  # Splash screen
│   │   ├── transactions/            # Transaction history
│   │   └── wallet/                  # Wallet/Points
│   │
│   ├── injection/                   # Dependency injection
│   │   └── dependency_injection.dart
│   │
│   ├── l10n/                        # Localization
│   │   ├── app_en.arb               # English
│   │   ├── app_hi.arb               # Hindi
│   │   ├── app_ta.arb               # Tamil
│   │   └── app_localizations.dart
│   │
│   └── services/                    # Legacy services
│       ├── bill_service.dart
│       ├── fcm_service.dart
│       ├── notification_service.dart
│       ├── pin_auth_service.dart
│       ├── session_service.dart
│       ├── storage_service.dart
│       └── user_service.dart
│
├── assets/                          # Static assets
│   ├── fonts/                       # Custom fonts
│   ├── images/                      # Images
│   └── icons/                       # Icons
│
├── android/                         # Android native code
├── ios/                            # iOS native code
├── functions/                       # Firebase Cloud Functions
└── test/                           # Unit & Widget tests
```

---

## 🎨 Features

### 1. **Authentication (auth)**

**Purpose:** Handle user authentication and PIN management

**Components:**
- PIN-based login (4-digit PIN)
- Phone number authentication
- PIN setup for new users
- PIN reset functionality
- Session management

**Key Files:**
- `login_page.dart` - Phone number entry
- `pin_login_page.dart` - PIN entry for existing users
- `pin_setup_page.dart` - PIN creation for new users
- `reset_pin_page.dart` - Reset existing PIN
- `auth_bloc.dart` - Authentication business logic

**User Flow:**
```
Phone Entry → Check if User Exists
    ├─ Exists → PIN Login → Dashboard
    └─ New User → PIN Setup → Profile Info → Dashboard
```

---

### 2. **Dashboard (dashboard)**

**Purpose:** Main overview screen showing key metrics

**Components:**
- Points balance display
- Tier status (Bronze/Silver/Gold/Platinum)
- Recent transactions
- Quick actions (Submit Bill, Spin, Offers)
- Notifications count

**Key Metrics:**
- Total Points
- Current Tier
- Points to Next Tier
- Recent Activity

---

### 3. **Home (home)**

**Purpose:** Primary landing screen with features and information

**Components:**
- User profile card
- Complete profile prompt
- Top 10 carpenters leaderboard
- Offers carousel
- Points history card
- Quick actions

**Widgets:**
- `user_profile_card.dart`
- `top_carpenters_display.dart`
- `offers_carousel.dart`
- `points_history_card.dart`

---

### 4. **Bills (bills)**

**Purpose:** Submit and manage bill submissions

**Components:**
- Bill submission form
- Image picker (camera/gallery)
- Bill amount entry
- Bill history
- Status tracking (Pending/Approved/Rejected)

**Validation:**
- Minimum bill amount
- Image required
- Profile completion check

**Admin Features:**
- View all bills
- Approve/reject bills
- Add points on approval
- View bill details

---

### 5. **Wallet (wallet)**

**Purpose:** Manage points and view balance

**Components:**
- Current points balance
- Transaction history
- Tier progress indicator
- Points earning history
- Points redemption history

**Transaction Types:**
- Bill Approval (+points)
- Offer Redemption (-points)
- Daily Spin (+points)
- Bonus Points (+points)

---

### 6. **Spin (spin)**

**Purpose:** Daily spin game to win bonus points

**Components:**
- Spin wheel with point segments
- Daily eligibility check
- Points winning animation
- Spin history
- QR code scanner (admin)

**Rules:**
- One spin per day
- Must be verified carpenter
- Random point rewards (10-500 points)
- Admin can grant extra spins

**Segments:**
- 10, 20, 50, 100, 200, 500 points

---

### 7. **Offers (redeem)**

**Purpose:** Browse and redeem available offers

**Components:**
- Offers grid/list
- Offer details
- Points required
- Redemption confirmation
- Redemption history

**Offer Types:**
- Product discounts
- Gift vouchers
- Exclusive deals
- Partner offers

**Redemption Process:**
```
Browse Offers → Select Offer → Check Points
    → Confirm Redemption → Deduct Points → Success
```

---

### 8. **Profile (profile)**

**Purpose:** Manage user profile and settings

**Components:**
- Profile information display
- Edit profile (name, photo)
- Phone number (read-only)
- Tier badge
- Profile completion percentage

**Editable Fields:**
- First Name
- Last Name
- Profile Image

---

### 9. **Notifications (notifications)**

**Purpose:** View and manage notifications

**Components:**
- Notification list
- Read/unread status
- Notification types (bill, tier, spin, offer)
- Mark as read
- Delete notifications

**Notification Types:**
- Bill Approved
- Bill Rejected
- Tier Upgraded
- New Offer Available
- Spin Available
- Points Expiring

---

### 10. **Transactions (transactions)**

**Purpose:** View complete transaction history

**Components:**
- Transaction list (chronological)
- Transaction details
- Filter by type/date
- Export history

**Transaction Info:**
- Date & Time
- Type (Credit/Debit)
- Amount
- Description
- Balance after transaction

---

### 11. **Settings (settings)**

**Purpose:** App configuration and preferences

**Components:**
- Language selection (EN/HI/TA)
- Theme mode (Light/Dark)
- Notification settings
- PIN management
- App version
- Logout

---

### 12. **Admin (admin)**

**Purpose:** Administrative functions and management

**Components:**
- Pending bills management
- User verification
- Carpenter management
- Offer management
- Daily spin management
- System diagnostics

**Admin Pages:**
- `admin_home_page.dart` - Admin dashboard
- `admin_add_bill_page.dart` - Manual bill entry
- `bill_details_page.dart` - View bill details
- `diagnostic_page.dart` - System diagnostics

**Admin Capabilities:**
- Approve/reject bills
- Verify carpenters
- Create/edit/delete offers
- Grant extra spins
- View all transactions
- Monitor system health

---

### 13. **Splash (splash)**

**Purpose:** App initialization and routing

**Components:**
- App logo display
- Firebase initialization
- Session check
- Automatic routing

**Routing Logic:**
```
App Start → Initialize Firebase
    → Check Session
        ├─ No Session → Login
        └─ Session Exists
            ├─ Admin → Admin Home
            └─ Carpenter → Dashboard
```

---

## 🛠️ Technology Stack

### Core Framework
- **Flutter:** 3.9.2
- **Dart:** SDK ^3.9.2

### State Management
- **flutter_bloc:** ^8.1.3 (BLoC pattern for features)
- **flutter_riverpod:** ^3.0.3 (Global state management)
- **equatable:** ^2.0.5 (Value equality)

### Navigation
- **go_router:** ^14.0.0 (Declarative routing)

### Backend & Database
- **firebase_core:** ^3.11.0
- **cloud_firestore:** ^5.7.0 (NoSQL database)
- **firebase_auth:** ^5.5.0 (Authentication)
- **firebase_storage:** ^12.4.0 (File storage)
- **firebase_messaging:** ^15.2.0 (Push notifications)

### Local Storage
- **shared_preferences:** ^2.2.2 (Key-value storage)
- **flutter_secure_storage:** ^9.0.0 (Secure storage)

### Image Handling
- **image_picker:** ^1.0.4 (Camera/Gallery)
- **cached_network_image:** ^3.3.0 (Image caching)

### UI/UX
- **google_fonts:** ^6.1.0
- **flutter_svg:** ^2.0.9
- **lottie:** ^3.0.0 (Animations)
- **shimmer:** ^3.0.0 (Loading effects)

### Utilities
- **intl:** ^0.19.0 (Internationalization)
- **logger:** ^2.0.2+1 (Logging)
- **dartz:** ^0.10.1 (Functional programming)
- **get_it:** ^7.6.4 (Dependency injection)
- **connectivity_plus:** ^5.0.2 (Network status)
- **url_launcher:** ^6.2.2 (External links)
- **qr_code_scanner:** ^1.0.1 (QR scanning)

---

## 🏛️ Core Components

### 1. **Theme System**

**Location:** `lib/core/theme/`

**Components:**
- **AppTheme** (`app_theme.dart`): Light and dark theme definitions
- **DesignToken** (`design_token.dart`): Design system tokens

**Theme Features:**
- Material 3 design
- Light/Dark mode support
- Custom color palette
- Typography system (Nunito font)
- Consistent spacing and sizing

**Colors:**
```dart
Primary: #FF6B35 (Orange)
Secondary: #004E89 (Blue)
Background: #F7F7F7 (Light Gray)
Text Dark: #1A1A1A
Wooden Theme: #8B4513 (Brown tones)
```

**Typography:**
```dart
Nunito Regular: FontWeight.w400
Nunito Medium: FontWeight.w500
Nunito SemiBold: FontWeight.w600
Nunito Bold: FontWeight.w700
```

---

### 2. **Constants**

**Location:** `lib/core/constants/app_constants.dart`

**Categories:**
- App Information (name, version)
- Firebase Collections
- Default Values
- Tier Thresholds
- Point Values
- Validation Rules

---

### 3. **Error Handling**

**Location:** `lib/core/error/`

**Components:**

**Exceptions** (`exceptions.dart`):
- `ServerException`
- `CacheException`
- `NetworkException`
- `AuthException`

**Failures** (`failures.dart`):
- `ServerFailure`
- `CacheFailure`
- `NetworkFailure`
- `AuthFailure`

**Pattern:**
```dart
try {
  // Operation
} catch (e) {
  return Left(ServerFailure(message: e.toString()));
}
```

---

### 4. **Widgets**

**Location:** `lib/core/widgets/`

**Common Widgets:**
- `bottom_nav_wrapper.dart` - Bottom navigation container
- `wooden_texture.dart` - Custom wooden background effect

**Loading Widgets:**
- `loading_overlay.dart` - Full-screen loading indicator
- `shimmer_loading.dart` - Shimmer effect for loading states

**Navigation Widgets:**
- `home_nav_bar.dart` - Bottom navigation bar

---

### 5. **Providers (Global State)**

**Location:** `lib/core/providers/`

**Global Providers:**
- **auth_provider.dart**: Current user authentication state
- **loading_provider.dart**: Global loading indicator
- **locale_provider.dart**: App language (EN/HI/TA)
- **theme_provider.dart**: Theme mode (Light/Dark)
- **daily_spin_provider.dart**: Daily spin eligibility

**Usage:**
```dart
// Read provider
final user = ref.watch(authProvider);

// Update provider
ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
```

---

### 6. **Mixins**

**Location:** `lib/core/mixins/`

**Available Mixins:**
- **double_tap_exit_mixin.dart**: Double tap to exit app
- **form_state_tracker_mixin.dart**: Track form changes

**Usage:**
```dart
class MyPage extends StatefulWidget with DoubleTapExitMixin {
  // Automatically adds double-tap-to-exit functionality
}
```

---

## 🔄 Data Flow

### Request Flow (Example: Submit Bill)

```
┌──────────────┐
│   User UI    │ Press "Submit Bill"
└──────┬───────┘
       │
       ↓
┌──────────────────────────────────────────┐
│  Presentation Layer                      │
│  ┌────────────────────────────────────┐  │
│  │ BLoC receives SubmitBillEvent      │  │
│  │ emit(BillSubmittingState())        │  │
│  └────────────────────────────────────┘  │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│  Domain Layer                            │
│  ┌────────────────────────────────────┐  │
│  │ SubmitBillUseCase.call()           │  │
│  │ Validates input                    │  │
│  │ Calls repository.submitBill()      │  │
│  └────────────────────────────────────┘  │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│  Data Layer                              │
│  ┌────────────────────────────────────┐  │
│  │ BillRepositoryImpl.submitBill()    │  │
│  │   ├─ Upload image to Storage       │  │
│  │   ├─ Create bill document          │  │
│  │   └─ Save to Firestore             │  │
│  └────────────────────────────────────┘  │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│  Firebase                                │
│  ┌────────────────────────────────────┐  │
│  │ Storage: Store bill image          │  │
│  │ Firestore: Save bill document      │  │
│  │ Return: Bill ID & download URL     │  │
│  └────────────────────────────────────┘  │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│  Response flows back through layers      │
│  BLoC emits BillSubmittedState(bill)     │
│  UI shows success message                │
└──────────────────────────────────────────┘
```

---

## 🎭 State Management

### BLoC Pattern (Feature-level)

**Used for:** Feature-specific state management

**Structure:**
```dart
// Event
abstract class AuthEvent extends Equatable {}
class LoginRequested extends AuthEvent {
  final String phoneNumber;
  final String pin;
}

// State
abstract class AuthState extends Equatable {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
}
class AuthError extends AuthState {
  final String message;
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(event.phoneNumber, event.pin);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

**Usage in UI:**
```dart
BlocProvider(
  create: (context) => getIt<AuthBloc>(),
  child: BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      if (state is AuthLoading) return LoadingWidget();
      if (state is AuthAuthenticated) return HomePage();
      if (state is AuthError) return ErrorWidget(state.message);
      return LoginWidget();
    },
  ),
)
```

---

### Riverpod (Global State)

**Used for:** App-wide state (theme, locale, auth)

**Providers:**
```dart
// Theme Provider
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

// Locale Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

// Auth Provider
final authProvider = StateProvider<User?>((ref) => null);
```

**Usage:**
```dart
// Read
final theme = ref.watch(themeModeProvider);

// Update
ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
```

---

## 🧭 Navigation

### GoRouter Implementation

**Location:** `lib/config/routes.dart`

**Features:**
- Declarative routing
- Named routes
- Deep linking support
- Navigation logging
- Error handling

**Route Structure:**
```dart
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => SplashPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => DashboardPage(),
    ),
    // ... more routes
  ],
);
```

**Navigation:**
```dart
// Go to route
context.go('/dashboard');

// Go with parameters
context.go('/bill-details', extra: billId);

// Named navigation
context.goNamed('dashboard');

// Pop
context.pop();
```

**Bottom Navigation:**
- Home
- Wallet
- Profile
- Settings
- Notifications

---

## 🔐 Authentication

### Authentication Flow

**1. Phone Number Entry:**
```
User enters phone → Check if exists in Firestore
    ├─ Exists → PIN Login
    └─ New → PIN Setup
```

**2. PIN Login (Existing User):**
```
Enter PIN → Hash PIN → Compare with Firestore
    ├─ Match → Load user data → Save session → Dashboard
    └─ No Match → Show error
```

**3. PIN Setup (New User):**
```
Enter phone → Enter name → Create 4-digit PIN
    → Hash PIN → Create Firestore document
    → Save session → Dashboard
```

**4. Session Management:**
```dart
// Save session
await SessionService.saveSession(
  userId: user.id,
  phoneNumber: user.phone,
  role: user.role,
);

// Check session
final session = await SessionService.getSession();
if (session != null) {
  // User logged in
}

// Clear session
await SessionService.clearSession();
```

**Security:**
- PIN is hashed before storage (SHA-256)
- Secure storage for session tokens
- Auto-logout on session expiry
- PIN attempts limiting

---

## 🔥 Backend Integration

### Firebase Services

**1. Firestore (Database)**

**Collections:**
```
users/
  ├─ {userId}
  │   ├─ phone: string
  │   ├─ firstName: string
  │   ├─ lastName: string
  │   ├─ role: string (carpenter|admin)
  │   ├─ points: number
  │   ├─ tier: string
  │   ├─ isVerified: boolean
  │   └─ createdAt: timestamp

bills/
  ├─ {billId}
  │   ├─ userId: string
  │   ├─ amount: number
  │   ├─ imageUrl: string
  │   ├─ status: string (pending|approved|rejected)
  │   ├─ pointsEarned: number
  │   ├─ submittedAt: timestamp
  │   └─ processedAt: timestamp

offers/
  ├─ {offerId}
  │   ├─ title: string
  │   ├─ description: string
  │   ├─ pointsRequired: number
  │   ├─ imageUrl: string
  │   ├─ isActive: boolean
  │   └─ expiryDate: timestamp

transactions/
  ├─ {transactionId}
  │   ├─ userId: string
  │   ├─ type: string (credit|debit)
  │   ├─ amount: number
  │   ├─ description: string
  │   ├─ balanceAfter: number
  │   └─ timestamp: timestamp

notifications/
  ├─ {notificationId}
  │   ├─ userId: string
  │   ├─ title: string
  │   ├─ body: string
  │   ├─ type: string
  │   ├─ isRead: boolean
  │   └─ createdAt: timestamp
```

**2. Firebase Storage**

**Structure:**
```
bills/
  └─ {userId}/
      └─ {billId}.jpg

profiles/
  └─ {userId}/
      └─ profile.jpg

offers/
  └─ {offerId}.jpg
```

**3. Firebase Cloud Messaging (FCM)**

**Notification Types:**
- Bill approved/rejected
- Tier upgraded
- New offer available
- Daily spin available
- Points expiring soon

**4. Firebase Authentication**

**Methods:**
- Phone authentication (for future)
- Anonymous authentication (current)
- Custom token authentication

---

## 📝 Logging System

### AppLogger

**Location:** `lib/core/utils/app_logger.dart`

**Features:**
- Comprehensive logging for all operations
- Automatic navigation tracking
- API call logging with timing
- BLoC event/state logging
- Performance metrics
- Error tracking with stack traces
- Sensitive data sanitization

**Log Types:**

**1. Navigation Logs:**
```dart
AppLogger.navigation('HomeScreen', action: 'opened');
AppLogger.navigation('ProfileScreen', action: 'popped', extra: 'User logged out');
```

**2. API Logs:**
```dart
AppLogger.apiRequest('POST', '/api/bills', body: billData);
AppLogger.apiResponse('POST', '/api/bills', statusCode: 200, duration: 450);
```

**3. BLoC Logs:**
```dart
AppLogger.blocEvent('AuthBloc', 'LoginRequested', data: {'phone': phone});
AppLogger.blocState('AuthBloc', 'Authenticated');
```

**4. Performance Logs:**
```dart
AppLogger.performance('Firebase initialization', 482);
AppLogger.performance('Image upload', 1250);
```

**5. Auth Logs:**
```dart
AppLogger.auth('Login successful', userId: 'user123');
AppLogger.auth('Logout requested');
```

**6. Error Logs:**
```dart
AppLogger.error('Failed to load data', error: e, stackTrace: st);
```

**Log Output Example:**
```
🧭 NAVIGATION: HomeScreen - opened (from: SplashScreen)
🚀 API REQUEST: POST /api/bills
   Body: {amount: 5000, userId: user123}
✅ API RESPONSE: POST /api/bills - 200 (450ms)
📤 BLOC EVENT: AuthBloc.LoginRequested
📥 BLOC STATE: AuthBloc.Authenticated
⚡ PERFORMANCE: Firebase initialization took 482ms
🔐 AUTH: Login successful (User: user123)
```

---

## 💉 Dependency Injection

### GetIt Implementation

**Location:** `lib/injection/dependency_injection.dart`

**Registration:**
```dart
final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Services
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseStorage.instance);
  
  // Data Sources
  getIt.registerLazySingleton(() => AuthRemoteDataSource());
  getIt.registerLazySingleton(() => BillRemoteDataSource());
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: getIt()),
  );
  
  // Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => SubmitBillUseCase(getIt()));
  
  // BLoCs
  getIt.registerFactory(() => AuthBloc(loginUseCase: getIt()));
  getIt.registerFactory(() => BillBloc(submitBillUseCase: getIt()));
}
```

**Usage:**
```dart
// In main.dart
await setupDependencyInjection();

// In widget
final authBloc = getIt<AuthBloc>();

// In BlocProvider
BlocProvider(
  create: (context) => getIt<AuthBloc>(),
  child: MyWidget(),
)
```

---

## 🎯 Design Patterns

### 1. **Repository Pattern**
- Abstract data sources behind repository interfaces
- Clean separation between data and domain layers

### 2. **BLoC Pattern**
- Business Logic Component for state management
- Separates UI from business logic

### 3. **Singleton Pattern**
- Used for services (via GetIt)
- One instance throughout app lifecycle

### 4. **Factory Pattern**
- BLoC instances created per screen
- Fresh state for each usage

### 5. **Observer Pattern**
- BLoC streams observe state changes
- Riverpod providers notify listeners

### 6. **Dependency Injection**
- Loose coupling between components
- Easy testing and mocking

---

## ✅ Best Practices

### Code Organization
- ✅ Feature-based folder structure
- ✅ Clean Architecture layers
- ✅ Single Responsibility Principle
- ✅ Clear naming conventions

### State Management
- ✅ BLoC for feature-level state
- ✅ Riverpod for global state
- ✅ Immutable state objects
- ✅ Event-driven architecture

### Error Handling
- ✅ Try-catch blocks with proper error types
- ✅ User-friendly error messages
- ✅ Error logging for debugging
- ✅ Graceful degradation

### Performance
- ✅ Lazy loading of data
- ✅ Image caching
- ✅ Pagination for lists
- ✅ Optimized rebuilds

### Security
- ✅ PIN hashing
- ✅ Secure storage for tokens
- ✅ Input validation
- ✅ Firestore security rules

### Testing
- ✅ Unit tests for use cases
- ✅ Widget tests for UI
- ✅ Integration tests for flows
- ✅ Mock dependencies

### Documentation
- ✅ Code comments for complex logic
- ✅ Architecture documentation
- ✅ API documentation
- ✅ Setup instructions

---

## 📱 App Flow

### User Journey (Carpenter)

```
App Launch
    → Splash Screen (Initialize Firebase)
    → Check Session
        ├─ No Session
        │   → Login Page
        │   → Enter Phone
        │       ├─ New User → PIN Setup → Profile Info → Dashboard
        │       └─ Existing → PIN Login → Dashboard
        │
        └─ Session Exists → Dashboard

Dashboard
    ├─ View Points & Tier
    ├─ Quick Actions
    │   ├─ Submit Bill → Upload Image → Enter Amount → Submit
    │   ├─ Daily Spin → Spin Wheel → Win Points
    │   ├─ Browse Offers → Select Offer → Redeem
    │   └─ View History → See Transactions
    │
    ├─ Bottom Navigation
    │   ├─ Home → User Info, Leaderboard, Offers
    │   ├─ Wallet → Points, Transactions, Tier
    │   ├─ Profile → Edit Profile, View Info
    │   ├─ Settings → Language, Theme, Notifications
    │   └─ Notifications → View Messages
    │
    └─ Profile Menu
        ├─ Edit Profile
        ├─ Change PIN
        ├─ Help & Support
        └─ Logout
```

### Admin Journey

```
Admin Login
    → Admin Dashboard
        ├─ Pending Bills → Review → Approve/Reject
        ├─ User Management
        │   ├─ Pending Carpenters → Verify
        │   ├─ Verified Users → View/Edit
        │   └─ User Details → Points, History
        │
        ├─ Offer Management
        │   ├─ Create Offer
        │   ├─ Edit Offer
        │   └─ Delete Offer
        │
        ├─ Daily Spin Management
        │   ├─ Grant Extra Spins
        │   └─ View Spin History
        │
        ├─ Reports & Analytics
        │   ├─ Total Users
        │   ├─ Total Bills
        │   ├─ Points Distributed
        │   └─ Active Offers
        │
        └─ System Diagnostics
            ├─ Firebase Status
            ├─ Error Logs
            └─ Performance Metrics
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Android Studio / VS Code
- Firebase account with project setup

### Installation

1. **Clone the repository:**
```bash
git clone <repository-url>
cd balaji_points
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Configure Firebase:**
- Add `google-services.json` to `android/app/`
- Add `GoogleService-Info.plist` to `ios/Runner/`

4. **Run the app:**
```bash
flutter run
```

### Build

**Debug APK:**
```bash
flutter build apk --debug
```

**Release APK:**
```bash
flutter build apk --release
```

**App Bundle:**
```bash
flutter build appbundle --release
```

---

## 📄 License

This project is proprietary software. All rights reserved.

---

## 👥 Team

**Development Team:** Internal Development Team  
**Version:** 1.0.3+5  
**Last Updated:** February 8, 2026

---

## 📞 Support

For technical support or queries, please contact the development team.

---

**End of Documentation**
