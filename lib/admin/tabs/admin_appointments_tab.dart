import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

/// Admin Appointments Tab - View & Manage All Appointments
class AdminAppointmentsTab extends StatefulWidget {
  const AdminAppointmentsTab({super.key});

  @override
  State<AdminAppointmentsTab> createState() => _AdminAppointmentsTabState();
}

class _AdminAppointmentsTabState extends State<AdminAppointmentsTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _filters = [
    {'label': 'All', 'value': 'all', 'color': Colors.blue},
    {'label': 'Pending', 'value': 'pending', 'color': Colors.orange},
    {'label': 'Confirmed', 'value': 'confirmed', 'color': Colors.blue},
    {'label': 'Completed', 'value': 'completed', 'color': Colors.green},
    {'label': 'Cancelled', 'value': 'cancelled', 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildSearchBar(isDark),
        _buildFilterChips(isDark),
        Expanded(child: _buildAppointmentsList(isDark)),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 10.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white : AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search by patient or doctor name...',
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.grey),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 10.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter['value'];
          
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter['value']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? LinearGradient(
                        colors: [filter['color'].withOpacity(0.8), filter['color']],
                      )
                    : null,
                color: isSelected ? null : (isDark ? const Color(0xFF1A1A2E) : Colors.white),
                borderRadius: BorderRadius.circular(25.r),
                border: isSelected ? null : Border.all(
                  color: isDark ? Colors.white24 : AppColors.lightGrey,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: (filter['color'] as Color).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Text(
                filter['label'],
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textSecondary),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList(bool isDark) {
    // Simple query without orderBy to avoid index requirement
    Stream<QuerySnapshot> stream;
    if (_selectedFilter != 'all') {
      stream = _firestore
          .collection('appointments')
          .where('status', isEqualTo: _selectedFilter)
          .snapshots();
    } else {
      stream = _firestore.collection('appointments').snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 50.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 14.sp)),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(isDark);
        }

        var appointments = snapshot.data!.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList();

        // Filter by appId (only show this app's appointments)
        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['appId'] == APP_ID || data['appId'] == null;
        }).toList();
        appointments = filteredDocs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();

        // Sort locally by date
        appointments.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

        // Filter by search
        if (_searchQuery.isNotEmpty) {
          appointments = appointments.where((a) =>
              a.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              a.doctorName.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        if (appointments.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            
            if (isTablet) {
              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 0.75,
                ),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  return _buildAppointmentCard(appointments[index], isDark);
                },
              );
            }
            
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return _buildAppointmentCard(appointments[index], isDark);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_today_rounded, size: 50.sp, color: AppColors.primary),
          ),
          SizedBox(height: 20.h),
          Text(
            'No appointments found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, bool isDark) {
    final statusColor = _getStatusColor(appointment.status);
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                // Date Card
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        appointment.appointmentDate.day.toString(),
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(appointment.appointmentDate),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14.sp, color: AppColors.grey),
                          SizedBox(width: 4.w),
                          Text(
                            appointment.timeSlot,
                            style: TextStyle(fontSize: 13.sp, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    appointment.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.medical_services_rounded,
                  'Doctor',
                  'Dr. ${appointment.doctorName}',
                  isDark,
                ),
                SizedBox(height: 10.h),
                _buildDetailRow(
                  Icons.local_hospital_rounded,
                  'Specialty',
                  appointment.doctorSpecialty,
                  isDark,
                ),
                SizedBox(height: 10.h),
                _buildDetailRow(
                  Icons.phone_rounded,
                  'Phone',
                  appointment.patientPhone.isNotEmpty ? appointment.patientPhone : 'Not provided',
                  isDark,
                ),
                SizedBox(height: 10.h),
                _buildDetailRow(
                  Icons.attach_money_rounded,
                  'Fee',
                  'Rs ${appointment.fee.toStringAsFixed(0)}',
                  isDark,
                ),
                if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes_rounded, size: 18.sp, color: AppColors.grey),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            appointment.notes!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Actions
          if (appointment.status == AppointmentStatus.pending ||
              appointment.status == AppointmentStatus.confirmed)
            _buildActionBar(appointment, isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: AppColors.primary),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: AppColors.grey),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBar(AppointmentModel appointment, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        children: [
          if (appointment.status == AppointmentStatus.pending) ...[
            Expanded(
              child: _buildActionButton(
                'Confirm',
                Icons.check_rounded,
                Colors.green,
                () => _updateStatus(appointment.id, AppointmentStatus.confirmed),
              ),
            ),
            SizedBox(width: 10.w),
          ],
          if (appointment.status == AppointmentStatus.confirmed)
            Expanded(
              child: _buildActionButton(
                'Complete',
                Icons.done_all_rounded,
                Colors.blue,
                () => _updateStatus(appointment.id, AppointmentStatus.completed),
              ),
            ),
          SizedBox(width: 10.w),
          Expanded(
            child: _buildActionButton(
              'Cancel',
              Icons.close_rounded,
              Colors.red,
              () => _updateStatus(appointment.id, AppointmentStatus.cancelled),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.awaitingApproval:
        return Colors.purple;
      case AppointmentStatus.confirmed:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.rejected:
        return Colors.red.shade700;
    }
  }

  Future<void> _updateStatus(String appointmentId, AppointmentStatus status) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status.name,
        if (status == AppointmentStatus.completed) 'completedAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar(
        'Success',
        'Appointment ${status.name}',
        backgroundColor: _getStatusColor(status),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update appointment');
    }
  }
}
