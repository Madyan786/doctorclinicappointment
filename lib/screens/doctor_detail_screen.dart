import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doctorclinic/core/core.dart';
import 'book_appointment_screen.dart';

class DoctorDetailScreen extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 700 : double.infinity),
          child: CustomScrollView(
            slivers: [
              // Premium App Bar with Doctor Image
              SliverAppBar(
                expandedHeight: isTablet ? 380.h : 320.h,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColors.primary,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200.w,
                      height: 200.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Doctor Info
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          // Doctor Image
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 55.r,
                              backgroundImage: doctor.profileImage.isNotEmpty ? NetworkImage(doctor.profileImage) : null,
                              child: doctor.profileImage.isEmpty ? Icon(Icons.person, size: 50.sp, color: Colors.white) : null,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          // Name
                          Text(
                            doctor.name,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          // Specialty
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              doctor.specialty,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  _buildStatsRow(isDark),
                  SizedBox(height: 25.h),

                  // About Section
                  _buildSectionTitle('About', isDark),
                  SizedBox(height: 10.h),
                  Text(
                    doctor.about.isNotEmpty
                        ? doctor.about
                        : 'Dr. ${doctor.name.split(' ').last} is a highly skilled ${doctor.specialty} with ${doctor.experienceYears} years of experience. Known for providing excellent patient care and using the latest medical techniques.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 25.h),

                  // Qualifications
                  _buildSectionTitle('Qualifications', isDark),
                  SizedBox(height: 10.h),
                  _buildQualifications(isDark),
                  SizedBox(height: 25.h),

                  // Hospital Info
                  _buildSectionTitle('Hospital', isDark),
                  SizedBox(height: 10.h),
                  _buildHospitalCard(isDark),
                  SizedBox(height: 25.h),

                  // Working Hours
                  _buildSectionTitle('Working Hours', isDark),
                  SizedBox(height: 10.h),
                  _buildWorkingHours(isDark),
                  SizedBox(height: 25.h),

                  // Reviews Section
                  _buildReviewsHeader(isDark),
                  SizedBox(height: 10.h),
                  _buildReviewsList(isDark),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
            ],
          ),
        ),
      ),
      // Book Appointment Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Fee Info
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consultation Fee',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Rs. ${doctor.consultationFee.toInt()}',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Book Button
              Expanded(
                flex: 2,
                child: Container(
                  height: 55.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: doctor.isAvailable
                        ? () => Get.to(() => BookAppointmentScreen(doctor: doctor))
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          doctor.isAvailable ? 'Book Appointment' : 'Not Available',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        _buildStatItem(
          Icons.work_rounded,
          '${doctor.experienceYears}+',
          'Years Exp.',
          const Color(0xFF11998e),
          isDark,
        ),
        SizedBox(width: 12.w),
        _buildStatItem(
          Icons.star_rounded,
          doctor.rating.toString(),
          'Rating',
          const Color(0xFFFF9F43),
          isDark,
        ),
        SizedBox(width: 12.w),
        _buildStatItem(
          Icons.people_rounded,
          '${doctor.totalReviews}+',
          'Reviews',
          const Color(0xFF355CE4),
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
          ),
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
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildQualifications(bool isDark) {
    final qualifications = doctor.qualifications.isNotEmpty
        ? doctor.qualifications
        : ['MBBS', 'MD - ${doctor.specialty}', 'Fellowship'];

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: qualifications.map((q) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, color: AppColors.primary, size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                q,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHospitalCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
        ),
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
              color: const Color(0xFFFF6B6B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.local_hospital_rounded, color: const Color(0xFFFF6B6B), size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.hospitalName.isNotEmpty ? doctor.hospitalName : 'City Medical Center',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14.sp, color: AppColors.textSecondary),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        doctor.hospitalAddress.isNotEmpty ? doctor.hospitalAddress : 'Main Street, City',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.directions_rounded,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHours(bool isDark) {
    final days = doctor.availableDays.isNotEmpty
        ? doctor.availableDays
        : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF11998e).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.access_time_rounded, color: const Color(0xFF11998e), size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${doctor.startTime} - ${doctor.endTime}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Working Hours',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
              final fullDay = {
                'Mon': 'Monday',
                'Tue': 'Tuesday',
                'Wed': 'Wednesday',
                'Thu': 'Thursday',
                'Fri': 'Friday',
                'Sat': 'Saturday',
                'Sun': 'Sunday',
              }[day]!;
              final isAvailable = days.contains(fullDay);
              return Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? AppColors.primary.withOpacity(0.15)
                      : (isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey),
                  borderRadius: BorderRadius.circular(12.r),
                  border: isAvailable
                      ? Border.all(color: AppColors.primary.withOpacity(0.3))
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isAvailable
                        ? AppColors.primary
                        : (isDark ? Colors.white30 : AppColors.grey),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 20.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                ),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'Reviews & Ratings',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showAddReviewDialog(isDark),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.rate_review_rounded, color: Colors.white, size: 16.sp),
                SizedBox(width: 4.w),
                Text(
                  'Add Review',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList(bool isDark) {
    final reviewService = Get.find<ReviewService>();
    
    return FutureBuilder<List<ReviewModel>>(
      future: reviewService.fetchDoctorReviews(doctor.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 100.h,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return Container(
            padding: EdgeInsets.all(30.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined, size: 50.sp, color: AppColors.grey),
                SizedBox(height: 10.h),
                Text(
                  'No reviews yet',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Be the first to review this doctor!',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: reviews.take(5).map((review) => _buildReviewCard(review, isDark)).toList(),
        );
      },
    );
  }

  Widget _buildReviewCard(ReviewModel review, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: review.patientImage.isNotEmpty 
                    ? NetworkImage(review.patientImage) 
                    : null,
                child: review.patientImage.isEmpty 
                    ? Icon(Icons.person, color: AppColors.primary, size: 20.sp) 
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.patientName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Star Rating
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddReviewDialog(bool isDark) {
    double selectedRating = 5.0;
    final commentController = TextEditingController();
    final reviewService = Get.find<ReviewService>();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.rate_review_rounded, color: Colors.white, size: 20.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Rate & Review',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25.r,
                        backgroundImage: doctor.profileImage.isNotEmpty 
                            ? NetworkImage(doctor.profileImage) 
                            : null,
                        child: doctor.profileImage.isEmpty 
                            ? Icon(Icons.person, color: AppColors.grey, size: 20.sp) 
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
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              doctor.specialty,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Rating Stars
                  Text(
                    'Your Rating',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedRating = index + 1.0),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            index < selectedRating 
                                ? Icons.star_rounded 
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 36.sp,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      _getRatingText(selectedRating),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Comment
                  Text(
                    'Your Review',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      controller: commentController,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Share your experience with this doctor...',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16.w),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Obx(() => ElevatedButton(
                onPressed: reviewService.isLoading.value
                    ? null
                    : () async {
                        if (commentController.text.trim().isEmpty) {
                          Get.snackbar('Error', 'Please write a review');
                          return;
                        }
                        
                        final success = await reviewService.submitReview(
                          doctor: doctor,
                          rating: selectedRating,
                          comment: commentController.text.trim(),
                        );
                        
                        if (success) {
                          Get.back();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
                child: reviewService.isLoading.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Submit Review',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              )),
            ],
          );
        },
      ),
    );
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }
}
