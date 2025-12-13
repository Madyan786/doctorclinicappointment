import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctorclinic/core/core.dart';

class DoctorAppointmentsTab extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorAppointmentsTab({super.key, required this.doctor});

  @override
  State<DoctorAppointmentsTab> createState() => _DoctorAppointmentsTabState();
}

class _DoctorAppointmentsTabState extends State<DoctorAppointmentsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24.r),
                      bottomRight: Radius.circular(24.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Appointments',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Manage your patient appointments',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                // Tab Bar
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark ? Colors.white60 : AppColors.textSecondary,
                    labelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Awaiting'),
                      Tab(text: 'Confirmed'),
                      Tab(text: 'Completed'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAppointmentList(null, isDark),
                      _buildAppointmentList('awaitingApproval', isDark),
                      _buildAppointmentList('confirmed', isDark),
                      _buildAppointmentList('completed', isDark),
                      _buildAppointmentList('cancelled', isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(String? statusFilter, bool isDark) {
    // Simple query without orderBy to avoid index requirement
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: widget.doctor.id)
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
                  'Error loading appointments',
                  style: TextStyle(fontSize: 14.sp, color: Colors.red),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(isDark);
        }

        var docs = snapshot.data!.docs.toList();
        
        // Sort by date locally
        docs.sort((a, b) {
          final dateA = (a.data() as Map<String, dynamic>)['appointmentDate'] as Timestamp;
          final dateB = (b.data() as Map<String, dynamic>)['appointmentDate'] as Timestamp;
          return dateB.compareTo(dateA);
        });
        
        // Filter by status if needed
        if (statusFilter != null) {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == statusFilter;
          }).toList();
        }

        if (docs.isEmpty) {
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
                  childAspectRatio: 1.2,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return _buildAppointmentCard(docs[index].id, data, isDark);
                },
              );
            }
            
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                return _buildAppointmentCard(docs[index].id, data, isDark);
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
          Icon(Icons.event_note_rounded, size: 80.sp, color: AppColors.grey.withOpacity(0.5)),
          SizedBox(height: 16.h),
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

  Widget _buildAppointmentCard(String id, Map<String, dynamic> data, bool isDark) {
    final status = data['status'] ?? 'pending';
    final date = (data['appointmentDate'] as Timestamp).toDate();
    final statusColor = _getStatusColor(status);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
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
          Row(
            children: [
              // Patient Avatar
              Container(
                width: 55.w,
                height: 55.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.person_rounded, color: AppColors.primary, size: 30.sp),
              ),
              SizedBox(width: 14.w),
              // Patient Info
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      data['patientPhone'] ?? '',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  status.toString().capitalize!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Date & Time
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                _buildInfoItem(Icons.calendar_today_rounded, DateFormat('MMM dd, yyyy').format(date), isDark),
                SizedBox(width: 20.w),
                _buildInfoItem(Icons.access_time_rounded, data['timeSlot'] ?? '', isDark),
                SizedBox(width: 20.w),
                _buildInfoItem(Icons.payments_rounded, 'Rs. ${(data['fee'] ?? 0).toInt()}', isDark),
              ],
            ),
          ),
          if (data['notes'] != null && data['notes'].isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.note_rounded, color: Colors.amber.shade700, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      data['notes'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.amber.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Payment Slip Section (for awaiting approval)
          if (data['paymentSlipUrl'] != null && data['paymentSlipUrl'].isNotEmpty) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => _showPaymentSlipDialog(data['paymentSlipUrl'], isDark),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.purple.withOpacity(0.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: CachedNetworkImage(
                          imageUrl: data['paymentSlipUrl'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.purple,
                            size: 24.sp,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.purple,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Slip',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Tap to view full image',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.purple.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.open_in_new_rounded, color: Colors.purple, size: 20.sp),
                  ],
                ),
              ),
            ),
          ],
          // Actions for awaiting approval
          if (status == 'awaitingApproval') ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Accept',
                    Icons.check_circle_rounded,
                    Colors.green,
                    () => _acceptAppointment(id),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildActionButton(
                    'Reject',
                    Icons.cancel_rounded,
                    Colors.red,
                    () => _showRejectDialog(id),
                  ),
                ),
              ],
            ),
          ],
          // Actions for confirmed appointments
          if (status == 'confirmed') ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Complete',
                    Icons.check_circle_rounded,
                    Colors.green,
                    () => _updateStatus(id, 'completed'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildActionButton(
                    'Cancel',
                    Icons.cancel_rounded,
                    Colors.red,
                    () => _showCancelDialog(id),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, bool isDark) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              text,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'confirmed':
        return AppColors.primary;
      case 'awaitingApproval':
        return Colors.purple;
      case 'rejected':
        return Colors.red.shade700;
      default:
        return Colors.orange;
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    await _firestore.collection('appointments').doc(id).update({'status': status});
    Get.snackbar('Success', 'Appointment marked as $status');
  }

  Future<void> _acceptAppointment(String id) async {
    try {
      final appointmentService = Get.find<AppointmentService>();
      await appointmentService.acceptAppointment(id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept appointment');
    }
  }

  void _showPaymentSlipDialog(String imageUrl, bool isDark) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Slip',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white60 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        height: 300.h,
                        color: Colors.grey.withOpacity(0.2),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200.h,
                        color: Colors.grey.withOpacity(0.2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 40.sp, color: Colors.red),
                            SizedBox(height: 8.h),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.red, fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(String id) {
    final reasonController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.red, size: 24.sp),
            SizedBox(width: 8.w),
            const Text('Reject Appointment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejection:'),
            SizedBox(height: 12.h),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Invalid payment slip, Schedule conflict...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
              Get.back();
              try {
                final appointmentService = Get.find<AppointmentService>();
                await appointmentService.rejectAppointment(id, reasonController.text.trim());
              } catch (e) {
                Get.snackbar('Error', 'Failed to reject appointment');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _updateStatus(id, 'cancelled');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
