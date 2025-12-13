import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'package:doctorclinic/auth/onboarding_screen.dart';
import 'package:doctorclinic/auth/user_type_selection_screen.dart';
import 'package:doctorclinic/home/main_navigation.dart';
import 'package:doctorclinic/admin/admin_main.dart';
import 'package:doctorclinic/doctor/doctor_main_navigation.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/core/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  developer.log('🚀 Initializing GetStorage...', name: 'Main');
  await GetStorage.init();
  developer.log('✅ GetStorage initialized successfully', name: 'Main');
  
  developer.log('🚀 Initializing Firebase...', name: 'Main');
  await Firebase.initializeApp();
  developer.log('✅ Firebase initialized successfully', name: 'Main');
  
  developer.log('🚀 Initializing Alarm Manager...', name: 'Main');
  await AndroidAlarmManager.initialize();
  developer.log('✅ Alarm Manager initialized successfully', name: 'Main');
  
  // Initialize GetX Services
  Get.put(AuthService());
  Get.put(SettingsController());
  Get.put(DoctorService());
  Get.put(AppointmentService());
  Get.put(ReviewService());
  Get.put(NotificationService());
  developer.log('✅ All services initialized', name: 'Main');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Determine initial screen based on onboarding and login status
  Widget _getInitialScreen() {
    final storage = GetStorage();
    final bool onboardingCompleted = storage.read('onboarding_completed') ?? false;
    final authService = Get.find<AuthService>();
    final storedUserType = authService.storedUserType;
    
    developer.log('📱 Checking app state...', name: 'Main');
    developer.log('📱 Onboarding completed: $onboardingCompleted', name: 'Main');
    developer.log('📱 User logged in: ${authService.isLoggedIn}', name: 'Main');
    developer.log('📱 User type: $storedUserType', name: 'Main');
    
    if (!onboardingCompleted) {
      developer.log('➡️ Navigating to OnboardingScreen', name: 'Main');
      return const OnboardingScreen();
    }
    
    // Check if admin is logged in
    if (storedUserType == UserType.admin) {
      developer.log('➡️ Navigating to AdminMain', name: 'Main');
      return const AdminMain();
    }
    
    // Check if doctor is logged in
    if (storedUserType == UserType.doctor) {
      developer.log('➡️ Navigating to DoctorMain', name: 'Main');
      return const DoctorLoader();
    }
    
    // Check if patient is logged in
    if (authService.isLoggedIn && authService.isEmailVerified) {
      developer.log('➡️ Navigating to MainNavigation', name: 'Main');
      return const MainNavigation();
    }
    
    developer.log('➡️ Navigating to UserTypeSelectionScreen', name: 'Main');
    return const UserTypeSelectionScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: ScreenUtilInit(
        designSize: const Size(360, 800),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            title: 'Doctor Clinic',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: _getInitialScreen(),
          );
        },
      ),
    );
  }
}

// Doctor loader widget to fetch doctor data on app restart
class DoctorLoader extends StatelessWidget {
  const DoctorLoader({super.key});

  Future<DocumentSnapshot?> _getDoctorData() async {
    final storage = GetStorage();
    final doctorId = storage.read('doctor_id');
    if (doctorId == null) return null;
    return FirebaseFirestore.instance.collection('doctors').doc(doctorId).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot?>(
      future: _getDoctorData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final doctor = DoctorModel.fromFirestore(snapshot.data!);
          return DoctorMainNavigation(doctor: doctor);
        }
        
        // Doctor not found, clear and go to selection
        final storage = GetStorage();
        storage.remove('user_type');
        storage.remove('doctor_id');
        return const UserTypeSelectionScreen();
      },
    );
  }
}
