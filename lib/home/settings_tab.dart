import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doctorclinic/core/core.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = Get.find<SettingsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : AppColors.white,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  // Premium Header with gradient
                  _buildPremiumHeader(isDark),
              SizedBox(height: 25.h),
              // Preferences Section
              _buildSectionHeader('Preferences', Icons.tune_rounded, isDark),
              SizedBox(height: 10.h),
              Obx(() => _buildPremiumSwitch(
                icon: Icons.notifications_active_rounded,
                title: 'Push Notifications',
                subtitle: 'Get notified about appointments',
                value: settings.isNotificationsEnabled.value,
                onChanged: settings.toggleNotifications,
                isDark: isDark,
                gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
              )),
              Obx(() => _buildPremiumSwitch(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: 'Reduce eye strain in low light',
                value: settings.isDarkMode.value,
                onChanged: settings.toggleDarkMode,
                isDark: isDark,
                gradientColors: [const Color(0xFF1a1a2e), const Color(0xFF16213e)],
              )),
              SizedBox(height: 25.h),
              // Security Section
              _buildSectionHeader('Security', Icons.shield_rounded, isDark),
              SizedBox(height: 10.h),
              Obx(() => _buildPremiumSwitch(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric Login',
                subtitle: settings.canUseBiometric.value 
                    ? 'Use fingerprint or face ID' 
                    : 'Not available on this device',
                value: settings.isBiometricEnabled.value,
                onChanged: settings.canUseBiometric.value 
                    ? (val) => settings.toggleBiometric(val) 
                    : null,
                isDark: isDark,
                gradientColors: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                enabled: settings.canUseBiometric.value,
              )),
              _buildPremiumOption(
                icon: Icons.lock_rounded,
                title: 'Change Password',
                subtitle: 'Update your password',
                isDark: isDark,
                gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
                onTap: () => _showChangePasswordDialog(context, isDark),
              ),
              _buildPremiumOption(
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy terms',
                isDark: isDark,
                gradientColors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
                onTap: () => settings.openPrivacyPolicy(),
              ),
              SizedBox(height: 25.h),
              // About Section
              _buildSectionHeader('About', Icons.info_rounded, isDark),
              SizedBox(height: 10.h),
              _buildPremiumOption(
                icon: Icons.info_outline_rounded,
                title: 'About App',
                subtitle: 'Learn more about Doctor Clinic',
                isDark: isDark,
                gradientColors: [const Color(0xFF355CE4), const Color(0xFF5F6FFF)],
                onTap: () => settings.showAboutDialog(),
              ),
              _buildPremiumOption(
                icon: Icons.star_rounded,
                title: 'Rate Us',
                subtitle: 'Love the app? Rate us 5 stars!',
                isDark: isDark,
                gradientColors: [const Color(0xFFf7971e), const Color(0xFFffd200)],
                onTap: () => settings.rateApp(),
              ),
              _buildPremiumOption(
                icon: Icons.share_rounded,
                title: 'Share App',
                subtitle: 'Tell your friends about us',
                isDark: isDark,
                gradientColors: [const Color(0xFF00c6fb), const Color(0xFF005bea)],
                onTap: () => settings.shareApp(),
              ),
              SizedBox(height: 25.h),
              // Danger Zone
              _buildSectionHeader('Advanced', Icons.settings_applications_rounded, isDark),
              SizedBox(height: 10.h),
              _buildPremiumOption(
                icon: Icons.restore_rounded,
                title: 'Reset Settings',
                subtitle: 'Restore default settings',
                isDark: isDark,
                gradientColors: [const Color(0xFFeb3349), const Color(0xFFf45c43)],
                onTap: () => settings.resetSettings(),
                isDanger: true,
              ),
                  SizedBox(height: 30.h),
                  // Version Info
                  _buildVersionInfo(settings, isDark),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF355CE4),
            const Color(0xFF5F6FFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355CE4).withOpacity(0.4),
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
            child: Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  'Settings',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  'Customize your experience',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          CustomText(
            title,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool)? onChanged,
    required bool isDark,
    required List<Color> gradientColors,
    bool enabled = true,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: value && enabled 
              ? gradientColors.first.withOpacity(0.3) 
              : (isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: value && enabled
                ? gradientColors.first.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: enabled && onChanged != null ? () => onChanged(!value) : null,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: enabled 
                          ? gradientColors 
                          : [Colors.grey.shade400, Colors.grey.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: enabled 
                            ? gradientColors.first.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        title,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: enabled 
                            ? (isDark ? Colors.white : AppColors.textPrimary)
                            : Colors.grey,
                      ),
                      SizedBox(height: 2.h),
                      CustomText(
                        subtitle,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: enabled 
                            ? (isDark ? Colors.white70 : AppColors.textSecondary)
                            : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Switch.adaptive(
                    value: value,
                    onChanged: enabled ? onChanged : null,
                    activeColor: gradientColors.first,
                    activeTrackColor: gradientColors.first.withOpacity(0.3),
                    inactiveThumbColor: Colors.grey.shade400,
                    inactiveTrackColor: isDark 
                        ? Colors.white.withOpacity(0.1) 
                        : Colors.grey.shade200,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        title,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDanger 
                            ? Colors.red 
                            : (isDark ? Colors.white : AppColors.textPrimary),
                      ),
                      SizedBox(height: 2.h),
                      CustomText(
                        subtitle,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withOpacity(0.1) 
                        : AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark ? Colors.white54 : AppColors.grey,
                    size: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo(SettingsController settings, bool isDark) {
    return Obx(() => Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withOpacity(0.05) 
                  : AppColors.lightGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.primary,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                CustomText(
                  'Version ${settings.appVersion.value} (${settings.buildNumber.value})',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : AppColors.grey,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          CustomText(
            'Made with ❤️ for better healthcare',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white54 : AppColors.grey,
          ),
        ],
      ),
    ));
  }

  void _showChangePasswordDialog(BuildContext context, bool isDark) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        contentPadding: EdgeInsets.all(24.w),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFf5576c).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 35.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                CustomText(
                  'Change Password',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  'Enter your current password and choose a new one',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                _buildPasswordField(
                  controller: currentPasswordController,
                  label: 'Current Password',
                  isDark: isDark,
                ),
                SizedBox(height: 16.h),
                _buildPasswordField(
                  controller: newPasswordController,
                  label: 'New Password',
                  isDark: isDark,
                ),
                SizedBox(height: 16.h),
                _buildPasswordField(
                  controller: confirmPasswordController,
                  label: 'Confirm Password',
                  isDark: isDark,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            side: BorderSide(
                              color: isDark 
                                  ? Colors.white24 
                                  : AppColors.lightGrey,
                            ),
                          ),
                        ),
                        child: CustomText(
                          'Cancel',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFf5576c).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _handleChangePassword(
                            formKey,
                            currentPasswordController.text,
                            newPasswordController.text,
                            confirmPasswordController.text,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: CustomText(
                            'Update',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimary,
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white54 : AppColors.textSecondary,
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: isDark 
            ? Colors.white.withOpacity(0.05) 
            : AppColors.lightGrey.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : AppColors.lightGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: isDark ? Colors.white54 : AppColors.grey,
          size: 20.sp,
        ),
      ),
    );
  }

  void _handleChangePassword(
    GlobalKey<FormState> formKey,
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) {
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (newPassword.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    // Call the auth service to change password
    final AuthService authService = Get.find<AuthService>();
    authService.changePassword(currentPassword, newPassword).then((success) {
      if (success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Password changed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    });
  }
}
