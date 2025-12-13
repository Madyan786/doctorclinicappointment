import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../models/review_model.dart';
import '../services/local_db_service.dart';

/// Main App Provider - Central State Management with Local Caching
class AppProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final LocalDbService _localDb = LocalDbService();
  final ImagePicker _picker = ImagePicker();

  // State Variables
  List<DoctorModel> _doctors = [];
  List<DoctorModel> _filteredDoctors = [];
  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> _upcomingAppointments = [];
  List<AppointmentModel> _completedAppointments = [];
  List<AppointmentModel> _cancelledAppointments = [];
  List<ReviewModel> _reviews = [];
  List<String> _specialties = ['All'];
  
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasInternet = true;
  String _selectedSpecialty = 'All';
  String _searchQuery = '';
  String? _errorMessage;

  // Getters
  List<DoctorModel> get doctors => _filteredDoctors;
  List<DoctorModel> get allDoctors => _doctors;
  List<AppointmentModel> get appointments => _appointments;
  List<AppointmentModel> get upcomingAppointments => _upcomingAppointments;
  List<AppointmentModel> get completedAppointments => _completedAppointments;
  List<AppointmentModel> get cancelledAppointments => _cancelledAppointments;
  List<ReviewModel> get reviews => _reviews;
  List<String> get specialties => _specialties;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasInternet => _hasInternet;
  String get selectedSpecialty => _selectedSpecialty;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    await _localDb.init();
    await _checkConnectivity();
    _listenToConnectivity();
  }

  // ============== CONNECTIVITY ==============
  
  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _hasInternet = result != ConnectivityResult.none;
    notifyListeners();
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      _hasInternet = result != ConnectivityResult.none;
      if (_hasInternet) {
        // Auto refresh when internet comes back
        refreshAllData();
      }
      notifyListeners();
    });
  }

  // ============== DOCTORS ==============

  /// Fetch doctors - First from cache, then from Firebase
  Future<void> fetchDoctors({bool forceRefresh = false}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load from cache first (instant display)
      if (!forceRefresh) {
        final cachedDoctors = await _localDb.getCachedDoctors();
        if (cachedDoctors.isNotEmpty) {
          _doctors = cachedDoctors;
          _filterDoctors();
          _extractSpecialties();
          notifyListeners();
          developer.log('📦 Loaded ${cachedDoctors.length} doctors from cache', name: 'AppProvider');
        }
      }

      // Fetch from Firebase
      if (_hasInternet) {
        final snapshot = await _firestore
            .collection('doctors')
            .where('verificationStatus', isEqualTo: 'approved')
            .where('isVerified', isEqualTo: true)
            .orderBy('rating', descending: true)
            .get();

        _doctors = snapshot.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList();
        
        // Cache the data
        await _localDb.cacheDoctors(_doctors);
        
        _filterDoctors();
        _extractSpecialties();
        
        developer.log('✅ Fetched ${_doctors.length} doctors from Firebase', name: 'AppProvider');
      }
    } catch (e) {
      developer.log('❌ Error fetching doctors: $e', name: 'AppProvider');
      _errorMessage = 'Failed to load doctors';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pull to refresh doctors
  Future<void> refreshDoctors() async {
    _isRefreshing = true;
    notifyListeners();
    
    await fetchDoctors(forceRefresh: true);
    
    _isRefreshing = false;
    notifyListeners();
  }

  void _filterDoctors() {
    _filteredDoctors = _doctors.where((doctor) {
      bool matchesSpecialty = _selectedSpecialty == 'All' || 
                              doctor.specialty == _selectedSpecialty;
      bool matchesSearch = _searchQuery.isEmpty ||
                          doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          doctor.specialty.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          doctor.hospitalName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSpecialty && matchesSearch;
    }).toList();
  }

  void _extractSpecialties() {
    final specs = _doctors.map((d) => d.specialty).toSet().toList();
    specs.sort();
    _specialties = ['All', ...specs];
  }

  void setSpecialtyFilter(String specialty) {
    _selectedSpecialty = specialty;
    _filterDoctors();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterDoctors();
    notifyListeners();
  }

  Future<DoctorModel?> getDoctorById(String id) async {
    // Check in memory first
    final local = _doctors.where((d) => d.id == id).firstOrNull;
    if (local != null) return local;

    // Fetch from Firebase
    try {
      final doc = await _firestore.collection('doctors').doc(id).get();
      if (doc.exists) {
        return DoctorModel.fromFirestore(doc);
      }
    } catch (e) {
      developer.log('❌ Error getting doctor: $e', name: 'AppProvider');
    }
    return null;
  }

  List<DoctorModel> getTopRatedDoctors({int limit = 5}) {
    final sorted = List<DoctorModel>.from(_doctors);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  // ============== APPOINTMENTS ==============

  Future<void> fetchAppointments({bool forceRefresh = false}) async {
    if (currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Load from cache first
      if (!forceRefresh) {
        final cached = await _localDb.getCachedAppointments(currentUser!.uid);
        if (cached.isNotEmpty) {
          _appointments = cached;
          _categorizeAppointments();
          notifyListeners();
          developer.log('📦 Loaded ${cached.length} appointments from cache', name: 'AppProvider');
        }
      }

      // Fetch from Firebase
      if (_hasInternet) {
        final snapshot = await _firestore
            .collection('appointments')
            .where('patientId', isEqualTo: currentUser!.uid)
            .orderBy('appointmentDate', descending: true)
            .get();

        _appointments = snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
        
        // Cache
        await _localDb.cacheAppointments(_appointments, currentUser!.uid);
        
        _categorizeAppointments();
        developer.log('✅ Fetched ${_appointments.length} appointments from Firebase', name: 'AppProvider');
      }
    } catch (e) {
      developer.log('❌ Error fetching appointments: $e', name: 'AppProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAppointments() async {
    _isRefreshing = true;
    notifyListeners();
    
    await fetchAppointments(forceRefresh: true);
    
    _isRefreshing = false;
    notifyListeners();
  }

  void _categorizeAppointments() {
    final now = DateTime.now();
    
    _upcomingAppointments = _appointments.where((a) =>
        (a.status == AppointmentStatus.pending || a.status == AppointmentStatus.confirmed) &&
        a.appointmentDate.isAfter(now.subtract(const Duration(days: 1)))
    ).toList();

    _completedAppointments = _appointments.where((a) =>
        a.status == AppointmentStatus.completed
    ).toList();

    _cancelledAppointments = _appointments.where((a) =>
        a.status == AppointmentStatus.cancelled
    ).toList();
  }

  Future<bool> bookAppointment({
    required DoctorModel doctor,
    required DateTime date,
    required String timeSlot,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = currentUser;
      if (user == null) return false;

      // Check slot availability
      final existing = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctor.id)
          .where('appointmentDate', isEqualTo: Timestamp.fromDate(date))
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      if (existing.docs.isNotEmpty) {
        _errorMessage = 'This slot is already booked';
        return false;
      }

      final appointment = {
        'doctorId': doctor.id,
        'doctorName': doctor.name,
        'doctorImage': doctor.profileImage,
        'doctorSpecialty': doctor.specialty,
        'patientId': user.uid,
        'patientName': user.displayName ?? 'Patient',
        'patientPhone': user.phoneNumber ?? '',
        'appointmentDate': Timestamp.fromDate(date),
        'timeSlot': timeSlot,
        'status': 'pending',
        'fee': doctor.consultationFee,
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('appointments').add(appointment);
      
      await fetchAppointments(forceRefresh: true);
      
      developer.log('✅ Appointment booked successfully', name: 'AppProvider');
      return true;
    } catch (e) {
      developer.log('❌ Error booking appointment: $e', name: 'AppProvider');
      _errorMessage = 'Failed to book appointment';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(String appointmentId, String reason) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
        'cancelReason': reason,
      });
      
      await fetchAppointments(forceRefresh: true);
      return true;
    } catch (e) {
      developer.log('❌ Error cancelling: $e', name: 'AppProvider');
      return false;
    }
  }

  Future<List<String>> getBookedSlots(String doctorId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('appointmentDate', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      return snapshot.docs.map((doc) => doc['timeSlot'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // ============== REVIEWS ==============

  Future<void> fetchDoctorReviews(String doctorId, {bool forceRefresh = false}) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_hasInternet) {
        final snapshot = await _firestore
            .collection('reviews')
            .where('doctorId', isEqualTo: doctorId)
            .where('isApproved', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .get();

        _reviews = snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
      }
    } catch (e) {
      developer.log('❌ Error fetching reviews: $e', name: 'AppProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview({
    required String doctorId,
    required String doctorName,
    required double rating,
    required String comment,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      await _firestore.collection('reviews').add({
        'doctorId': doctorId,
        'doctorName': doctorName,
        'patientId': user.uid,
        'patientName': user.displayName ?? 'Patient',
        'patientImage': user.photoURL ?? '',
        'rating': rating,
        'comment': comment,
        'isApproved': false, // Admin will approve
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      developer.log('❌ Error submitting review: $e', name: 'AppProvider');
      return false;
    }
  }

  // ============== IMAGE UPLOAD ==============

  Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      developer.log('❌ Error picking image: $e', name: 'AppProvider');
    }
    return null;
  }

  Future<String?> uploadDoctorImage(File imageFile, String doctorId) async {
    try {
      final ref = _storage.ref().child('doctor_images/$doctorId/profile.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      developer.log('❌ Error uploading image: $e', name: 'AppProvider');
      return null;
    }
  }

  Future<String?> uploadDegreeImage(File imageFile, String doctorId, int index) async {
    try {
      final ref = _storage.ref().child('doctor_documents/$doctorId/degree_$index.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      developer.log('❌ Error uploading degree: $e', name: 'AppProvider');
      return null;
    }
  }

  Future<String?> uploadLicenseImage(File imageFile, String doctorId) async {
    try {
      final ref = _storage.ref().child('doctor_documents/$doctorId/license.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      developer.log('❌ Error uploading license: $e', name: 'AppProvider');
      return null;
    }
  }

  // ============== REFRESH ALL ==============

  Future<void> refreshAllData() async {
    _isRefreshing = true;
    notifyListeners();

    await Future.wait([
      fetchDoctors(forceRefresh: true),
      fetchAppointments(forceRefresh: true),
    ]);

    _isRefreshing = false;
    notifyListeners();
  }

  // ============== CLEAR ==============

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> clearAllCache() async {
    await _localDb.clearAll();
    _doctors = [];
    _filteredDoctors = [];
    _appointments = [];
    notifyListeners();
  }
}
