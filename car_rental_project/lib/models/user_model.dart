class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // Factory method to create UserModel from Firestore data (Map)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555");
    print(json);
    return UserModel(
       id: json['id'] != null ? json['id'] as String : '',
      name: json['name'] != null ? json['name'] as String : 'Unknown',
      email: json['email'] != null ? json['email'] as String : 'Unknown',
      role: json['role'] != null ? json['role'] as String : 'user',
    );
  }

  // Convert UserModel to JSON for Firestore (if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
