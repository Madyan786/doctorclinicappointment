import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorclinic/core/constants/app_constants.dart';

enum AppointmentStatus { pending, awaitingApproval, confirmed, completed, cancelled, rejected }

class AppointmentModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorImage;
  final String doctorSpecialty;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final DateTime appointmentDate;
  final String timeSlot;
  final AppointmentStatus status;
  final double fee;
  final String? notes;
  final String? cancelReason;
  final DateTime createdAt;
  final String? paymentSlipUrl;
  final String? rejectionReason;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorImage,
    required this.doctorSpecialty,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.fee,
    this.notes,
    this.cancelReason,
    required this.createdAt,
    this.paymentSlipUrl,
    this.rejectionReason,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorImage: data['doctorImage'] ?? '',
      doctorSpecialty: data['doctorSpecialty'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientPhone: data['patientPhone'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      fee: (data['fee'] ?? 0).toDouble(),
      notes: data['notes'],
      cancelReason: data['cancelReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentSlipUrl: data['paymentSlipUrl'],
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImage': doctorImage,
      'doctorSpecialty': doctorSpecialty,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'status': status.name,
      'fee': fee,
      'notes': notes,
      'cancelReason': cancelReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentSlipUrl': paymentSlipUrl,
      'rejectionReason': rejectionReason,
      'appId': APP_ID,  // App identifier for filtering
    };
  }

  /// Create from Map (for local DB cache)
  factory AppointmentModel.fromMap(Map<String, dynamic> data) {
    return AppointmentModel(
      id: data['id'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorImage: data['doctorImage'] ?? '',
      doctorSpecialty: data['doctorSpecialty'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientPhone: data['patientPhone'] ?? '',
      appointmentDate: data['appointmentDate'] is int
          ? DateTime.fromMillisecondsSinceEpoch(data['appointmentDate'])
          : DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      status: _parseStatusFromString(data['status'] as String? ?? 'pending'),
      fee: (data['fee'] ?? 0).toDouble(),
      notes: data['notes'],
      cancelReason: data['cancelReason'],
      createdAt: data['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      paymentSlipUrl: data['paymentSlipUrl'],
      rejectionReason: data['rejectionReason'],
    );
  }

  static AppointmentStatus _parseStatusFromString(String status) {
    switch (status) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'awaitingApproval':
        return AppointmentStatus.awaitingApproval;
      case 'rejected':
        return AppointmentStatus.rejected;
      default:
        return AppointmentStatus.pending;
    }
  }

  AppointmentModel copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? doctorImage,
    String? doctorSpecialty,
    String? patientId,
    String? patientName,
    String? patientPhone,
    DateTime? appointmentDate,
    String? timeSlot,
    AppointmentStatus? status,
    double? fee,
    String? notes,
    String? cancelReason,
    DateTime? createdAt,
    String? paymentSlipUrl,
    String? rejectionReason,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorImage: doctorImage ?? this.doctorImage,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      fee: fee ?? this.fee,
      notes: notes ?? this.notes,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt ?? this.createdAt,
      paymentSlipUrl: paymentSlipUrl ?? this.paymentSlipUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  String get statusText {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.awaitingApproval:
        return 'Awaiting Approval';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.rejected:
        return 'Rejected';
    }
  }
}
