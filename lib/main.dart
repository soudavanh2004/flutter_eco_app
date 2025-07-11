import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
// import 'package:firebase_core/firebase_core.dart'; // Comment ออกก่อน
import 'package:front_end_ecoapp_new/screens/home/components/app_strings.dart';
import 'package:front_end_ecoapp_new/screens/home/components/shop_list_item.dart';
import 'package:front_end_ecoapp_new/screens/shop/ShopDetailScreen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/scan/scan_screen.dart' hide HomeScreen, ShopDetailScreen;

// เพิ่ม Services
import 'services/auth_service.dart';
import 'services/storage_service.dart';

import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Comment Firebase ออกชั่วคราว
  // await Firebase.initializeApp();
  
  // Initialize StorageService

  
  // Initialize GetX Services
  await initServices();

// void _processImage(CameraImage image) async {
//   final results = await tfliteService!.processImage(image);
//   if (results != null) {
//     setState(() {
//       recognitions = results;
//       FirebaseFirestore.instance.collection('detections').add({
//         'objects': results.map((r) => r['detectedClass']).toList(),
//         'timestamp': DateTime.now(),
//       });
//     });
//   }
// }

  // Initialize cameras for YOLOv8n
  final cameras = await availableCameras();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(MyApp(cameras: cameras));
}

/// Initialize all GetX services
Future<void> initServices() async {
  print('🚀 Initializing GetX Services...');
  
  // Initialize AuthService
  Get.put(AuthService(), permanent: true);
  
  print('✅ All services initialized');
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/signin', page: () => const SignInScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/scan', page: () => const ScanScreen()),
        GetPage(name: '/ShopDetailScreen', page: () => const ShopDetailScreen()),
      ],
      onGenerateRoute: (settings) {
        if (settings.name == '/shop_detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return GetPageRoute(
            page: () => ShopListItem(shop: args['shopId'], onTap: () {}),
          );
        }
        return null;
      },
    );
  }
}