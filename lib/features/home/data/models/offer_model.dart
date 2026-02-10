// lib/features/home/data/models/offer_model.dart
// Offer data model for home page offers carousel

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an offer/promotion in the Balaji Points app
class OfferModel {
  final String id;
  final String title;
  final String description;
  final String bannerUrl;
  final int points;
  final DateTime? validUntil;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.points,
    this.validUntil,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Robust converter for Firestore timestamps / ISO strings / null
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

  /// Create OfferModel from Firestore document
  factory OfferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return OfferModel(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      bannerUrl: (data['bannerUrl'] ?? '') as String,
      points: (data['points'] ?? 0) as int,
      validUntil: data['validUntil'] != null ? _toDate(data['validUntil']) : null,
      isActive: data['isActive'] ?? true,
      createdAt: _toDate(data['createdAt'], DateTime.now()),
      updatedAt: _toDate(data['updatedAt'], DateTime.now()),
    );
  }

  /// Check if offer has a banner image
  bool get hasBanner => bannerUrl.isNotEmpty;

  /// Check if offer is expired
  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  /// Check if offer is valid (active and not expired)
  bool get isValid => isActive && !isExpired;

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'bannerUrl': bannerUrl,
        'points': points,
        'validUntil': validUntil?.toIso8601String(),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Copy with method for immutability
  OfferModel copyWith({
    String? id,
    String? title,
    String? description,
    String? bannerUrl,
    int? points,
    DateTime? validUntil,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      points: points ?? this.points,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfferModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'OfferModel(id: $id, title: $title, points: $points)';
}
