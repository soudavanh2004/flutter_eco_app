

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:path/path.dart' as path;
import '../models/detection_result.dart';
import '../utils/constants.dart';
import '../utils/image_utils.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Token management
  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  bool get isAuthenticated => _authToken != null;

  // Getter for auth token
  String? get authToken => _authToken;

  // API Methods for Scanning and History

  static Future<bool> checkHealth() async {
    try {
      Constants.debugUrl();
      final String healthUrl = Constants.getUrl(Constants.health);
      print('Making request to: $healthUrl');
      
      final response = await http.get(
        Uri.parse(healthUrl),
        headers: Constants.defaultHeaders,
      ).timeout(Constants.healthCheckTimeout);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  static Future<bool> loadModel() async {
    try {
      final String loadModelUrl = Constants.getUrl('/api/load-model');
      final response = await http.post(
        Uri.parse(loadModelUrl),
        headers: Constants.defaultHeaders,
      ).timeout(Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('Model load failed: $e');
      return false;
    }
  }

  static Future<DetectionResult> detectWaste({
    required File imageFile,
    required bool saveToHistory,
    required double confidenceThreshold,
    required String userId,
  }) async {
    try {
      Constants.debugUrl();
      final String detectUrl = Constants.getUrl('/api/detect-waste');
      print('Making waste detection request to: $detectUrl');

      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist: ${imageFile.path}');
      }
      if (!ImageUtils.isImageFile(imageFile.path)) {
        throw Exception('Unsupported image format: ${path.extension(imageFile.path)}');
      }

      await ImageUtils.checkImageFileSize(imageFile);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(detectUrl),
      );

      request.headers.addAll(_instance.isAuthenticated
          ? Constants.authHeaders(_instance._authToken!)
          : Constants.defaultHeaders);

      final String fileExtension = path.extension(imageFile.path);
      final String contentType = ImageUtils.getContentType(fileExtension);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: http_parser.MediaType.parse(contentType),
        ),
      );

      request.fields['save_to_history'] = saveToHistory.toString();
      request.fields['confidence_threshold'] = confidenceThreshold.toString();
      request.fields['user_id'] = userId;

      print('Sending file: ${imageFile.path}');
      print('Content-Type: $contentType');
      print('Fields: ${request.fields}');

      final streamedResponse = await request.send().timeout(Constants.requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('Detection response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return DetectionResult.fromApiResponse(jsonData);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Failed to connect to server');
      } else if (e is TimeoutException) {
        throw Exception('Request timed out after ${Constants.requestTimeout.inSeconds} seconds');
      }
      throw Exception('Waste detection failed: $e');
    }
  }

  Future<List<ScanHistory>> getScanHistory({
    int? page,
    int? limit,
  }) async {
    try {
      String url = Constants.getUrl('/api/scan-history');
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      if (queryParams.isNotEmpty) {
        url += '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      final response = await _get(url, requireAuth: true);
      final List<dynamic> historyJson = response['data'] ?? [];
      return historyJson.map((json) => ScanHistory.fromApiResponse(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteScan(String scanId) async {
    try {
      final url = Constants.getUrl('/api/scan-history/$scanId');
      await _delete(url, requireAuth: true);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Existing Auth and Other Methods (Unchanged)
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? address,
  }) async {
    final url = Constants.getUrl(Constants.authRegister);
    
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address ?? '',
    };

    print('📤 Register Request Body: $body');
    return await _post(url, body: body);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Constants.getUrl(Constants.authLogin);
    
    final body = {
      'email': email,
      'password': password,
    };

    print('📤 Login Request Body: $body');
    final response = await _post(url, body: body);
    
    if (response.containsKey('access_token')) {
      setAuthToken(response['access_token']);
    }
    
    return response;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final url = Constants.getUrl(Constants.authProfile);
    return await _get(url, requireAuth: true);
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final url = Constants.getUrl(Constants.authUpdateProfile);
    
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (address != null) body['address'] = address;

    return await _put(url, body: body, requireAuth: true);
  }

  Future<void> logout() async {
    final url = Constants.getUrl(Constants.authLogout);
    await _post(url, requireAuth: true);
    clearAuthToken();
  }

  Future<Map<String, dynamic>> getCollectionPoints({
    int? page,
    int? limit,
  }) async {
    String url = Constants.getUrl(Constants.collectionPoints);
    
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    
    if (queryParams.isNotEmpty) {
      url += '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    }

    return await _get(url);
  }

  Future<Map<String, dynamic>> getNearbyCollectionPoints({
    required double latitude,
    required double longitude,
    double? radius,
  }) async {
    String url = Constants.getUrl(Constants.nearbyCollectionPoints);
    
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (radius != null) 'radius': radius.toString(),
    };
    
    url += '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    return await _get(url);
  }

  Future<Map<String, dynamic>> getCollectionPoint(String pointId) async {
    final url = Constants.getUrl(
      Constants.replacePathParams(Constants.getCollectionPoint, {'point_id': pointId})
    );
    return await _get(url);
  }

  Future<Map<String, dynamic>> createCollectionPoint({
    required String name,
    required String ownerName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required String district,
    required String village,
    required List<String> wasteTypes,
    required String openingHours,
    required double pricePerKg,
  }) async {
    final url = Constants.getUrl(Constants.collectionPoints);
    
    final body = {
      'name': name,
      'owner_name': ownerName,
      'phone': phone,
      'address': address,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'district': district,
      'village': village,
      'waste_types': wasteTypes,
      'opening_hours': openingHours,
      'price_per_kg': pricePerKg,
    };

    return await _post(url, body: body, requireAuth: true);
  }

  Future<Map<String, dynamic>> getWasteCategories() async {
    final url = Constants.getUrl(Constants.wasteCategories);
    return await _get(url);
  }

  Future<Map<String, dynamic>> getActiveWasteCategories() async {
    final url = Constants.getUrl(Constants.activeWasteCategories);
    return await _get(url);
  }

  Future<Map<String, dynamic>> getWasteCategory(String categoryId) async {
    final url = Constants.getUrl(
      Constants.replacePathParams(Constants.getWasteCategory, {'category_id': categoryId})
    );
    return await _get(url);
  }

  Future<Map<String, dynamic>> getCategoryPricing(String categoryId) async {
    final url = Constants.getUrl(
      Constants.replacePathParams(Constants.getCategoryPricing, {'category_id': categoryId})
    );
    return await _get(url);
  }

  Future<Map<String, dynamic>> getMyPurchases() async {
    final url = Constants.getUrl(Constants.getMyPurchases);
    return await _get(url, requireAuth: true);
  }

  Future<Map<String, dynamic>> createPurchase({
    required String categoryId,
    required double weight,
    required double totalPrice,
    String? notes,
  }) async {
    final url = Constants.getUrl(Constants.createPurchase);
    
    final body = {
      'category_id': categoryId,
      'weight': weight,
      'total_price': totalPrice,
      if (notes != null) 'notes': notes,
    };

    return await _post(url, body: body, requireAuth: true);
  }

  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    final url = Constants.getUrl(Constants.uploadProfileImage);
    return await _uploadFile(url, imageFile, 'file', requireAuth: true);
  }

  Future<Map<String, dynamic>> uploadWasteImage(File imageFile) async {
    final url = Constants.getUrl(Constants.uploadWasteImage);
    return await _uploadFile(url, imageFile, 'file', requireAuth: true);
  }

  Future<Map<String, dynamic>> _get(String url, {bool requireAuth = false}) async {
    try {
      final headers = requireAuth ? Constants.authHeaders(_authToken!) : Constants.defaultHeaders;
      
      print('📡 GET $url');
      print('📤 Headers: $headers');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(Constants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> _post(String url, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    try {
      final headers = requireAuth ? Constants.authHeaders(_authToken!) : Constants.defaultHeaders;
      
      print('📡 POST $url');
      print('📤 Headers: $headers');
      print('📤 Body: $body');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(Constants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> _put(String url, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    try {
      final headers = requireAuth ? Constants.authHeaders(_authToken!) : Constants.defaultHeaders;
      
      print('📡 PUT $url');
      print('📤 Headers: $headers');
      print('📤 Body: $body');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(Constants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> _delete(String url, {bool requireAuth = false}) async {
    try {
      final headers = requireAuth ? Constants.authHeaders(_authToken!) : Constants.defaultHeaders;
      
      print('📡 DELETE $url');
      print('📤 Headers: $headers');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(Constants.requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> _uploadFile(
    String url,
    File file,
    String fieldName, {
    bool requireAuth = false,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      if (requireAuth) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      request.headers.addAll(Constants.multipartHeaders);

      final String fileExtension = path.extension(file.path);
      final String contentType = ImageUtils.getContentType(fileExtension);
      
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: http_parser.MediaType.parse(contentType),
        ),
      );

      final streamedResponse = await request.send().timeout(Constants.requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;
    final String body = response.body;

    print('📥 API Response - Status: $statusCode');
    print('📥 Response Body: $body');

    if (statusCode >= 200 && statusCode < 300) {
      try {
        return json.decode(body) as Map<String, dynamic>;
      } catch (e) {
        print('❌ Failed to parse response JSON: $e');
        throw Exception('Failed to parse response JSON: $e');
      }
    } else {
      try {
        final errorData = json.decode(body) as Map<String, dynamic>;
        final message = errorData['detail'] ?? errorData['message'] ?? 'Server error';
        print('❌ API Error ($statusCode): $message');
        throw Exception('API Error ($statusCode): $message');
      } catch (e) {
        print('❌ Server error ($statusCode): $body');
        throw Exception('Server error ($statusCode): $body');
      }
    }
  }

  Exception _handleError(dynamic error) {
    if (error is SocketException) {
      return Exception('Network error: Failed to connect to server');
    } else if (error is TimeoutException) {
      return Exception('Request timed out after ${Constants.requestTimeout.inSeconds} seconds');
    } else if (error is Exception) {
      return error;
    } else {
      return Exception('Unexpected error: $error');
    }
  }
}