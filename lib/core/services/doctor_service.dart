import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../models/doctor_model.dart';

class DoctorService extends GetxController {
  static DoctorService get to => Get.find<DoctorService>();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'doctors';
  final String _imageFolder = 'doctor_images';

  final RxList<DoctorModel> doctors = <DoctorModel>[].obs;
  final RxList<DoctorModel> filteredDoctors = <DoctorModel>[].obs;
  final RxList<String> specialties = <String>['All'].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedSpecialty = 'All'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
  }

  // Get doctor image URL from Firebase Storage
  Future<String> getDoctorImageUrl(String doctorId) async {
    try {
      // Try different file extensions
      final extensions = ['jpg', 'jpeg', 'png', 'webp'];
      
      for (final ext in extensions) {
        try {
          final ref = _storage.ref().child('$_imageFolder/$doctorId.$ext');
          final url = await ref.getDownloadURL();
          developer.log('✅ Found image for doctor $doctorId: $ext', name: 'DoctorService');
          return url;
        } catch (_) {
          // Try next extension
          continue;
        }
      }
      
      // If no image found with doctorId, return empty
      developer.log('⚠️ No image found for doctor $doctorId', name: 'DoctorService');
      return '';
    } catch (e) {
      developer.log('❌ Error getting doctor image: $e', name: 'DoctorService');
      return '';
    }
  }

  // Fetch all doctors from Firebase
  Future<void> fetchDoctors() async {
    try {
      isLoading.value = true;
      developer.log('📥 Fetching doctors...', name: 'DoctorService');

      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('rating', descending: true)
          .get();

      List<DoctorModel> doctorList = snapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc))
          .toList();

      // Fetch images from Storage for doctors without imageUrl
      for (int i = 0; i < doctorList.length; i++) {
        final doctor = doctorList[i];
        if (doctor.profileImage.isEmpty || !doctor.profileImage.startsWith('http')) {
          final imageUrl = await getDoctorImageUrl(doctor.id);
          if (imageUrl.isNotEmpty) {
            doctorList[i] = doctor.copyWith(profileImage: imageUrl);
          }
        }
      }

      doctors.value = doctorList;

      // Extract unique specialties
      final uniqueSpecialties = doctors
          .map((d) => d.specialty)
          .toSet()
          .toList();
      specialties.value = ['All', ...uniqueSpecialties];

      applyFilters();
      
      developer.log('✅ Fetched ${doctors.length} doctors', name: 'DoctorService');
    } catch (e) {
      developer.log('❌ Error fetching doctors: $e', name: 'DoctorService');
      Get.snackbar('Error', 'Failed to load doctors');
    } finally {
      isLoading.value = false;
    }
  }

  // Get doctor by ID
  Future<DoctorModel?> getDoctorById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return DoctorModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      developer.log('❌ Error getting doctor: $e', name: 'DoctorService');
      return null;
    }
  }

  // Get doctors by specialty
  List<DoctorModel> getDoctorsBySpecialty(String specialty) {
    if (specialty == 'All') return doctors;
    return doctors.where((d) => d.specialty == specialty).toList();
  }

  // Search doctors
  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Set specialty filter
  void setSpecialtyFilter(String specialty) {
    selectedSpecialty.value = specialty;
    applyFilters();
  }

  // Apply all filters
  void applyFilters() {
    List<DoctorModel> result = doctors.toList();

    // Filter by specialty
    if (selectedSpecialty.value != 'All') {
      result = result.where((d) => d.specialty == selectedSpecialty.value).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      result = result.where((d) =>
          d.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          d.specialty.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          d.hospitalName.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    filteredDoctors.value = result;
  }

  // Get available time slots for a doctor on a specific date
  List<String> getAvailableTimeSlots(DoctorModel doctor, DateTime date) {
    List<String> slots = [];
    
    // Parse start and end times
    final startParts = doctor.startTime.split(':');
    final endParts = doctor.endTime.split(':');
    
    int startHour = int.parse(startParts[0]);
    int endHour = int.parse(endParts[0]);
    
    // Generate 30-minute slots
    for (int hour = startHour; hour < endHour; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      slots.add('${hour.toString().padLeft(2, '0')}:30');
    }
    
    return slots;
  }

  // Get top rated doctors
  List<DoctorModel> getTopDoctors({int limit = 8}) {
    final sorted = doctors.toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  // Get available doctors only
  List<DoctorModel> getAvailableDoctors() {
    return doctors.where((d) => d.isAvailable).toList();
  }

  // Stream for real-time updates
  Stream<List<DoctorModel>> streamDoctors() {
    return _firestore
        .collection(_collection)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DoctorModel.fromFirestore(doc))
            .toList());
  }

  // Get doctor by email (for doctor login)
  Future<DoctorModel?> getDoctorByEmail(String email) async {
    try {
      developer.log('🔍 Finding doctor by email: $email', name: 'DoctorService');
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        developer.log('⚠️ No doctor found with email: $email', name: 'DoctorService');
        return null;
      }

      final doctor = DoctorModel.fromFirestore(snapshot.docs.first);
      developer.log('✅ Found doctor: ${doctor.name}', name: 'DoctorService');
      return doctor;
    } catch (e) {
      developer.log('❌ Error finding doctor by email: $e', name: 'DoctorService');
      return null;
    }
  }

  // Create new doctor profile
  Future<DoctorModel?> createDoctor(DoctorModel doctor) async {
    try {
      developer.log('📝 Creating doctor profile...', name: 'DoctorService');
      
      final docRef = await _firestore.collection(_collection).add(doctor.toFirestore());
      
      final newDoctor = doctor.copyWith(id: docRef.id);
      doctors.add(newDoctor);
      applyFilters();
      
      developer.log('✅ Doctor profile created: ${docRef.id}', name: 'DoctorService');
      return newDoctor;
    } catch (e) {
      developer.log('❌ Error creating doctor: $e', name: 'DoctorService');
      return null;
    }
  }

  // Update doctor profile
  Future<bool> updateDoctor(String doctorId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(doctorId).update(data);
      
      // Update local list
      final index = doctors.indexWhere((d) => d.id == doctorId);
      if (index != -1) {
        await fetchDoctors(); // Refresh to get updated data
      }
      
      developer.log('✅ Doctor updated: $doctorId', name: 'DoctorService');
      return true;
    } catch (e) {
      developer.log('❌ Error updating doctor: $e', name: 'DoctorService');
      return false;
    }
  }
}
