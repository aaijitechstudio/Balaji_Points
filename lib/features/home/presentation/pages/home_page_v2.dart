// lib/features/home/presentation/pages/home_page_v2.dart
// Redesigned home page with BLoC pattern and clean architecture
// Target: <500 lines (vs 1,726 lines in old version)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';

import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/theme/design_token_extensions.dart';
import 'package:balaji_points/core/widgets/navigation/balaji_top_nav_bar.dart';
import 'package:balaji_points/features/home/presentation/bloc/home_bloc.dart';
import 'package:balaji_points/features/home/presentation/bloc/home_event.dart';
import 'package:balaji_points/features/home/presentation/bloc/home_state.dart';
import 'package:balaji_points/features/home/presentation/widgets/hero_section/hero_section.dart';
import 'package:balaji_points/features/home/presentation/widgets/complete_profile_card.dart';
import 'package:balaji_points/features/home/presentation/widgets/offers/offers_carousel_v2.dart';
import 'package:balaji_points/features/home/presentation/widgets/achievement_highlights/achievement_highlights.dart';
import 'package:balaji_points/features/home/presentation/widgets/leaderboard_preview/leaderboard_preview.dart';
import 'package:balaji_points/features/home/presentation/widgets/top_carpenters_list.dart';
import 'package:balaji_points/features/home/presentation/widgets/top_carpenters_display.dart'
    show CarpenterRank;
import 'package:balaji_points/features/home/data/repositories/home_repository.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/core/utils/app_logger.dart';

class HomePageV2 extends StatefulWidget {
  const HomePageV2({super.key});

  @override
  State<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends State<HomePageV2>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late ConfettiController _confettiController;
  late HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    AppLogger.navigation('HomePage', action: 'init');

