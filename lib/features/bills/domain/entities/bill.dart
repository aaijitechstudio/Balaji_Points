/// Bill entity
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents a bill in the business logic.
class Bill {
  final String id;
  final String billId;
  final String carpenterId;
  final String carpenterPhone;
  final double amount;
  final String imageUrl;
  final String status;
  final int pointsEarned;
  final DateTime billDate;
  final String storeName;
  final String billNumber;
  final String notes;
  final String? submittedBy;
  final String? adminId;
  final String? adminPhone;
  final String? adminName;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  const Bill({
    required this.id,
    required this.billId,
    required this.carpenterId,
    required this.carpenterPhone,
    required this.amount,
    required this.imageUrl,
    required this.status,
    required this.pointsEarned,
    required this.billDate,
    required this.storeName,
    required this.billNumber,
    required this.notes,
    this.submittedBy,
    this.adminId,
    this.adminPhone,
    this.adminName,
    this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bill && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  Bill copyWith({
    String? id,
    String? billId,
    String? carpenterId,
    String? carpenterPhone,
    double? amount,
    String? imageUrl,
    String? status,
    int? pointsEarned,
    DateTime? billDate,
    String? storeName,
    String? billNumber,
    String? notes,
    String? submittedBy,
    String? adminId,
    String? adminPhone,
    String? adminName,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
  }) {
    return Bill(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      carpenterId: carpenterId ?? this.carpenterId,
      carpenterPhone: carpenterPhone ?? this.carpenterPhone,
      amount: amount ?? this.amount,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      billDate: billDate ?? this.billDate,
      storeName: storeName ?? this.storeName,
      billNumber: billNumber ?? this.billNumber,
      notes: notes ?? this.notes,
      submittedBy: submittedBy ?? this.submittedBy,
      adminId: adminId ?? this.adminId,
      adminPhone: adminPhone ?? this.adminPhone,
      adminName: adminName ?? this.adminName,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }
}
