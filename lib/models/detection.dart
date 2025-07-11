import 'bounding_box.dart';

class Detection {
  final String className;
  final int classId;
  final double confidence;
  final BoundingBox bbox;

  Detection({
    required this.className,
    required this.classId,
    required this.confidence,
    required this.bbox,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      className: json['class'] as String,
      classId: json['class_id'] as int,
      confidence: (json['confidence'] as num).toDouble(),
      bbox: BoundingBox.fromJson(json['bbox'] as Map<String, dynamic>),
    );
  }
}