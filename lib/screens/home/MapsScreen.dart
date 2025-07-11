import 'package:flutter/material.dart';
import 'package:front_end_ecoapp_new/screens/home/components/app_colors.dart';
import 'package:front_end_ecoapp_new/models/shop.dart';
import 'package:front_end_ecoapp_new/screens/home/home_screen.dart';


class MapsScreen extends StatefulWidget {
  final List<Shop> shops;
  
  const MapsScreen({Key? key, required this.shops}) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  
  // void _navigateToShopDetail(Shop shop) {
  //   Get.toNamed('/shop_detail', arguments: {'shopId': shop.id});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
            appBar: AppBar(
            title: const Text(
          'ແຜນທີ່',
          style: TextStyle(fontFamily: 'NotoSansLao'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black54,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Map placeholder
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ແຜນທີ່ຈະມາໃນໄວໆນີ້',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: 'NotoSansLao',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Shops list below map
          // Expanded(
          //   child: widget.shops.isEmpty
          //       ? const Center(
          //           child: CircularProgressIndicator(),
          //         )
          //       : ListView.builder(
          //           padding: const EdgeInsets.all(16),
          //           itemCount: widget.shops.length,
          //           itemBuilder: (context, index) {
          //             return ShopListItem(
          //               shop: widget.shops[index],
          //               onTap: () => _navigateToShopDetail(widget.shops[index]),
          //             );
          //           },
          //         ),
          // ),
        ],
      ),
    );
  }
}