// lib/presentation/screens/home/home_page.dart
// Complete Home screen: Offers (dynamic) + Top 10 carpenters (dynamic) + current user rank
// Uses CarpenterRank (version A: rank, name, points, imageUrl) from top_carpenters_display.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'dart:async';

import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/presentation/widgets/top_carpenters_display.dart'; // provides CarpenterRank
import 'package:balaji_points/presentation/widgets/top_carpenters_list.dart';
import 'package:balaji_points/presentation/widgets/shimmer_loading.dart';
import 'package:balaji_points/presentation/screens/home/widgets/complete_profile_card.dart';
import 'package:balaji_points/presentation/widgets/offers_carousel.dart';
// Daily spin removed - admin only feature now
import 'package:balaji_points/services/user_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/services/cart_service.dart';
import 'package:balaji_points/services/fcm_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;

/// ---------------------------------------------------------------------------
/// OFFERS CAROUSEL & CARDS
/// - horizontal list for banner offers with page indicators
/// - vertical list with full-width cards when no banners
/// ---------------------------------------------------------------------------
/// ---------------------------------------------------------------------------
/// HOME PAGE
/// ---------------------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin<HomePage> {
  final UserService _userService = UserService();
  final SessionService _sessionService = SessionService();
  final CartService _cartService = CartService();
  final FCMService _fcmService = FCMService();

  // Offers
  List<OfferItem> _offers = [];
  bool _isLoadingOffers = true;

  // Cart count for header badge
  int _cartItemCount = 0;
  StreamSubscription<int>? _cartSubscription;

  // Live user points / tier subscription so Home reflects real-time updates
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _userPointsSubscription;

  // User id (phone) for points stream – kept in sync with wallet page logic
  String? _pointsUserId;

  // App version (mirrors profile page)
  String _appVersion = '';

  // Top carpenters
  List<CarpenterRank> _topCarpenters = [];
  bool _isLoadingCarpenters = true;

  // current user
  Map<String, dynamic>? _currentUserData;
  int? _currentUserRank;
  int _currentUserPoints = 0;
  bool _isCarpenter = false;
  // ignore: unused_field
  String? _currentUserId;
  // ignore: unused_field
  String? _userRole;

  // animation for add points button
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  bool _greetingIconPressed = false;

  // Confetti controller for celebration
  late ConfettiController _confettiController;

  // Product hero carousel
  late final PageController _productHeroPageController;
  int _currentProductHeroPage = 0;

  static const List<_HomeProductCategory> _categories =
      <_HomeProductCategory>[
    _HomeProductCategory(
      title: 'Bedroom',
      icon: Icons.bed_rounded,
      background: Color(0xFFF5F0FF),
      imageAsset: 'docs/furnitures_pics/luxirous lifestyle.jpeg',
    ),
    _HomeProductCategory(
      title: 'Kitchen',
      icon: Icons.kitchen_rounded,
      background: Color(0xFFFFF3E0),
      imageAsset:
          'docs/furnitures_pics/22 Gorgeous Brown Kitchen Cabinet Designs.jpeg',
    ),
    _HomeProductCategory(
      title: 'Living Room',
      icon: Icons.chair_rounded,
      background: Color(0xFFE3F2FD),
      imageAsset: 'docs/furnitures_pics/_ (6).jpeg',
    ),
    _HomeProductCategory(
      title: 'Wardrobe',
      icon: Icons.checkroom_rounded,
      background: Color(0xFFE8F5E9),
      imageAsset: 'docs/furnitures_pics/_ (10).jpeg',
    ),
    _HomeProductCategory(
      title: 'Office',
      icon: Icons.workspaces_rounded,
      background: Color(0xFFE8F0FE),
      imageAsset:
          'docs/furnitures_pics/Home Office_Todos os direitos da autoria e imagem são reservados aos responsáveis_.jpeg',
    ),
    _HomeProductCategory(
      title: 'Bathroom',
      icon: Icons.bathtub_rounded,
      background: Color(0xFFF3E5F5),
      imageAsset:
          'docs/furnitures_pics/Elegant Sage Green Kitchen with Brass Accents & Marble Island.jpeg',
    ),
  ];

  static const List<_ProductHeroCardData> _heroCards =
      <_ProductHeroCardData>[
    _ProductHeroCardData(
      title: 'Surfaces that\nradiate luxury',
      subtitle: 'Decorative laminates,\nveneers and acrylic panels.',
      imageAsset:
          'docs/furnitures_pics/22 Gorgeous Brown Kitchen Cabinet Designs.jpeg',
      icon: Icons.layers_rounded,
    ),
    _ProductHeroCardData(
      title: 'Bedroom that feels premium',
      subtitle: 'Warm finishes for\ncozy master bedrooms.',
      imageAsset: 'docs/furnitures_pics/luxirous lifestyle.jpeg',
      icon: Icons.bed_rounded,
    ),
    _ProductHeroCardData(
      title: 'Kitchen that inspires',
      subtitle: 'Modern finishes for\npremium modular kitchens.',
      imageAsset:
          'docs/furnitures_pics/Elegant Sage Green Kitchen with Brass Accents & Marble Island.jpeg',
      icon: Icons.kitchen_rounded,
    ),
    _ProductHeroCardData(
      title: 'Living room that welcomes',
      subtitle: 'TV units & wall panels\nfor family time.',
      imageAsset: 'docs/furnitures_pics/_ (6).jpeg',
      icon: Icons.weekend_rounded,
    ),
    _ProductHeroCardData(
      title: 'Office that boosts focus',
      subtitle: 'Create productive workspaces\nwith designer surfaces.',
      imageAsset:
          'docs/furnitures_pics/Home Office_Todos os direitos da autoria e imagem são reservados aos responsáveis_.jpeg',
      icon: Icons.chair_rounded,
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _productHeroPageController = PageController(viewportFraction: 0.9);

    _loadPointsUserId();
    _loadAppVersion();
    _loadInitialData();
  }

  Future<void> _loadPointsUserId() async {
    final phoneNumber = await _sessionService.getPhoneNumber();
    if (!mounted) return;
    setState(() {
      _pointsUserId = phoneNumber;
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion =
            'Version ${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      debugPrint('HomePage: Error loading app version: $e');
      if (!mounted) return;
      setState(() {
        _appVersion = 'Version 1.0.0';
      });
    }
  }

  Future<void> _loadInitialData() async {
    // Load user data immediately (most important)
    await _loadUserData();

    // Load other data in parallel for better performance
    await Future.wait([
      _loadOffers(),
      _loadTopCarpenters(),
      _loadCurrentUserRank(),
    ]);
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
      _loadOffers();
      _loadTopCarpenters();
      _loadCurrentUserRank();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cartSubscription?.cancel();
    _userPointsSubscription?.cancel();
    _animationController.dispose();
    _confettiController.dispose();
    _productHeroPageController.dispose();
    super.dispose();
  }

  // ------------------ Offers ------------------
  Future<void> _loadOffers() async {
    setState(() => _isLoadingOffers = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10) // Limit to 10 offers for performance
          .get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return OfferItem(
          title: data['title'] as String? ?? '',
          description: data['description'] as String? ?? '',
          actionText: (data['bannerUrl'] != null && data['bannerUrl'] != '')
              ? 'View Offer'
              : 'Learn More',
          imageUrl: data['bannerUrl'] as String? ?? '',
        );
      }).toList();
      if (mounted) {
        setState(() {
          _offers = list;
          _isLoadingOffers = false;
        });
      }
    } catch (e, st) {
      debugPrint('Error loading offers: $e\n$st');
      if (mounted) {
        setState(() => _isLoadingOffers = false);
      }
    }
  }

  // ------------------ Top Carpenters ------------------
  Future<void> _loadTopCarpenters() async {
    setState(() => _isLoadingCarpenters = true);
    try {
      // Fetch all carpenters (without orderBy to avoid index requirement)
      final qs = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'carpenter')
          .get();

      final carpenters = <CarpenterRank>[];
      final currentUserId = await _sessionService.getUserId();

      // Process all carpenters
      for (var doc in qs.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final firstName = (data['firstName'] ?? '') as String;
        final lastName = (data['lastName'] ?? '') as String;
        final name = ('$firstName $lastName').trim().isEmpty
            ? 'Carpenter'
            : ('$firstName $lastName').trim();
        final points = (data['totalPoints'] ?? 0) as int;
        final imageUrl = (data['profileImage'] ?? '') as String?;
        final userId = doc.id;

        // Debug logging for name construction
        debugPrint('Carpenter ID: $userId');
        debugPrint('  firstName: "$firstName"');
        debugPrint('  lastName: "$lastName"');
        debugPrint('  Constructed name: "$name"');
        debugPrint('  All data keys: ${data.keys.toList()}');

        carpenters.add(
          CarpenterRank(
            rank: 0, // Will be set after sorting
            name: name,
            points: points,
            imageUrl: imageUrl,
            userId: userId,
            isCurrentUser: userId == currentUserId,
          ),
        );
      }

      // Sort by points descending (in memory - no index needed)
      carpenters.sort((a, b) => b.points.compareTo(a.points));

      // Assign ranks after sorting - create new list with ranks
      final rankedCarpenters = <CarpenterRank>[];
      for (var i = 0; i < carpenters.length; i++) {
        final carpenter = carpenters[i];
        rankedCarpenters.add(
          CarpenterRank(
            rank: i + 1,
            name: carpenter.name,
            points: carpenter.points,
            imageUrl: carpenter.imageUrl,
            userId: carpenter.userId,
            isCurrentUser: carpenter.isCurrentUser,
          ),
        );
      }

      // Take top 10 for display
      final top10 = rankedCarpenters.take(10).toList();

      if (mounted)
        setState(() {
          _topCarpenters = top10;
          _isLoadingCarpenters = false;
        });
    } catch (e, st) {
      debugPrint('Error loading carpenters: $e\n$st');
      if (mounted) setState(() => _isLoadingCarpenters = false);
    }
  }

  // ------------------ Current user data ------------------
  Future<void> _loadUserData() async {
    try {
      // Prefer unified UserService so Home/Profile use same source of truth
      final data = await _user_service_getCurrentUserDataSafe();
      final userId = await _sessionService.getUserId();

      if (mounted) {
        setState(() {
          _currentUserData = data;
          _isCarpenter = (data?['role'] ?? '') == 'carpenter';
          _userRole = (data?['role'] ?? '') as String?;
          _currentUserId = userId;
        });
        if (userId != null) {
          _subscribeCartCount(userId);
        }
        _subscribeUserPointsForCurrentUser();
      }
    } catch (e) {
      debugPrint('Error loading current user data: $e');
      // Fallback to service method on error
      try {
        final data = await _user_service_getCurrentUserDataSafe();
        final errorFallbackUserId = await _sessionService.getUserId();
        if (mounted) {
          setState(() {
            _currentUserData = data;
            _isCarpenter = (data?['role'] ?? '') == 'carpenter';
            _userRole = (data?['role'] ?? '') as String?;
            _currentUserId = errorFallbackUserId;
          });
          if (errorFallbackUserId != null) {
            _subscribeCartCount(errorFallbackUserId);
          }
          _subscribeUserPointsForCurrentUser();
        }
      } catch (e2) {
        debugPrint('Error in fallback user data load: $e2');
      }
    }
  }

  Future<Map<String, dynamic>?> _user_service_getCurrentUserDataSafe() async {
    try {
      return await _userService.getCurrentUserData();
    } catch (_) {
      return null;
    }
  }

  void _subscribeCartCount(String userId) {
    _cartSubscription?.cancel();
    _cartSubscription = _cartService.watchCartCount(userId).listen((count) {
      if (!mounted) return;
      setState(() {
        _cartItemCount = count;
      });
    });
  }

  Future<void> _subscribeUserPointsForCurrentUser() async {
    final phoneNumber = await _sessionService.getPhoneNumber();
    if (phoneNumber == null) return;

    _userPointsSubscription?.cancel();
    _userPointsSubscription = FirebaseFirestore.instance
        .collection('user_points')
        .doc(phoneNumber)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      final data = snapshot.data();
      if (data == null) return;

      final newPoints = (data['totalPoints'] ?? 0) as int;

      setState(() {
        _currentUserPoints = newPoints;
        // Merge latest Firestore data into current user data so tier/name etc. stay fresh
        _currentUserData = {
          ...?_currentUserData,
          ...data,
        };
      });
    });
  }

  // ------------------ Current user rank ------------------
  Future<void> _loadCurrentUserRank() async {
    try {
      // Use phone-based document ID for carpenters
      final phoneNumber = await _sessionService.getPhoneNumber();
      if (phoneNumber == null) {
        if (mounted) setState(() => _currentUserRank = null);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .get();
      final userData = userDoc.data();

      // Check if user is a carpenter
      if (userData?['role'] != 'carpenter') {
        if (mounted) setState(() => _currentUserRank = null);
        return;
      }

      final userPoints = (userData?['totalPoints'] ?? 0) as int;

      // Fetch all carpenters and calculate rank in memory (avoids index requirement)
      final allCarpenters = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'carpenter')
          .get();

      // Count how many have more points than current user
      int rank = 1;
      for (var doc in allCarpenters.docs) {
        final data = doc.data();
        final points = (data['totalPoints'] ?? 0) as int;
        if (points > userPoints) {
          rank++;
        }
      }

      if (mounted)
        setState(() {
          _currentUserRank = rank;
        });
    } catch (e, st) {
      debugPrint('Error computing user rank: $e\n$st');
      if (mounted) setState(() => _currentUserRank = null);
    }
  }

  // ------------------ UI helper getters ------------------
  String _getUserDisplayName() {
    final fn = _currentUserData?['firstName'] ?? '';
    final ln = _currentUserData?['lastName'] ?? '';
    final name = '$fn $ln'.trim();
    return name.isEmpty ? 'User' : name;
  }

  String _getUserTier() => _currentUserData?['tier'] ?? 'Bronze';
  int _getUserPoints() => _currentUserPoints;
  String? _getUserProfileImage() =>
      _currentUserData?['profileImage'] as String?;

  /// Check if user profile is complete (has firstName, lastName, and profileImage)
  bool _isProfileComplete() {
    if (_currentUserData == null) return false;

    final firstName = (_currentUserData!['firstName'] as String? ?? '').trim();
    final lastName = (_currentUserData!['lastName'] as String? ?? '').trim();
    final profileImage = (_currentUserData!['profileImage'] as String? ?? '')
        .trim();

    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        profileImage.isNotEmpty;
  }

  /// Check if URL is valid for NetworkImage (http or https)
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final trimmed = url.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  Widget _buildHeaderPointsBadge() {
    // Fallback while we don't yet know the user id (phone)
    if (_pointsUserId == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (_, __) => Transform.rotate(
              angle: _glowAnimation.value * 2 * pi,
              child: Icon(
                Icons.monetization_on,
                color: DesignToken.amberShade300,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '0',
            style: AppTextStyles.nunitoBold.copyWith(
              color: DesignToken.white,
              fontSize: DesignToken.fontSizeLG,
            ),
          ),
        ],
      );
    }

    // Mirror wallet page behaviour: stream users/{phone} and read totalPoints
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_pointsUserId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final points = (data?['totalPoints'] ?? 0) as int;

        final display = points >= 1000
            ? '${(points / 1000).toStringAsFixed(1)}K'
            : '$points';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => Transform.rotate(
                angle: _glowAnimation.value * 2 * pi,
                child: Icon(
                  Icons.monetization_on,
                  color: DesignToken.amberShade300,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              display,
              style: AppTextStyles.nunitoBold.copyWith(
                color: DesignToken.white,
                fontSize: DesignToken.fontSizeLG,
              ),
            ),
          ],
        );
      },
    );
  }


  Future<CarpenterRank?> _buildCurrentUserAsCarpenterRank() async {
    final currentUserId = await _sessionService.getUserId();
    if (currentUserId == null || _currentUserRank == null) return null;

    // Check if current user is already in top 10
    final existingUser = _topCarpenters.firstWhere(
      (c) => c.userId == currentUserId,
      orElse: () => CarpenterRank(rank: -1, name: '', points: 0, userId: ''),
    );

    if (existingUser.rank > 0) {
      // User is in top 10, return the existing one
      return existingUser;
    }

    // User is not in top 10, create a new entry
    return CarpenterRank(
      rank: _currentUserRank!,
      name: _getUserDisplayName(),
      points: _currentUserPoints,
      imageUrl: _getUserProfileImage(),
      userId: currentUserId,
      isCurrentUser: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Note: currentUserRankObj is now async, handled in FutureBuilder below
    final top3 = _topCarpenters.take(3).toList();

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _buildHomeDrawer(context),
      appBar: _buildHomeAppBar(context, theme),
      body: Stack(
        children: [
          Container(
            color: theme.colorScheme.surface,
            child: RefreshIndicator(
              onRefresh: _loadInitialData,
              color: DesignToken.primary,
              backgroundColor: theme.colorScheme.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildHomeHeroCard(context),
                      const SizedBox(height: 12),
                      // Complete Profile Card (shown if profile is incomplete)
                      if (!_isProfileComplete()) ...[
                        const CompleteProfileCard(),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 8),
                      // Latest Offers header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context)!.latestOffers,
                          style: AppTextStyles.nunitoSemiBold.copyWith(
                            color: DesignToken.primary,
                            fontSize: DesignToken.fontSizeMD,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Offers carousel
                      _isLoadingOffers
                          ? const ShimmerOfferCard()
                          : OffersCarousel(offers: _offers),
                      const SizedBox(height: 16),
                      // Products section (horizontal carousel)
                      _buildProductsSection(context),
                      const SizedBox(height: 16),
                      // Today's Winner Display
                      _buildTodaysWinner(),
                      const SizedBox(height: 16),
                      // Current User Position Card
                      _buildCurrentUserPositionCard(),
                      const SizedBox(height: 16),
                      // Top carpenters
                      if (_isLoadingCarpenters)
                        const ShimmerTopCarpenters()
                      else if (_topCarpenters.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: DesignToken.black.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: FutureBuilder<CarpenterRank?>(
                            future: _buildCurrentUserAsCarpenterRank(),
                            builder: (context, snapshot) {
                              return TopCarpentersDisplay(
                                topCarpenters: top3,
                                currentUser: snapshot.data,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Top 10 Carpenters List (without bordered card container)
                        if (_topCarpenters.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TopCarpentersList(
                              carpenters: _topCarpenters,
                              showViewAll: false,
                            ),
                          ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
          ),
          // Confetti widget for celebration
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // Down
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                DesignToken.amber,
                DesignToken.orange,
                DesignToken.red,
                DesignToken.pink,
                DesignToken.purple,
                DesignToken.blue500,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildHomeDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.padding.bottom;
    final topInset = mediaQuery.padding.top;
    final bottomNavHeight = kBottomNavigationBarHeight;
    final bool isDarkTheme = theme.brightness == Brightness.dark;
    final Color titleColor =
        isDarkTheme ? DesignToken.white : DesignToken.textDark;
    final Color subtitleColor = isDarkTheme
        ? DesignToken.white.withValues(alpha: 0.80)
        : DesignToken.textDark.withValues(alpha: 0.70);

    final String name = _getUserDisplayName();
    final String phone = (_currentUserData?['phone'] as String?) ?? '';
    final String? profileImageUrl = _getUserProfileImage();

    final l10n = AppLocalizations.of(context)!;

    // Light, modern background that adapts to theme, with a subtle pattern‑like gradient
    final Color drawerBase = theme.colorScheme.surface;
    final Color drawerTintSoft = isDarkTheme
        ? DesignToken.primary.withValues(alpha: 0.10)
        : DesignToken.secondary.withValues(alpha: 0.06);
    final Color drawerTintAccent = isDarkTheme
        ? DesignToken.blueShade600.withValues(alpha: 0.16)
        : DesignToken.amberShade200.withValues(alpha: 0.30);

    return Drawer(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                drawerBase,
                drawerTintSoft,
                drawerTintAccent,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header (including top safe area)
            Container(
              padding: EdgeInsets.fromLTRB(20, 20 + topInset, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDarkTheme
                        ? DesignToken.blueShade600.withValues(alpha: 0.6)
                        : DesignToken.secondary.withValues(alpha: 0.15),
                    isDarkTheme
                        ? DesignToken.purpleShade600.withValues(alpha: 0.7)
                        : DesignToken.amberShade100.withValues(alpha: 0.9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignToken.black.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DesignToken.white.withValues(alpha: 0.9),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DesignToken.black.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _isValidImageUrl(profileImageUrl)
                          ? Image.network(
                              profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const ColoredBox(
                                  color: DesignToken.white,
                                  child: Icon(
                                    Icons.person,
                                    color: DesignToken.primary,
                                  ),
                                );
                              },
                            )
                          : const ColoredBox(
                              color: DesignToken.white,
                              child: Icon(
                                Icons.person,
                                color: DesignToken.primary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.nunitoSemiBold.copyWith(
                            color: DesignToken.white,
                            fontSize: DesignToken.fontSizeLG,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (phone.isNotEmpty)
                          Text(
                            phone,
                            style: AppTextStyles.nunitoRegular.copyWith(
                              color:
                                  DesignToken.white.withValues(alpha: 0.85),
                              fontSize: DesignToken.fontSizeSM,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Main items
            ListTile(
              leading: Icon(
                Icons.home_rounded,
                color: DesignToken.secondary,
              ),
              title: Text(
                l10n.home,
                style: AppTextStyles.nunitoRegular.copyWith(
                  color: titleColor,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.account_balance_wallet_rounded,
                color: DesignToken.secondary,
              ),
              title: Text(
                l10n.wallet,
                style: AppTextStyles.nunitoRegular.copyWith(
                  color: titleColor,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/wallet');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.notifications_rounded,
                color: DesignToken.secondary,
              ),
              title: Text(
                l10n.notifications,
                style: AppTextStyles.nunitoRegular.copyWith(
                  color: titleColor,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/notifications');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.layers_rounded,
                color: DesignToken.secondary,
              ),
              title: Text(
                'Products',
                style: AppTextStyles.nunitoRegular.copyWith(
                  color: titleColor,
                ),
              ),
              subtitle: Text(
                'Browse all product categories',
                style: AppTextStyles.nunitoRegular.copyWith(
                  color: subtitleColor,
                  fontSize: DesignToken.fontSizeSM,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/products');
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            ListTile(
              leading: Icon(
                Icons.person_rounded,
                color: DesignToken.secondary,
              ),
              title: Text(
                l10n.profile,
                style: AppTextStyles.nunitoRegular.copyWith(
                  color: titleColor,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/profile');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings_rounded,
                color: DesignToken.secondary,
              ),
              title: Text(
                l10n.settings,
                style: AppTextStyles.nunitoRegular.copyWith(
                  color: titleColor,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/notification-settings');
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            // Logout + version
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16 +
                    bottomNavHeight +
                    40 +
                    (bottomInset > 0 ? bottomInset : 8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_appVersion.isNotEmpty) ...[
                    Center(
                      child: Text(
                        _appVersion,
                        style: AppTextStyles.nunitoRegular.copyWith(
                          fontSize: 12,
                          color: DesignToken.textDark.withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignToken.redShade600,
                      foregroundColor: DesignToken.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 22),
                    label: Text(
                      l10n.logout,
                      style: AppTextStyles.nunitoBold.copyWith(
                        fontSize: 16,
                        color: DesignToken.white,
                      ),
                    ),
                    onPressed: () => _handleLogout(context),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignToken.error.withValues(alpha: 0.08),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: DesignToken.error,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.logout,
                style: AppTextStyles.nunitoBold.copyWith(
                  fontSize: 20,
                  color: DesignToken.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.logoutConfirmation,
                textAlign: TextAlign.center,
                style: AppTextStyles.nunitoRegular.copyWith(
                  fontSize: 15,
                  color: DesignToken.textDark.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: DesignToken.grey400.withValues(alpha: 0.8),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        l10n.no,
                        style: AppTextStyles.nunitoMedium.copyWith(
                          fontSize: 15,
                          color: DesignToken.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignToken.error,
                        foregroundColor: DesignToken.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.yes,
                        style: AppTextStyles.nunitoSemiBold.copyWith(
                          fontSize: 15,
                          color: DesignToken.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldLogout == true && context.mounted) {
      try {
        await _fcmService.deleteToken();
        await _sessionService.clearSession();
        if (context.mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.logoutFailed}: ${e.toString()}'),
              backgroundColor: DesignToken.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildProductsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color titleColor =
        isDark ? DesignToken.white : DesignToken.textDark;
    final surfaceColor = theme.colorScheme.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: DesignToken.woodenGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.layers_rounded,
                      size: 18,
                      color: DesignToken.brownShade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wood & Plywood',
                        style: AppTextStyles.nunitoSemiBold.copyWith(
                          color: DesignToken.textDark,
                          fontSize: DesignToken.fontSizeMD,
                        ),
                      ),
                      Text(
                        'Premium laminates & surfaces',
                        style: AppTextStyles.nunitoRegular.copyWith(
                          color: DesignToken.textDark.withValues(alpha: 0.70),
                          fontSize: DesignToken.fontSizeSM,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/products'),
                child: Text(
                  'View all',
                  style: AppTextStyles.nunitoRegular.copyWith(
                    color: DesignToken.primary,
                    fontSize: DesignToken.fontSizeSM,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _productHeroPageController,
            itemCount: _heroCards.length,
            onPageChanged: (index) {
              setState(() => _currentProductHeroPage = index);
            },
            itemBuilder: (context, index) {
              final hero = _heroCards[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:
                            DesignToken.brownShade800.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          hero.imageAsset,
                          fit: BoxFit.cover,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.10),
                                Colors.black.withValues(alpha: 0.65),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: DesignToken.white.withValues(
                                    alpha: 0.92,
                                  ),
                                ),
                                child: Icon(
                                  hero.icon,
                                  size: 20,
                                  color: DesignToken.brownShade800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                hero.title,
                                style: AppTextStyles.nunitoBold.copyWith(
                                  color: DesignToken.white,
                                  fontSize: DesignToken.fontSizeLG,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                hero.subtitle,
                                style: AppTextStyles.nunitoRegular.copyWith(
                                  color: DesignToken.white.withValues(
                                    alpha: 0.92,
                                  ),
                                  fontSize: DesignToken.fontSizeSM,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_heroCards.length, (index) {
              final isActive = index == _currentProductHeroPage;
              return AnimatedContainer(
                duration: DesignToken.animationDurationFast,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: isActive ? 18 : 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? DesignToken.white.withValues(alpha: 0.95)
                      : DesignToken.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 124,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _ProductCategoryCard(
                category: category,
                surfaceColor: surfaceColor,
                textColor: titleColor,
                onTap: () => context.push(
                  '/products?category=${Uri.encodeComponent(category.title)}',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Home Top App Bar ─────────────────────────────────────────────────────
  PreferredSizeWidget _buildHomeAppBar(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    // Match bottom tab bar background:
    // - Light mode: pure white bar
    // - Dark mode: deep navy background
    final Color barColor =
        isDark ? DesignToken.navyBackground : DesignToken.white;

    final Color headerTextColor =
        isDark ? DesignToken.white : DesignToken.textDark;
    final Color headerSubTextColor = isDark
        ? DesignToken.white.withValues(alpha: 0.85)
        : DesignToken.textDark.withValues(alpha: 0.70);

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark, // Android
      statusBarBrightness:
          isDark ? Brightness.dark : Brightness.light, // iOS
    );

    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Container(
          // Outer gradient border to mirror the bottom tab bar accent
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: DesignToken.primaryGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(19),
                bottomRight: Radius.circular(19),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.35 : 0.06,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignToken.paddingLG,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    // ── Side menu button ───────────────────────────────────
                    Builder(
                      builder: (context) => InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: headerTextColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            Icons.menu_rounded,
                            color: headerTextColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: DesignToken.widthMD),
                    // ── Logo (square with rounded corners) ────────────────
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: headerTextColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: headerTextColor.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/images/balaji_point_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.storefront_rounded,
                          color: headerTextColor,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: DesignToken.widthMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Balaji Points',
                            style: AppTextStyles.nunitoBold.copyWith(
                              color: headerTextColor,
                              fontSize: DesignToken.fontSizeLG,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: headerSubTextColor,
                                size: 11,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  'Shri Balaji Plywood and Hardware - E road',
                                  style: AppTextStyles.nunitoRegular.copyWith(
                                    color: headerSubTextColor,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // ── Cart button with live item-count badge ──────────────
                    GestureDetector(
                      onTap: () => context.push('/cart'),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: headerTextColor.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: headerTextColor.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: headerTextColor,
                              size: 22,
                            ),
                          ),
                          if (_cartItemCount > 0)
                            Positioned(
                              top: -6,
                              right: -6,
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: DesignToken.error,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: DesignToken.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  _cartItemCount > 99
                                      ? '99+'
                                      : '$_cartItemCount',
                                  style: const TextStyle(
                                    color: DesignToken.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeHeroCard(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final isDayTime = hour >= 6 && hour < 18;
    final greeting = hour < 12
        ? 'Good Morning'
        : (hour < 17 ? 'Good Afternoon' : 'Good Evening');

    final profileImage = _getUserProfileImage();
    final hasValidImage =
        profileImage != null &&
        (profileImage.startsWith('http://') ||
            profileImage.startsWith('https://'));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DesignToken.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[DesignToken.primary, DesignToken.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: DesignToken.borderRadiusXL,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: DesignToken.primary.withValues(alpha: 0.30),
            blurRadius: DesignToken.elevationXL,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignToken.paddingLG,
          vertical: DesignToken.paddingMD,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$greeting,',
                        style: AppTextStyles.nunitoRegular.copyWith(
                          fontSize: DesignToken.fontSizeMD,
                          color:
                              DesignToken.white.withValues(alpha: 0.80),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getUserDisplayName(),
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: DesignToken.fontSizeLG,
                          color: DesignToken.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _SunMoonBadge(
                  isDayTime: isDayTime,
                  pressed: _greetingIconPressed,
                  onPressedChanged: (v) =>
                      setState(() => _greetingIconPressed = v),
                ),
              ],
            ),
            const SizedBox(height: DesignToken.heightMD),
            Divider(
              color: DesignToken.white.withValues(alpha: 0.20),
              height: 1,
            ),
            const SizedBox(height: DesignToken.heightMD),
            Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DesignToken.white.withValues(alpha: 0.8),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        DesignToken.white.withValues(alpha: 0.25),
                    backgroundImage:
                        hasValidImage ? NetworkImage(profileImage) : null,
                    child: !hasValidImage
                        ? const Icon(
                            Icons.person,
                            size: 26,
                            color: DesignToken.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: DesignToken.widthMD),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.star_rounded,
                        color: DesignToken.amberShade300,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getUserTier()} Tier',
                        style: AppTextStyles.nunitoMedium.copyWith(
                          color:
                              DesignToken.white.withValues(alpha: 0.90),
                          fontSize: DesignToken.fontSizeSM,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignToken.paddingMD,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: DesignToken.white.withValues(alpha: 0.20),
                    borderRadius: DesignToken.borderRadiusMD,
                    border: Border.all(
                      color: DesignToken.white.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildHeaderPointsBadge(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _SunMoonBadge({
    required bool isDayTime,
    required bool pressed,
    required ValueChanged<bool> onPressedChanged,
  }) {
    final icon = isDayTime ? Icons.wb_sunny_outlined : Icons.nightlight_round;

    return GestureDetector(
      onTapDown: (_) => onPressedChanged(true),
      onTapUp: (_) => onPressedChanged(false),
      onTapCancel: () => onPressedChanged(false),
      child: AnimatedScale(
        duration: DesignToken.animationDurationFast,
        scale: pressed ? 0.9 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDayTime
                  ? [DesignToken.amberShade300, DesignToken.amberShade500]
                  : [DesignToken.blueShade600, DesignToken.purpleShade600],
            ),
            boxShadow: [
              BoxShadow(
                color: DesignToken.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: DesignToken.white, size: 28),
        ),
      ),
    );
  }

  // Build CarpenterRank object for current user to pass to TopCarpentersDisplay
  // Note: currentUserRankObj is now async - use FutureBuilder where needed

  List<CarpenterRank> get remaining =>
      _topCarpenters.length > 3 ? _topCarpenters.sublist(3) : <CarpenterRank>[];

  // Current User Position Card
  Widget _buildCurrentUserPositionCard() {
    if (_currentUserRank == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [DesignToken.blue700, DesignToken.purpleShade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DesignToken.blue500.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: DesignToken.white,
              shape: BoxShape.circle,
              border: Border.all(color: DesignToken.amberShade400, width: 3),
              boxShadow: [
                BoxShadow(
                  color: DesignToken.amber.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#$_currentUserRank',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DesignToken.blue700,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.rankShort,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: DesignToken.grey500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.yourPosition,
                  style: const TextStyle(
                    color: DesignToken.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getUserDisplayName(),
                  style: const TextStyle(
                    color: DesignToken.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.stars, color: DesignToken.amber, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$_currentUserPoints Points',
                      style: const TextStyle(
                        color: DesignToken.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Trophy Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DesignToken.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: DesignToken.amber,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // Today's Winner Display Card
  Widget _buildTodaysWinner() {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('daily_prize_winners')
            .where('date', isEqualTo: todayStr)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerWinnerCard();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            final theme = Theme.of(context);
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: DesignToken.secondary.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignToken.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Trophy Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DesignToken.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events_outlined,
                      size: 28,
                      color: DesignToken.secondary.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // No Winner Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.todaysWinnerLabel,
                          style: AppTextStyles.nunitoBold.copyWith(
                            fontSize: 14,
                            color: DesignToken.secondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)!.noWinnerYetToday,
                          style: AppTextStyles.nunitoRegular.copyWith(
                            fontSize: 14,
                            color: DesignToken.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Info Icon
                  const Icon(
                    Icons.info_outline,
                    size: 24,
                    color: DesignToken.grey400,
                  ),
                ],
              ),
            );
          }

          final winnerDoc = snapshot.data!.docs.first;
          final winnerData = winnerDoc.data() as Map<String, dynamic>;
          final winnerName = winnerData['carpenterName'] ?? 'Unknown';
          final winnerPhoto = winnerData['carpenterPhoto'] ?? '';
          final prizePoints = winnerData['prizePoints'] ?? 0;
          final winnerId = winnerData['carpenterId'] as String?;

          // Check if current user is the winner (using FutureBuilder for async check)
          return FutureBuilder<String?>(
            future: _sessionService.getUserId(),
            builder: (context, userIdSnapshot) {
              final currentUserId = userIdSnapshot.data;
              final isCurrentUserWinner =
                  currentUserId != null && winnerId == currentUserId;

              // Trigger confetti if current user is winner
              if (isCurrentUserWinner) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _confettiController.play();
                });
              }

              final theme = Theme.of(context);
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrentUserWinner
                        ? DesignToken.amberShade300
                        : DesignToken.secondary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: DesignToken.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Trophy Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCurrentUserWinner
                            ? DesignToken.amberShade50
                            : DesignToken.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: 28,
                        color: isCurrentUserWinner
                            ? DesignToken.amberShade700
                            : DesignToken.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Profile Image
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrentUserWinner
                              ? DesignToken.amberShade300
                              : DesignToken.secondary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _isValidImageUrl(winnerPhoto)
                            ? Image.network(
                                winnerPhoto,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: DesignToken.secondary.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 25,
                                      color: DesignToken.secondary,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: DesignToken.secondary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 25,
                                  color: DesignToken.secondary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Winner Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isCurrentUserWinner
                                ? AppLocalizations.of(context)!.youWonPrize
                                : AppLocalizations.of(
                                    context,
                                  )!.todaysWinnerLabel,
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 14,
                              color: isCurrentUserWinner
                                  ? DesignToken.amberShade800
                                  : DesignToken.secondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            winnerName,
                            style: AppTextStyles.nunitoSemiBold.copyWith(
                              fontSize: 16,
                              color: DesignToken.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Points Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: DesignToken.amberShade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: DesignToken.amberShade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: 16,
                            color: DesignToken.amberShade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$prizePoints',
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 14,
                              color: DesignToken.amberShade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

}

class _HomeProductCategory {
  final String title;
  final IconData icon;
  final Color background;
  final String imageAsset;

  const _HomeProductCategory({
    required this.title,
    required this.icon,
    required this.background,
    required this.imageAsset,
  });
}

class _ProductHeroCardData {
  final String title;
  final String subtitle;
  final String imageAsset;
  final IconData icon;

  const _ProductHeroCardData({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.icon,
  });
}

class _ProductCategoryCard extends StatelessWidget {
  final _HomeProductCategory category;
  final Color surfaceColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ProductCategoryCard({
    required this.category,
    required this.surfaceColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: category.background,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: DesignToken.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Furniture photo background
            Positioned.fill(
              child: Image.asset(
                category.imageAsset,
                fit: BoxFit.cover,
              ),
            ),
            // Dark gradient at bottom for readable text
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.10),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: surfaceColor.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      color: DesignToken.primary,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    category.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.nunitoSemiBold.copyWith(
                      color: DesignToken.white,
                      fontSize: DesignToken.fontSizeMD,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
