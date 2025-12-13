import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/admin/admin_main.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Admin credentials (in production, use Firebase Auth with admin custom claims)
  final String _adminEmail = 'admin@doctorclinic.com';
  final String _adminPassword = 'admin123';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check admin credentials
      if (_emailController.text.trim() == _adminEmail &&
          _passwordController.text.trim() == _adminPassword) {
        // Save admin login state
        Get.find<AuthService>().setUserType(UserType.admin);
        Get.offAll(() => const AdminMain());
      } else {
        // Check Firebase for admin
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .where('email', isEqualTo: _emailController.text.trim())
            .limit(1)
            .get();

        if (adminDoc.docs.isNotEmpty) {
          final adminData = adminDoc.docs.first.data();
          if (adminData['password'] == _passwordController.text.trim()) {
            // Save admin login state
            Get.find<AuthService>().setUserType(UserType.admin);
            Get.offAll(() => const AdminMain());
          } else {
            Get.snackbar('Error', 'Invalid credentials');
          }
        } else {
          Get.snackbar('Error', 'Admin not found');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Login failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Admin Icon
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFeb3349), Color(0xFFf45c43)],
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFeb3349).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(Icons.admin_panel_settings_rounded,
                      color: Colors.white, size: 50.sp),
                ),
                SizedBox(height: 30.h),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Login to manage doctors & app',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 40.h),
                // Email Field
                _buildTextField(
                  controller: _emailController,
                  hint: 'Admin Email',
                  icon: Icons.email_outlined,
                  isDark: isDark,
                ),
                SizedBox(height: 16.h),
                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isDark: isDark,
                ),
                SizedBox(height: 30.h),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFeb3349),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Login as Admin',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Info Text
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Default: admin@doctorclinic.com / admin123',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(
          fontSize: 15.sp,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 15.sp, color: AppColors.grey),
          prefixIcon: Icon(icon, color: const Color(0xFFeb3349), size: 22.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        ),
      ),
    );
  }
}
