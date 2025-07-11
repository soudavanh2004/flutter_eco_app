import 'dart:convert';
import 'package:get/get.dart';
import '../models/user.dart';
import '../models/login_response.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();
  
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService.instance;
  
  // Reactive variables
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isAuthenticated = false.obs;
  final RxBool _isLoading = false.obs;

  // Getters
  User? get currentUser => _currentUser.value;
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoading => _isLoading.value;
  
  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadStoredAuth();
  }

  /// Load stored authentication data on app start
  Future<void> _loadStoredAuth() async {
    try {
      _isLoading.value = true;
      
      final token = await _storageService.getString(_tokenKey);
      final userData = await _storageService.getString(_userKey);
      
      if (token != null && userData != null) {
        _apiService.setAuthToken(token);
        final userMap = json.decode(userData) as Map<String, dynamic>;
        _currentUser.value = User.fromJson(userMap);
        _isAuthenticated.value = true;
        await _verifyToken();
      }
    } catch (e) {
      print('Failed to load stored auth: $e');
      await logout();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Verify if current token is still valid
  Future<bool> _verifyToken() async {
    try {
      if (!_isAuthenticated.value) return false;
      await _apiService.getProfile();
      return true;
    } catch (e) {
      print('Token verification failed: $e');
      await logout();
      return false;
    }
  }

  /// Register new user - แค่สร้าง account (ไม่ต้อง login)
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? address,
  }) async {
    try {
      _isLoading.value = true;
      print('🚀 Starting registration...');

      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );

      print('📥 Register API Response: $response');

      // Check response
      if (response == null || response is! Map<String, dynamic>) {
        throw Exception('Invalid response from server');
      }

      // สร้าง User object จาก response (ไม่ต้องมี access_token)
      final user = User.fromJson(response);
      
      print('✅ Registration successful - User created: ${user.name} (${user.email})');
      print('🔄 User needs to login separately');
      
      return user;
    } catch (e) {
      print('❌ Registration failed: $e');
      // ดู response ที่แท้จริง
      print('Raw error: ${e.toString()}');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Login user - ได้ access_token
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading.value = true;
      print('🚀 Starting login...');

      final response = await _apiService.login(
        email: email,
        password: password,
      );

      print('📥 Login Response: $response');

      // Check response format
      if (response == null || response is! Map<String, dynamic>) {
        throw Exception('Invalid response from server');
      }

      // Check if login response has access_token
      if (!response.containsKey('access_token')) {
        throw Exception('Login failed: No access token received');
      }

      if (!response.containsKey('user')) {
        throw Exception('Login failed: No user data received');
      }

      final loginResponse = LoginResponse.fromJson(response);
      await _setAuthData(loginResponse);
      
      print('✅ Login successful - Welcome ${loginResponse.user.name}!');
      return loginResponse;
    } catch (e) {
      print('❌ Login failed: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Set authentication data after successful login
  Future<void> _setAuthData(LoginResponse loginResponse) async {
    try {
      // Set token in API service
      _apiService.setAuthToken(loginResponse.accessToken);
      
      // Store in local storage
      await _storageService.setString(_tokenKey, loginResponse.accessToken);
      await _storageService.setString(_userKey, json.encode(loginResponse.user.toJson()));
      
      // Update reactive state
      _currentUser.value = loginResponse.user;
      _isAuthenticated.value = true;
      
      print('✅ Authentication data saved successfully');
    } catch (e) {
      print('❌ Failed to save authentication data: $e');
      rethrow;
    }
  }

  /// Get current user profile (requires authentication)
  Future<User> getProfile() async {
    try {
      if (!_isAuthenticated.value) {
        throw Exception('User not authenticated');
      }

      final response = await _apiService.getProfile();
      final user = User.fromJson(response);
      
      // Update stored user data
      _currentUser.value = user;
      await _storageService.setString(_userKey, json.encode(user.toJson()));
      
      return user;
    } catch (e) {
      print('Get profile failed: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<User> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      if (!_isAuthenticated.value) {
        throw Exception('User not authenticated');
      }

      _isLoading.value = true;

      final response = await _apiService.updateProfile(
        name: name,
        phone: phone,
        address: address,
      );

      final user = User.fromJson(response);
      
      // Update stored user data
      _currentUser.value = user;
      await _storageService.setString(_userKey, json.encode(user.toJson()));
      
      return user;
    } catch (e) {
      print('Update profile failed: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      
      // Call logout API if authenticated
      if (_isAuthenticated.value) {
        try {
          await _apiService.logout();
        } catch (e) {
          print('API logout failed: $e');
          // Continue with local logout even if API fails
        }
      }
      
      // Clear stored data
      await _storageService.remove(_tokenKey);
      await _storageService.remove(_userKey);
      
      // Clear API service token
      _apiService.clearAuthToken();
      
      // Clear reactive variables
      _currentUser.value = null;
      _isAuthenticated.value = false;
      
      print('✅ Logout completed');
    } catch (e) {
      print('❌ Logout failed: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return _currentUser.value?.role.toLowerCase() == role.toLowerCase();
  }

  /// Check if user is admin
  bool get isAdmin => hasRole('admin');

  /// Check if user is active
  bool get isActive => _currentUser.value?.status.toLowerCase() == 'active';

  /// Force refresh authentication state
  Future<void> refreshAuth() async {
    if (_isAuthenticated.value) {
      await getProfile();
    }
  }

  /// Get current auth token
  String? get authToken => _apiService.authToken;

  // ===== VALIDATION HELPERS =====

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone format (basic validation)
  static bool isValidPhone(String phone) {
    return phone.length >= 8 && RegExp(r'^[0-9+\-\s]+$').hasMatch(phone);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Get password strength description
  static String getPasswordStrength(String password) {
    if (password.length < 6) return 'Too short';
    if (password.length < 8) return 'Weak';
    if (password.contains(RegExp(r'[A-Z]')) && 
        password.contains(RegExp(r'[a-z]')) && 
        password.contains(RegExp(r'[0-9]'))) {
      return 'Strong';
    }
    return 'Medium';
  }
}