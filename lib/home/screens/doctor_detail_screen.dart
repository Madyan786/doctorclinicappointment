import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/core/providers/providers.dart';

/// Doctor Detail Screen with Booking
class DoctorDetailScreen extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<String> _generateTimeSlots() {
    final slots = <String>[];
    final start = int.parse(widget.doctor.startTime.split(':')[0]);
    final end = int.parse(widget.doctor.endTime.split(':')[0]);

    for (int hour = start; hour < end; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      slots.add('${hour.toString().padLeft(2, '0')}:30');
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Doctor Image
          _buildSliverAppBar(isDark),
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Info Card
                _buildDoctorInfoCard(isDark),
                
                // About Section
                _buildAboutSection(isDark),
                
                // Schedule Section
                _buildScheduleSection(isDark),
                
                // Reviews Section
                _buildReviewsSection(isDark),
                
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: AppColors.primary,
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
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.all(8.w),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(Icons.favorite_border_rounded, color: Colors.white),
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                ),
              ),
            ),
            // Pattern
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200.w,
                height: 200.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Doctor Image
            Positioned(
              bottom: 20.h,
              left: 0,
              right: 0,
              child: Center(
                child: Hero(
                  tag: 'doctor_${widget.doctor.id}',
                  child: CachedNetworkImage(
                    imageUrl: widget.doctor.profileImage,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 140.w,
                      height: 140.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) => _buildImagePlaceholder(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 140.w,
      height: 140.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Icon(Icons.person, color: Colors.white, size: 60.sp),
    );
  }

  Widget _buildDoctorInfoCard(bool isDark) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          // Name & Specialty
          Text(
            widget.doctor.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            widget.doctor.specialty,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_hospital_rounded, size: 16.sp, color: AppColors.grey),
              SizedBox(width: 6.w),
              Text(
                widget.doctor.hospitalName,
                style: TextStyle(fontSize: 13.sp, color: AppColors.grey),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Stats Row
          Row(
            children: [
              _buildStatItem('Rating', widget.doctor.rating.toStringAsFixed(1), Icons.star_rounded, Colors.amber),
              _buildVerticalDivider(),
              _buildStatItem('Reviews', '${widget.doctor.totalReviews}', Icons.reviews_rounded, Colors.blue),
              _buildVerticalDivider(),
              _buildStatItem('Experience', '${widget.doctor.experienceYears} yrs', Icons.work_rounded, Colors.green),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Fee
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Consultation Fee',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Rs ${widget.doctor.consultationFee.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 50.h,
      width: 1,
      color: AppColors.lightGrey,
    );
  }

  Widget _buildAboutSection(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Doctor',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            widget.doctor.about.isNotEmpty 
                ? widget.doctor.about 
                : 'No description available.',
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.6,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Qualifications
          if (widget.doctor.qualifications.isNotEmpty) ...[
            Text(
              'Qualifications',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: widget.doctor.qualifications.map((q) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    q,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleSection(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Date Selection
          Text(
            'Select Date',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 85.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = _selectedDate.day == date.day && 
                                   _selectedDate.month == date.month;
                final isAvailable = widget.doctor.availableDays.contains(
                    DateFormat('EEEE').format(date));

                return GestureDetector(
                  onTap: isAvailable ? () {
                    setState(() => _selectedDate = date);
                  } : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60.w,
                    margin: EdgeInsets.only(right: 10.w),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                            )
                          : null,
                      color: isSelected 
                          ? null 
                          : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                      borderRadius: BorderRadius.circular(16.r),
                      border: !isAvailable 
                          ? Border.all(color: Colors.red.withOpacity(0.3))
                          : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10)]
                          : null,
                    ),
                    child: Opacity(
                      opacity: isAvailable ? 1.0 : 0.4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isSelected ? Colors.white70 : AppColors.grey,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected 
                                  ? Colors.white 
                                  : (isDark ? Colors.white : AppColors.textPrimary),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            DateFormat('MMM').format(date),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isSelected ? Colors.white70 : AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
          
          // Time Slots
          Text(
            'Select Time',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          
          FutureBuilder<List<String>>(
            future: context.read<AppProvider>().getBookedSlots(widget.doctor.id, _selectedDate),
            builder: (context, snapshot) {
              final bookedSlots = snapshot.data ?? [];
              final allSlots = _generateTimeSlots();

              return Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: allSlots.map((slot) {
                  final isBooked = bookedSlots.contains(slot);
                  final isSelected = _selectedSlot == slot;

                  return GestureDetector(
                    onTap: isBooked ? null : () {
                      setState(() => _selectedSlot = slot);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                              )
                            : null,
                        color: isBooked 
                            ? Colors.red.withOpacity(0.1)
                            : (isSelected ? null : (isDark ? const Color(0xFF1E1E1E) : Colors.white)),
                        borderRadius: BorderRadius.circular(12.r),
                        border: isBooked 
                            ? Border.all(color: Colors.red.withOpacity(0.3))
                            : null,
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isBooked 
                              ? Colors.red.withOpacity(0.5)
                              : (isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textSecondary)),
                          decoration: isBooked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('See All', style: TextStyle(fontSize: 13.sp)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Sample Reviews (would be loaded from Firebase)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: widget.doctor.totalReviews > 0
                ? Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            child: Icon(Icons.person, color: AppColors.primary, size: 20.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Patient Review',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (i) => Icon(
                                    i < widget.doctor.rating.round() 
                                        ? Icons.star_rounded 
                                        : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 14.sp,
                                  )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Excellent doctor! Very professional and thorough in examination.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Text(
                        'No reviews yet',
                        style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            return ElevatedButton(
              onPressed: provider.isLoading || _selectedSlot == null
                  ? null
                  : () => _bookAppointment(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 18.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: provider.isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20.sp),
                        SizedBox(width: 10.w),
                        Text(
                          _selectedSlot == null 
                              ? 'Select a time slot' 
                              : 'Book Appointment',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _bookAppointment(AppProvider provider) async {
    if (!provider.isLoggedIn) {
      Get.snackbar('Error', 'Please login to book appointment',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final success = await provider.bookAppointment(
      doctor: widget.doctor,
      date: _selectedDate,
      timeSlot: _selectedSlot!,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Appointment booked successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        provider.errorMessage ?? 'Failed to book appointment',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
