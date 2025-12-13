import 'package:doctorclinic/auth/signup_screen.dart';
import 'package:doctorclinic/auth/forgot_password_screen.dart';
import 'package:doctorclinic/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:doctorclinic/core/core.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validation
  bool _validateInputs() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    developer.log('📝 Validating login inputs...', name: 'LoginScreen');

    if (email.isEmpty) {
      Get.snackbar('Error', 'Please enter your email', snackPosition: SnackPosition.TOP);
      developer.log('❌ Validation failed: Email empty', name: 'LoginScreen');
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email', snackPosition: SnackPosition.TOP);
      developer.log('❌ Validation failed: Invalid email format', name: 'LoginScreen');
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar('Error', 'Please enter your password', snackPosition: SnackPosition.TOP);
      developer.log('❌ Validation failed: Password empty', name: 'LoginScreen');
      return false;
    }

    developer.log('✅ Validation passed', name: 'LoginScreen');
    return true;
  }

  // Dismiss keyboard
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _onLogin() async {
    _dismissKeyboard();
    if (!_validateInputs()) return;

    developer.log('🚀 Starting login process...', name: 'LoginScreen');

    bool success = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success) {
      developer.log('✅ Login successful - Navigating to home', name: 'LoginScreen');
      _authService.setUserType(UserType.patient);
      Get.offAll(() => const MainNavigation());
    }
  }

  void _onForgotPassword() {
    _dismissKeyboard();
    Get.to(() => const ForgotPasswordScreen());
  }

  void _onSignUp() {
    _dismissKeyboard();
    Get.to(() => const SignupScreen());
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
                      'assets/images/authimages/loginscreenimage.png',
                      width: double.infinity,
                      height: isTablet ? 350.h : 420.h,
                      fit: BoxFit.cover,
                    ),
              SizedBox(height: 20.h),
              // Line with icon
              LineWithIcon.image(
                imagePath: 'assets/images/selectionscreen/person.png',
              ),
              SizedBox(height: 20.h),
              // Login with Password title
              Padding(
                padding:  EdgeInsets.only(left: 25.w),
                child: CustomText(
                  'Login with Password',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 10.h),
              // Email TextField
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: CustomTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(height: 16.h),
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
              // Forgot Password
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: _onForgotPassword,
                    child: CustomText(
                      'Forgot Password?',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Login Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Obx(() => _authService.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: 'Log In',
                        onPressed: _onLogin,
                        backgroundColor: AppColors.primary,
                        textColor: AppColors.white,
                      ),
                ),
              ),
              SizedBox(height: 10.h),
              // Don't have an account? Sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    "Don't have an account? ",
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  GestureDetector(
                    onTap: _onSignUp,
                    child: CustomText(
                      'Sign up',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
                    SizedBox(height: 20.h),
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
