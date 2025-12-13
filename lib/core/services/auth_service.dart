import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'package:doctorclinic/core/constants/app_constants.dart';

enum UserType { patient, doctor, admin }

class AuthService extends GetxController {
  static AuthService get instance => Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  
  // Observable user
  Rx<User?> firebaseUser = Rx<User?>(null);
  
  // Loading state
  RxBool isLoading = false.obs;
  
  // Current user type
  Rx<UserType?> userType = Rx<UserType?>(null);
  
  // Get stored user type
  UserType? get storedUserType {
    final type = _storage.read('user_type');
    if (type == 'admin') return UserType.admin;
    if (type == 'doctor') return UserType.doctor;
    if (type == 'patient') return UserType.patient;
    return null;
  }
  
  // Set user type
  void setUserType(UserType type) {
    userType.value = type;
    _storage.write('user_type', type.name);
    developer.log('📱 User type set to: ${type.name}', name: 'AuthService');
  }
  
  // Clear user type on logout
  void clearUserType() {
    userType.value = null;
    _storage.remove('user_type');
  }

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user != null) {
      developer.log('✅ User logged in: ${user.email}', name: 'AuthService');
      if (user.emailVerified) {
        developer.log('✅ Email verified', name: 'AuthService');
      } else {
        developer.log('⚠️ Email not verified', name: 'AuthService');
      }
    } else {
      developer.log('❌ User logged out', name: 'AuthService');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // SIGN UP
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      developer.log('📝 Starting sign up for: $email', name: 'AuthService');
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      developer.log('✅ User created successfully', name: 'AuthService');
      
      // Send email verification
      await userCredential.user?.sendEmailVerification();
      developer.log('📧 Verification email sent to: $email', name: 'AuthService');
      
      Get.snackbar(
        'Success',
        'Verification email sent! Please check your inbox.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      
    } on FirebaseAuthException catch (e) {
      developer.log('❌ Sign up error: ${e.code} - ${e.message}', name: 'AuthService');
      _handleAuthError(e);
    } catch (e) {
      developer.log('❌ Unknown error: $e', name: 'AuthService');
      Get.snackbar('Error', 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // LOGIN
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      developer.log('🔐 Starting login for: $email', name: 'AuthService');
      
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        if (userCredential.user!.emailVerified) {
          developer.log('✅ Login successful - Email verified', name: 'AuthService');
          Get.snackbar(
            'Success',
            'Welcome back!',
            snackPosition: SnackPosition.TOP,
          );
          return true;
        } else {
          developer.log('⚠️ Email not verified', name: 'AuthService');
          Get.snackbar(
            'Email Not Verified',
            'Please verify your email first. Check your inbox.',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );
          // Resend verification email
          await userCredential.user!.sendEmailVerification();
          developer.log('📧 Verification email resent', name: 'AuthService');
          await _auth.signOut();
          return false;
        }
      }
      return false;
    } on FirebaseAuthException catch (e) {
      developer.log('❌ Login error: ${e.code} - ${e.message}', name: 'AuthService');
      _handleAuthError(e);
      return false;
    } catch (e) {
      developer.log('❌ Unknown error: $e', name: 'AuthService');
      Get.snackbar('Error', 'Something went wrong. Please try again.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // FORGOT PASSWORD
  Future<void> forgotPassword({required String email}) async {
    try {
      isLoading.value = true;
      developer.log('🔑 Sending password reset email to: $email', name: 'AuthService');
      
      await _auth.sendPasswordResetEmail(email: email);
      
      developer.log('✅ Password reset email sent', name: 'AuthService');
      Get.snackbar(
        'Success',
        'Password reset email sent! Check your inbox.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      
    } on FirebaseAuthException catch (e) {
      developer.log('❌ Forgot password error: ${e.code} - ${e.message}', name: 'AuthService');
      _handleAuthError(e);
    } catch (e) {
      developer.log('❌ Unknown error: $e', name: 'AuthService');
      Get.snackbar('Error', 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // CHANGE PASSWORD
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      isLoading.value = true;
      developer.log('🔑 Changing password...', name: 'AuthService');
      
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        Get.snackbar('Error', 'User not logged in');
        return false;
      }
      
      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
      
      developer.log('✅ Password changed successfully', name: 'AuthService');
      return true;
      
    } on FirebaseAuthException catch (e) {
      developer.log('❌ Change password error: ${e.code} - ${e.message}', name: 'AuthService');
      if (e.code == 'wrong-password') {
        Get.snackbar(
          'Error',
          'Current password is incorrect',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        _handleAuthError(e);
      }
      return false;
    } catch (e) {
      developer.log('❌ Unknown error: $e', name: 'AuthService');
      Get.snackbar('Error', 'Failed to change password');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      developer.log('👋 Logging out...', name: 'AuthService');
      await _auth.signOut();
      clearUserType();
      developer.log('✅ Logged out successfully', name: 'AuthService');
      Get.snackbar('Success', 'Logged out successfully');
    } catch (e) {
      developer.log('❌ Logout error: $e', name: 'AuthService');
      Get.snackbar('Error', 'Failed to logout');
    }
  }
  
  // Update user profile in Firestore
  Future<bool> updateUserProfile({
    required String name,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // Update display name in Firebase Auth
      await user.updateDisplayName(name);
      
      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': user.email,
        'phone': phone ?? '',
        'address': address ?? '',
        'profileImage': profileImage ?? '',
        'appId': APP_ID,  // App identifier for filtering
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      developer.log('✅ Profile updated successfully', name: 'AuthService');
      Get.snackbar('Success', 'Profile updated successfully');
      return true;
    } catch (e) {
      developer.log('❌ Profile update error: $e', name: 'AuthService');
      Get.snackbar('Error', 'Failed to update profile');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      developer.log('❌ Get profile error: $e', name: 'AuthService');
      return null;
    }
  }

  // Handle Firebase Auth Errors
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'weak-password':
        message = 'The password is too weak.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email.';
        break;
      case 'invalid-email':
        message = 'The email address is invalid.';
        break;
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Incorrect password.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password.';
        break;
      default:
        message = e.message ?? 'An error occurred.';
    }
    Get.snackbar('Error', message, snackPosition: SnackPosition.TOP);
  }
}
