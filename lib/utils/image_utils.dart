// import 'dart:io';
// import 'package:path/path.dart' as path;
// import 'constants.dart';

// class ImageUtils {
//   static bool isImageFile(String filePath) {
//     final String extension = path.extension(filePath).toLowerCase();
//     return Constants.supportedFormats.contains(extension);
//   }

//   static String getContentType(String fileExtension) {
//     const supportedTypes = {
//       '.png': 'image/png',
//       '.webp': 'image/webp',
//       '.bmp': 'image/bmp',
//       '.tiff': 'image/tiff',
//       '.jpg': 'image/jpeg',
//       '.jpeg': 'image/jpeg',
//     };
//     return supportedTypes[fileExtension.toLowerCase()] ?? 'image/jpeg';
//   }

//   static Future<void> checkImageFileSize(File imageFile) async {
//     try {
//       final int fileSize = await imageFile.length();
//       final double fileSizeInMB = fileSize / 1024 / 1024;
      
//       print('Image file size: ${fileSizeInMB.toStringAsFixed(2)} MB');
      
//       if (fileSize > Constants.maxFileSizeBytes) {
//         throw Exception(
//           'Image file too large: ${fileSizeInMB.toStringAsFixed(2)} MB. '
//           'Maximum allowed size is ${Constants.maxFileSizeBytes / 1024 / 1024}MB.'
//         );
//       }
//     } catch (e) {
//       if (e is FileSystemException) {
//         throw Exception('Error accessing file: ${e.message}');
//       }
//       rethrow;
//     }
//   }
// }

import 'dart:io';
import 'package:path/path.dart' as path;
import 'constants.dart';

class ImageUtils {
  static bool isImageFile(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();
    return Constants.supportedFormats.contains(extension);
  }

  static String getContentType(String fileExtension) {
    const supportedTypes = {
      '.png': 'image/png',
      '.webp': 'image/webp',
      '.bmp': 'image/bmp',
      '.tiff': 'image/tiff',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
    };
    return supportedTypes[fileExtension.toLowerCase()] ?? 'image/jpeg';
  }

  static Future<void> checkImageFileSize(File imageFile) async {
    try {
      final int fileSize = await imageFile.length();
      final double fileSizeInMB = fileSize / 1024 / 1024;
      
      print('Image file size: ${fileSizeInMB.toStringAsFixed(2)} MB');
      
      if (fileSize > Constants.maxFileSizeBytes) {
        throw Exception(
          'Image file too large: ${fileSizeInMB.toStringAsFixed(2)} MB. '
          'Maximum allowed size is ${Constants.maxFileSizeBytes / 1024 / 1024}MB.'
        );
      }
    } catch (e) {
      if (e is FileSystemException) {
        throw Exception('Error accessing file: ${e.message}');
      }
      rethrow;
    }
  }
}