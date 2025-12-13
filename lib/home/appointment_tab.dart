import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:doctorclinic/core/core.dart';

class AppointmentTab extends StatefulWidget {
  const AppointmentTab({super.key});

  @override
  State<AppointmentTab> createState() => _AppointmentTabState();
}

class _AppointmentTabState extends State<AppointmentTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final appointmentService = Get.find<AppointmentService>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header
                _buildHeader(isDark),
                SizedBox(height: 20.h),
                // Tab Bar
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark ? Colors.white60 : AppColors.textSecondary,
                    labelStyle: TextStyle(fontSize: isTablet ? 15.sp : 13.sp, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: TextStyle(fontSize: isTablet ? 15.sp : 13.sp, fontWeight: FontWeight.w500),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Completed'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // Tab Views
                Expanded(
                  child: Obx(() {
                    if (appointmentService.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAppointmentList(appointmentService.upcomingAppointments, 'upcoming', isDark),
                        _buildAppointmentList(appointmentService.completedAppointments, 'completed', isDark),
                        _buildAppointmentList(appointmentService.cancelledAppointments, 'cancelled', isDark),
                      ],
                    );
                  }),
                ),
              ],
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355CE4).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.calendar_month_rounded, color: Colors.white, size: 26.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Appointments',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Manage your medical schedule',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Refresh button
              GestureDetector(
                onTap: () => Get.find<AppointmentService>().fetchUserAppointments(),
                child: Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.refresh_rounded, color: Colors.white, size: 22.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<AppointmentModel> appointments, String type, bool isDark) {
    if (appointments.isEmpty) {
      return _buildEmptyState(type, isDark);
    }

    return RefreshIndicator(
      onRefresh: () => Get.find<AppointmentService>().fetchUserAppointments(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          
          if (isTablet) {
            return GridView.builder(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1.3,
              ),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return _buildAppointmentCard(appointments[index], isDark);
              },
            );
          }
          
          return ListView.builder(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              return _buildAppointmentCard(appointments[index], isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String type, bool isDark) {
    IconData icon;
    String title;
    String subtitle;
    Color color;

    switch (type) {
      case 'upcoming':
        icon = Icons.event_available_rounded;
        title = 'No Upcoming Appointments';
        subtitle = 'Book an appointment with a doctor';
        color = AppColors.primary;
        break;
      case 'completed':
        icon = Icons.task_alt_rounded;
        title = 'No Completed Appointments';
        subtitle = 'Your completed appointments will appear here';
        color = Colors.green;
        break;
      default:
        icon = Icons.event_busy_rounded;
        title = 'No Cancelled Appointments';
        subtitle = 'Your cancelled appointments will appear here';
        color = Colors.red;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 50.sp, color: color),
          ),
          SizedBox(height: 20.h),
          CustomText(
            title,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: CustomText(
              subtitle,
              fontSize: 14,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ),
          if (type == 'upcoming') ...[
            SizedBox(height: 24.h),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to doctors tab (index 4)
                },
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                label: const Text('Find a Doctor', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, bool isDark) {
    Color statusColor;
    IconData statusIcon;
    
    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case AppointmentStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule_rounded;
        break;
      case AppointmentStatus.awaitingApproval:
        statusColor = Colors.purple;
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case AppointmentStatus.completed:
        statusColor = AppColors.primary;
        statusIcon = Icons.task_alt_rounded;
        break;
      case AppointmentStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        break;
      case AppointmentStatus.rejected:
        statusColor = Colors.red.shade700;
        statusIcon = Icons.block_rounded;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey),
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
          // Main Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  children: [
                    // Doctor Image
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: statusColor, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 32.r,
                        backgroundColor: AppColors.lightGrey,
                        backgroundImage: appointment.doctorImage.isNotEmpty 
                            ? NetworkImage(appointment.doctorImage)
                            : null,
                        child: appointment.doctorImage.isEmpty
                            ? Icon(Icons.person, size: 32.sp, color: AppColors.grey)
                            : null,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    // Doctor Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            appointment.doctorName,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: CustomText(
                              appointment.doctorSpecialty,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14.sp, color: statusColor),
                          SizedBox(width: 4.w),
                          CustomText(
                            appointment.statusText,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Date & Time Card
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.08),
                        statusColor.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 36.w,
                              height: 36.h,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(Icons.calendar_today_rounded, size: 18.sp, color: statusColor),
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    'Date',
                                    fontSize: 10,
                                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                                  ),
                                  CustomText(
                                    DateFormat('MMM dd').format(appointment.appointmentDate),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36.h,
                        color: statusColor.withOpacity(0.3),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 36.w,
                              height: 36.h,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(Icons.access_time_rounded, size: 18.sp, color: statusColor),
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    'Time',
                                    fontSize: 10,
                                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                                  ),
                                  CustomText(
                                    appointment.timeSlot,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Awaiting Approval Info
          if (appointment.status == AppointmentStatus.awaitingApproval)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top_rounded, color: Colors.purple, size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Waiting for doctor to review your payment slip',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Rejection Info
          if (appointment.status == AppointmentStatus.rejected && appointment.rejectionReason != null)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red.shade700, size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Reason: ${appointment.rejectionReason}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Action Buttons (only for confirmed)
          if (appointment.status == AppointmentStatus.confirmed)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCancelDialog(appointment),
                      icon: Icon(Icons.close_rounded, size: 18.sp),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.edit_calendar_rounded, size: 18.sp, color: Colors.white),
                        label: const Text('Reschedule', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(AppointmentModel appointment) {
    final reasonController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28.sp),
            SizedBox(width: 10.w),
            const Text('Cancel Appointment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this appointment?'),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Reason for cancellation (optional)',
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
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Get.find<AppointmentService>().cancelAppointment(
                appointment.id,
                reasonController.text,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
