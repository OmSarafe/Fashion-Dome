class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.deliveryAddress = '',
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.gender = '',
    this.dateOfBirth,
    this.orderNotificationsEnabled = true,
    this.marketingNotificationsEnabled = true,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String gender;
  final String? dateOfBirth;
  final bool orderNotificationsEnabled;
  final bool marketingNotificationsEnabled;

  bool get isAdmin => role == 'admin';

  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'customer',
      phone: data['phone'] as String? ?? '',
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
      deliveryLatitude: (data['deliveryLatitude'] as num?)?.toDouble(),
      deliveryLongitude: (data['deliveryLongitude'] as num?)?.toDouble(),
      gender: data['gender'] as String? ?? '',
      dateOfBirth: data['dateOfBirth'] as String?,
      orderNotificationsEnabled:
          data['orderNotificationsEnabled'] as bool? ?? true,
      marketingNotificationsEnabled:
          data['marketingNotificationsEnabled'] as bool? ?? true,
    );
  }
}
