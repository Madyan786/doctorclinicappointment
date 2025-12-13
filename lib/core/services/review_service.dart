import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/review_model.dart';
import '../models/doctor_model.dart';

class ReviewService extends GetxController {
  static ReviewService get to => Get.find<ReviewService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'reviews';

  final RxList<ReviewModel> allReviews = <ReviewModel>[].obs;
  final RxList<ReviewModel> doctorReviews = <ReviewModel>[].obs;
  final RxBool isLoading = false.obs;

  String? get currentUserId => _auth.currentUser?.uid;

  // Fetch all reviews (for admin)
  Future<void> fetchAllReviews() async {
    try {
      isLoading.value = true;
      developer.log('📥 Fetching all reviews...', name: 'ReviewService');

      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      allReviews.value = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();

      developer.log('✅ Fetched ${allReviews.length} reviews', name: 'ReviewService');
    } catch (e) {
      developer.log('❌ Error fetching reviews: $e', name: 'ReviewService');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch reviews for a specific doctor
  Future<List<ReviewModel>> fetchDoctorReviews(String doctorId) async {
    try {
      developer.log('📥 Fetching reviews for doctor: $doctorId', name: 'ReviewService');

      final snapshot = await _firestore
          .collection(_collection)
          .where('doctorId', isEqualTo: doctorId)
          .where('isApproved', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();

      doctorReviews.value = reviews;
      developer.log('✅ Fetched ${reviews.length} reviews for doctor', name: 'ReviewService');
      return reviews;
    } catch (e) {
      developer.log('❌ Error fetching doctor reviews: $e', name: 'ReviewService');
      return [];
    }
  }

  // Submit a new review
  Future<bool> submitReview({
    required DoctorModel doctor,
    required double rating,
    required String comment,
  }) async {
    if (currentUserId == null) {
      Get.snackbar('Error', 'Please login to submit a review');
      return false;
    }

    try {
      isLoading.value = true;
      developer.log('📝 Submitting review...', name: 'ReviewService');

      final user = _auth.currentUser;

      // Check if user already reviewed this doctor
      final existingReview = await _firestore
          .collection(_collection)
          .where('doctorId', isEqualTo: doctor.id)
          .where('patientId', isEqualTo: currentUserId)
          .get();

      if (existingReview.docs.isNotEmpty) {
        Get.snackbar('Already Reviewed', 'You have already reviewed this doctor');
        return false;
      }

      final review = ReviewModel(
        id: '',
        doctorId: doctor.id,
        doctorName: doctor.name,
        patientId: currentUserId!,
        patientName: user?.displayName ?? 'Patient',
        patientImage: user?.photoURL ?? '',
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        isApproved: true, // Auto-approve for now, can be changed to false for moderation
      );

      // Add review to Firestore
      await _firestore.collection(_collection).add(review.toFirestore());

      // Update doctor's rating
      await _updateDoctorRating(doctor.id);

      developer.log('✅ Review submitted successfully', name: 'ReviewService');
      Get.snackbar('Success', 'Thank you for your review!');
      return true;
    } catch (e) {
      developer.log('❌ Error submitting review: $e', name: 'ReviewService');
      Get.snackbar('Error', 'Failed to submit review');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update doctor's overall rating
  Future<void> _updateDoctorRating(String doctorId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection(_collection)
          .where('doctorId', isEqualTo: doctorId)
          .where('isApproved', isEqualTo: true)
          .get();

      if (reviewsSnapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += (doc.data()['rating'] ?? 0).toDouble();
      }

      final averageRating = totalRating / reviewsSnapshot.docs.length;
      final totalReviews = reviewsSnapshot.docs.length;

      await _firestore.collection('doctors').doc(doctorId).update({
        'rating': double.parse(averageRating.toStringAsFixed(1)),
        'totalReviews': totalReviews,
      });

      developer.log('✅ Doctor rating updated: $averageRating ($totalReviews reviews)', name: 'ReviewService');
    } catch (e) {
      developer.log('❌ Error updating doctor rating: $e', name: 'ReviewService');
    }
  }

  // Delete a review (admin only)
  Future<bool> deleteReview(String reviewId) async {
    try {
      isLoading.value = true;
      
      final reviewDoc = await _firestore.collection(_collection).doc(reviewId).get();
      final doctorId = reviewDoc.data()?['doctorId'];

      await _firestore.collection(_collection).doc(reviewId).delete();
      
      // Update doctor rating after deletion
      if (doctorId != null) {
        await _updateDoctorRating(doctorId);
      }

      await fetchAllReviews();
      Get.snackbar('Success', 'Review deleted successfully');
      return true;
    } catch (e) {
      developer.log('❌ Error deleting review: $e', name: 'ReviewService');
      Get.snackbar('Error', 'Failed to delete review');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Approve/Disapprove review (admin)
  Future<bool> toggleReviewApproval(String reviewId, bool isApproved) async {
    try {
      isLoading.value = true;
      
      final reviewDoc = await _firestore.collection(_collection).doc(reviewId).get();
      final doctorId = reviewDoc.data()?['doctorId'];

      await _firestore.collection(_collection).doc(reviewId).update({
        'isApproved': isApproved,
      });

      // Update doctor rating
      if (doctorId != null) {
        await _updateDoctorRating(doctorId);
      }

      await fetchAllReviews();
      Get.snackbar('Success', isApproved ? 'Review approved' : 'Review disapproved');
      return true;
    } catch (e) {
      developer.log('❌ Error toggling review approval: $e', name: 'ReviewService');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get average rating for a doctor
  double getAverageRating(String doctorId) {
    final reviews = doctorReviews.where((r) => r.doctorId == doctorId).toList();
    if (reviews.isEmpty) return 0;
    
    double total = reviews.fold(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  // Get review stats
  Map<String, dynamic> getReviewStats() {
    return {
      'total': allReviews.length,
      'approved': allReviews.where((r) => r.isApproved).length,
      'pending': allReviews.where((r) => !r.isApproved).length,
      'averageRating': allReviews.isEmpty 
          ? 0 
          : allReviews.fold(0.0, (sum, r) => sum + r.rating) / allReviews.length,
    };
  }

  // Stream of reviews for real-time updates
  Stream<List<ReviewModel>> reviewsStream(String doctorId) {
    return _firestore
        .collection(_collection)
        .where('doctorId', isEqualTo: doctorId)
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList());
  }
}
