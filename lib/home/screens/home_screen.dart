import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/core/providers/providers.dart';
import 'package:doctorclinic/home/screens/doctor_detail_screen.dart';

/// Home Screen with Pull-to-Refresh & Cached Images
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController _refreshController = RefreshController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchDoctors();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    await context.read<AppProvider>().refreshDoctors();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              onRefresh: _onRefresh,
              header: WaterDropMaterialHeader(
                backgroundColor: AppColors.primary,
                color: Colors.white,
              ),
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(child: _buildHeader(isDark)),
                  
                  // Search Bar
                  SliverToBoxAdapter(child: _buildSearchBar(isDark, provider)),
                  
                  // Specialty Filter
                  SliverToBoxAdapter(child: _buildSpecialtyFilter(isDark, provider)),
                  
                  // Top Rated Section
                  SliverToBoxAdapter(child: _buildTopRatedSection(isDark, provider)),
                  
                  // All Doctors Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'All Doctors',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          if (!provider.hasInternet)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.cloud_off_rounded, size: 14.sp, color: Colors.orange),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Offline',
                                    style: TextStyle(fontSize: 11.sp, color: Colors.orange, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Doctors List - Responsive
                  if (provider.isLoading && provider.doctors.isEmpty)
                    SliverToBoxAdapter(child: _buildShimmerList())
                  else if (provider.doctors.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState(isDark))
                  else
                    SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final isTablet = constraints.crossAxisExtent > 600;
                        
                        if (isTablet) {
                          return SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            sliver: SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16.w,
                                mainAxisSpacing: 16.h,
                                childAspectRatio: 2.2,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildDoctorCard(provider.doctors[index], isDark),
                                childCount: provider.doctors.length,
                              ),
                            ),
                          );
                        }
                        
                        return SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildDoctorCard(provider.doctors[index], isDark),
                              childCount: provider.doctors.length,
                            ),
                          ),
                        );
                      },
                    ),
                  
                  SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Your',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Specialist Doctor',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: isDark ? Colors.white70 : AppColors.textPrimary,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, AppProvider provider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.grey, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => provider.setSearchQuery(value),
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search doctors, specialties...',
                hintStyle: TextStyle(fontSize: 15.sp, color: AppColors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.tune_rounded, color: Colors.white, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyFilter(bool isDark, AppProvider provider) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(top: 20.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: provider.specialties.length,
        itemBuilder: (context, index) {
          final specialty = provider.specialties[index];
          final isSelected = provider.selectedSpecialty == specialty;
          
          return GestureDetector(
            onTap: () => provider.setSpecialtyFilter(specialty),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)])
                    : null,
                color: isSelected ? null : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
              ),
              child: Text(
                specialty,
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

  Widget _buildTopRatedSection(bool isDark, AppProvider provider) {
    final topDoctors = provider.getTopRatedDoctors(limit: 5);
    if (topDoctors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Rated Doctors',
                style: TextStyle(
                  fontSize: 20.sp,
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
        ),
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: topDoctors.length,
            itemBuilder: (context, index) {
              return _buildTopDoctorCard(topDoctors[index], isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopDoctorCard(DoctorModel doctor, bool isDark) {
    return GestureDetector(
      onTap: () => Get.to(() => DoctorDetailScreen(doctor: doctor)),
      child: Container(
        width: 160.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Image
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: doctor.profileImage,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 40.r,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) => CircleAvatar(
                        radius: 40.r,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white, size: 30.sp),
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: 40.r,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white, size: 30.sp),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Info
                  Text(
                    doctor.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    doctor.specialty,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        doctor.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '(${doctor.totalReviews})',
                        style: TextStyle(fontSize: 10.sp, color: Colors.white60),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor, bool isDark) {
    return GestureDetector(
      onTap: () => Get.to(() => DoctorDetailScreen(doctor: doctor)),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Doctor Image with CachedNetworkImage
              CachedNetworkImage(
                imageUrl: doctor.profileImage,
                imageBuilder: (context, imageProvider) => Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) => _buildImagePlaceholder(),
              ),
              SizedBox(width: 16.w),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (doctor.isAvailable)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              'Available',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      doctor.specialty,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.local_hospital_rounded, size: 14.sp, color: AppColors.grey),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            doctor.hospitalName,
                            style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        // Rating
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star_rounded, color: Colors.amber, size: 14.sp),
                              SizedBox(width: 4.w),
                              Text(
                                doctor.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Experience
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '${doctor.experienceYears} yrs',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Fee
                        Text(
                          'Rs ${doctor.consultationFee.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(Icons.person, color: AppColors.grey, size: 40.sp),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: List.generate(4, (index) {
            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 80.sp,
              color: AppColors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 20.h),
            Text(
              'No Doctors Found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try changing your search or filters',
              style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
