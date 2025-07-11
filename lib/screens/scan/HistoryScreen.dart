
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:front_end_ecoapp_new/screens/home/home_screen.dart';
import 'package:front_end_ecoapp_new/services/storage_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
          'ປະຫວັດການສະແກນ',
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
      body: FutureBuilder<List<File>>(
        future: StorageService.getSavedImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'ກຳລັງໂຫຼດຮູບພາບ...', // "Loading images..."
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ຜິດພາດ: ${snapshot.error}', // "Error: ${snapshot.error}"
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger rebuild to retry
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('ລອງໃໝ່'), // "Try Again"
                  ),
                ],
              ),
            );
          }
          
          final images = snapshot.data ?? [];
          
          if (images.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ຍັງບໍ່ມີຮູບພາບທີ່ບັນທຶກ', // "No saved images yet"
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ກົດຖ່າຍຮູບເພື່ອເລີ່ມຕົ້ນ', // "Take a photo to get started"
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return _buildImageCard(context, image, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, File image, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showImageDialog(context, image);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ຮູບທີ ${index + 1}', // "Image ${index + 1}"
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getImageDate(image),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getImageDate(File image) {
    try {
      final stat = image.statSync();
      final modified = stat.modified;
      return '${modified.day}/${modified.month}/${modified.year}';
    } catch (e) {
      return 'ບໍ່ຮູ້ວັນທີ'; // "Unknown date"
    }
  }

  void _showImageDialog(BuildContext context, File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('ເບິ່ງຮູບພາບ'), // "View Image"
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteConfirmation(context, image);
                    },
                  ),
                ],
              ),
              Flexible(
                child: InteractiveViewer(
                  child: Image.file(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('ບໍ່ສາມາດໂຫຼດຮູບພາບໄດ້'), // "Cannot load image"
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ລຶບຮູບພາບ'), // "Delete Image"
          content: const Text('ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການລຶບຮູບພາບນີ້?'), // "Are you sure you want to delete this image?"
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ຍົກເລີກ'), // "Cancel"
            ),
            TextButton(
              onPressed: () async {
                try {
                  await image.delete();
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close confirmation dialog
                    Navigator.of(context).pop(); // Close image dialog
                    // Trigger rebuild of the main screen
                    (context as Element).markNeedsBuild();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ບໍ່ສາມາດລຶບຮູບພາບໄດ້: $e'), // "Cannot delete image: $e"
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('ລຶບ'), // "Delete"
            ),
          ],
        );
      },
    );
  }
}