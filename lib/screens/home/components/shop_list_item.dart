// screens/home/components/shop_list_item.dart

import 'package:flutter/material.dart';
import 'package:front_end_ecoapp_new/screens/home/components/app_colors.dart';
import 'package:front_end_ecoapp_new/screens/home/components/app_text_styles.dart';
import '../../../models/shop.dart';

class ShopListItem extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;

   const ShopListItem({
    Key? key,
    required this.shop,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            _buildShopIcon(),
            const SizedBox(width: 10),
            _buildShopInfo(),
            _buildShopDistance(),
          ],
        ),
      ),
    );
  }

  Widget _buildShopIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFD5F2DE),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.store_outlined,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildShopInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                shop.name,
                style: AppTextStyles.subtitle1,
              ),
              const SizedBox(width: 3),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                shop.operatingHours,
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            shop.acceptedMaterials.join(' '),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: shop.isOpen ? const Color(0xFFD5F2DE) : const Color(0xFFFFD6D6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        shop.isOpen ? 'ເປີດ' : 'ປິດ',
        style: TextStyle(
          color: shop.isOpen ? AppColors.primary : const Color(0xFFE53935),
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildShopDistance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          shop.distance,
          style: AppTextStyles.subtitle2,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFEEEEEE),
            ),
          ),
          child: const Text(
            'ເບິ່ງເສັ້ນທາງ',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}