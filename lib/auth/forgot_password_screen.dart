import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:doctorclinic/core/core.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Validation
  bool _validateInputs() {
    String email = _emailController.text.trim();

    developer.log('📝 Validating forgot password inputs...', name: 'ForgotPasswordScreen');

    if (email.isEmpty) {
      Get.snackbar('Error', 'Please enter your email', snackPosition: SnackPosition.TOP);
      developer.log('❌ Validation failed: Email empty', name: 'ForgotPasswordScreen');
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email', snackPosition: SnackPosition.TOP);
      developer.log('❌ Validation failed: Invalid email format', name: 'ForgotPasswordScreen');
      return false;
    }

    developer.log('✅ Validation passed', name: 'ForgotPasswordScreen');
    return true;
  }

  // Dismiss keyboard
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _onResetPassword() async {
    _dismissKeyboard();
    if (!_validateInputs()) return;

    developer.log('🚀 Starting password reset process...', name: 'ForgotPasswordScreen');

    await _authService.forgotPassword(
      email: _emailController.text.trim(),
    );

    // Show success dialog and go back
    if (!_authService.isLoading.value) {
      developer.log('✅ Password reset email sent - Showing dialog', name: 'ForgotPasswordScreen');
      
      Get.defaultDialog(
        title: 'Email Sent!',
        titleStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        middleText: 'Password reset link has been sent to your email. Please check your inbox.',
        middleTextStyle: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
        ),
        confirm: CustomButton(
          text: 'OK',
          onPressed: () {
            Get.back(); // Close dialog
            Get.back(); // Go back to login
          },
          backgroundColor: AppColors.primary,
          textColor: AppColors.white,
          width: 100,
          height: 45,
        ),
        barrierDismissible: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              // Back Button
                GestureDetector(
                  onTap: () {
                    _dismissKeyboard();
                    Get.back();
                  },
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: 50.h),
              // Title
              CustomText(
                'Forgot Your Password?',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              SizedBox(height: 15.h),
              // Description
              CustomText(
                'No worries, you just need to type your email address or username and we will send the verification code.',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              SizedBox(height: 30.h),
              // Email Label
              CustomText(
                'EMAIL',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
              SizedBox(height: 8.h),
              // Email TextField
              CustomTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 25.h),
              // Reset Password Button
              Obx(() => _authService.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Reset my password',
                      onPressed: _onResetPassword,
                      backgroundColor: AppColors.primary,
                      textColor: AppColors.white,
                    ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
