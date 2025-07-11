// import 'package:cloud_firestore/cloud_firestore.dart';

// models/shop.dart
class Shop {
  final String id;
  final String name;
  final String operatingHours;
  final bool isOpen;
  final String distance;
  final List<String> acceptedMaterials;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl; // Add imageUrl
  final String? phone; // Add phone

  Shop({
    required this.id,
    required this.name,
    required this.operatingHours,
    required this.isOpen,
    required this.distance,
    required this.acceptedMaterials,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.phone,
  });

  // Convert Shop to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'operatingHours': operatingHours,
      'isOpen': isOpen,
      'distance': distance,
      'acceptedMaterials': acceptedMaterials,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}