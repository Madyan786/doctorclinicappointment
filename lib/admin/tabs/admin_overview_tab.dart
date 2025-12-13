import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:intl/intl.dart';

/// Admin Overview Tab - Dashboard with Stats & Charts
class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards Row
          _buildStatsSection(isDark, isDesktop),
          SizedBox(height: 24.h),
          
          // Two Column Layout for Desktop
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildRecentAppointments(isDark)),
                SizedBox(width: 20.w),
                Expanded(child: _buildPendingDoctors(isDark)),
              ],
            )
          else ...[
            _buildRecentAppointments(isDark),
            SizedBox(height: 20.h),
            _buildPendingDoctors(isDark),
          ],
          
          SizedBox(height: 24.h),
          _buildRecentReviews(isDark),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark, bool isDesktop) {
    final firestore = FirebaseFirestore.instance;
    
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('doctors').snapshots(),
      builder: (context, doctorsSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('appointments').snapshots(),
          builder: (context, appointmentsSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('users').snapshots(),
              builder: (context, usersSnapshot) {
                int totalDoctors = 0, pendingDoctors = 0, totalAppointments = 0, 
                    todayAppointments = 0, totalUsers = 0, totalRevenue = 0;

                // Doctors
                if (doctorsSnapshot.hasData) {
                  for (var doc in doctorsSnapshot.data!.docs) {
                    totalDoctors++;
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['verificationStatus'] == 'pending') pendingDoctors++;
                  }
                }
                
                // Appointments
                if (appointmentsSnapshot.hasData) {
                  final today = DateTime.now();
                  for (var doc in appointmentsSnapshot.data!.docs) {
                    totalAppointments++;
                    final data = doc.data() as Map<String, dynamic>;
                    final dateTs = data['appointmentDate'] as Timestamp?;
                    if (dateTs != null) {
                      final date = dateTs.toDate();
                      if (date.day == today.day && date.month == today.month && date.year == today.year) {
                        todayAppointments++;
                      }
                    }
                    if (data['status'] == 'completed') {
                      totalRevenue += ((data['fee'] ?? 0) as num).toInt();
                    }
                  }
                }
                
                // Users
                if (usersSnapshot.hasData) {
                  totalUsers = usersSnapshot.data!.docs.length;
                }

                return Wrap(
                  spacing: 16.w,
                  runSpacing: 16.h,
                  children: [
                    _buildStatCard(
                      title: 'Total Doctors',
                      value: totalDoctors.toString(),
                      icon: Icons.medical_services_rounded,
                      gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
                      subtitle: '$pendingDoctors pending',
                      isDark: isDark,
                      isDesktop: isDesktop,
                    ),
                    _buildStatCard(
                      title: 'Appointments',
                      value: totalAppointments.toString(),
                      icon: Icons.calendar_today_rounded,
                      gradient: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                      subtitle: '$todayAppointments today',
                      isDark: isDark,
                      isDesktop: isDesktop,
                    ),
                    _buildStatCard(
                      title: 'Total Users',
                      value: totalUsers.toString(),
                      icon: Icons.people_rounded,
                      gradient: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
                      subtitle: 'Registered patients',
                      isDark: isDark,
                      isDesktop: isDesktop,
                    ),
                    _buildStatCard(
                      title: 'Revenue',
                      value: 'Rs ${NumberFormat.compact().format(totalRevenue)}',
                      icon: Icons.account_balance_wallet_rounded,
                      gradient: [const Color(0xFFf2994a), const Color(0xFFf2c94c)],
                      subtitle: 'From appointments',
                      isDark: isDark,
                      isDesktop: isDesktop,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
    required String subtitle,
    required bool isDark,
    required bool isDesktop,
  }) {
    return Container(
      width: isDesktop ? 220.w : 160.w,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.white, size: 24.sp),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _buildActionChip(
                icon: Icons.person_add_rounded,
                label: 'Verify Doctors',
                color: Colors.blue,
                isDark: isDark,
              ),
              _buildActionChip(
                icon: Icons.rate_review_rounded,
                label: 'Moderate Reviews',
                color: Colors.orange,
                isDark: isDark,
              ),
              _buildActionChip(
                icon: Icons.analytics_rounded,
                label: 'View Reports',
                color: Colors.purple,
                isDark: isDark,
              ),
              _buildActionChip(
                icon: Icons.notifications_rounded,
                label: 'Send Notification',
                color: Colors.green,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(width: 8.w),
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
    );
  }

  Widget _buildRecentAppointments(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Appointments',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('View All', style: TextStyle(fontSize: 13.sp)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildEmptyState('Error loading data', Icons.error_outline);
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState('No appointments yet', Icons.calendar_today_rounded);
              }

              // Sort locally and take first 5
              var docs = snapshot.data!.docs.toList();
              docs.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                final dateA = dataA['createdAt'] as Timestamp?;
                final dateB = dataB['createdAt'] as Timestamp?;
                if (dateA == null || dateB == null) return 0;
                return dateB.compareTo(dateA);
              });
              final recentDocs = docs.take(5).toList();

              return Column(
                children: recentDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildAppointmentItem(data, isDark);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(Map<String, dynamic> data, bool isDark) {
    final status = data['status'] ?? 'pending';
    final statusColor = status == 'pending' ? Colors.orange :
                        status == 'confirmed' ? Colors.blue :
                        status == 'completed' ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: statusColor.withOpacity(0.2),
            child: Icon(Icons.calendar_today_rounded, color: statusColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['patientName'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Dr. ${data['doctorName'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingDoctors(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Pending Verifications',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('doctors')
                          .where('verificationStatus', isEqualTo: 'pending')
                          .snapshots(),
                      builder: (context, snapshot) {
                        return Text(
                          '${snapshot.data?.docs.length ?? 0}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text('View All', style: TextStyle(fontSize: 13.sp)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('doctors')
                .where('verificationStatus', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildEmptyState('Error loading data', Icons.error_outline);
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState('No pending verifications', Icons.check_circle_rounded);
              }

              // Sort locally and take first 5
              var docs = snapshot.data!.docs.toList();
              docs.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                final dateA = dataA['createdAt'] as Timestamp?;
                final dateB = dataB['createdAt'] as Timestamp?;
                if (dateA == null || dateB == null) return 0;
                return dateB.compareTo(dateA);
              });
              final recentDocs = docs.take(5).toList();

              return Column(
                children: recentDocs.map((doc) {
                  final doctor = DoctorModel.fromFirestore(doc);
                  return _buildDoctorItem(doctor, isDark);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorItem(DoctorModel doctor, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.orange.withOpacity(0.2),
            backgroundImage: doctor.profileImage.isNotEmpty 
                ? NetworkImage(doctor.profileImage) 
                : null,
            child: doctor.profileImage.isEmpty
                ? Icon(Icons.person, color: Colors.orange, size: 20.sp)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  doctor.specialty,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildSmallIconButton(
                icon: Icons.check_rounded,
                color: Colors.green,
                onTap: () => _approveDoctor(doctor.id),
              ),
              SizedBox(width: 8.w),
              _buildSmallIconButton(
                icon: Icons.close_rounded,
                color: Colors.red,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 18.sp),
      ),
    );
  }

  Widget _buildRecentReviews(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Reviews',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('View All', style: TextStyle(fontSize: 13.sp)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reviews')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildEmptyState('Error loading data', Icons.error_outline);
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState('No reviews yet', Icons.star_rounded);
              }

              // Sort locally and take first 3
              var docs = snapshot.data!.docs.toList();
              docs.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                final dateA = dataA['createdAt'] as Timestamp?;
                final dateB = dataB['createdAt'] as Timestamp?;
                if (dateA == null || dateB == null) return 0;
                return dateB.compareTo(dateA);
              });
              final recentDocs = docs.take(3).toList();

              return Column(
                children: recentDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildReviewItem(data, isDark);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> data, bool isDark) {
    final rating = (data['rating'] ?? 0).toDouble();
    final isApproved = data['isApproved'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isApproved 
              ? Colors.green.withOpacity(0.3) 
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Icon(Icons.person, color: AppColors.primary, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['patientName'] ?? 'Anonymous',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Dr. ${data['doctorName'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 16.sp,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            data['comment'] ?? '',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: (isApproved ? Colors.green : Colors.orange).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  isApproved ? 'Approved' : 'Pending',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: isApproved ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              if (!isApproved)
                Row(
                  children: [
                    _buildSmallIconButton(
                      icon: Icons.check_rounded,
                      color: Colors.green,
                      onTap: () {},
                    ),
                    SizedBox(width: 6.w),
                    _buildSmallIconButton(
                      icon: Icons.close_rounded,
                      color: Colors.red,
                      onTap: () {},
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          children: [
            Icon(icon, size: 40.sp, color: Colors.grey),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveDoctor(String doctorId) async {
    await FirebaseFirestore.instance.collection('doctors').doc(doctorId).update({
      'isVerified': true,
      'verificationStatus': 'approved',
      'rejectionReason': '',
    });
  }
}
