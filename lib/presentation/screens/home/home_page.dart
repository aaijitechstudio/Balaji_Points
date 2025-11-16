// lib/presentation/screens/home/home_page.dart
// Complete Home screen: Offers (dynamic) + Top 10 carpenters (dynamic) + current user rank
// Uses CarpenterRank (version A: rank, name, points, imageUrl) from top_carpenters_display.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:balaji_points/presentation/widgets/home_nav_bar.dart';
import 'package:balaji_points/presentation/widgets/user_profile_card.dart';
import 'package:balaji_points/presentation/widgets/top_carpenters_display.dart'; // provides CarpenterRank
import 'package:balaji_points/presentation/widgets/top_carpenters_list.dart';
import 'package:balaji_points/presentation/widgets/daily_spin_wheel.dart';
import 'package:balaji_points/services/user_service.dart';
import 'package:balaji_points/config/theme.dart';

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
/// - horizontal list
/// - full-width banner when bannerUrl exists
/// - fallback older card UI when bannerUrl is empty
/// ---------------------------------------------------------------------------
class OffersCarousel extends StatelessWidget {
  final List<OfferItem> offers;

  const OffersCarousel({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final offer = offers[index];
          if (offer.bannerUrl.isNotEmpty) {
            return _BannerOfferCard(offer: offer);
          } else {
            return _BasicOfferCard(offer: offer);
          }
        },
      ),
    );
  }
}

class _BannerOfferCard extends StatelessWidget {
  final OfferItem offer;
  const _BannerOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.95;
    return Container(
      width: width,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          Image.network(
            offer.bannerUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.grey.shade300),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: Colors.grey.shade300,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  offer.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  "${offer.points} Points",
                  style: const TextStyle(
                    color: Colors.yellowAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent, // no white background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
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
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Spacer(),
          Text(
            "${offer.points} Points",
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
              fontWeight: FontWeight.w700,
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

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _loadUserData();
    await Future.wait([_loadOffers(), _loadTopCarpenters()]);
    await _loadCurrentUserRank();
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
          .get();
      final list = snapshot.docs.map((d) => OfferItem.fromDoc(d)).toList();
      if (mounted)
        setState(() {
          _offers = list;
          _isLoadingOffers = false;
        });
    } catch (e, st) {
      debugPrint('Error loading offers: $e\n$st');
      if (mounted) setState(() => _isLoadingOffers = false);
    }
  }

  // ------------------ Top Carpenters ------------------
  Future<void> _loadTopCarpenters() async {
    setState(() => _isLoadingCarpenters = true);
    try {
      final qs = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'carpenter')
          .orderBy('totalPoints', descending: true)
          .limit(10)
          .get();

      final carpenters = <CarpenterRank>[];
      for (var i = 0; i < qs.docs.length; i++) {
        final doc = qs.docs[i];
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final firstName = (data['firstName'] ?? '') as String;
        final lastName = (data['lastName'] ?? '') as String;
        final name = ('$firstName $lastName').trim().isEmpty
            ? 'Carpenter ${i + 1}'
            : ('$firstName $lastName').trim();
        final points = (data['totalPoints'] ?? 0) as int;
        final imageUrl = (data['profileImage'] ?? '') as String?;

        // Use CarpenterRank constructor (Version A: no uid)
        carpenters.add(
          CarpenterRank(
            rank: i + 1,
            name: name,
            points: points,
            imageUrl: imageUrl,
            uid: null,
          ),
        );
      }

      if (mounted)
        setState(() {
          _topCarpenters = carpenters;
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
      final data = await _user_service_getCurrentUserDataSafe();
      if (mounted)
        setState(() {
          _currentUserData = data;
          _currentUserPoints = (data?['totalPoints'] ?? 0) as int;
        });
    } catch (e) {
      debugPrint('Error loading current user data: $e');
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _currentUserRank = null);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();
      final userPoints =
          (userData != null
                  ? (userData['totalPoints'] ?? 0)
                  : _currentUserPoints)
              as int;

      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'carpenter')
          .where('totalPoints', isGreaterThan: userPoints)
          .get();
      final rank = query.docs.length + 1;

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

  CarpenterRank _buildCurrentUserAsCarpenterRank() {
    return CarpenterRank(
      rank: _currentUserRank ?? -1,
      name: _getUserDisplayName(),
      points: _currentUserPoints,
      imageUrl: _getUserProfileImage(),
      uid: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserRankObj = _buildCurrentUserAsCarpenterRank();
    final top3 = _topCarpenters.take(3).toList();
    final remaining = _topCarpenters.length > 3
        ? _topCarpenters.sublist(3)
        : <CarpenterRank>[];

    return Scaffold(
      backgroundColor: AppColors.primary,
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          const HomeNavBar(),

          Expanded(
            child: Container(
              color: AppColors.woodenBackground,
              child: SingleChildScrollView(
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

                    const SizedBox(height: 20),

                    // Add Points Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade600,
                                  Colors.purple.shade500,
                                  AppColors.secondary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(
                                    _glowAnimation.value,
                                  ),
                                  blurRadius: 25,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    GoRouter.of(context).push('/add-bill'),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 18,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.monetization_on,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Add Points',
                                        style: AppTextStyles.nunitoBold
                                            .copyWith(
                                              fontSize: 20,
                                              color: Colors.white,
                                              letterSpacing: 1,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Latest Offers header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Latest Offers',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ).merge(AppTextStyles.nunitoBold),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Offers carousel
                    _isLoadingOffers
                        ? Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: OffersCarousel(offers: _offers),
                          ),

                    const SizedBox(height: 20),

                    // Top carpenters
                    if (_isLoadingCarpenters)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (_topCarpenters.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TopCarpentersDisplay(
                          topCarpenters: top3,
                          currentUser: currentUserRankObj,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (remaining.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TopCarpentersList(
                            carpenters: remaining,
                            showViewAll: false,
                          ),
                        ),
                    ],

                    const SizedBox(height: 20),

                    const DailySpinWheel(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build CarpenterRank object for current user to pass to TopCarpentersDisplay
  CarpenterRank get currentUserRankObj => _buildCurrentUserAsCarpenterRank();

  List<CarpenterRank> get remaining =>
      _topCarpenters.length > 3 ? _topCarpenters.sublist(3) : <CarpenterRank>[];

  // Drawer (kept same as your UI)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
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
                  backgroundImage: _getUserProfileImage()?.isNotEmpty == true
                      ? NetworkImage(_getUserProfileImage()!)
                      : null,
                  child: _getUserProfileImage()?.isEmpty != false
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.secondary,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  _getUserDisplayName(),
                  style: const TextStyle(
                    color: Colors.white,
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
            leading: const Icon(Icons.home, color: AppColors.primary),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(
              Icons.monetization_on,
              color: AppColors.primary,
            ),
            title: const Text('My Points'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard, color: AppColors.primary),
            title: const Text('Redeem Rewards'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.history, color: AppColors.primary),
            title: const Text('Transaction History'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard, color: AppColors.primary),
            title: const Text('Leaderboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.primary),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.primary),
            title: const Text('Help & Support'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
