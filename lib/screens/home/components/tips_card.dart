// screens/home/components/tips_card.dart
import 'package:flutter/material.dart';
import 'package:front_end_ecoapp_new/screens/home/WarningPage.dart';
import 'package:front_end_ecoapp_new/screens/home/components/app_colors.dart';
import 'app_text_styles.dart';
 // Import your WarningPage

class TipsCard extends StatelessWidget {
  const TipsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WarningPage(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2FF),
          borderRadius: BorderRadius.circular(16),
          // Add subtle shadow for better tap feedback
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF3D85C6),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'ຄໍາແນະນໍາການຖ່າຍຮູບ',
                  style: AppTextStyles.subtitle1,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem('ຖ່າຍຮູບໃນບ່ອນທີ່ມີແສງສະຫວ່າງພຽງພໍ'),
            _buildTipItem('ວາງວັດຖຸໃຫ້ຢູ່ກາງຮູບ'),
            _buildTipItem('ຖ່າຍໃຫ້ເຫັນວັດຖຸທັງຫມົດ'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2,
            ),
          ),
        ],
      ),
    );
  }
}