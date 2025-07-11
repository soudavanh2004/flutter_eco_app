import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:front_end_ecoapp_new/screens/home/MapsScreen.dart';
import 'package:front_end_ecoapp_new/screens/home/ProfileScreen.dart';
import 'package:front_end_ecoapp_new/screens/home/components/app_colors.dart';
import 'package:front_end_ecoapp_new/screens/scan/HistoryScreen.dart';
import 'components/scan_card.dart';
import 'components/tips_card.dart';
import 'components/shop_list_item.dart';
import 'components/section_header.dart';
import '../../models/shop.dart';
import '../../models/collection_point.dart';
import '../../models/collection_points_response.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<CameraDescription> cameras = [];
  List<Shop> _shops = [];
  List<CollectionPoint> _collectionPoints = [];
  bool _isLoadingShops = true;
  String? _errorMessage;

  // Services
  final ApiService _apiService = ApiService();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    _initializeCameras();
    _fetchCollectionPoints();
  }

  Future<void> _initializeCameras() async {
    try {
      cameras = await availableCameras();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing cameras: $e');
    }
  }

  Future<void> _fetchCollectionPoints() async {
    setState(() {
      _isLoadingShops = true;
      _errorMessage = null;
    });

    try {
      print('🚀 Fetching collection points from API...');
      
      final response = await _apiService.getCollectionPoints(
        page: 1,
        limit: 20,
      );
      
      print('📥 Raw API Response: $response');

      if (response == null) {
        throw Exception('ບໍ່ໄດ້ຮັບຂໍ້ມູນຈາກເຊີເວີ');
      }

      // Parse response with error handling
      final collectionPointsResponse = CollectionPointsResponse.fromJson(response);
      
      print('📊 Parsed ${collectionPointsResponse.collectionPoints.length} collection points');
      
      // Convert CollectionPoints to Shops for compatibility
      final shops = <Shop>[];
      for (var cp in collectionPointsResponse.collectionPoints) {
        try {
          final shop = cp.toShop(distance: _calculateDistance(cp));
          shops.add(shop);
          print('✅ Converted point: ${cp.name} -> ${shop.name}');
        } catch (e) {
          print('⚠️ Failed to convert point ${cp.id}: $e');
          // Continue with other points
        }
      }
      
      if (mounted) {
        setState(() {
          _collectionPoints = collectionPointsResponse.collectionPoints;
          _shops = shops;
          _isLoadingShops = false;
          _errorMessage = shops.isEmpty ? 'ບໍ່ພົບຂໍ້ມູນຈຸດຮັບຊື້' : null;
        });
        
        if (shops.isNotEmpty) {
          print('✅ Successfully loaded ${shops.length} collection points');
        } else {
          print('⚠️ No valid collection points found');
        }
      }
      
    } catch (e) {
      print('❌ Error fetching collection points: $e');
      
      if (mounted) {
        setState(() {
          _collectionPoints = [];
          _shops = [];
          _isLoadingShops = false;
          _errorMessage = 'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນຈຸດຮັບຊື້ໄດ້: ${_getErrorMessage(e)}';
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorStr = error.toString();
    
    // Translate common error messages to Lao
    if (errorStr.contains('Connection refused') || errorStr.contains('Failed to connect')) {
      return 'ບໍ່ສາມາດເຊື່ອມຕໍ່ເຊີເວີໄດ້';
    } else if (errorStr.contains('timeout') || errorStr.contains('Timeout')) {
      return 'ການເຊື່ອມຕໍ່ຫມົດເວລາ';
    } else if (errorStr.contains('500') || errorStr.contains('Server error')) {
      return 'ເຊີເວີມີບັນຫາ';
    } else if (errorStr.contains('404') || errorStr.contains('Not found')) {
      return 'ບໍ່ພົບຂໍ້ມູນ';
    } else if (errorStr.contains('401') || errorStr.contains('Unauthorized')) {
      return 'ບໍ່ມີສິດເຂົ້າເຖິງ';
    }
    
    return errorStr.length > 50 ? errorStr.substring(0, 50) + '...' : errorStr;
  }

  // Calculate distance (enhanced with better mock data)
  String _calculateDistance(CollectionPoint cp) {
    try {
      // Mock distance calculation based on location
      final lat = cp.location.latitude;
      final lng = cp.location.longitude;
      
      // Default Vientiane center: 17.9757, 102.6331
      final centerLat = 17.9757;
      final centerLng = 102.6331;
      
      // Simple distance calculation (not accurate, just for demo)
      final distance = ((lat - centerLat).abs() + (lng - centerLng).abs()) * 111; // Rough km conversion
      
      if (distance < 1) {
        return '${(distance * 1000).toInt()}m';
      } else {
        return '${distance.toStringAsFixed(1)}km';
      }
    } catch (e) {
      // Fallback distances
      final distances = ['0.5km', '0.9km', '1.2km', '1.5km', '2.1km', '2.8km'];
      return distances[cp.hashCode % distances.length];
    }
  }

  // 🏠 Home Tab - Original home screen content
  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 16),
                if (cameras.isNotEmpty)
                  ScanCard(cameras: cameras)
                else
                  const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 16),
                const TipsCard(),
                const SizedBox(height: 16),
                SectionHeader(
                  title: 'ຈຸດຮັບຊື້ໃກ້ຄຽງ',
                  actionText: _collectionPoints.isNotEmpty ? 'ເບິ່ງທັງໝົດ (${_collectionPoints.length})' : null,
                  onActionTap: () {
                    // Navigate to maps tab to see all collection points
                    setState(() => _currentIndex = 2);
                  },
                ),
                const SizedBox(height: 8),
                _buildShopsList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ECO SCAN',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansLao',
              ),
            ),
            Text(
              _authService.isAuthenticated 
                ? 'ສະບາຍດີ, ${_authService.currentUser?.name ?? 'User'}'
                : 'ຄົ້ນພົບຄຸນຄ່າຈາກຂີ້ເຫຍື້ອ',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontFamily: 'NotoSansLao',
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => setState(() => _currentIndex = 3), // Navigate to profile tab
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFCE6A6),
              shape: BoxShape.circle,
            ),
            child: _authService.currentUser?.profileImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      _authService.currentUser!.profileImage!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    ),
                  )
                : _buildDefaultAvatar(),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.asset(
        'assets/images/profile.jpg',
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 36,
            height: 36,
            color: AppColors.primary,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopsList() {
    // Show loading indicator
    if (_isLoadingShops) {
      return Container(
        height: 120,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(
                'ກຳລັງໂຫຼດຂໍ້ມູນຈຸດຮັບຊື້...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'NotoSansLao',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error message
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              'ເກີດຂໍ້ຜິດພາດ',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansLao',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontFamily: 'NotoSansLao',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fetchCollectionPoints,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text(
                'ລອງໃໝ່',
                style: TextStyle(fontFamily: 'NotoSansLao'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (_shops.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.location_off_outlined,
              color: Colors.grey[400],
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'ບໍ່ພົບຈຸດຮັບຊື້',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'NotoSansLao',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ຍັງບໍ່ມີຂໍ້ມູນຈຸດຮັບຊື້ໃນພື້ນທີ່ນີ້',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontFamily: 'NotoSansLao',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchCollectionPoints,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text(
                'ລອງໃໝ່',
                style: TextStyle(fontFamily: 'NotoSansLao'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Show shops list
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _shops.length > 5 ? 5 : _shops.length, // Show max 5 items on home
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return ShopListItem(
              shop: _shops[index],
              onTap: () => _navigateToShopDetail(_shops[index]),
            );
          },
        ),
        if (_shops.length > 5) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Navigate to maps tab to see all collection points
                setState(() => _currentIndex = 2);
              },
              icon: const Icon(Icons.map_outlined, size: 16),
              label: Text(
                'ເບິ່ງທັງໝົດ ${_shops.length} ແຫ່ງ',
                style: const TextStyle(
                  fontFamily: 'NotoSansLao',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _refreshData() async {
    await _fetchCollectionPoints();
  }

  void _navigateToShopDetail(Shop shop) {
    Get.toNamed('/ShopDetailScreen', arguments: shop);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeTab(), // 🏠 Home
      const HistoryScreen(), // 📱 History
      MapsScreen(shops: _shops), // 🗺️ Maps
      const ProfileScreen(), // 👤 Profile
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'NotoSansLao',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'NotoSansLao',
            fontSize: 12,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'ໜ້າຫຼັກ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'ປະຫວັດ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'ແຜນທີ່',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'ໂປຣໄຟລ໌',
            ),
          ],
        ),
      ),
    );
  }
}