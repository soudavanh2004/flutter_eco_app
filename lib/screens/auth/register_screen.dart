import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:front_end_ecoapp_new/screens/home/components/app_colors.dart';
import '../../widgets/eco_button.dart';
import '../../widgets/eco_text_field.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Get.find<AuthService>();
      await authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      // Navigate back to login screen after successful registration
      Get.back();
      
      // Show success message
      Get.snackbar(
        'ສຳເລັດ',
        'ລົງທະບຽນສຳເລັດ - ກະລຸນາເຂົ້າສູ່ລະບົບ',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );

    } catch (e) {
      // Show error message
      Get.snackbar(
        'ຜິດພາດ',
        'ລົງທະບຽນບໍ່ສຳເລັດ: ${e.toString()}',
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

  void _navigateToSignIn() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF40A578)),
          onPressed: _navigateToSignIn,
        ),
        title: const Text(
          'ລົງທະບຽນ',
          style: TextStyle(
            color: Color(0xFF40A578),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Section (Smaller)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Positioned(
                      top: 30,
                      child: Image.asset(
                        'assets/images/BG.png',
                        width: 140,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/eco_scan_logo.png',
                          width: 200,  
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
                
                // App Title
                const Text(
                  'ສ້າງບັນຊີໃໝ່',
                  style: TextStyle(
                    color: Color(0xFF40A578),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Name Field
                EcoTextField(
                  controller: _nameController,
                  hintText: 'ຊື່ເຕັມ',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ກະລຸນາໃສ່ຊື່ເຕັມ';
                    }
                    if (value.length < 2) {
                      return 'ຊື່ຕ້ອງມີຢ່າງໜ້ອຍ 2 ຕົວອັກສອນ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

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

                const SizedBox(height: 12),

                // Phone Field
                EcoTextField(
                  controller: _phoneController,
                  hintText: 'ເບີໂທ',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ກະລຸນາໃສ່ເບີໂທ';
                    }
                    if (!AuthService.isValidPhone(value)) {
                      return 'ຮູບແບບເບີໂທບໍ່ຖືກຕ້ອງ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Address Field - Required with min 10 characters
                EcoTextField(
                  controller: _addressController,
                  hintText: 'ທີ່ຢູ່',
                  prefixIcon: Icons.location_on,
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ກະລຸນາໃສ່ທີ່ຢູ່';
                    }
                    if (value.length < 10) {
                      return 'ທີ່ຢູ່ຕ້ອງມີຢ່າງໜ້ອຍ 10 ຕົວອັກສອນ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

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

                const SizedBox(height: 12),

                // Confirm Password Field
                EcoTextField(
                  controller: _confirmPasswordController,
                  hintText: 'ຢືນຢັນລະຫັດຜ່ານ',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ກະລຸນາຢືນຢັນລະຫັດຜ່ານ';
                    }
                    if (value != _passwordController.text) {
                      return 'ລະຫັດຜ່ານບໍ່ຕົງກັນ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Register Button
                EcoButton(
                  text: _isLoading ? 'ກຳລັງລົງທະບຽນ...' : 'ລົງທະບຽນ',
                  color: AppColors.primary,
                  onPressed: _isLoading ? null : _handleRegister,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 12),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ມີບັນຊີແລ້ວ? ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: _navigateToSignIn,
                      child: Text(
                        'ເຂົ້າສູ່ລະບົບ',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
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