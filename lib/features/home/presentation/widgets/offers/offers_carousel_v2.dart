// lib/features/home/presentation/widgets/offers/offers_carousel_v2.dart
// Improved offers carousel using OfferModel from data layer

import 'package:flutter/material.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/theme/design_token_extensions.dart';
import 'package:balaji_points/features/home/data/models/offer_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OffersCarouselV2 extends StatefulWidget {
  final List<OfferModel> offers;
  final Function(OfferModel)? onOfferTap;

  const OffersCarouselV2({
    super.key,
    required this.offers,
    this.onOfferTap,
  });

  @override
  State<OffersCarouselV2> createState() => _OffersCarouselV2State();
}

class _OffersCarouselV2State extends State<OffersCarouselV2> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Carousel
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.offers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.lg,
                ),
                child: OfferCard(
                  offer: widget.offers[index],
                  onTap: widget.onOfferTap != null
                      ? () => widget.onOfferTap!(widget.offers[index])
                      : null,
                ),
              );
            },
          ),
        ),

        // Page indicators
        if (widget.offers.length > 1) ...[
          SizedBox(height: context.spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.offers.length,
              (index) => _buildPageIndicator(index == _currentPage),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: context.spacing.xs),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? DesignToken.primary : DesignToken.grey300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: context.spacing.lg),
      decoration: BoxDecoration(
        color: DesignToken.grey100,
        borderRadius: context.radius.borderMD,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 48,
              color: DesignToken.grey400,
            ),
            SizedBox(height: context.spacing.md),
            Text(
              'No active offers at the moment',
              style: context.text.bodyMedium.copyWith(
                color: DesignToken.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback? onTap;

  const OfferCard({
    super.key,
    required this.offer,
    this.onTap,
  });

  String _formatValidUntil() {
    if (offer.validUntil == null) return '';
    final now = DateTime.now();
    final difference = offer.validUntil!.difference(now);
    
    if (difference.inDays > 0) {
      return 'Valid for \${difference.inDays} more days';
    } else if (difference.inHours > 0) {
      return 'Valid for \${difference.inHours} more hours';
    } else {
      return 'Expiring soon';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.radius.borderMD,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: context.radius.borderMD,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: context.radius.borderMD,
            child: Stack(
              children: [
                // Banner image (if available)
                if (offer.hasBanner)
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: offer.bannerUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: DesignToken.grey200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: DesignToken.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: DesignToken.grey200,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  )
                else
                  // Fallback gradient background
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            DesignToken.primary.withOpacity(0.1),
                            DesignToken.secondary.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                Positioned(
                  left: context.spacing.lg,
                  right: context.spacing.lg,
                  bottom: context.spacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        offer.title,
                        style: context.text.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (offer.description.isNotEmpty) ...[
                        SizedBox(height: context.spacing.xs),
                        Text(
                          offer.description,
                          style: context.text.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (offer.validUntil != null) ...[
                        SizedBox(height: context.spacing.xs),
                        Text(
                          _formatValidUntil(),
                          style: context.text.labelSmall.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // NO Points badge - removed as per requirement
              ],
            ),
          ),
        ),
      ),
    );
  }
}
