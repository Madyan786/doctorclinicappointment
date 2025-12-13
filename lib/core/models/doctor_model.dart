import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorclinic/core/constants/app_constants.dart';

enum VerificationStatus { pending, approved, rejected }

class DoctorModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final String about;
  final String profileImage;
  final int experienceYears;
  final double rating;
  final int totalReviews;
  final double consultationFee;
  final bool isAvailable;
  final List<String> availableDays;
  final String startTime;
  final String endTime;
  final String hospitalName;
  final String hospitalAddress;
  final List<String> qualifications;
  final DateTime createdAt;
  // Verification fields
  final bool isVerified;
  final VerificationStatus verificationStatus;
  final String licenseNumber;
  final String rejectionReason;
  // Document uploads
  final String licenseDocument;  // License image URL
  final List<String> degreeImages;  // Degree certificate images

  DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.about,
    required this.profileImage,
    required this.experienceYears,
    required this.rating,
    required this.totalReviews,
    required this.consultationFee,
    required this.isAvailable,
    required this.availableDays,
    required this.startTime,
    required this.endTime,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.qualifications,
    required this.createdAt,
    this.isVerified = false,
    this.verificationStatus = VerificationStatus.pending,
    this.licenseNumber = '',
    this.rejectionReason = '',
    this.licenseDocument = '',
    this.degreeImages = const [],
  });

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      specialty: data['specialty'] ?? '',
      about: data['about'] ?? '',
      profileImage: data['profileImage'] ?? '',
      experienceYears: data['experienceYears'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      consultationFee: (data['consultationFee'] ?? 0).toDouble(),
      isAvailable: data['isAvailable'] ?? false,
      availableDays: List<String>.from(data['availableDays'] ?? []),
      startTime: data['startTime'] ?? '09:00',
      endTime: data['endTime'] ?? '17:00',
      hospitalName: data['hospitalName'] ?? '',
      hospitalAddress: data['hospitalAddress'] ?? '',
      qualifications: List<String>.from(data['qualifications'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: data['isVerified'] ?? false,
      verificationStatus: _parseVerificationStatus(data['verificationStatus']),
      licenseNumber: data['licenseNumber'] ?? '',
      rejectionReason: data['rejectionReason'] ?? '',
      licenseDocument: data['licenseDocument'] ?? '',
      degreeImages: List<String>.from(data['degreeImages'] ?? []),
    );
  }

  /// Create from Map (for local DB cache)
  factory DoctorModel.fromMap(Map<String, dynamic> data) {
    return DoctorModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      specialty: data['specialty'] ?? '',
      about: data['about'] ?? '',
      profileImage: data['profileImage'] ?? '',
      experienceYears: data['experienceYears'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      consultationFee: (data['consultationFee'] ?? 0).toDouble(),
      isAvailable: data['isAvailable'] ?? false,
      availableDays: List<String>.from(data['availableDays'] ?? []),
      startTime: data['startTime'] ?? '09:00',
      endTime: data['endTime'] ?? '17:00',
      hospitalName: data['hospitalName'] ?? '',
      hospitalAddress: data['hospitalAddress'] ?? '',
      qualifications: List<String>.from(data['qualifications'] ?? []),
      createdAt: data['createdAt'] is int 
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      isVerified: data['isVerified'] ?? false,
      verificationStatus: _parseVerificationStatus(data['verificationStatus']),
      licenseNumber: data['licenseNumber'] ?? '',
      rejectionReason: data['rejectionReason'] ?? '',
      licenseDocument: data['licenseDocument'] ?? '',
      degreeImages: List<String>.from(data['degreeImages'] ?? []),
    );
  }

  static VerificationStatus _parseVerificationStatus(String? status) {
    switch (status) {
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'specialty': specialty,
      'about': about,
      'profileImage': profileImage,
      'experienceYears': experienceYears,
      'rating': rating,
      'totalReviews': totalReviews,
      'consultationFee': consultationFee,
      'isAvailable': isAvailable,
      'availableDays': availableDays,
      'startTime': startTime,
      'endTime': endTime,
      'hospitalName': hospitalName,
      'hospitalAddress': hospitalAddress,
      'qualifications': qualifications,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVerified': isVerified,
      'verificationStatus': verificationStatus.name,
      'licenseNumber': licenseNumber,
      'rejectionReason': rejectionReason,
      'licenseDocument': licenseDocument,
      'degreeImages': degreeImages,
      'appId': APP_ID,  // App identifier for filtering
    };
  }

  DoctorModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? specialty,
    String? about,
    String? profileImage,
    int? experienceYears,
    double? rating,
    int? totalReviews,
    double? consultationFee,
    bool? isAvailable,
    List<String>? availableDays,
    String? startTime,
    String? endTime,
    String? hospitalName,
    String? hospitalAddress,
    List<String>? qualifications,
    DateTime? createdAt,
    bool? isVerified,
    VerificationStatus? verificationStatus,
    String? licenseNumber,
    String? rejectionReason,
    String? licenseDocument,
    List<String>? degreeImages,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialty: specialty ?? this.specialty,
      about: about ?? this.about,
      profileImage: profileImage ?? this.profileImage,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      consultationFee: consultationFee ?? this.consultationFee,
      isAvailable: isAvailable ?? this.isAvailable,
      availableDays: availableDays ?? this.availableDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hospitalName: hospitalName ?? this.hospitalName,
      hospitalAddress: hospitalAddress ?? this.hospitalAddress,
      qualifications: qualifications ?? this.qualifications,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      licenseDocument: licenseDocument ?? this.licenseDocument,
      degreeImages: degreeImages ?? this.degreeImages,
    );
  }
}
