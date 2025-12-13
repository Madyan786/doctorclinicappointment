import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/models.dart';

/// Admin Service for managing all admin panel data
class AdminService extends GetxController {
  static AdminService get to => Get.find<AdminService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable lists
  final RxList<DoctorModel> doctors = <DoctorModel>[].obs;
  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<AdminModel> admins = <AdminModel>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;

  // Stats
  int get totalDoctors => doctors.length;
  int get totalAppointments => appointments.length;
  int get totalReviews => reviews.length;
  int get totalUsers => users.length;
  int get pendingAppointments => appointments.where((a) => a.status == AppointmentStatus.pending).length;
  int get pendingReviews => reviews.where((r) => !r.isApproved).length;
  int get approvedReviews => reviews.where((r) => r.isApproved).length;

  double get averageRating {
    if (reviews.isEmpty) return 0;
    return reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
  }

  // Fetch all doctors
  Future<void> fetchDoctors() async {
    try {
      isLoading.value = true;
      developer.log('📥 Fetching all doctors...', name: 'AdminService');

      final snapshot = await _firestore
          .collection('doctors')
          .orderBy('createdAt', descending: true)
          .get();

      doctors.value = snapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc))
          .toList();

      developer.log('✅ Fetched ${doctors.length} doctors', name: 'AdminService');
    } catch (e) {
      developer.log('❌ Error fetching doctors: $e', name: 'AdminService');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch all appointments
  Future<void> fetchAppointments() async {
    try {
      isLoading.value = true;
      developer.log('📥 Fetching all appointments...', name: 'AdminService');

      final snapshot = await _firestore
          .collection('appointments')
          .orderBy('appointmentDate', descending: true)
          .get();

      appointments.value = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();

      developer.log('✅ Fetched ${appointments.length} appointments', name: 'AdminService');
    } catch (e) {
      developer.log('❌ Error fetching appointments: $e', name: 'AdminService');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch all reviews
  Future<void> fetchReviews() async {
    try {
      isLoading.value = true;
      developer.log('📥 Fetching all reviews...', name: 'AdminService');

      final snapshot = await _firestore
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      reviews.value = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();

      developer.log('✅ Fetched ${reviews.length} reviews', name: 'AdminService');
    } catch (e) {
      developer.log('❌ Error fetching reviews: $e', name: 'AdminService');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch all users
  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      developer.log('📥 Fetching all users...', name: 'AdminService');

      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      users.value = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      developer.log('✅ Fetched ${users.length} users', name: 'AdminService');
    } catch (e) {
      developer.log('❌ Error fetching users: $e', name: 'AdminService');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch all admins
  Future<void> fetchAdmins() async {
    try {
      isLoading.value = true;
      developer.log('📥 Fetching all admins...', name: 'AdminService');

      final snapshot = await _firestore
          .collection('admins')
          .get();

      admins.value = snapshot.docs
          .map((doc) => AdminModel.fromFirestore(doc))
          .toList();

      developer.log('✅ Fetched ${admins.length} admins', name: 'AdminService');
    } catch (e) {
      developer.log('❌ Error fetching admins: $e', name: 'AdminService');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch all data for admin dashboard
  Future<void> fetchAllData() async {
    await Future.wait([
      fetchDoctors(),
      fetchAppointments(),
      fetchReviews(),
      fetchUsers(),
      fetchAdmins(),
    ]);
  }

  // Approve/Disapprove review
  Future<bool> toggleReviewApproval(String reviewId, bool isApproved) async {
    try {
      isLoading.value = true;

      await _firestore.collection('reviews').doc(reviewId).update({
        'isApproved': isApproved,
      });

      // Update local list
      final index = reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        reviews[index] = reviews[index].copyWith(isApproved: isApproved);
      }

      // Update doctor rating
      final review = reviews.firstWhereOrNull((r) => r.id == reviewId);
      if (review != null) {
        await _updateDoctorRating(review.doctorId);
      }

      Get.snackbar('Success', isApproved ? 'Review approved' : 'Review disapproved');
      return true;
    } catch (e) {
      developer.log('❌ Error toggling review: $e', name: 'AdminService');
      Get.snackbar('Error', 'Failed to update review');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete review
  Future<bool> deleteReview(String reviewId) async {
    try {
      isLoading.value = true;

      final review = reviews.firstWhereOrNull((r) => r.id == reviewId);
      await _firestore.collection('reviews').doc(reviewId).delete();

      reviews.removeWhere((r) => r.id == reviewId);

      // Update doctor rating
      if (review != null) {
        await _updateDoctorRating(review.doctorId);
      }

      Get.snackbar('Success', 'Review deleted');
      return true;
    } catch (e) {
      developer.log('❌ Error deleting review: $e', name: 'AdminService');
      Get.snackbar('Error', 'Failed to delete review');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update doctor rating after review changes
  Future<void> _updateDoctorRating(String doctorId) async {
    try {
      final doctorReviews = reviews
          .where((r) => r.doctorId == doctorId && r.isApproved)
          .toList();

      if (doctorReviews.isEmpty) {
        await _firestore.collection('doctors').doc(doctorId).update({
          'rating': 0,
          'totalReviews': 0,
        });
        return;
      }

      final totalRating = doctorReviews.fold(0.0, (sum, r) => sum + r.rating);
      final averageRating = totalRating / doctorReviews.length;

      await _firestore.collection('doctors').doc(doctorId).update({
        'rating': double.parse(averageRating.toStringAsFixed(1)),
        'totalReviews': doctorReviews.length,
      });

      developer.log('✅ Updated doctor rating: $averageRating', name: 'AdminService');
    } catch (e) {
      developer.log('❌ Error updating doctor rating: $e', name: 'AdminService');
    }
  }

  // Update appointment status
  Future<bool> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    try {
      isLoading.value = true;

      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status.name,
      });

      // Update local list
      final index = appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        appointments[index] = appointments[index].copyWith(status: status);
      }

      Get.snackbar('Success', 'Appointment status updated');
      return true;
    } catch (e) {
      developer.log('❌ Error updating appointment: $e', name: 'AdminService');
      Get.snackbar('Error', 'Failed to update appointment');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get dashboard stats
  Map<String, dynamic> getDashboardStats() {
    return {
      'totalDoctors': totalDoctors,
      'totalAppointments': totalAppointments,
      'totalReviews': totalReviews,
      'totalUsers': totalUsers,
      'pendingAppointments': pendingAppointments,
      'pendingReviews': pendingReviews,
      'approvedReviews': approvedReviews,
      'averageRating': averageRating.toStringAsFixed(1),
    };
  }

  // Streams for real-time updates
  Stream<List<ReviewModel>> get reviewsStream => _firestore
      .collection('reviews')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList());

  Stream<List<AppointmentModel>> get appointmentsStream => _firestore
      .collection('appointments')
      .orderBy('appointmentDate', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList());
}
