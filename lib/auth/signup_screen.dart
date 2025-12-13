import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/auth/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validation
  bool _validateInputs() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    developer.log('📝 Validating signup inputs...', name: 'SignupScreen');

    // Email validation
    if (email.isEmpty) {
      Get.snackbar('Error', 'Please enter your email', snackPosition: SnackPosition.TOP);
      developer.log('❌ Validation failed: Email empty', name: 'SignupScreen');
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email', snackPosition: SnackPosition.TOP);
      developer.log('❌ Validation failed: Invalid email format', name: 'SignupScreen');
      return false;
    }

    // Password validation
    if (password.isEmpty) {
      Get.snackbar('Error', 'Please enter your password', snackPosition: SnackPosition.TOP);
      developer.log('❌ Validation failed: Password empty', name: 'SignupScreen');
      return false;
    }

    if (password.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters', snackPosition: SnackPosition.TOP);
      developer.log('❌ Validation failed: Password too short', name: 'SignupScreen');
      return false;
    }

    // Confirm password validation
    if (confirmPassword.isEmpty) {
      Get.snackbar('Error', 'Please confirm your password', snackPosition: SnackPosition.TOP);
      developer.log('❌ Validation failed: Confirm password empty', name: 'SignupScreen');
      return false;
    }

    if (password != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match', snackPosition: SnackPosition.TOP);
      developer.log('❌ Validation failed: Passwords do not match', name: 'SignupScreen');
      return false;
    }

    // Terms validation
    if (!_agreeToTerms) {
      Get.snackbar('Error', 'Please agree to Terms of Service and Privacy Policy', snackPosition: SnackPosition.TOP);
      developer.log('❌ Validation failed: Terms not accepted', name: 'SignupScreen');
      return false;
    }

    developer.log('✅ Validation passed', name: 'SignupScreen');
    return true;
  }

  // Dismiss keyboard
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _onCreateAccount() async {
    _dismissKeyboard();
    if (!_validateInputs()) return;

    developer.log('🚀 Starting signup process...', name: 'SignupScreen');

    await _authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // If signup successful, navigate to login
    if (!_authService.isLoading.value) {
      developer.log('✅ Navigating to login screen', name: 'SignupScreen');
      Get.off(() => const LoginScreen());
    }
  }

  void _onLogin() {
    _dismissKeyboard();
    Get.off(() => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 500 : double.infinity),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Image at top
                    Image.asset(
                      'assets/images/authimages/registerscreenimage.png',
                      width: double.infinity,
                      height: isTablet ? 280.h : 325.h,
                      fit: BoxFit.cover,
                    ),
              SizedBox(height: 20.h),
              // Line with icon
              LineWithIcon.image(
                imagePath: 'assets/images/selectionscreen/person.png',
              ),
              SizedBox(height: 10.h),
              // Signup with Password title
              Padding(
                padding: EdgeInsets.only(left: 25.w),
                child: CustomText(
                  'Signup with Password',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 15.h),
              // Email TextField
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: CustomTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(height: 12.h),
              // Password TextField
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  isPassword: true,
                ),
              ),
              SizedBox(height: 12.h),
              // Confirm Password TextField
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  isPassword: true,
                ),
              ),
              SizedBox(height: 12.h),
              // Terms and Conditions Checkbox
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Wrap(
                        children: [
                          CustomText(
                            "I'm agree to The ",
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          GestureDetector(
                            onTap: () {
                              // Open Terms of Service
                            },
                            child: CustomText(
                              'Terms of Service',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                          CustomText(
                            ' and ',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          GestureDetector(
                            onTap: () {
                              // Open Privacy Policy
                            },
                            child: CustomText(
                              'Privacy Policy',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                    SizedBox(height: 20.h),
                    // Create Account Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Obx(() => _authService.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButton(
                              text: 'Create Account',
                              onPressed: _onCreateAccount,
                              backgroundColor: AppColors.primary,
                              textColor: AppColors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
