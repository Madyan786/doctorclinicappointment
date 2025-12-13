import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/screens/screens.dart';

class AllDoctorsTab extends StatelessWidget {
  const AllDoctorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DoctorService doctorService = Get.find<DoctorService>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final crossAxisCount = isTablet ? 2 : 1;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 900 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header
                _buildHeader(isDark, doctorService),
                SizedBox(height: 15.h),
                // Specialty Filter
                _buildSpecialtyFilter(isDark, doctorService),
                SizedBox(height: 15.h),
                // Doctors Count
                Obx(() => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Container(
                        width: 4.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      CustomText(
                        '${doctorService.filteredDoctors.length} Doctors Available',
                        fontSize: isTablet ? 15 : 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ],
                  ),
                )),
                SizedBox(height: 12.h),
                // Doctors List/Grid
                Expanded(
                  child: Obx(() {
                    if (doctorService.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (doctorService.filteredDoctors.isEmpty) {
                      return _buildEmptyState(isDark, doctorService);
                    }

                    // Use GridView for tablets, ListView for phones
                    if (isTablet) {
                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 16.w,
                          childAspectRatio: 2.8,
                        ),
                        itemCount: doctorService.filteredDoctors.length,
                        itemBuilder: (context, index) {
                          return _buildDoctorCard(doctorService.filteredDoctors[index], isDark);
                        },
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: doctorService.filteredDoctors.length,
                      itemBuilder: (context, index) {
                        return _buildDoctorCard(doctorService.filteredDoctors[index], isDark);
                      },
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

  Widget _buildHeader(bool isDark, DoctorService doctorService) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.people_rounded, color: Colors.white, size: 24.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'Find Your Doctor',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    CustomText(
                      'Book appointments with top specialists',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: TextField(
              onChanged: (value) => doctorService.setSearchQuery(value),
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name, specialty...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.white38 : AppColors.grey,
                ),
                prefixIcon: Container(
                  padding: EdgeInsets.all(12.w),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.search_rounded, color: AppColors.primary, size: 20.sp),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyFilter(bool isDark, DoctorService doctorService) {
    return SizedBox(
      height: 45.h,
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: doctorService.specialties.length,
        itemBuilder: (context, index) {
          final specialty = doctorService.specialties[index];
          final isSelected = doctorService.selectedSpecialty.value == specialty;
          
          return GestureDetector(
            onTap: () => doctorService.setSpecialtyFilter(specialty),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)])
                    : null,
                color: isSelected ? null : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(25.r),
                border: isSelected
                    ? null
                    : Border.all(color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                    : null,
              ),
              alignment: Alignment.center,
              child: CustomText(
                specialty,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textSecondary),
              ),
            ),
          );
        },
      )),
    );
  }

  Widget _buildEmptyState(bool isDark, DoctorService doctorService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded, size: 50.sp, color: AppColors.primary),
          ),
          SizedBox(height: 20.h),
          CustomText(
            'No doctors found',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          SizedBox(height: 8.h),
          CustomText(
            'Try a different search or filter',
            fontSize: 14,
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () {
              doctorService.setSearchQuery('');
              doctorService.setSpecialtyFilter('All');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text('Clear Filters', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor, bool isDark) {
    return GestureDetector(
      onTap: () => Get.to(() => DoctorDetailScreen(doctor: doctor)),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
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
        child: Row(
          children: [
            // Doctor Image with availability indicator
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: doctor.isAvailable ? Colors.green : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 35.r,
                    backgroundImage: doctor.profileImage.isNotEmpty ? NetworkImage(doctor.profileImage) : null,
                    child: doctor.profileImage.isEmpty ? Icon(Icons.person, color: Colors.white, size: 30.sp) : null,
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 16.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: doctor.isAvailable ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      doctor.isAvailable ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 14.w),
            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          doctor.name,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 14.sp, color: Colors.amber),
                            SizedBox(width: 2.w),
                            CustomText(
                              doctor.rating.toString(),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade700,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: CustomText(
                      doctor.specialty,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    children: [
                      _buildInfoChip(Icons.work_rounded, '${doctor.experienceYears} yrs', isDark),
                      _buildInfoChip(Icons.reviews_rounded, '${doctor.totalReviews} reviews', isDark),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            // Book Button
            Container(
              decoration: BoxDecoration(
                gradient: doctor.isAvailable
                    ? const LinearGradient(colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)])
                    : null,
                color: doctor.isAvailable ? null : AppColors.grey,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: doctor.isAvailable
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: doctor.isAvailable
                      ? () => Get.to(() => BookAppointmentScreen(doctor: doctor))
                      : null,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      children: [
                        Icon(
                          doctor.isAvailable ? Icons.calendar_month_rounded : Icons.block_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(height: 2.h),
                        CustomText(
                          doctor.isAvailable ? 'Book' : 'Busy',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: isDark ? Colors.white54 : AppColors.grey),
        SizedBox(width: 4.w),
        CustomText(
          text,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white60 : AppColors.textSecondary,
        ),
      ],
    );
  }
}
