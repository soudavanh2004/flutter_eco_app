import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:front_end_ecoapp_new/screens/home/components/app_colors.dart';
import '../../widgets/eco_button.dart';
import '../../widgets/eco_text_field.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Get.find<AuthService>();
      await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Navigate to home screen if login successful
      Get.offAllNamed('/home');
      
      // Show success message
      Get.snackbar(
        'ສຳເລັດ',
        'ເຂົ້າສູ່ລະບົບສຳເລັດແລ້ວ',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );

    } catch (e) {
      // Show error message
      Get.snackbar(
        'ຜິດພາດ',
        'ເຂົ້າສູ່ລະບົບບໍ່ສຳເລັດ: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRegister() {
    Get.to(() => const RegisterScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Section
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Positioned(
                      top: 110,
                      child: Image.asset(
                        'assets/images/BG.png',
                        width: 220,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/eco_scan_logo.png',
                          width: 350,  
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
                
                // App Title
                const Text(
                  'ECO SCAN',
                  style: TextStyle(
                    color: Color(0xFF40A578),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            
                const Text(
                  'ຄົ້ນພົບຄຸນຄ່າຈາກຂີ້ເຫຍື້ອ',
                  style: TextStyle(
                    color: Color(0xFF40A578),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 40),

                // Email Field
                EcoTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ກະລຸນາໃສ່ອີເມລ';
                    }
                    if (!AuthService.isValidEmail(value)) {
                      return 'ຮູບແບບອີເມລບໍ່ຖືກຕ້ອງ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Field
                EcoTextField(
                  controller: _passwordController,
                  hintText: 'ລະຫັດຜ່ານ',
                  prefixIcon: Icons.lock,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ກະລຸນາໃສ່ລະຫັດຜ່ານ';
                    }
                    if (!AuthService.isValidPassword(value)) {
                      return 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Sign In Button
                EcoButton(
                  text: _isLoading ? 'ກຳລັງເຂົ້າສູ່ລະບົບ...' : 'ເຂົ້າສູ່ລະບົບ',
                  color: AppColors.primary,
                  onPressed: _isLoading ? null : _handleSignIn,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 16),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ຍັງບໍ່ມີບັນຊີ? ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: _navigateToRegister,
                      child: Text(
                        'ລົງທະບຽນ',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}