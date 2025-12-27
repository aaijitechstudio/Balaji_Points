// lib/presentation/screens/home/home_page.dart
// Complete Home screen: Offers (dynamic) + Top 10 carpenters (dynamic) + current user rank
// Uses CarpenterRank (version A: rank, name, points, imageUrl) from top_carpenters_display.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/presentation/widgets/home_nav_bar.dart';
import 'package:balaji_points/presentation/widgets/user_profile_card.dart';
import 'package:balaji_points/presentation/widgets/top_carpenters_display.dart'; // provides CarpenterRank
import 'package:balaji_points/presentation/widgets/top_carpenters_list.dart';
import 'package:balaji_points/presentation/widgets/shimmer_loading.dart';
import 'package:balaji_points/presentation/widgets/complete_profile_card.dart';
// Daily spin removed - admin only feature now
import 'package:balaji_points/services/user_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;

/// ---------------------------------------------------------------------------
/// OFFER MODEL
/// ---------------------------------------------------------------------------
class OfferItem {
  final String id;
  final String title;
  final String description;
  final String bannerUrl;
  final int points;
  final DateTime? validUntil;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  OfferItem({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.points,
    required this.validUntil,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Robust converter for Firestore timestamps / iso strings / null
  static DateTime _toDate(dynamic ts, [DateTime? fallback]) {
    final fb = fallback ?? DateTime.now();
    try {
      if (ts == null) return fb;
      if (ts is Timestamp) return ts.toDate();
      if (ts is DateTime) return ts;
      if (ts is String) return DateTime.parse(ts);
    } catch (_) {}
    return fb;
  }

  factory OfferItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return OfferItem(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      bannerUrl: (data['bannerUrl'] ?? '') as String,
      points: (data['points'] ?? 0) as int,
      validUntil: data['validUntil'] != null
          ? _toDate(data['validUntil'])
          : null,
      isActive: data['isActive'] ?? true,
      createdAt: _toDate(data['createdAt'], DateTime.now()),
      updatedAt: _toDate(data['updatedAt'], DateTime.now()),
    );
  }
}

/// ---------------------------------------------------------------------------
/// OFFERS CAROUSEL & CARDS
/// - horizontal list for banner offers with page indicators
/// - vertical list with full-width cards when no banners
/// ---------------------------------------------------------------------------
class OffersCarousel extends StatefulWidget {
  final List<OfferItem> offers;

  const OffersCarousel({super.key, required this.offers});

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool get _hasBanners =>
      widget.offers.any((offer) => offer.bannerUrl.isNotEmpty);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If no banners, show vertical list with full-width cards
    if (!_hasBanners) {
      return Column(
        children: widget.offers.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _FullWidthOfferCard(offer: entry.value, index: entry.key),
          );
        }).toList(),
      );
    }

    // If banners exist, show horizontal carousel with page indicators
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.offers.length,
            itemBuilder: (context, index) {
              final offer = widget.offers[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: offer.bannerUrl.isNotEmpty
                    ? _BannerOfferCard(offer: offer)
                    : _BasicOfferCard(offer: offer),
              );
            },
          ),
        ),
        // Page indicators (dots) - only show if more than 1 offer
        if (widget.offers.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.offers.length,
              (index) => _buildDot(index),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index
            ? DesignToken.primary
            : DesignToken.primary.withOpacity(0.3),
      ),
    );
  }
}

class _BannerOfferCard extends StatelessWidget {
  final OfferItem offer;
  const _BannerOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [DesignToken.primary, DesignToken.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DesignToken.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          offer.bannerUrl.isNotEmpty
              ? Image.network(
                  offer.bannerUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [DesignToken.primary, DesignToken.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [DesignToken.primary, DesignToken.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  },
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [DesignToken.primary, DesignToken.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 48, color: Colors.white),
                  ),
                ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [DesignToken.black54, DesignToken.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    color: DesignToken.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // const SizedBox(height: 6),
                // Text(
                //   offer.description,
                //   maxLines: 2,
                //   overflow: TextOverflow.ellipsis,
                //   style: TextStyle(color: DesignToken.white70, fontSize: 14),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicOfferCard extends StatelessWidget {
  final OfferItem offer;
  const _BasicOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignToken.transparent, // no white background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DesignToken.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignToken.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offer.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            offer.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: DesignToken.black54),
          ),
        ],
      ),
    );
  }
}

