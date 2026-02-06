/// Session entity for user authentication state
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the authenticated user session in the business logic.
class Session {
  final String? id;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? role;

  const Session({
    this.id,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.role,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session &&
        other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.role == role;
  }

  @override
  int get hashCode => Object.hash(id, phoneNumber, firstName, lastName, role);

  Session copyWith({
    String? id,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? role,
  }) {
    return Session(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
    );
  }
}
