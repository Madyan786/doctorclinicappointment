import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:doctorclinic/core/core.dart';

class DoctorHomeTab extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorHomeTab({super.key, required this.doctor});

  @override
  State<DoctorHomeTab> createState() => _DoctorHomeTabState();
}

class _DoctorHomeTabState extends State<DoctorHomeTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(isDark),
                  SizedBox(height: 25.h),
                  // Stats Cards
                  _buildStatsSection(isDark),
                  SizedBox(height: 25.h),
                  // Today's Appointments
                  _buildTodayAppointments(isDark),
                  SizedBox(height: 25.h),
                  // Recent Reviews
                  _buildRecentReviews(isDark),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355CE4).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: widget.doctor.profileImage.isNotEmpty
                ? NetworkImage(widget.doctor.profileImage)
                : null,
            child: widget.doctor.profileImage.isEmpty
                ? Icon(Icons.person, color: Colors.white, size: 35.sp)
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  widget.doctor.name,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    widget.doctor.specialty,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 24.sp),
                Text(
                  widget.doctor.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: widget.doctor.id)
          .snapshots(),
      builder: (context, snapshot) {
        int totalAppointments = 0;
        int todayAppointments = 0;
        int pendingAppointments = 0;
        int completedAppointments = 0;

        if (snapshot.hasData) {
          final appointments = snapshot.data!.docs;
          totalAppointments = appointments.length;
          
          final today = DateTime.now();
          for (var doc in appointments) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['appointmentDate'] as Timestamp).toDate();
            final status = data['status'] ?? '';

            if (date.day == today.day && date.month == today.month && date.year == today.year) {
              todayAppointments++;
            }
            if (status == 'pending' || status == 'confirmed') {
              pendingAppointments++;
            }
            if (status == 'completed') {
              completedAppointments++;
            }
          }
        }

        return Row(
          children: [
            Expanded(child: _buildStatCard('Today', todayAppointments.toString(), Icons.today_rounded, const Color(0xFF11998e), isDark)),
            SizedBox(width: 12.w),
            Expanded(child: _buildStatCard('Pending', pendingAppointments.toString(), Icons.pending_actions_rounded, const Color(0xFFFF9F43), isDark)),
            SizedBox(width: 12.w),
            Expanded(child: _buildStatCard('Done', completedAppointments.toString(), Icons.check_circle_rounded, const Color(0xFF355CE4), isDark)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointments(bool isDark) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Appointments",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Text(
              DateFormat('MMM dd, yyyy').format(today),
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('appointments')
              .where('doctorId', isEqualTo: widget.doctor.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter for today's appointments locally
            final todayDocs = snapshot.data?.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final apptDate = (data['appointmentDate'] as Timestamp).toDate();
              return apptDate.year == today.year && 
                     apptDate.month == today.month && 
                     apptDate.day == today.day;
            }).toList() ?? [];

            if (!snapshot.hasData || todayDocs.isEmpty) {
              return Container(
                padding: EdgeInsets.all(30.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Icon(Icons.event_available_rounded, size: 50.sp, color: AppColors.grey),
                    SizedBox(height: 10.h),
                    Text(
                      'No appointments today',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Enjoy your day off!',
                      style: TextStyle(fontSize: 13.sp, color: AppColors.grey),
                    ),
                  ],
                ),
              );
            }

            // Sort by time
            todayDocs.sort((a, b) {
              final timeA = (a.data() as Map<String, dynamic>)['timeSlot'] ?? '';
              final timeB = (b.data() as Map<String, dynamic>)['timeSlot'] ?? '';
              return timeA.compareTo(timeB);
            });

            return Column(
              children: todayDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildAppointmentCard(doc.id, data, isDark);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(String id, Map<String, dynamic> data, bool isDark) {
    final status = data['status'] ?? 'pending';
    final statusColor = status == 'completed'
        ? Colors.green
        : status == 'cancelled'
            ? Colors.red
            : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.person, color: AppColors.primary, size: 28.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['patientName'] ?? 'Patient',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14.sp, color: AppColors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      data['timeSlot'] ?? '',
                      style: TextStyle(fontSize: 13.sp, color: AppColors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status & Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  status.toString().capitalize!,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              if (status == 'pending' || status == 'confirmed') ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildActionButton(Icons.check, Colors.green, () => _updateStatus(id, 'completed')),
                    SizedBox(width: 8.w),
                    _buildActionButton(Icons.close, Colors.red, () => _updateStatus(id, 'cancelled')),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 16.sp),
      ),
    );
  }

  Future<void> _updateStatus(String appointmentId, String status) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': status,
    });
    Get.snackbar('Success', 'Appointment marked as $status');
  }

  Widget _buildRecentReviews(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reviews',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 15.h),
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('reviews')
              .where('doctorId', isEqualTo: widget.doctor.id)
              .orderBy('createdAt', descending: true)
              .limit(3)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Text(
                    'No reviews yet',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
                  ),
                ),
              );
            }

            return Column(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildReviewCard(data, isDark);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> data, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(Icons.person, color: AppColors.primary, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  data['patientName'] ?? 'Patient',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < (data['rating'] ?? 0)
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 16.sp,
                  );
                }),
              ),
            ],
          ),
          if (data['comment'] != null && data['comment'].isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              data['comment'],
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
