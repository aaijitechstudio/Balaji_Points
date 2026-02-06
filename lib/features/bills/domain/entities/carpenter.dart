/// Carpenter entity for bill selection
class Carpenter {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? city;
  final String? skill;
  final String? profileImage;

  const Carpenter({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.city,
    this.skill,
    this.profileImage,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Carpenter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
