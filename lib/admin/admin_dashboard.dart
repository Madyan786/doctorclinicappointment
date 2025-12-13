import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/auth/user_type_selection_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFeb3349),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28.sp),
            SizedBox(width: 10.w),
            Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.offAll(() => const UserTypeSelectionScreen());
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Logout', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.hourglass_top_rounded)),
            Tab(text: 'Approved', icon: Icon(Icons.check_circle_rounded)),
            Tab(text: 'Rejected', icon: Icon(Icons.cancel_rounded)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats Cards
          _buildStatsSection(isDark),
          // Tabs Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDoctorsList('pending', isDark),
                _buildDoctorsList('approved', isDark),
                _buildDoctorsList('rejected', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('doctors').snapshots(),
      builder: (context, snapshot) {
        int pending = 0, approved = 0, rejected = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['verificationStatus'] ?? 'pending';
            if (status == 'pending') pending++;
            else if (status == 'approved') approved++;
            else if (status == 'rejected') rejected++;
          }
        }

        return Container(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(child: _buildStatCard('Pending', pending, Colors.orange, Icons.hourglass_top_rounded, isDark)),
              SizedBox(width: 12.w),
              Expanded(child: _buildStatCard('Approved', approved, Colors.green, Icons.check_circle_rounded, isDark)),
              SizedBox(width: 12.w),
              Expanded(child: _buildStatCard('Rejected', rejected, Colors.red, Icons.cancel_rounded, isDark)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, int count, Color color, IconData icon, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(height: 8.h),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: color,
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

  Widget _buildDoctorsList(String status, bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('doctors')
          .where('verificationStatus', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'pending' ? Icons.hourglass_empty_rounded :
                  status == 'approved' ? Icons.check_circle_outline_rounded :
                  Icons.cancel_outlined,
                  size: 60.sp,
                  color: AppColors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No ${status} doctors',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final doctor = DoctorModel.fromFirestore(doc);
            return _buildDoctorCard(doctor, status, isDark);
          },
        );
      },
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor, String status, bool isDark) {
    final statusColor = status == 'pending' ? Colors.orange :
                        status == 'approved' ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: statusColor.withOpacity(0.2),
                  backgroundImage: doctor.profileImage.isNotEmpty
                      ? NetworkImage(doctor.profileImage)
                      : null,
                  child: doctor.profileImage.isEmpty
                      ? Icon(Icons.person, color: statusColor, size: 30.sp)
                      : null,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        doctor.specialty,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
                _buildDetailRow(Icons.email_outlined, doctor.email, isDark),
                SizedBox(height: 8.h),
                _buildDetailRow(Icons.phone_outlined, doctor.phone, isDark),
                SizedBox(height: 8.h),
                _buildDetailRow(Icons.local_hospital_outlined, doctor.hospitalName, isDark),
                SizedBox(height: 8.h),
                _buildDetailRow(Icons.work_outline_rounded, '${doctor.experienceYears} years experience', isDark),
                SizedBox(height: 8.h),
                _buildDetailRow(Icons.school_outlined, doctor.qualifications.join(', '), isDark),
                if (doctor.rejectionReason.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.red, size: 18.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Rejection: ${doctor.rejectionReason}',
                            style: TextStyle(fontSize: 12.sp, color: Colors.red),
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
          if (status == 'pending')
            Container(
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
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveDoctor(doctor.id),
                      icon: const Icon(Icons.check_rounded, color: Colors.white),
                      label: const Text('Approve', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRejectDialog(doctor.id),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      label: const Text('Reject', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (status == 'rejected')
            Container(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _approveDoctor(doctor.id),
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text('Re-approve', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.grey),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _approveDoctor(String doctorId) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update({
        'isVerified': true,
        'verificationStatus': 'approved',
        'rejectionReason': '',
      });
      Get.snackbar('Success', 'Doctor approved successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve doctor');
    }
  }

  void _showRejectDialog(String doctorId) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            const Flexible(child: Text('Reject Doctor', overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter rejection reason...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Please provide a reason');
                return;
              }
              await _rejectDoctor(doctorId, reasonController.text.trim());
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectDoctor(String doctorId, String reason) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update({
        'isVerified': false,
        'verificationStatus': 'rejected',
        'rejectionReason': reason,
      });
      Get.snackbar('Success', 'Doctor rejected',
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject doctor');
    }
  }
}
