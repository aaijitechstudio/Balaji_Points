import 'package:flutter/material.dart';
import 'package:balaji_points/config/theme.dart';

class OffersCarousel extends StatefulWidget {
  final List<OfferItem> offers;

  const OffersCarousel({super.key, required this.offers});

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty) {
      return const SizedBox.shrink();
    }

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
              return _buildOfferCard(widget.offers[index]);
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.offers.length,
            (index) => _buildDot(index == _currentPage),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard(OfferItem offer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative pattern
          Positioned.fill(child: CustomPaint(painter: _OfferPatternPainter())),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (offer.title.isNotEmpty)
                  Text(
                    offer.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 12),
                if (offer.description.isNotEmpty)
                  Text(
                    offer.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 16),
                if (offer.actionText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      offer.actionText,
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OfferItem {
  final String title;
  final String description;
  final String actionText;
  final String? imageUrl;

  OfferItem({
    required this.title,
    required this.description,
    required this.actionText,
    this.imageUrl,
  });
}

class _OfferPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(
          Offset(size.width * 0.2 * (i + 1), size.height * 0.3 * (j + 1)),
          20,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
