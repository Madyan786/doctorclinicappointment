import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/auth/login_screen.dart';
import 'package:doctorclinic/auth/signup_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  void _onLoginPressed() {
    Get.to(() => const LoginScreen());
  }

  void _onRegisterPressed() {
    Get.to(() => const SignupScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Doctor Image at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/selectionscreen/SelectionScreen.png',
              width: 360.w,
              height: 500.h,
              fit: BoxFit.cover,
            ),
          ),
          // White curved section at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 280.h,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.r),
                  topRight: Radius.circular(50.r),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 100.h),
                  // Login Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 17.w),
                    child: CustomButton(
                      text: 'Log In',
                      onPressed: _onLoginPressed,
                      backgroundColor: AppColors.primary,
                      textColor: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Register Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 17.w),
                    child: CustomButton(
                      text: 'Register',
                      onPressed: _onRegisterPressed,

                      backgroundColor: AppColors.primary,
                      textColor: AppColors.white,
                      hasBorder: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Line with icon in center
          Positioned(
            top: 530.h,
            left: 0,
            right: 0,
            child: LineWithIcon.image(
              imagePath: 'assets/images/selectionscreen/person.png',
            ),
          ),
        ],
      ),
    );
  }
}
