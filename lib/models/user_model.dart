class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role; // 'admin', 'evaluator', 'owner'
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? map['_id'] ?? '',
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      createdAt: map['createdAt'] is String ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] is String ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }
}