class _FullWidthOfferCard extends StatelessWidget {
  final OfferItem offer;
  final int index;
  const _FullWidthOfferCard({required this.offer, required this.index});

  // Generate dynamic gradient based on index
  LinearGradient _getGradient() {
    final gradients = [
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          DesignToken.primary,
          DesignToken.primary.withOpacity(0.7),
          DesignToken.secondary.withOpacity(0.8),
        ],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          DesignToken.secondary,
          DesignToken.secondary.withOpacity(0.7),
          DesignToken.primary.withOpacity(0.8),
        ],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          DesignToken.blue600,
          DesignToken.primary,
          DesignToken.secondary,
        ],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          DesignToken.purpleShade500,
          DesignToken.secondary,
          DesignToken.primary.withOpacity(0.9),
        ],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          DesignToken.primary.withOpacity(0.9),
          DesignToken.blue500,
          DesignToken.secondary.withOpacity(0.9),
        ],
      ),
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getGradient(),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DesignToken.primary.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: DesignToken.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: DesignToken.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  offer.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: DesignToken.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// HOME PAGE
/// ---------------------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final UserService _userService = UserService();
  final SessionService _sessionService = SessionService();

  // Offers
  List<OfferItem> _offers = [];
  bool _isLoadingOffers = true;

  // Top carpenters
  List<CarpenterRank> _topCarpenters = [];
  bool _isLoadingCarpenters = true;

  // current user
  Map<String, dynamic>? _currentUserData;
  int? _currentUserRank;
  int _currentUserPoints = 0;

  // animation for add points button
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  // Confetti controller for celebration
  late ConfettiController _confettiController;

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

    _loadInitialData();
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
    _animationController.dispose();
    _confettiController.dispose();
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
      final list = snapshot.docs.map((d) => OfferItem.fromDoc(d)).toList();
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
      // Force refresh by getting fresh data directly from Firestore
      final userId = await _sessionService.getUserId();
      if (userId != null) {
        // Get fresh data directly from Firestore for immediate update
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          if (mounted) {
            setState(() {
              _currentUserData = data;
              _currentUserPoints = (data?['totalPoints'] ?? 0) as int;
            });
            debugPrint(
              'User data refreshed: totalPoints=${_currentUserPoints}, profileImage=${data?['profileImage']}',
            );
          }
          return;
        } else {
          debugPrint('User document does not exist for uid: $userId');
        }
      }

      // Fallback to service method
      final data = await _user_service_getCurrentUserDataSafe();
      if (mounted)
        setState(() {
          _currentUserData = data;
          _currentUserPoints = (data?['totalPoints'] ?? 0) as int;
        });
    } catch (e) {
      debugPrint('Error loading current user data: $e');
      // Fallback to service method on error
      try {
        final data = await _user_service_getCurrentUserDataSafe();
        if (mounted)
          setState(() {
            _currentUserData = data;
            _currentUserPoints = (data?['totalPoints'] ?? 0) as int;
          });
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

  // ------------------ Current user rank ------------------
  Future<void> _loadCurrentUserRank() async {
    try {
      final userId = await _sessionService.getUserId();
      if (userId == null) {
        if (mounted) setState(() => _currentUserRank = null);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
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
          _currentUserPoints = userPoints;
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

  /// Show dialog when user tries to add bill with incomplete profile
  void _showCompleteProfileDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_alt_1,
                color: Colors.orange.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.profileIncomplete,
                style: AppTextStyles.nunitoBold.copyWith(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.completeProfileMessage,
          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: AppTextStyles.nunitoMedium.copyWith(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/edit-profile');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.completeProfile,
              style: AppTextStyles.nunitoSemiBold.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
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
    // Note: currentUserRankObj is now async, handled in FutureBuilder below
    final top3 = _topCarpenters.take(3).toList();
    final remaining = _topCarpenters.length > 3
        ? _topCarpenters.sublist(3)
        : <CarpenterRank>[];

    return Scaffold(
      backgroundColor: DesignToken.primary,
      body: Stack(
        children: [
          Column(
            children: [
              HomeNavBar(userImageUrl: _getUserProfileImage()),

              Expanded(
                child: Container(
                  color: DesignToken.woodenBackground,
                  child: RefreshIndicator(
                    onRefresh: _loadInitialData,
                    color: DesignToken.primary,
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // User profile card
                          UserProfileCard(
                            userName: _getUserDisplayName(),
                            totalPoints: _getUserPoints(),
                            tier: _getUserTier(),
                            userImageUrl: _getUserProfileImage(),
                          ),

                          const SizedBox(height: 16),

                          // Complete Profile Card (shown if profile is incomplete)
                          if (!_isProfileComplete()) ...[
                            const CompleteProfileCard(),
                            const SizedBox(height: 16),
                          ],

                          const SizedBox(height: 4),

                          // Latest Offers header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              AppLocalizations.of(context)!.latestOffers,
                              style: TextStyle(
                                color: DesignToken.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ).merge(AppTextStyles.nunitoBold),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Offers carousel
                          _isLoadingOffers
                              ? const ShimmerOfferCard()
                              : OffersCarousel(offers: _offers),

                          const SizedBox(height: 20),

                          // Today's Winner Display
                          _buildTodaysWinner(),

                          const SizedBox(height: 20),

                          // Current User Position Card
                          _buildCurrentUserPositionCard(),

                          const SizedBox(height: 20),

                          // Top carpenters
                          if (_isLoadingCarpenters)
                            const ShimmerTopCarpenters()
                          else if (_topCarpenters.isNotEmpty) ...[
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: DesignToken.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
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
                            const SizedBox(height: 20),

                            // Top 10 Carpenters List (without bordered card container)
                            if (_topCarpenters.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: TopCarpentersList(
                                  carpenters: _topCarpenters,
                                  showViewAll: false,
                                ),
                              ),
                          ],

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                Colors.amber,
                Colors.orange,
                DesignToken.red,
                DesignToken.pink,
                DesignToken.purple,
                DesignToken.blue500,
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DesignToken.secondary.withOpacity(
                    _glowAnimation.value,
                  ),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                if (!_isProfileComplete()) {
                  _showCompleteProfileDialog(context);
                } else {
                  GoRouter.of(context).push('/add-bill');
                }
              },
              backgroundColor: DesignToken.secondary,
              elevation: 6,
              icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
              label: Text(
                AppLocalizations.of(context)!.addPoints,
                style: AppTextStyles.nunitoBold.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber.shade400, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.4),
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
                    color: Colors.grey,
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
                    const Icon(Icons.stars, color: Colors.amber, size: 18),
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
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.amber,
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
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: DesignToken.secondary.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Info Icon
                  Icon(
                    Icons.info_outline,
                    size: 24,
                    color: Colors.grey.shade400,
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

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrentUserWinner
                        ? Colors.amber.shade300
                        : DesignToken.secondary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
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
                            ? Colors.amber.shade50
                            : DesignToken.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: 28,
                        color: isCurrentUserWinner
                            ? Colors.amber.shade700
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
                              ? Colors.amber.shade300
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
                                  ? Colors.amber.shade800
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
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.amber.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: 16,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$prizePoints',
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 14,
                              color: Colors.amber.shade900,
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

  // Drawer (kept same as your UI)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [DesignToken.primary, DesignToken.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: _isValidImageUrl(_getUserProfileImage())
                      ? NetworkImage(_getUserProfileImage()!)
                      : null,
                  child: !_isValidImageUrl(_getUserProfileImage())
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: DesignToken.secondary,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  _getUserDisplayName(),
                  style: const TextStyle(
                    color: DesignToken.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_getUserTier()} Tier • ${_getUserPoints()} Points',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: DesignToken.primary),
            title: Text(AppLocalizations.of(context)!.home),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(
              Icons.monetization_on,
              color: DesignToken.primary,
            ),
            title: Text(AppLocalizations.of(context)!.myPoints),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(
              Icons.card_giftcard,
              color: DesignToken.primary,
            ),
            title: Text(AppLocalizations.of(context)!.redeemRewards),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.history, color: DesignToken.primary),
            title: Text(AppLocalizations.of(context)!.transactionHistory),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard, color: DesignToken.primary),
            title: Text(AppLocalizations.of(context)!.leaderboard),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: DesignToken.primary),
            title: Text(AppLocalizations.of(context)!.settings),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline, color: DesignToken.primary),
            title: Text(AppLocalizations.of(context)!.helpSupport),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
