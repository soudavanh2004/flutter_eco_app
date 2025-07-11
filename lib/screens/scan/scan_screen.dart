

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:front_end_ecoapp_new/models/detection_result.dart';
import 'package:front_end_ecoapp_new/screens/home/home_screen.dart';
import 'package:front_end_ecoapp_new/screens/scan/HistoryScreen.dart';

import 'package:front_end_ecoapp_new/services/api_service.dart';
import 'package:front_end_ecoapp_new/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const ScanScreen());
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  ScanScreenState createState() => ScanScreenState();
}

class ScanScreenState extends State<ScanScreen> {
  File? _imageFile;
  DetectionResult? _detectionResult;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isModelLoaded = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkApiHealth();
  }

  Future<void> _checkApiHealth() async {
    try {
      final isHealthy = await ApiService.checkHealth();
      if (!isHealthy) {
        setState(() {
          _isLoading = true;
        });
        final modelLoaded = await ApiService.loadModel();
        setState(() {
          _isModelLoaded = modelLoaded;
          _isLoading = false;
        });
        if (!modelLoaded) {
          setState(() {
            _errorMessage = 'ບໍ່ສາມາດໂຫຼດໂມເດວ AI ໄດ້';
          });
        }
      } else {
        setState(() {
          _isModelLoaded = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'ບໍ່ສາມາດເຊື່ອມຕໍ່ເຊີເວີໄດ້: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _detectionResult = null;
      });

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (pickedFile == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final File imageFile = File(pickedFile.path);
      setState(() {
        _imageFile = imageFile;
      });

      // Save image locally and get file
      final savedImageFile = await StorageService.saveImageToPermanentStorage(imageFile);

      // Call API for detection
      final DetectionResult result = await ApiService.detectWaste(
        imageFile: savedImageFile,
        saveToHistory: true,
        confidenceThreshold: 0.5,
        userId: 'flutter_user', // Replace with actual user ID from your auth system
      );

      setState(() {
        _detectionResult = result;
        _imageFile = savedImageFile; // Update to use saved image
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'ຜິດພາດ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildConnectionStatus() {
    if (_errorMessage != null && _errorMessage!.contains('ເຊີເວີ')) {
      return Card(
        color: Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ບໍ່ສາມາດເຊື່ອມຕໍ່ເຊີເວີໄດ້',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _checkApiHealth,
                child: const Text('ລອງໃໝ່'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isModelLoaded) {
      return Card(
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.downloading, color: Colors.blue[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ກຳລັງໂຫຼດໂມເດວ AI...',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ກຽມພ້ອມສຳລັບການກວດສອບ',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Object Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'ກວດສອບວັດຖຸ',
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
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildConnectionStatus(),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 48,
                          color: Colors.green[600],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: (_isLoading || !_isModelLoaded) ? null : _pickImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('ຖ່າຍຮູບ', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'ກຳລັງປະມວນຜົນຮູບພາບ...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_errorMessage != null && !_errorMessage!.contains('ເຊີເວີ'))
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.file(
                            _imageFile!,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ວັດຖຸທີ່ພົບ: ${_detectionResult?.wasteDetections ?? 0}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (_detectionResult != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'ເວລາປະມວນຜົນ: ${_detectionResult!.processingTime.toStringAsFixed(2)} ວິນາທີ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_detectionResult != null && _detectionResult!.detections.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'ຜົນການກວດສອບ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _detectionResult!.detections.length,
                    itemBuilder: (context, index) {
                      final detection = _detectionResult!.detections[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getIconForCategory(detection.wasteCategory),
                              color: Colors.green[600],
                              size: 24,
                            ),
                          ),
                          title: Text(
                            detection.className,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.category, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ປະເພດ: ${detection.wasteCategory}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.analytics, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ຄວາມມັ້ນໃຈ: ${(detection.confidence * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getColorForConfidence(detection.confidence),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(detection.confidence * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        '/history': (context) => const HistoryScreen(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('lo', 'LA'),
        Locale('en', 'US'),
      ],
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'plastic':
        return Icons.recycling;
      case 'metal':
        return Icons.hardware;
      case 'electronic':
        return Icons.electrical_services;
      case 'paper':
        return Icons.description;
      case 'textile':
        return Icons.dry_cleaning;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorForConfidence(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}