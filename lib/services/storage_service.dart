// import 'dart:io';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:front_end_ecoapp_new/models/detection_result.dart';
// import 'package:front_end_ecoapp_new/services/api_service.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
// import '../utils/constants.dart';
// import '../utils/image_utils.dart';

// class StorageService {
//   // Singleton pattern
//   static final StorageService instance = StorageService._internal();
//   StorageService._internal();

//   static SharedPreferences? _prefs;

//   // Initialize SharedPreferences
//   static Future<void> init() async {
//     _prefs ??= await SharedPreferences.getInstance();
//   }

//   // ===== KEY-VALUE STORAGE METHODS (สำหรับ Auth) =====
  
//   Future<String?> getString(String key) async {
//     await init();
//     return _prefs?.getString(key);
//   }

//   Future<bool> setString(String key, String value) async {
//     await init();
//     return await _prefs?.setString(key, value) ?? false;
//   }

//   Future<bool> remove(String key) async {
//     await init();
//     return await _prefs?.remove(key) ?? false;
//   }

//   Future<bool> getBool(String key, {bool defaultValue = false}) async {
//     await init();
//     return _prefs?.getBool(key) ?? defaultValue;
//   }

//   Future<bool> setBool(String key, bool value) async {
//     await init();
//     return await _prefs?.setBool(key, value) ?? false;
//   }

//   Future<bool> clear() async {
//     await init();
//     return await _prefs?.clear() ?? false;
//   }

//   Future<bool> containsKey(String key) async {
//     await init();
//     return _prefs?.containsKey(key) ?? false;
//   }

//   // ===== ORIGINAL IMAGE STORAGE METHODS =====
  
//   static Future<Directory> _createImageDirectory() async {
//     try {
//       final Directory appDocDir = await getApplicationDocumentsDirectory();
//       final Directory imageDir = Directory(path.join(appDocDir.path, 'captured_images'));
      
//       if (!await imageDir.exists()) {
//         await imageDir.create(recursive: true);
//       }
      
//       return imageDir;
//     } catch (e) {
//       throw Exception('Failed to create image directory: $e');
//     }
//   }

//   static Future<File> saveImageToPermanentStorage(File tempImageFile) async {
//     try {
//       final Directory imageDir = await _createImageDirectory();
//       final String timestamp = DateTime.now().toIso8601String();
//       final String fileName = 'captured_$timestamp.jpg';  
//       final String permanentPath = path.join(imageDir.path, fileName);
      
//       final File permanentFile = await tempImageFile.copy(permanentPath);
//       print('Image saved to: $permanentPath');
//       return permanentFile;
//     } catch (e) {
//       throw Exception('Error saving image: $e');
//     }
//   }

//   static Future<List<File>> getSavedImages() async {
//     try {
//       final Directory imageDir = await _createImageDirectory();
//       final List<FileSystemEntity> files = await imageDir.list().toList();
      
//       return files
//           .whereType<File>()
//           .where((file) => ImageUtils.isImageFile(file.path))
//           .toList()
//         ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
//     } catch (e) {
//       print('Error getting saved images: $e');
//       return [];
//     }
//   }

//   static Future<void> cleanupOldImages() async {
//     try {
//       final List<File> savedImages = await getSavedImages();
      
//       if (savedImages.length > Constants.maxSavedImages) {
//         final List<File> oldImages = savedImages.skip(Constants.maxSavedImages).toList();
        
//         for (File oldImage in oldImages) {
//           await oldImage.delete();
//           print('Deleted old image: ${oldImage.path}');
//         }
//       }
//     } catch (e) {
//       print('Error cleaning up old images: $e');
//     }
//   }

//   static Future<DetectionResult> processAndDetectImage(File tempImageFile) async {
//     try {
//       final File permanentImageFile = await saveImageToPermanentStorage(tempImageFile);
//       await cleanupOldImages();
//       return await ApiService.detectObjects(permanentImageFile);
//     } catch (e) {
//       throw Exception('Error processing image: $e');
//     }
//   }
// }

import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../utils/constants.dart';
import '../utils/image_utils.dart';

class StorageService {
  // Singleton pattern
  static final StorageService instance = StorageService._internal();
  StorageService._internal();

  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ===== KEY-VALUE STORAGE METHODS (สำหรับ Auth) =====
  
  Future<String?> getString(String key) async {
    await init();
    return _prefs?.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    await init();
    return await _prefs?.setString(key, value) ?? false;
  }

  Future<bool> remove(String key) async {
    await init();
    return await _prefs?.remove(key) ?? false;
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    await init();
    return _prefs?.getBool(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) async {
    await init();
    return await _prefs?.setBool(key, value) ?? false;
  }

  Future<bool> clear() async {
    await init();
    return await _prefs?.clear() ?? false;
  }

  Future<bool> containsKey(String key) async {
    await init();
    return _prefs?.containsKey(key) ?? false;
  }

  // ===== IMAGE STORAGE METHODS =====
  
  static Future<Directory> _createImageDirectory() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory(path.join(appDocDir.path, 'captured_images'));
      
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      return imageDir;
    } catch (e) {
      throw Exception('Failed to create image directory: $e');
    }
  }

  static Future<File> saveImageToPermanentStorage(File tempImageFile) async {
    try {
      final Directory imageDir = await _createImageDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(tempImageFile.path).toLowerCase();
      if (!ImageUtils.isImageFile(tempImageFile.path)) {
        throw Exception('Unsupported image format: $extension');
      }
      final String fileName = 'captured_$timestamp$extension';  
      final String permanentPath = path.join(imageDir.path, fileName);
      
      final File permanentFile = await tempImageFile.copy(permanentPath);
      print('Image saved to: $permanentPath');
      return permanentFile;
    } catch (e) {
      throw Exception('Error saving image: $e');
    }
  }

  static Future<String> getImagesDirectory() async {
    return path.join(await getApplicationDocumentsDirectory().then((dir) => dir.path), 'captured_images');
  }

  static Future<List<File>> getSavedImages() async {
    try {
      final Directory imageDir = await _createImageDirectory();
      final List<FileSystemEntity> files = await imageDir.list().toList();
      
      return files
          .whereType<File>()
          .where((file) => ImageUtils.isImageFile(file.path))
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    } catch (e) {
      print('Error getting saved images: $e');
      return [];
    }
  }

  static Future<void> cleanupOldImages() async {
    try {
      final List<File> savedImages = await getSavedImages();
      
      if (savedImages.length > Constants.maxSavedImages) {
        final List<File> oldImages = savedImages.skip(Constants.maxSavedImages).toList();
        
        for (File oldImage in oldImages) {
          await oldImage.delete();
          print('Deleted old image: ${oldImage.path}');
        }
      }
    } catch (e) {
      print('Error cleaning up old images: $e');
    }
  }
}

