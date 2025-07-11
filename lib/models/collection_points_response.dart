import 'collection_point.dart';

class CollectionPointsResponse {
  final List<CollectionPoint> collectionPoints;
  final int total;
  final int page;
  final int limit;

  CollectionPointsResponse({
    required this.collectionPoints,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory CollectionPointsResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('📥 Parsing CollectionPointsResponse: $json');
      
      List<CollectionPoint> points = [];
      
      // Try different possible field names for collection points
      dynamic pointsData = json['collection_points'] ?? 
                          json['data'] ?? 
                          json['items'] ?? 
                          json['results'] ?? 
                          [];
      
      if (pointsData is List) {
        for (var item in pointsData) {
          try {
            if (item is Map<String, dynamic>) {
              final point = CollectionPoint.fromJson(item);
              points.add(point);
              print('✅ Successfully parsed point: ${point.name}');
            }
          } catch (e) {
            print('⚠️ Failed to parse individual point: $e');
            print('📄 Point data: $item');
            // Continue with other points even if one fails
          }
        }
      }
      
      return CollectionPointsResponse(
        collectionPoints: points,
        total: _parseInt(json['total']),
        page: _parseInt(json['page']),
        limit: _parseInt(json['limit']),
      );
    } catch (e) {
      print('❌ Error parsing CollectionPointsResponse: $e');
      print('📥 Raw JSON: $json');
      
      // Return empty response if parsing completely fails
      return CollectionPointsResponse(
        collectionPoints: [],
        total: 0,
        page: 1,
        limit: 20,
      );
    }
  }

  static int _parseInt(dynamic value) {
    try {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'collection_points': collectionPoints.map((cp) => cp.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
    };
  }
}