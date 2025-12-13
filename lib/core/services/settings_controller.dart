import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:developer' as developer;

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();
  
  final _storage = GetStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Observables
  final RxBool isDarkMode = false.obs;
  final RxBool isNotificationsEnabled = true.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxBool canUseBiometric = false.obs;
  final RxString appVersion = '1.0.0'.obs;
  final RxString buildNumber = '1'.obs;
  
  // Keys for storage
  static const String _darkModeKey = 'dark_mode';
  static const String _notificationsKey = 'notifications';
  static const String _biometricKey = 'biometric';
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _checkBiometricAvailability();
    _loadAppInfo();
  }
  
  // Load settings from storage
  void _loadSettings() {
    isDarkMode.value = _storage.read(_darkModeKey) ?? false;
    isNotificationsEnabled.value = _storage.read(_notificationsKey) ?? true;
    isBiometricEnabled.value = _storage.read(_biometricKey) ?? false;
    
    // Apply theme
    _applyTheme();
    
    developer.log('✅ Settings loaded', name: 'SettingsController');
  }
  
  // Check if biometric is available
  Future<void> _checkBiometricAvailability() async {
    try {
      canUseBiometric.value = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();
      
      developer.log('Biometrics available: ${availableBiometrics.toString()}', 
          name: 'SettingsController');
    } catch (e) {
      developer.log('Biometric check failed: $e', name: 'SettingsController');
      canUseBiometric.value = false;
    }
  }
  
  // Load app info
  Future<void> _loadAppInfo() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      appVersion.value = info.version;
      buildNumber.value = info.buildNumber;
    } catch (e) {
      developer.log('Failed to load app info: $e', name: 'SettingsController');
    }
  }
  
  // Toggle dark mode
  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    _storage.write(_darkModeKey, value);
    _applyTheme();
    developer.log('Dark mode: $value', name: 'SettingsController');
  }
  
  // Apply theme
  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
  
  // Toggle notifications
  void toggleNotifications(bool value) {
    isNotificationsEnabled.value = value;
    _storage.write(_notificationsKey, value);
    developer.log('Notifications: $value', name: 'SettingsController');
    
    if (value) {
      Get.snackbar(
        'Notifications Enabled',
        'You will receive push notifications',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Notifications Disabled',
        'You will not receive push notifications',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  // Toggle biometric
  Future<void> toggleBiometric(bool value) async {
    if (value && canUseBiometric.value) {
      // Authenticate before enabling
      try {
        final bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Authenticate to enable biometric login',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
        
        if (authenticated) {
          isBiometricEnabled.value = true;
          _storage.write(_biometricKey, true);
          Get.snackbar(
            'Biometric Enabled',
            'You can now use fingerprint to login',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.9),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 2),
          );
        }
      } catch (e) {
        developer.log('Biometric auth failed: $e', name: 'SettingsController');
        Get.snackbar(
          'Authentication Failed',
          'Could not enable biometric login',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } else {
      isBiometricEnabled.value = false;
      _storage.write(_biometricKey, false);
    }
  }
  
  // Authenticate with biometric
  Future<bool> authenticateWithBiometric() async {
    if (!isBiometricEnabled.value || !canUseBiometric.value) {
      return true; // Skip if not enabled
    }
    
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      developer.log('Biometric auth error: $e', name: 'SettingsController');
      return false;
    }
  }
  
  // Share app
  Future<void> shareApp() async {
    try {
      await Share.share(
        'Check out Doctor Clinic App - Book appointments with trusted doctors!\n\nhttps://play.google.com/store/apps/details?id=com.doctorclinic.app',
        subject: 'Doctor Clinic - Healthcare App',
      );
    } catch (e) {
      developer.log('Share failed: $e', name: 'SettingsController');
    }
  }
  
  // Rate app
  Future<void> rateApp() async {
    const String playStoreUrl = 
        'https://play.google.com/store/apps/details?id=com.doctorclinic.app';
    const String appStoreUrl = 
        'https://apps.apple.com/app/doctor-clinic/id123456789';
    
    try {
      // Try Play Store first, then App Store
      final Uri url = Uri.parse(playStoreUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Coming Soon',
          'App store link will be available soon',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      developer.log('Rate app failed: $e', name: 'SettingsController');
    }
  }
  
  // Open privacy policy
  Future<void> openPrivacyPolicy() async {
    const String privacyUrl = 'https://doctorclinic.app/privacy-policy';
    
    try {
      final Uri url = Uri.parse(privacyUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showPrivacyPolicyDialog();
      }
    } catch (e) {
      _showPrivacyPolicyDialog();
    }
  }
  
  void _showPrivacyPolicyDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Doctor Clinic Privacy Policy\n\n'
            '1. Information Collection\n'
            'We collect information you provide directly to us, including your name, email, and medical appointment data.\n\n'
            '2. Use of Information\n'
            'We use your information to provide and improve our services, process appointments, and communicate with you.\n\n'
            '3. Data Security\n'
            'We implement appropriate security measures to protect your personal information.\n\n'
            '4. Contact Us\n'
            'For questions about this policy, contact us at privacy@doctorclinic.app',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  // Show about dialog
  void showAboutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF355CE4),
                    const Color(0xFF5F6FFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF355CE4).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Doctor Clinic',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${appVersion.value} (${buildNumber.value})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your trusted healthcare companion.\nBook appointments with verified doctors easily.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '© 2024 Doctor Clinic. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  // Reset all settings
  void resetSettings() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              isDarkMode.value = false;
              isNotificationsEnabled.value = true;
              isBiometricEnabled.value = false;
              
              _storage.write(_darkModeKey, false);
              _storage.write(_notificationsKey, true);
              _storage.write(_biometricKey, false);
              
              _applyTheme();
              
              Get.back();
              Get.snackbar(
                'Settings Reset',
                'All settings have been reset to default',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withOpacity(0.9),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
