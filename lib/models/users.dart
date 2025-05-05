class users {
  final String id;
  final String name;
  final String email;
  final String password;
  final String emergencyPhone;
  final String? profileImage;

  users({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.emergencyPhone,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'emergencyPhone': emergencyPhone,
      'profileImage': profileImage,
    };
  }

  Map<String, dynamic> toRegistrationMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'emergencyPhone': emergencyPhone,
      'profileImage': profileImage,
    };
  }

  factory users.fromJson(Map<String, dynamic> json) {
    return users(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      emergencyPhone: json['emergencyPhone'] ?? '',
      profileImage: json['profileImage'],
    );
  }
}
