

class DetectionResult {
  final String status;
  final String filename;
  final Map<String, int> imageSize;
  final int totalDetections;
  final int wasteDetections;
  final List<Detection> detections;
  final List<Detection> allDetections;
  final bool scanSaved;
  final double processingTime;

  DetectionResult({
    required this.status,
    required this.filename,
    required this.imageSize,
    required this.totalDetections,
    required this.wasteDetections,
    required this.detections,
    required this.allDetections,
    this.scanSaved = false,
    this.processingTime = 0.0,
  });

  int get detectionsCount => wasteDetections;

  factory DetectionResult.fromApiResponse(Map<String, dynamic> json) {
    return DetectionResult(
      status: json['status'] ?? 'success',
      filename: json['filename'] ?? '',
      imageSize: {
        'width': json['image_size']?['width'] ?? 0,
        'height': json['image_size']?['height'] ?? 0,
      },
      totalDetections: json['total_detections'] ?? 0,
      wasteDetections: json['waste_detections'] ?? 0,
      detections: (json['detections'] as List? ?? [])
          .map((detection) => Detection.fromApiResponse(detection))
          .toList(),
      allDetections: (json['all_detections'] as List? ?? [])
          .map((detection) => Detection.fromApiResponse(detection))
          .toList(),
      scanSaved: json['scan_saved'] ?? false,
      processingTime: (json['processing_time'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'filename': filename,
      'image_size': imageSize,
      'total_detections': totalDetections,
      'waste_detections': wasteDetections,
      'detections': detections.map((d) => d.toJson()).toList(),
      'all_detections': allDetections.map((d) => d.toJson()).toList(),
      'scan_saved': scanSaved,
      'processing_time': processingTime,
    };
  }
}

class Detection {
  final String className;
  final int classId;
  final double confidence;
  final String wasteCategory;
  final BoundingBox bbox;

  Detection({
    required this.className,
    required this.classId,
    required this.confidence,
    required this.wasteCategory,
    required this.bbox,
  });

  factory Detection.fromApiResponse(Map<String, dynamic> json) {
    return Detection(
      className: json['class'] ?? '',
      classId: json['class_id'] ?? 0,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      wasteCategory: json['waste_category'] ?? 'other',
      bbox: BoundingBox.fromApiResponse(json['bbox'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class': className,
      'class_id': classId,
      'confidence': confidence,
      'waste_category': wasteCategory,
      'bbox': bbox.toJson(),
    };
  }
}

class BoundingBox {
  final double xCenter;
  final double yCenter;
  final double width;
  final double height;
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  BoundingBox({
    required this.xCenter,
    required this.yCenter,
    required this.width,
    required this.height,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory BoundingBox.fromApiResponse(Map<String, dynamic> json) {
    return BoundingBox(
      xCenter: (json['x_center'] ?? 0.0).toDouble(),
      yCenter: (json['y_center'] ?? 0.0).toDouble(),
      width: (json['width'] ?? 0.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
      x1: (json['x1'] ?? 0.0).toDouble(),
      y1: (json['y1'] ?? 0.0).toDouble(),
      x2: (json['x2'] ?? 0.0).toDouble(),
      y2: (json['y2'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x_center': xCenter,
      'y_center': yCenter,
      'width': width,
      'height': height,
      'x1': x1,
      'y1': y1,
      'x2': x2,
      'y2': y2,
    };
  }
}

class ScanHistory {
  final String id;
  final String userId;
  final String imageFilename;
  final List<Detection> detections;
  final int totalObjects;
  final double confidenceThreshold;
  final double processingTime;
  final String notes;
  final DateTime createdAt;

  ScanHistory({
    required this.id,
    required this.userId,
    required this.imageFilename,
    required this.detections,
    required this.totalObjects,
    required this.confidenceThreshold,
    required this.processingTime,
    required this.notes,
    required this.createdAt,
  });

  factory ScanHistory.fromApiResponse(Map<String, dynamic> json) {
    return ScanHistory(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      imageFilename: json['image_filename'] ?? '',
      detections: (json['detections'] as List? ?? [])
          .map((detection) => Detection.fromApiResponse(detection))
          .toList(),
      totalObjects: json['total_objects'] ?? 0,
      confidenceThreshold: (json['confidence_threshold'] ?? 0.0).toDouble(),
      processingTime: (json['processing_time'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}