    // Initialize confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Initialize BLoC
    _homeBloc = HomeBloc(repository: HomeRepository());
    _homeBloc.add(const LoadHomeData());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppLogger.navigation('HomePage', action: 'resumed', extra: 'refreshing data');
      _homeBloc.add(const RefreshHomeData());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _confettiController.dispose();
    _homeBloc.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    AppLogger.navigation('HomePage', action: 'pull-to-refresh');
    _homeBloc.add(const RefreshHomeData());
    // Wait a bit for the refresh to complete
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: DesignToken.primary,
            appBar: _buildAppBar(context, state),
            body: Stack(
              children: [
                _buildBody(context, state),
                _buildConfetti(),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, HomeState state) {
    final isCarpenter = state.isCarpenter;
    final userId = state.userId;

    return BalajiTopNavBar(
      titleText: '',
      backgroundColor: DesignToken.primary,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          backgroundImage: state.userImageUrl != null && state.userImageUrl!.isNotEmpty
              ? NetworkImage(state.userImageUrl!)
              : null,
          child: state.userImageUrl == null || state.userImageUrl!.isEmpty
              ? Text(
                  state.userName.isNotEmpty ? state.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
      actions: isCarpenter && userId != null
          ? [
              // Notification button with badge
              StreamBuilder<QuerySnapshot>(
                stream: HomeRepository().getNotificationsStream(userId),
                builder: (context, snapshot) {
                  int notificationCount = 0;

                  if (snapshot.hasData) {
                    // Filter out admin-only notifications
                    final docs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final type = data['type'] as String?;
                      const adminOnlyTypes = [
                        'dailySpinReminder',
                        'newPendingBill',
                        'newUserRegistered',
                      ];
                      return !adminOnlyTypes.contains(type);
                    }).toList();

                    notificationCount = docs.length;
                  }

                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          AppLogger.navigation('HomePage', action: 'navigate to notifications');
                          context.push('/notifications');
                        },
                        tooltip: 'Notifications',
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                notificationCount > 99 ? '99+' : '$notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ]
          : null,
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state.isLoading) {
      return _buildLoadingState();
    }

    if (state.isError) {
      return _buildErrorState(context, state.errorMessage);
    }

    return Container(
      color: DesignToken.woodenBackground,
      child: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: DesignToken.primary,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.spacing.xl),

                // Hero Section (greeting + points)
                HeroSection(
                  userName: state.userName,
                  points: state.userPoints,
                  tier: state.userTier,
                  userImageUrl: state.userImageUrl,
                  showQuickActions: false, // Can enable later with navigation
                ),

                SizedBox(height: context.spacing.xl),

                // Profile Completion Card (if incomplete)
                if (!state.isProfileComplete) ...[
                  const CompleteProfileCard(),
                  SizedBox(height: context.spacing.xl),
                ],

                // Latest Offers Section
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context)!.latestOffers,
                ),
                SizedBox(height: context.spacing.md),
                
                state.offersLoading
                    ? _buildOffersShimmer()
                    : OffersCarouselV2(offers: state.offers),

                SizedBox(height: context.spacing.xl2),

                // Achievement Highlights (Today's Winner + Your Ranking)
                if (state.todaysWinner != null || state.currentUserRank != null) ...[
                  AchievementHighlights(
                    todaysWinner: state.todaysWinner,
                    currentUserRank: state.currentUserRank,
                    totalCarpenters: state.topCarpenters.length,
                    onViewLeaderboard: () {
                      AppLogger.navigation('HomePage', action: 'view leaderboard', extra: 'from achievements');
                      _showFullLeaderboard(context, state);
                    },
                  ),
                  SizedBox(height: context.spacing.xl2),
                ],

                // Leaderboard Preview
                if (state.hasLeaderboard) ...[
                  _buildSectionHeader(context, 'Leaderboard'),
                  SizedBox(height: context.spacing.md),
                  LeaderboardPreview(
                    topCarpenters: state.topCarpenters,
                    currentUserRank: state.currentUserRank,
                    isLoading: state.leaderboardLoading,
                    onViewFull: () {
                      AppLogger.navigation('HomePage', action: 'view full leaderboard');
                      _showFullLeaderboard(context, state);
                    },
                  ),
                  SizedBox(height: context.spacing.xl2),
                ],

                // Bottom padding
                SizedBox(height: context.spacing.xl2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.lg),
      child: Text(
        title,
        style: context.text.heading2.copyWith(
          color: DesignToken.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: DesignToken.woodenBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: DesignToken.primary,
            ),
            SizedBox(height: context.spacing.lg),
            Text(
              'Loading...',
              style: context.text.bodyMedium.copyWith(
                color: DesignToken.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Container(
      color: DesignToken.woodenBackground,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: DesignToken.error,
              ),
              SizedBox(height: context.spacing.lg),
              Text(
                'Oops! Something went wrong',
                style: context.text.heading3.copyWith(
                  color: DesignToken.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing.md),
              Text(
                errorMessage ?? 'Please try again',
                style: context.text.bodyMedium.copyWith(
                  color: DesignToken.grey600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing.xl),
              ElevatedButton.icon(
                onPressed: () {
                  _homeBloc.add(const LoadHomeData());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignToken.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.xl2,
                    vertical: context.spacing.md,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOffersShimmer() {
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: context.spacing.lg),
      decoration: BoxDecoration(
        color: DesignToken.grey200,
        borderRadius: context.radius.borderMD,
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: DesignToken.primary,
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple,
        ],
      ),
    );
  }

  void _showFullLeaderboard(BuildContext context, HomeState state) {
    // Convert CarpenterRankModel to CarpenterRank for old widget
    final oldFormatCarpenters = state.topCarpenters.map((model) {
      return CarpenterRank(
        rank: model.rank,
        name: model.displayName,
        points: model.points,
        imageUrl: model.imageUrl,
      );
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.radius.borderLG.topLeft.x),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: context.spacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DesignToken.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.lg,
                  vertical: context.spacing.md,
                ),
                child: Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 24)),
                    SizedBox(width: context.spacing.sm),
                    Text(
                      'Full Leaderboard',
                      style: context.text.heading2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // List
              Expanded(
                child: TopCarpentersList(
                  carpenters: oldFormatCarpenters,
                  showViewAll: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
