import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/bills/domain/entities/bill.dart';

/// Data model for Bill
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between Firestore and domain entities.
class BillModel extends Bill {
  const BillModel({
    required super.id,
    required super.billId,
    required super.carpenterId,
    required super.carpenterPhone,
    required super.amount,
    required super.imageUrl,
    required super.status,
    required super.pointsEarned,
    required super.billDate,
    required super.storeName,
    required super.billNumber,
    required super.notes,
    super.submittedBy,
    super.adminId,
    super.adminPhone,
    super.adminName,
    super.createdAt,
    super.approvedAt,
    super.approvedBy,
  });

  /// Convert from Firestore document
  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillModel.fromJson(data, doc.id);
  }

  /// Convert from JSON
  factory BillModel.fromJson(Map<String, dynamic> json, [String? id]) {
    return BillModel(
      id: id ?? json['billId'] as String? ?? '',
      billId: json['billId'] as String? ?? '',
      carpenterId: json['carpenterId'] as String? ?? '',
      carpenterPhone: json['carpenterPhone'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      billDate: json['billDate'] != null
          ? (json['billDate'] as Timestamp).toDate()
          : DateTime.now(),
      storeName: json['storeName'] as String? ?? '',
      billNumber: json['billNumber'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      submittedBy: json['submittedBy'] as String?,
      adminId: json['adminId'] as String?,
      adminPhone: json['adminPhone'] as String?,
      adminName: json['adminName'] as String?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      approvedAt: json['approvedAt'] != null
          ? (json['approvedAt'] as Timestamp).toDate()
          : null,
      approvedBy: json['approvedBy'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'carpenterId': carpenterId,
      'carpenterPhone': carpenterPhone,
      'amount': amount,
      'imageUrl': imageUrl,
      'status': status,
      'pointsEarned': pointsEarned,
      'billDate': Timestamp.fromDate(billDate),
      'storeName': storeName,
      'billNumber': billNumber,
      'notes': notes,
      if (submittedBy != null) 'submittedBy': submittedBy,
      if (adminId != null) 'adminId': adminId,
      if (adminPhone != null) 'adminPhone': adminPhone,
      if (adminName != null) 'adminName': adminName,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (approvedAt != null) 'approvedAt': Timestamp.fromDate(approvedAt!),
      if (approvedBy != null) 'approvedBy': approvedBy,
    };
  }

  /// Convert from domain entity
  factory BillModel.fromEntity(Bill bill) {
    return BillModel(
      id: bill.id,
      billId: bill.billId,
      carpenterId: bill.carpenterId,
      carpenterPhone: bill.carpenterPhone,
      amount: bill.amount,
      imageUrl: bill.imageUrl,
      status: bill.status,
      pointsEarned: bill.pointsEarned,
      billDate: bill.billDate,
      storeName: bill.storeName,
      billNumber: bill.billNumber,
      notes: bill.notes,
      submittedBy: bill.submittedBy,
      adminId: bill.adminId,
      adminPhone: bill.adminPhone,
      adminName: bill.adminName,
      createdAt: bill.createdAt,
      approvedAt: bill.approvedAt,
      approvedBy: bill.approvedBy,
    );
  }

  /// Convert to domain entity
  Bill toEntity() {
    return Bill(
      id: id,
      billId: billId,
      carpenterId: carpenterId,
      carpenterPhone: carpenterPhone,
      amount: amount,
      imageUrl: imageUrl,
      status: status,
      pointsEarned: pointsEarned,
      billDate: billDate,
      storeName: storeName,
      billNumber: billNumber,
      notes: notes,
      submittedBy: submittedBy,
      adminId: adminId,
      adminPhone: adminPhone,
      adminName: adminName,
      createdAt: createdAt,
      approvedAt: approvedAt,
      approvedBy: approvedBy,
    );
  }
}
