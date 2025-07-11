import 'package:flutter/material.dart';
import 'package:front_end_ecoapp_new/screens/home/components/app_colors.dart';


class ObjectDetectionPainter extends CustomPainter {
  final List<dynamic>? recognitions;
  final Size imageSize;

  ObjectDetectionPainter(this.recognitions, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = AppColors.primary; // ใช้สีจาก AppColors

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var recognition in recognitions ?? []) {
      final rect = Rect.fromLTWH(
        recognition["rect"]["x"] * size.width,
        recognition["rect"]["y"] * size.height,
        recognition["rect"]["w"] * size.width,
        recognition["rect"]["h"] * size.height,
      );

      // วาดกรอบ
      canvas.drawRect(rect, paint);

      // วาด label และ confidence
      textPainter.text = TextSpan(
        text: "${recognition['detectedClass']} ${(recognition['confidence'] * 100).toStringAsFixed(0)}%",
        style: const TextStyle(
          color: AppColors.textPrimary, // ใช้สีจาก AppColors
          fontSize: 15,
          fontFamily: 'NotoSansLao', // ใช้ font จากโปรเจกต์
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rect.left, rect.top - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}