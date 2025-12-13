import 'dart:developer' as developer;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import 'doctor_service.dart';
import 'notification_service.dart';

class AppointmentService extends GetxController {
  static AppointmentService get to => Get.find<AppointmentService>();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'appointments';

  final RxList<AppointmentModel> allAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> upcomingAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> completedAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> cancelledAppointments = <AppointmentModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserAppointments();
  }

  String? get currentUserId => _auth.currentUser?.uid;

  // Fetch all appointments for current user
  Future<void> fetchUserAppointments() async {
    if (currentUserId == null) return;
    
    try {
      isLoading.value = true;
      developer.log('📥 Fetching appointments...', name: 'AppointmentService');

      final snapshot = await _firestore
          .collection(_collection)
          .where('patientId', isEqualTo: currentUserId)
          .orderBy('appointmentDate', descending: true)
          .get();

      List<AppointmentModel> appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();

      // Fetch doctor images for appointments with missing images
      try {
        final doctorService = Get.find<DoctorService>();
        for (int i = 0; i < appointments.length; i++) {
          if (appointments[i].doctorImage.isEmpty) {
            final imageUrl = await doctorService.getDoctorImageUrl(appointments[i].doctorId);
            if (imageUrl.isNotEmpty) {
              appointments[i] = appointments[i].copyWith(doctorImage: imageUrl);
            }
          }
        }
      } catch (e) {
        developer.log('Could not fetch some doctor images: $e', name: 'AppointmentService');
      }

      allAppointments.value = appointments;
      _categorizeAppointments();
      
      developer.log('✅ Fetched ${allAppointments.length} appointments', name: 'AppointmentService');
    } catch (e) {
      developer.log('❌ Error fetching appointments: $e', name: 'AppointmentService');
    } finally {
      isLoading.value = false;
    }
  }

  void _categorizeAppointments() {
    final now = DateTime.now();
    
    upcomingAppointments.value = allAppointments
        .where((a) => 
            a.appointmentDate.isAfter(now) && 
            (a.status == AppointmentStatus.pending || 
             a.status == AppointmentStatus.confirmed ||
             a.status == AppointmentStatus.awaitingApproval))
        .toList();
    
    completedAppointments.value = allAppointments
        .where((a) => a.status == AppointmentStatus.completed)
        .toList();
    
    cancelledAppointments.value = allAppointments
        .where((a) => a.status == AppointmentStatus.cancelled || 
                      a.status == AppointmentStatus.rejected)
        .toList();
  }

  // Upload payment slip to Firebase Storage
  Future<String?> uploadPaymentSlip(File imageFile, String doctorId) async {
    try {
      final String fileName = 'payment_slips/${currentUserId}_${doctorId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      
      developer.log('✅ Payment slip uploaded: $downloadUrl', name: 'AppointmentService');
      return downloadUrl;
    } catch (e) {
      developer.log('❌ Error uploading payment slip: $e', name: 'AppointmentService');
      return null;
    }
  }

  // Book new appointment with payment slip
  Future<bool> bookAppointment({
    required DoctorModel doctor,
    required DateTime date,
    required String timeSlot,
    String? notes,
    String? paymentSlipUrl,
  }) async {
    if (currentUserId == null) {
      Get.snackbar('Error', 'Please login to book appointment');
      return false;
    }

    try {
      isLoading.value = true;
      developer.log('📅 Booking appointment...', name: 'AppointmentService');

      final user = _auth.currentUser!;
      
      // Check if slot is already booked
      final existingBooking = await _firestore
          .collection(_collection)
          .where('doctorId', isEqualTo: doctor.id)
          .where('appointmentDate', isEqualTo: Timestamp.fromDate(date))
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', whereIn: ['pending', 'confirmed', 'awaitingApproval'])
          .get();

      if (existingBooking.docs.isNotEmpty) {
        Get.snackbar('Slot Unavailable', 'This time slot is already booked or pending approval');
        return false;
      }

      // Get doctor image - use profileImage or fetch from storage
      String doctorImageUrl = doctor.profileImage;
      if (doctorImageUrl.isEmpty) {
        try {
          final doctorService = Get.find<DoctorService>();
          doctorImageUrl = await doctorService.getDoctorImageUrl(doctor.id);
        } catch (e) {
          developer.log('Could not fetch doctor image: $e', name: 'AppointmentService');
        }
      }

      final appointment = AppointmentModel(
        id: '',
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorImage: doctorImageUrl,
        doctorSpecialty: doctor.specialty,
        patientId: currentUserId!,
        patientName: user.displayName ?? 'Patient',
        patientPhone: user.phoneNumber ?? '',
        appointmentDate: date,
        timeSlot: timeSlot,
        status: paymentSlipUrl != null ? AppointmentStatus.awaitingApproval : AppointmentStatus.pending,
        fee: doctor.consultationFee,
        notes: notes,
        createdAt: DateTime.now(),
        paymentSlipUrl: paymentSlipUrl,
      );

      final docRef = await _firestore.collection(_collection).add(appointment.toFirestore());
      
      // Create appointment with ID for notifications
      final bookedAppointment = appointment.copyWith(id: docRef.id);
      
      // Show appropriate notification based on payment slip
      try {
        final notificationService = Get.find<NotificationService>();
        if (paymentSlipUrl != null) {
          await notificationService.showInstantNotification(
            title: '📝 Appointment Request Sent',
            body: 'Your appointment request with ${doctor.name} is awaiting approval. The doctor will review your payment slip.',
            payload: docRef.id,
          );
        } else {
          await notificationService.scheduleAppointmentReminder(bookedAppointment);
          await notificationService.showAppointmentBookedNotification(bookedAppointment);
        }
      } catch (e) {
        developer.log('⚠️ Could not schedule notifications: $e', name: 'AppointmentService');
      }
      
      await fetchUserAppointments();
      
      developer.log('✅ Appointment booked successfully', name: 'AppointmentService');
      final message = paymentSlipUrl != null 
          ? 'Appointment request sent! Awaiting doctor approval.'
          : 'Appointment booked successfully!';
      Get.snackbar('Success', message);
      return true;
    } catch (e) {
      developer.log('❌ Error booking appointment: $e', name: 'AppointmentService');
      Get.snackbar('Error', 'Failed to book appointment');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel appointment
  Future<bool> cancelAppointment(String appointmentId, String reason) async {
    try {
      isLoading.value = true;
      
      await _firestore.collection(_collection).doc(appointmentId).update({
        'status': AppointmentStatus.cancelled.name,
        'cancelReason': reason,
      });

      // Cancel scheduled notifications
      try {
        final notificationService = Get.find<NotificationService>();
        await notificationService.cancelAppointmentReminder(appointmentId);
      } catch (e) {
        developer.log('⚠️ Could not cancel notifications: $e', name: 'AppointmentService');
      }

      await fetchUserAppointments();
      
      Get.snackbar('Cancelled', 'Appointment cancelled successfully');
      return true;
    } catch (e) {
      developer.log('❌ Error cancelling appointment: $e', name: 'AppointmentService');
      Get.snackbar('Error', 'Failed to cancel appointment');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Reschedule appointment
  Future<bool> rescheduleAppointment(
    String appointmentId,
    DateTime newDate,
    String newTimeSlot,
  ) async {
    try {
      isLoading.value = true;
      
      await _firestore.collection(_collection).doc(appointmentId).update({
        'appointmentDate': Timestamp.fromDate(newDate),
        'timeSlot': newTimeSlot,
        'status': AppointmentStatus.pending.name,
      });

      await fetchUserAppointments();
      
      Get.snackbar('Success', 'Appointment rescheduled successfully');
      return true;
    } catch (e) {
      developer.log('❌ Error rescheduling appointment: $e', name: 'AppointmentService');
      Get.snackbar('Error', 'Failed to reschedule appointment');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Doctor accepts appointment
  Future<bool> acceptAppointment(String appointmentId) async {
    try {
      isLoading.value = true;
      
      // Get appointment data first
      final doc = await _firestore.collection(_collection).doc(appointmentId).get();
      if (!doc.exists) {
        Get.snackbar('Error', 'Appointment not found');
        return false;
      }
      
      final appointment = AppointmentModel.fromFirestore(doc);
      
      await _firestore.collection(_collection).doc(appointmentId).update({
        'status': AppointmentStatus.confirmed.name,
      });

      // Send notification to patient
      try {
        final notificationService = Get.find<NotificationService>();
        await notificationService.showInstantNotification(
          title: '✅ Appointment Confirmed!',
          body: 'Your appointment with Dr. ${appointment.doctorName} on ${_formatDate(appointment.appointmentDate)} at ${appointment.timeSlot} has been confirmed.',
          payload: appointmentId,
        );
      } catch (e) {
        developer.log('⚠️ Could not send notification: $e', name: 'AppointmentService');
      }

      Get.snackbar('Success', 'Appointment accepted successfully');
      return true;
    } catch (e) {
      developer.log('❌ Error accepting appointment: $e', name: 'AppointmentService');
      Get.snackbar('Error', 'Failed to accept appointment');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Doctor rejects appointment
  Future<bool> rejectAppointment(String appointmentId, String reason) async {
    try {
      isLoading.value = true;
      
      // Get appointment data first
      final doc = await _firestore.collection(_collection).doc(appointmentId).get();
      if (!doc.exists) {
        Get.snackbar('Error', 'Appointment not found');
        return false;
      }
      
      final appointment = AppointmentModel.fromFirestore(doc);
      
      await _firestore.collection(_collection).doc(appointmentId).update({
        'status': AppointmentStatus.rejected.name,
        'rejectionReason': reason,
      });

      // Send notification to patient
      try {
        final notificationService = Get.find<NotificationService>();
        await notificationService.showInstantNotification(
          title: '❌ Appointment Rejected',
          body: 'Your appointment with Dr. ${appointment.doctorName} was rejected. Reason: $reason',
          payload: appointmentId,
        );
      } catch (e) {
        developer.log('⚠️ Could not send notification: $e', name: 'AppointmentService');
      }

      Get.snackbar('Rejected', 'Appointment rejected');
      return true;
    } catch (e) {
      developer.log('❌ Error rejecting appointment: $e', name: 'AppointmentService');
      Get.snackbar('Error', 'Failed to reject appointment');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  // Get booked slots for a doctor on a specific date
  Future<List<String>> getBookedSlots(String doctorId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(_collection)
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('appointmentDate', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: ['pending', 'confirmed', 'awaitingApproval'])
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['timeSlot'] as String)
          .toList();
    } catch (e) {
      developer.log('❌ Error getting booked slots: $e', name: 'AppointmentService');
      return [];
    }
  }

  // Stream for real-time updates
  Stream<List<AppointmentModel>> streamUserAppointments() {
    if (currentUserId == null) return const Stream.empty();
    
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: currentUserId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }
}
