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

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      xCenter: (json['x_center'] as num).toDouble(),
      yCenter: (json['y_center'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      x1: (json['x1'] as num).toDouble(),
      y1: (json['y1'] as num).toDouble(),
      x2: (json['x2'] as num).toDouble(),
      y2: (json['y2'] as num).toDouble(),
    );
  }
}