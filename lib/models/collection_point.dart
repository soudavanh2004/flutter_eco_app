import 'shop.dart';
import 'location.dart';

class CollectionPoint {
  final String id;
  final String name;
  final String ownerName;
  final String phone;
  final String address;
  final Location location;
  final String district;
  final String village;
  final List<String> wasteTypes;
  final String openingHours;
  final double pricePerKg;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  CollectionPoint({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.phone,
    required this.address,
    required this.location,
    required this.district,
    required this.village,
    required this.wasteTypes,
    required this.openingHours,
    required this.pricePerKg,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CollectionPoint.fromJson(Map<String, dynamic> json) {
    try {
      return CollectionPoint(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'ຮ້ານຮັບຊື້ຂີ້ເຫຍື້ອ',
        ownerName: json['owner_name']?.toString() ?? json['ownerName']?.toString() ?? 'ບໍ່ມີຂໍ້ມູນ',
        phone: json['phone']?.toString() ?? '020 0000 0000',
        address: json['address']?.toString() ?? 'ວຽງຈັນ',
        location: _parseLocation(json['location']),
        district: json['district']?.toString() ?? 'ວຽງຈັນ',
        village: json['village']?.toString() ?? 'ບໍ່ມີຂໍ້ມູນ',
        wasteTypes: _parseWasteTypes(json['waste_types'] ?? json['wasteTypes']),
        openingHours: json['opening_hours']?.toString() ?? json['openingHours']?.toString() ?? '8:00-18:00',
        pricePerKg: _parseDouble(json['price_per_kg'] ?? json['pricePerKg']),
        status: json['status']?.toString() ?? 'active',
        createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
        updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
      );
    } catch (e) {
      print('❌ Error parsing CollectionPoint: $e');
      print('📥 Raw JSON: $json');
      
      // Return default object with minimal data if parsing fails
      return CollectionPoint(
        id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: json['name']?.toString() ?? 'ຮ້ານຮັບຊື້ຂີ້ເຫຍື້ອ',
        ownerName: 'ບໍ່ມີຂໍ້ມູນ',
        phone: '020 0000 0000',
        address: 'ວຽງຈັນ',
        location: Location(latitude: 17.9757, longitude: 102.6331),
        district: 'ວຽງຈັນ',
        village: 'ບໍ່ມີຂໍ້ມູນ',
        wasteTypes: ['ເຈ້ຍ'],
        openingHours: '8:00-18:00',
        pricePerKg: 1000.0,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Helper methods for safe parsing
  static Location _parseLocation(dynamic locationData) {
    try {
      if (locationData == null) {
        return Location(latitude: 17.9757, longitude: 102.6331); // Default Vientiane
      }
      
      if (locationData is Map<String, dynamic>) {
        return Location.fromJson(locationData);
      }
      
      return Location(latitude: 17.9757, longitude: 102.6331);
    } catch (e) {
      print('⚠️ Failed to parse location: $e');
      return Location(latitude: 17.9757, longitude: 102.6331);
    }
  }

  static List<String> _parseWasteTypes(dynamic wasteTypesData) {
    try {
      if (wasteTypesData == null) {
        return ['ເຈ້ຍ']; // Default waste type
      }
      
      if (wasteTypesData is List) {
        return wasteTypesData.map((e) => e.toString()).toList();
      }
      
      if (wasteTypesData is String) {
        return [wasteTypesData];
      }
      
      return ['ເຈ້ຍ'];
    } catch (e) {
      print('⚠️ Failed to parse waste types: $e');
      return ['ເຈ້ຍ'];
    }
  }

  static double _parseDouble(dynamic value) {
    try {
      if (value == null) return 1000.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 1000.0;
      return 1000.0;
    } catch (e) {
      return 1000.0;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    try {
      if (value == null) return DateTime.now();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_name': ownerName,
      'phone': phone,
      'address': address,
      'location': location.toJson(),
      'district': district,
      'village': village,
      'waste_types': wasteTypes,
      'opening_hours': openingHours,
      'price_per_kg': pricePerKg,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert to Shop model for backward compatibility
  Shop toShop({String distance = ''}) {
    return Shop(
      id: id,
      name: name,
      operatingHours: openingHours,
      isOpen: status.toLowerCase() == 'active',
      distance: distance.isNotEmpty ? distance : '0.0km',
      acceptedMaterials: wasteTypes,
      address: address,
      latitude: location.latitude,
      longitude: location.longitude,
      phone: phone,
    );
  }

  CollectionPoint copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? phone,
    String? address,
    Location? location,
    String? district,
    String? village,
    List<String>? wasteTypes,
    String? openingHours,
    double? pricePerKg,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollectionPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      location: location ?? this.location,
      district: district ?? this.district,
      village: village ?? this.village,
      wasteTypes: wasteTypes ?? this.wasteTypes,
      openingHours: openingHours ?? this.openingHours,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}