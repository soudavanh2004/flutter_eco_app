import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:front_end_ecoapp_new/screens/home/components/app_colors.dart';
import 'package:front_end_ecoapp_new/screens/home/home_screen.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Services
  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();

  // State variables
  bool _isLoading = false;
  bool _isEditing = false;
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _phoneController.text = user.phone;
        _addressController.text = user.address;
        _emailController.text = user.email;
        _currentImageUrl = user.profileImage;
      });
    }
  }

  Future<void> _refreshUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = await _authService.getProfile();
      setState(() {
        _nameController.text = user.name;
        _phoneController.text = user.phone;
        _addressController.text = user.address;
        _emailController.text = user.email;
        _currentImageUrl = user.profileImage;
      });

      Get.snackbar(
        'ສຳເລັດ',
        'ອັບເດດຂໍ້ມູນແລ້ວ',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'ຜິດພາດ',
        'ບໍ່ສາມາດອັບເດດຂໍ້ມູນໄດ້: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_isEditing) {
      setState(() {
        _isEditing = true;
      });
      return;
    }

    // Validate input
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar(
        'ຜິດພາດ',
        'ກະລຸນາໃສ່ຊື່',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      Get.snackbar(
        'ຜິດພາດ',
        'ກະລຸນາໃສ່ເບີໂທ',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_addressController.text.trim().length < 10) {
      Get.snackbar(
        'ຜິດພາດ',
        'ທີ່ຢູ່ຕ້ອງມີຢ່າງໜ້ອຍ 10 ຕົວອັກສອນ',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Upload profile image if selected
      if (_selectedImage != null) {
        try {
          print('📸 Uploading profile image...');
          final uploadResponse = await _apiService.uploadProfileImage(_selectedImage!);
          if (uploadResponse.containsKey('url')) {
            _currentImageUrl = uploadResponse['url'];
            print('✅ Profile image uploaded: $_currentImageUrl');
          }
        } catch (e) {
          print('⚠️ Failed to upload image: $e');
          // Continue with profile update even if image upload fails
        }
      }

      // Update profile data
      final updatedUser = await _authService.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      setState(() {
        _isEditing = false;
        _selectedImage = null;
        _currentImageUrl = updatedUser.profileImage;
      });

      Get.snackbar(
        'ສຳເລັດ',
        'ອັບເດດໂປຣໄຟລ໌ສຳເລັດແລ້ວ',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'ຜິດພາດ',
        'ບໍ່ສາມາດອັບເດດໂປຣໄຟລ໌ໄດ້: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _selectedImage = null;
    });
    _loadUserData(); // Reset to original data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8), // Light green background
      appBar: AppBar(
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
        title: Text(
          _isEditing ? 'ແກ້ໄຂໂປຣໄຟລ໌' : 'ໂປຣໄຟລ໌',
          style: const TextStyle(
            color: Colors.black87,
            fontFamily: 'NotoSansLao',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _cancelEdit,
              child: const Text(
                'ຍົກເລີກ',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'NotoSansLao',
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'ກຳລັງປະມວນຜົນ...',
                    style: TextStyle(
                      fontFamily: 'NotoSansLao',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshUserData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Profile Image with Edit Button
                    _buildProfileImage(),
                    
                    const SizedBox(height: 40),
                    
                    // Profile Form
                    _buildProfileForm(),
                    
                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: const BoxDecoration(
            color: Color(0xFFFCE6A6), // Yellow background
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(70),
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  )
                : _currentImageUrl != null
                    ? Image.network(
                        _currentImageUrl!,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar();
                        },
                      )
                    : _buildDefaultAvatar(),
          ),
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black54,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    final user = _authService.currentUser;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFCE6A6),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'NotoSansLao',
          ),
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    final user = _authService.currentUser;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEditing ? 'ແກ້ໄຂໂປຣໄຟລ໌' : 'ຂໍ້ມູນສ່ວນຕົວ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'NotoSansLao',
                  color: Colors.black87,
                ),
              ),
              if (!_isEditing)
                IconButton(
                  onPressed: _updateProfile,
                  icon: const Icon(
                    Icons.edit,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // User ID (Read-only)
          _buildInfoField(
            icon: Icons.badge_outlined,
            label: 'ID ຜູ້ໃຊ້',
            value: user?.id ?? 'ບໍ່ມີຂໍ້ມູນ',
            isReadOnly: true,
          ),
          
          const SizedBox(height: 16),
          
          // Email (Read-only)
          _buildInfoField(
            icon: Icons.email_outlined,
            label: 'ອີເມລ',
            value: user?.email ?? 'ບໍ່ມີຂໍ້ມູນ',
            isReadOnly: true,
          ),
          
          const SizedBox(height: 16),
          
          // Name Field
          _buildInputField(
            controller: _nameController,
            icon: Icons.person_outline,
            hintText: 'ຊື່ຜູ້ໃຊ້',
            enabled: _isEditing,
          ),
          
          const SizedBox(height: 16),
          
          // Phone Field
          _buildInputField(
            controller: _phoneController,
            icon: Icons.phone_outlined,
            hintText: 'ເບີໂທລະສັບ',
            keyboardType: TextInputType.phone,
            enabled: _isEditing,
          ),
          
          const SizedBox(height: 16),
          
          // Address Field
          _buildInputField(
            controller: _addressController,
            icon: Icons.location_on_outlined,
            hintText: 'ທີ່ຢູ່',
            maxLines: 3,
            enabled: _isEditing,
          ),

          const SizedBox(height: 16),

          // Account Status
          _buildInfoField(
            icon: Icons.verified_user_outlined,
            label: 'ສະຖານະບັນຊີ',
            value: user?.status == 'active' ? 'ເປີດໃຊ້ງານ' : 'ປິດໃຊ້ງານ',
            isReadOnly: true,
            valueColor: user?.status == 'active' ? Colors.green : Colors.red,
          ),

          const SizedBox(height: 16),

          // Account Role
          _buildInfoField(
            icon: Icons.admin_panel_settings_outlined,
            label: 'ບົດບາດ',
            value: _getRoleText(user?.role ?? 'user'),
            isReadOnly: true,
          ),

          const SizedBox(height: 16),

          // Member Since
          _buildInfoField(
            icon: Icons.calendar_today_outlined,
            label: 'ສະມາຊິກຕັ້ງແຕ່',
            value: user?.createdAt != null 
                ? _formatDate(user!.createdAt)
                : 'ບໍ່ມີຂໍ້ມູນ',
            isReadOnly: true,
          ),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          if (_isEditing) ...[
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'ບັນທຶກການປ່ຽນແປງ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'NotoSansLao',
                  ),
                ),
              ),
            ),
          ] else ...[
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'ອອກຈາກລະບົບ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'NotoSansLao',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.grey.shade100 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        style: TextStyle(
          fontFamily: 'NotoSansLao',
          fontSize: 16,
          color: enabled ? Colors.black87 : Colors.grey.shade600,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
            size: 20,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontFamily: 'NotoSansLao',
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
    bool isReadOnly = true,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'NotoSansLao',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ?? Colors.black87,
                    fontFamily: 'NotoSansLao',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'ຜູ້ດູແລລະບົບ';
      case 'user':
        return 'ຜູ້ໃຊ້ທົ່ວໄປ';
      case 'moderator':
        return 'ຜູ້ຄວບຄຸມ';
      default:
        return role;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'ມັງກອນ', 'ກຸມພາ', 'ມີນາ', 'ເມສາ', 'ພຶດສະພາ', 'ມິຖຸນາ',
      'ກໍລະກົດ', 'ສິງຫາ', 'ກັນຍາ', 'ຕຸລາ', 'ພະຈິກ', 'ທັນວາ'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ເລືອກຮູບພາບ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'NotoSansLao',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'ກ້ອງຖ່າຍຮູບ',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'ແກລເລີ່',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'NotoSansLao',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'ຜິດພາດ',
        'ບໍ່ສາມາດເລືອກຮູບພາບໄດ້: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'ອອກຈາກລະບົບ',
            style: TextStyle(
              fontFamily: 'NotoSansLao',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກລະບົບ?',
            style: TextStyle(
              fontFamily: 'NotoSansLao',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'ຍົກເລີກ',
                style: TextStyle(
                  fontFamily: 'NotoSansLao',
                  color: Colors.grey.shade600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'ອອກຈາກລະບົບ',
                style: TextStyle(
                  fontFamily: 'NotoSansLao',
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  await _authService.logout();
                  Get.offAllNamed('/signin');
                  
                  Get.snackbar(
                    'ສຳເລັດ',
                    'ອອກຈາກລະບົບແລ້ວ',
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                } catch (e) {
                  Get.snackbar(
                    'ຜິດພາດ',
                    'ບໍ່ສາມາດອອກຈາກລະບົບໄດ້: ${e.toString()}',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}