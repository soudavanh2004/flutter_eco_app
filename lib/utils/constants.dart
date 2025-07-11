// class Constants {
//   // Server Configuration
//   static const String _baseIP = '192.168.100.81'; // ✅ IP ที่ถูกต้อง
// static const String _port = '8001'; // ✅ Port separately
// static const String baseUrl = 'http://$_baseIP:$_port'; // ✅ Correct format
  
//   // File Upload Settings
//   static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
//   static const Duration requestTimeout = Duration(seconds: 30);
//   static const Duration healthCheckTimeout = Duration(seconds: 10);
//   static const int maxSavedImages = 50;

//   static const List<String> supportedFormats = [
//     '.jpg',
//     '.jpeg',
//     '.png',
//     '.webp',
//     '.bmp',
//     '.tiff',
//   ];

//   // ===== NEW ECO SCAN API ENDPOINTS =====
  
//   // Authentication Endpoints
//   static const String authRegister = '/api/auth/register';
//   static const String authLogin = '/api/auth/login';
//   static const String authProfile = '/api/auth/profile';
//   static const String authUpdateProfile = '/api/auth/profile';
//   static const String authChangePassword = '/api/auth/change-password';
//   static const String authLogout = '/api/auth/logout';
//   static const String authVerifyToken = '/api/auth/verify-token';

//   // User Management Endpoints
//   static const String getAllUsers = '/';
//   static const String getUserById = '/{user_id}';
//   static const String updateUserById = '/{user_id}';
//   static const String deleteUser = '/{user_id}';
//   static const String updateUserStatus = '/{user_id}/status';
//   static const String updateUserRole = '/{user_id}/role';
//   static const String getUserStats = '/stats/summary';

//   // Collection Points Endpoints
//   static const String collectionPoints = '/api/collection-points/';
//   static const String nearbyCollectionPoints = '/api/collection-points/nearby';
//   static const String collectionPointStats = '/api/collection-points/stats';
//   static const String getCollectionPoint = '/api/collection-points/{point_id}';
//   static const String updateCollectionPoint = '/api/collection-points/{point_id}';
//   static const String deleteCollectionPoint = '/api/collection-points/{point_id}';
//   static const String toggleCollectionPointStatus = '/api/collection-points/{point_id}/status';

//   // Waste Categories Endpoints
//   static const String wasteCategories = '/api/waste-categories/';
//   static const String activeWasteCategories = '/api/waste-categories/active';
//   static const String getWasteCategory = '/api/waste-categories/{category_id}';
//   static const String updateWasteCategory = '/api/waste-categories/{category_id}';
//   static const String deleteWasteCategory = '/api/waste-categories/{category_id}';
//   static const String toggleWasteCategoryStatus = '/api/waste-categories/{category_id}/status';
//   static const String getCategoryPricing = '/api/waste-categories/{category_id}/pricing';

//   // Purchase History Endpoints
//   static const String createPurchase = '/api/purchases/';
//   static const String getPurchaseHistory = '/api/purchases/';
//   static const String getMyPurchases = '/api/purchases/my-purchases';
//   static const String getPurchaseStats = '/api/purchases/stats';
//   static const String getPurchase = '/api/purchases/{purchase_id}';
//   static const String updatePurchase = '/api/purchases/{purchase_id}';
//   static const String deletePurchase = '/api/purchases/{purchase_id}';
//   static const String updatePurchaseStatus = '/api/purchases/{purchase_id}/status';

//   // File Upload Endpoints
//   static const String testStorage = '/api/files/test-storage';
//   static const String testFileRoute = '/api/files/test';
//   static const String uploadProfileImage = '/api/files/upload-profile-image';
//   static const String uploadWasteImage = '/api/files/upload-waste-image';
//   static const String deleteFile = '/api/files/{cloudinary_id}';

//   // Health Check Endpoints (Original + New)
//   static const String health = '/health';
//   static const String testFirebase = '/api/test-firebase';
//   static const String debugRoutes = '/api/debug-routes';

//   // Detection Endpoint (Original)
//   static const String detect = '/detect';

//   // ===== HELPER METHODS =====
  
//   /// Get full URL for endpoint
//   static String getUrl(String endpoint) {
//     return '$baseUrl$endpoint';
//   }

//   /// Replace path parameters in endpoint
//   static String replacePathParams(String endpoint, Map<String, String> params) {
//     String result = endpoint;
//     params.forEach((key, value) {
//       result = result.replaceAll('{$key}', value);
//     });
//     return result;
//   }

//   /// Debug URL information
//   static void debugUrl() {
//     print('=== ECO SCAN API DEBUG ===');
//     print('Base IP: $_baseIP');
//     print('Port: $_port');
//     print('Full URL: $baseUrl');
//     print('Health URL: ${getUrl(health)}');
//     print('Login URL: ${getUrl(authLogin)}');
//     print('Collection Points URL: ${getUrl(collectionPoints)}');
//     print('Waste Categories URL: ${getUrl(wasteCategories)}');
//     print('==========================');
//   }

