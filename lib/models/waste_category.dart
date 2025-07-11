class WasteCategory {
  final String id;
  final String name;
  final String nameEn;
  final String description;
  final double basePrice;
  final String? image;
  final String status;
  final DateTime createdAt;

  WasteCategory({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.basePrice,
    this.image,
    required this.status,
    required this.createdAt,
  });

  factory WasteCategory.fromJson(Map<String, dynamic> json) {
    return WasteCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      description: json['description'] ?? '',
      basePrice: (json['base_price'] ?? 0).toDouble(),
      image: json['image'],
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'description': description,
      'base_price': basePrice,
      'image': image,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isActive => status.toLowerCase() == 'active';

  WasteCategory copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? description,
    double? basePrice,
    String? image,
    String? status,
    DateTime? createdAt,
  }) {
    return WasteCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      image: image ?? this.image,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}