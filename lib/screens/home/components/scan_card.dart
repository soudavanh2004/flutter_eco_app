
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:front_end_ecoapp_new/screens/home/components/app_colors.dart';
import 'package:front_end_ecoapp_new/screens/home/components/app_text_styles.dart';
import 'package:front_end_ecoapp_new/screens/scan/scan_screen.dart';

class ScanCard extends StatelessWidget {
  final List<CameraDescription> cameras;

  const ScanCard({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  ScanScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFDEFFE8), Color(0xFFE0F2FF)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ແຕະເພື່ອສະແກນຂີ້ເຫຍື້ອ',
                style: AppTextStyles.subtitle1,
              ),
              const SizedBox(height: 8),
              const Text(
                'ຖ່າຍຮູບເພື່ອກວດສອບປະເພດ',
                style: AppTextStyles.body2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}