//   // ===== HTTP HEADERS =====
  
//   static Map<String, String> get defaultHeaders => {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };

//   static Map<String, String> authHeaders(String token) => {
//     ...defaultHeaders,
//     'Authorization': 'Bearer $token',
//   };

//   static Map<String, String> get multipartHeaders => {
//     'Accept': 'application/json',
//   };
// }

class Constants {
  // Server Configuration
  static const String _baseIP = '192.168.100.128'; // ✅ IP ที่ถูกต้อง
  static const String _port = '8001'; // ✅ Port separately
  static const String baseUrl = 'http://$_baseIP:$_port'; // ✅ Correct format
  
  // File Upload Settings
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration healthCheckTimeout = Duration(seconds: 10);
  static const int maxSavedImages = 50;

  static const List<String> supportedFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.bmp',
    '.tiff',
  ];

  // ===== NEW ECO SCAN API ENDPOINTS =====
  
  // Authentication Endpoints
  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authProfile = '/api/auth/profile';
  static const String authUpdateProfile = '/api/auth/profile';
  static const String authChangePassword = '/api/auth/change-password';
  static const String authLogout = '/api/auth/logout';
  static const String authVerifyToken = '/api/auth/verify-token';

  // User Management Endpoints
  static const String getAllUsers = '/';
  static const String getUserById = '/{user_id}';
  static const String updateUserById = '/{user_id}';
  static const String deleteUser = '/{user_id}';
  static const String updateUserStatus = '/{user_id}/status';
  static const String updateUserRole = '/{user_id}/role';
  static const String getUserStats = '/stats/summary';

  // Collection Points Endpoints
  static const String collectionPoints = '/api/collection-points/';
  static const String nearbyCollectionPoints = '/api/collection-points/nearby';
  static const String collectionPointStats = '/api/collection-points/stats';
  static const String getCollectionPoint = '/api/collection-points/{point_id}';
  static const String updateCollectionPoint = '/api/collection-points/{point_id}';
  static const String deleteCollectionPoint = '/api/collection-points/{point_id}';
  static const String toggleCollectionPointStatus = '/api/collection-points/{point_id}/status';

  // Waste Categories Endpoints
  static const String wasteCategories = '/api/waste-categories/';
  static const String activeWasteCategories = '/api/waste-categories/active';
  static const String getWasteCategory = '/api/waste-categories/{category_id}';
  static const String updateWasteCategory = '/api/waste-categories/{category_id}';
  static const String deleteWasteCategory = '/api/waste-categories/{category_id}';
  static const String toggleWasteCategoryStatus = '/api/waste-categories/{category_id}/status';
  static const String getCategoryPricing = '/api/waste-categories/{category_id}/pricing';

  // Purchase History Endpoints
  static const String createPurchase = '/api/purchases/';
  static const String getPurchaseHistory = '/api/purchases/';
  static const String getMyPurchases = '/api/purchases/my-purchases';
  static const String getPurchaseStats = '/api/purchases/stats';
  static const String getPurchase = '/api/purchases/{purchase_id}';
  static const String updatePurchase = '/api/purchases/{purchase_id}';
  static const String deletePurchase = '/api/purchases/{purchase_id}';
  static const String updatePurchaseStatus = '/api/purchases/{purchase_id}/status';

  // File Upload Endpoints
  static const String testStorage = '/api/files/test-storage';
  static const String testFileRoute = '/api/files/test';
  static const String uploadProfileImage = '/api/files/upload-profile-image';
  static const String uploadWasteImage = '/api/files/upload-waste-image';
  static const String deleteFile = '/api/files/{cloudinary_id}';

  // Health Check Endpoints (Original + New)
  static const String health = '/health';
  static const String testFirebase = '/api/test-firebase';
  static const String debugRoutes = '/api/debug-routes';

  // Detection Endpoint (Original)
  static const String detect = '/detect';

  // ===== HELPER METHODS =====
  
  /// Get full URL for endpoint
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Replace path parameters in endpoint
  static String replacePathParams(String endpoint, Map<String, String> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  /// Debug URL information
  static void debugUrl() {
    print('=== ECO SCAN API DEBUG ===');
    print('Base IP: $_baseIP');
    print('Port: $_port');
    print('Full URL: $baseUrl');
    print('Health URL: ${getUrl(health)}');
    print('Login URL: ${getUrl(authLogin)}');
    print('Collection Points URL: ${getUrl(collectionPoints)}');
    print('Waste Categories URL: ${getUrl(wasteCategories)}');
    print('==========================');
  }

  // ===== HTTP HEADERS =====
  
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
  };
}