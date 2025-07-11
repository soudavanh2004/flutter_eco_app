import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    // หน่วงเวลา 2 วินาทีก่อนไปยังหน้า Sign In
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/signin');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive positioning
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFDEFFE8), // สีพื้นหลังเขียวอ่อน
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox to push content down slightly from the exact center
            SizedBox(height: size.height * 0.05),
            
            // Main visual stack with recycling elements
            SizedBox(
              height: 300, // Fixed height container for the stack
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 🟢 วงกลมพื้นหลัง (BG) - Green circular background
                  Positioned(
                    // Position relative to center of stack
                    top: 110,
                    child: Image.asset(
                      'assets/images/BG.png',
                      width: 220,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  // Main visual elements in a column
                  Positioned(
                    top: 0,
                    child: Image.asset(
                      'assets/images/eco_scan_logo.png',
                      width: 350,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            
            // Text elements with proper spacing
            const Text(
              'ECO SCAN',
              style: TextStyle(
                color: Color(0xFF40A578),
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12), // Consistent spacing
            
            // ข้อความภาษาลาว
            const Text(
              'ຄົ້ນພົບຄຸນຄ່າຈາກຂີ້ເຫຍື້ອ',
              style: TextStyle(
                color: Color(0xFF65A986),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            // Add extra space at bottom for visual balance
            SizedBox(height: size.height * 0.1),
          ],
        ),
      ),
    );
  }
}