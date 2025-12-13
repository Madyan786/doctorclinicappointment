import 'package:cloud_firestore/cloud_firestore.dart';

enum AdminRole { admin, superAdmin }

class AdminModel {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final DateTime createdAt;

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = AdminRole.admin,
    required this.createdAt,
  });

  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] == 'super_admin' ? AdminRole.superAdmin : AdminRole.admin,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role == AdminRole.superAdmin ? 'super_admin' : 'admin',
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AdminModel copyWith({
    String? id,
    String? name,
    String? email,
    AdminRole? role,
    DateTime? createdAt,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
