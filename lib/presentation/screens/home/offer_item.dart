// lib/models/offer_item.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class OfferItem {
  final String title;
  final String description;
  final String bannerUrl;
  final int points;
  final DateTime validUntil;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String actionText; // auto-generated

  OfferItem({
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.points,
    required this.validUntil,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.actionText,
  });

  factory OfferItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OfferItem(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      points: data['points'] ?? 0,
      validUntil: (data['validUntil'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),

      // Auto-generate action text
      actionText: (data['bannerUrl'] != null && data['bannerUrl'] != '')
          ? "View Offer"
          : "Learn More",
    );
  }
}
