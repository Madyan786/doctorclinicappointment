import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/auth/user_type_selection_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onGetStarted() {
    final controller = OnboardingController.to;
    controller.completeOnboarding();
    Get.offAll(() => const UserTypeSelectionScreen());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF5F6FFF),
          ),
          // PageView with content
          PageView.builder(
            controller: controller.pageController,
            itemCount: controller.pages.length,
            onPageChanged: controller.onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _OnboardingPage(data: controller.pages[index]);
            },
          ),
          // Page Indicators
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: controller.currentPage.value == index ? 35.w : 25.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: controller.currentPage.value == index
                        ? const Color(0xFF001B7B)
                        : const Color(0xFF6FDDD7),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            )),
          ),
          // Skip Button (only on first screens)
          Obx(() => controller.currentPage.value < 2
            ? Positioned(
                top: 50.h,
                right: 20.w,
                child: GestureDetector(
                  onTap: controller.skipToLast,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: CustomText(
                      'Skip',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
          ),
          // Get Started Button (only on last screen)
          Obx(() => controller.isLastPage.value
            ? Positioned(
                bottom: 70.h,
                left: 60.w,
                right: 60.w,
                child: ElevatedButton(
                  onPressed: _onGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        'Get Started',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward_rounded, size: 20.sp, color: AppColors.primary),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Title Text
          Positioned(
            top: 150.h,
            left: 30.w,
            right: 30.w,
            child: Column(
              children: [
                CustomText(
                  data.title,
                  textAlign: TextAlign.center,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
                if (data.subtitle != null) ...[
                  SizedBox(height: 10.h),
                  CustomText(
                    data.subtitle!,
                    textAlign: TextAlign.center,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    height: 60 / 28,
                  ),
                ],
              ],
            ),
          ),
          // Doctor Image (overlaps indicators)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              data.image,
              width: 360.w,
              height: 420.h,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    );
  }
}
