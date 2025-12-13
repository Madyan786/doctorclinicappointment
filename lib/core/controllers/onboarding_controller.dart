import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as developer;

class OnboardingController extends GetxController {
  static OnboardingController get to => Get.find<OnboardingController>();
  
  final _storage = GetStorage();
  final String _onboardingKey = 'onboarding_completed';
  
  late PageController pageController;
  final RxInt currentPage = 0.obs;
  final RxBool isLastPage = false.obs;
  
  final List<OnboardingData> pages = [
    OnboardingData(
      title: 'Booking\nAppointment\nWith 100+ Trusted\nDoctors',
      image: 'assets/images/onboardingscreens/onboardingscreen1.png',
    ),
    OnboardingData(
      title: 'Your Trusted Partner In\nManaging Your Healthcare Needs Conveniently.',
      image: 'assets/images/onboardingscreens/onboardingscreen2.png',
    ),
    OnboardingData(
      title: 'WELCOME TO\nDOCTORS CLINIC',
      subtitle: 'Complete Health Solutions',
      image: 'assets/images/onboardingscreens/onboardingscreen3.png',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    developer.log('🚀 OnboardingController initialized', name: 'OnboardingController');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    isLastPage.value = index == pages.length - 1;
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipToLast() {
    pageController.animateToPage(
      pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void goToPage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Check if onboarding is completed
  bool get isOnboardingCompleted => _storage.read(_onboardingKey) ?? false;

  // Mark onboarding as completed
  void completeOnboarding() {
    _storage.write(_onboardingKey, true);
    developer.log('✅ Onboarding completed and saved', name: 'OnboardingController');
  }

  // Reset onboarding (for testing)
  void resetOnboarding() {
    _storage.remove(_onboardingKey);
    developer.log('🔄 Onboarding reset', name: 'OnboardingController');
  }
}

class OnboardingData {
  final String title;
  final String? subtitle;
  final String image;

  OnboardingData({
    required this.title,
    this.subtitle,
    required this.image,
  });
}
