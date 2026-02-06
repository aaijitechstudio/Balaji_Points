import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/wallet/domain/entities/bill.dart';

/// Data model for bill
/// 
/// Extends the domain entity and adds Firestore serialization.
/// Handles conversion between Firestore and domain entities.
class BillModel extends Bill {
  const BillModel({
    required super.id,
    required super.storeName,
    required super.amount,
    required super.status,
    required super.pointsEarned,
    super.createdAt,
    required super.carpenterId,
  });
  
  /// Convert from Firestore document
  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillModel(
      id: doc.id,
      storeName: data['storeName'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'pending',
      pointsEarned: data['pointsEarned'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      carpenterId: data['carpenterId'] as String? ?? '',
    );
  }
  
  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'amount': amount,
      'status': status,
      'pointsEarned': pointsEarned,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'carpenterId': carpenterId,
    };
  }
  
  /// Convert from domain entity
  factory BillModel.fromEntity(Bill entity) {
    return BillModel(
      id: entity.id,
      storeName: entity.storeName,
      amount: entity.amount,
      status: entity.status,
      pointsEarned: entity.pointsEarned,
      createdAt: entity.createdAt,
      carpenterId: entity.carpenterId,
    );
  }
  
  /// Convert to domain entity
  Bill toEntity() {
    return Bill(
      id: id,
      storeName: storeName,
      amount: amount,
      status: status,
      pointsEarned: pointsEarned,
      createdAt: createdAt,
      carpenterId: carpenterId,
    );
  }
}
