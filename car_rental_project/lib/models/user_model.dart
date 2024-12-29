class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? address;
  final String? phone;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.address,
    this.phone,
  });

  // Validation Methods
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'Name must contain only letters and spaces';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    // Add more password requirements if needed
    //  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(password)) {
    //    return 'Password must contain at least one letter and one number';
    //  }
    // return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // Phone is optional
    }

    if (phone.length != 11) {
      return 'Phone number must be 11 digits long';
    }

    // Validates phone numbers with optional country code
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phone)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateAddress(String? address) {
    if (address == null || address.isEmpty) {
      return null; // Address is optional
    }
    if (address.length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }

  // static String? validateRole(String? role) {
  //   if (role == null || role.isEmpty) {
  //     return 'Role is required';
  //   }
  //   final validRoles = ['user', 'admin'];
  //   if (!validRoles.contains(role.toLowerCase())) {
  //     return 'Invalid role';
  //   }
  //   return null;
  // }

  // Helper method to validate all required fields
  static Map<String, String?> validateAll({
    required String name,
    required String email,
    String? password,
    String? address,
    String? phone,
  }) {
    return {
      'name': validateName(name),
      'email': validateEmail(email),
      if (password != null) 'password': validatePassword(password),
      if (address != null) 'address': validateAddress(address),
      if (phone != null) 'phone': validatePhone(phone),
    };
  }

  // Factory method to create UserModel from Firestore data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? 'Unknown',
      role: json['role'] as String? ?? 'user',
      address: json['address'] as String?,
      phone: json['phone'] as String?,
    );
  }

  // Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
    };
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? address,
    String? phone,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }
}
