import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/core/constants/app_constants.dart';

/// Admin Doctors Tab - Manage Doctor Verifications
class AdminDoctorsTab extends StatefulWidget {
  const AdminDoctorsTab({super.key});

  @override
  State<AdminDoctorsTab> createState() => _AdminDoctorsTabState();
}

class _AdminDoctorsTabState extends State<AdminDoctorsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

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

    return Column(
      children: [
        // Search & Filter Bar
        _buildSearchBar(isDark),
        
        // Tab Bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(4.w),
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? Colors.white60 : AppColors.textSecondary,
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_top_rounded, size: 18.sp),
                    SizedBox(width: 6.w),
                    const Text('Pending'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 18.sp),
                    SizedBox(width: 6.w),
                    const Text('Approved'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_rounded, size: 18.sp),
                    SizedBox(width: 6.w),
                    const Text('Rejected'),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        
        // Tab Content
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
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.grey, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search doctors by name, email, specialty...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.grey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.tune_rounded, color: Colors.white, size: 20.sp),
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
          .snapshots(),
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
                Text(
                  'Error loading doctors',
                  style: TextStyle(fontSize: 16.sp, color: Colors.red),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(status, isDark);
        }

        var doctors = snapshot.data!.docs
            .map((doc) => DoctorModel.fromFirestore(doc))
            .toList();

        // Filter by appId (only show this app's doctors)
        doctors = doctors.where((d) {
          final data = snapshot.data!.docs.firstWhere((doc) => doc.id == d.id).data() as Map<String, dynamic>;
          return data['appId'] == APP_ID || data['appId'] == null; // Include legacy data without appId
        }).toList();

        // Sort by createdAt locally
        doctors.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          doctors = doctors.where((d) =>
              d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.specialty.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        if (doctors.isEmpty) {
          return _buildEmptyState(status, isDark);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            
            if (isTablet) {
              // Grid view for tablet
              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 0.85,
                ),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  return _buildDoctorCard(doctors[index], status, isDark);
                },
              );
            }
            
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                return _buildDoctorCard(doctors[index], status, isDark);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String status, bool isDark) {
    IconData icon;
    String message;
    Color color;

    switch (status) {
      case 'pending':
        icon = Icons.hourglass_empty_rounded;
        message = 'No pending verifications';
        color = Colors.orange;
        break;
      case 'approved':
        icon = Icons.check_circle_outline_rounded;
        message = 'No approved doctors';
        color = Colors.green;
        break;
      default:
        icon = Icons.cancel_outlined;
        message = 'No rejected doctors';
        color = Colors.red;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 50.sp, color: color),
          ),
          SizedBox(height: 20.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Try a different search term'
                : 'All caught up!',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white54 : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor, String status, bool isDark) {
    final statusColor = status == 'pending' ? Colors.orange :
                        status == 'approved' ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withOpacity(0.8), statusColor.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                // Profile Image
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13.r),
                    child: doctor.profileImage.isNotEmpty
                        ? Image.network(
                            doctor.profileImage,
                            width: 60.w,
                            height: 60.h,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(60),
                          )
                        : _buildAvatarPlaceholder(60),
                  ),
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
                          doctor.specialty,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    status.toUpperCase(),
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
          
          // Details Section
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildInfoRow(Icons.email_outlined, doctor.email, isDark),
                SizedBox(height: 10.h),
                _buildInfoRow(Icons.phone_outlined, doctor.phone, isDark),
                SizedBox(height: 10.h),
                _buildInfoRow(Icons.local_hospital_outlined, doctor.hospitalName, isDark),
                SizedBox(height: 10.h),
                _buildInfoRow(Icons.work_outline_rounded, '${doctor.experienceYears} years experience', isDark),
                SizedBox(height: 10.h),
                _buildInfoRow(Icons.school_outlined, doctor.qualifications.join(', '), isDark),
                SizedBox(height: 10.h),
                _buildInfoRow(Icons.badge_outlined, 'License: ${doctor.licenseNumber}', isDark),
                SizedBox(height: 10.h),
                _buildInfoRow(Icons.attach_money_rounded, 'Fee: Rs ${doctor.consultationFee.toStringAsFixed(0)}', isDark),
                
                // Show Uploaded Documents
                if (doctor.licenseDocument.isNotEmpty || doctor.degreeImages.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _buildDocumentsSection(doctor, isDark),
                ],
                
                if (doctor.rejectionReason.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Colors.red, size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Rejection Reason: ${doctor.rejectionReason}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.red,
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
          
          // Action Buttons
          if (status == 'pending') _buildPendingActions(doctor.id, isDark),
          if (status == 'approved') _buildApprovedActions(doctor, isDark),
          if (status == 'rejected') _buildRejectedActions(doctor.id, isDark),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(double size) {
    return Container(
      width: size.w,
      height: size.h,
      color: AppColors.lightGrey,
      child: Icon(Icons.person, size: (size / 2).sp, color: AppColors.grey),
    );
  }

  Widget _buildDocumentsSection(DoctorModel doctor, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_rounded, color: Colors.blue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Uploaded Documents',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // License Document
          if (doctor.licenseDocument.isNotEmpty)
            _buildDocumentThumbnail(
              'Medical License',
              doctor.licenseDocument,
              Icons.badge_rounded,
              Colors.green,
            ),
          
          // Degree Images
          if (doctor.degreeImages.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'Degree Certificates (${doctor.degreeImages.length})',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 80.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: doctor.degreeImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showImageDialog(doctor.degreeImages[index]),
                    child: Container(
                      width: 80.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.r),
                        child: Image.network(
                          doctor.degreeImages[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image_rounded,
                            color: Colors.grey,
                            size: 30.sp,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentThumbnail(String title, String url, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _showImageDialog(url),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7.r),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
                errorBuilder: (_, __, ___) => Icon(icon, color: color, size: 30.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              Text(
                'Tap to view full size',
                style: TextStyle(fontSize: 11.sp, color: AppColors.grey),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.open_in_new_rounded, color: color, size: 18.sp),
        ],
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: 300.w,
                      height: 300.h,
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(Icons.close_rounded, color: Colors.white, size: 20.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.primary),
        ),
        SizedBox(width: 12.w),
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

  Widget _buildPendingActions(String doctorId, bool isDark) {
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
          Expanded(
            child: _buildActionButton(
              icon: Icons.check_rounded,
              label: 'Approve',
              gradient: [Colors.green.shade400, Colors.green.shade600],
              onTap: () => _approveDoctor(doctorId),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildActionButton(
              icon: Icons.close_rounded,
              label: 'Reject',
              gradient: [Colors.red.shade400, Colors.red.shade600],
              onTap: () => _showRejectDialog(doctorId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedActions(DoctorModel doctor, bool isDark) {
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
          Expanded(
            child: _buildActionButton(
              icon: Icons.visibility_rounded,
              label: 'View Profile',
              gradient: [Colors.blue.shade400, Colors.blue.shade600],
              onTap: () {},
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildActionButton(
              icon: Icons.block_rounded,
              label: 'Suspend',
              gradient: [Colors.orange.shade400, Colors.orange.shade600],
              onTap: () => _showRejectDialog(doctor.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedActions(String doctorId, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: _buildActionButton(
        icon: Icons.refresh_rounded,
        label: 'Re-approve Doctor',
        gradient: [Colors.green.shade400, Colors.green.shade600],
        onTap: () => _approveDoctor(doctorId),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveDoctor(String doctorId) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update({
        'isVerified': true,
        'verificationStatus': 'approved',
        'rejectionReason': '',
      });
      Get.snackbar(
        'Success',
        'Doctor approved successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12,
      );
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
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Icon(Icons.cancel_rounded, color: Colors.red),
            ),
            SizedBox(width: 12.w),
            const Text('Reject Doctor'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejection:'),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ],
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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
      Get.snackbar(
        'Success',
        'Doctor rejected',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject doctor');
    }
  }
}
