import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/auth/login_screen.dart';
import 'package:doctorclinic/auth/doctor/doctor_login_screen.dart';
import 'package:doctorclinic/admin/admin_login_screen.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 500 : double.infinity),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 60.h),
                  // Logo and Title
                  Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                      ),
                      borderRadius: BorderRadius.circular(25.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF355CE4).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      color: Colors.white,
                      size: 50.sp,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Doctor Clinic',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Select how you want to continue',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 60.h),
                  // Selection Cards
                  _buildSelectionCard(
                    icon: Icons.person_rounded,
                    title: 'I am a Patient',
                    subtitle: 'Book appointments with doctors',
                    gradientColors: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                    onTap: () => Get.to(() => const LoginScreen()),
                    isDark: isDark,
                  ),
                  SizedBox(height: 20.h),
                  _buildSelectionCard(
                    icon: Icons.medical_services_rounded,
                    title: 'I am a Doctor',
                    subtitle: 'Manage your appointments & patients',
                    gradientColors: [const Color(0xFF355CE4), const Color(0xFF5F6FFF)],
                    onTap: () => Get.to(() => const DoctorLoginScreen()),
                    isDark: isDark,
                  ),
                  const Spacer(),
                  // Footer
                  Text(
                    'By continuing, you agree to our',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white54 : AppColors.grey,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        ' and ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.white54 : AppColors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Admin Login Link
                  // GestureDetector(
                  //   onTap: () => Get.to(() => const AdminLoginScreen()),
                  //   child: Container(
                  //     padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  //     decoration: BoxDecoration(
                  //       color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                  //       borderRadius: BorderRadius.circular(12.r),
                  //     ),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Icon(Icons.admin_panel_settings_rounded,
                  //              color: isDark ? Colors.white54 : AppColors.grey,
                  //              size: 18.sp),
                  //         SizedBox(width: 8.w),
                  //         Text(
                  //           'Admin Panel',
                  //           style: TextStyle(
                  //             fontSize: 13.sp,
                  //             fontWeight: FontWeight.w500,
                  //             color: isDark ? Colors.white54 : AppColors.grey,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, color: Colors.white, size: 32.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
