import 'shop.dart'; // เพิ่มบรรทัดนี้ที่ด้านบน

class User {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String email;
  final String? profileImage;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    this.profileImage,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

factory User.fromJson(Map<String, dynamic> json) {
  try {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
      role: json['role']?.toString() ?? 'user',
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : DateTime.now(),
    );
  } catch (e) {
    print('Error parsing User JSON: $e');
    print('JSON data: $json');
    rethrow;
  }
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'profile_image': profileImage,
      'role': role,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? email,
    String? profileImage,
    String? role,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}