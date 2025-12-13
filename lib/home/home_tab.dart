import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/screens/screens.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF7F9FC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Beautiful App Bar
          SliverToBoxAdapter(child: _buildPremiumHeader(isDark)),
          // Search Bar
          SliverToBoxAdapter(child: _buildSearchBar(isDark)),
          // Quick Actions
          SliverToBoxAdapter(child: _buildQuickActions(isDark)),
          // Specialties Section
          SliverToBoxAdapter(child: _buildSpecialtiesSection(isDark, isTablet)),
          // Featured Doctors
          SliverToBoxAdapter(child: _buildFeaturedDoctors(isDark, isTablet)),
          // Upcoming Appointment
          SliverToBoxAdapter(child: _buildUpcomingAppointment(isDark)),
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(bool isDark) {
    final authService = Get.find<AuthService>();
    
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 25.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
              : [const Color(0xFF667eea), const Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35.r),
          bottomRight: Radius.circular(35.r),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF667eea) : const Color(0xFF667eea)).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Hello, ',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '👋',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    authService.currentUser?.displayName ?? 'Friend',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildHeaderIcon(Icons.notifications_outlined, () {}, isDark),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => NavigationController.to.goToProfile(),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 22.r,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 20.r,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Icon(Icons.person, color: AppColors.primary, size: 22.sp),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Motivational Text
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.favorite_rounded, color: Colors.white, size: 24.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Health Matters! 💪',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Book your appointment with top doctors',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.8),
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
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 22.sp),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: GestureDetector(
        onTap: () => NavigationController.to.goToDoctors(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.search_rounded, color: Colors.white, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  'Search doctors, specialties...',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: isDark ? Colors.white54 : AppColors.grey,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: isDark ? Colors.white54 : AppColors.grey,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 25.h, 20.w, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              '🏥',
              'Find\nDoctors',
              [const Color(0xFF11998e), const Color(0xFF38ef7d)],
              () => NavigationController.to.goToDoctors(),
              isDark,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildQuickActionCard(
              '📅',
              'My\nAppointments',
              [const Color(0xFFf093fb), const Color(0xFFf5576c)],
              () => NavigationController.to.goToAppointments(),
              isDark,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildQuickActionCard(
              '👤',
              'My\nProfile',
              [const Color(0xFF667eea), const Color(0xFF764ba2)],
              () => NavigationController.to.goToProfile(),
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String emoji,
    String label,
    List<Color> colors,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 8.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.map((c) => c.withOpacity(isDark ? 0.3 : 0.15)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: colors[0].withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 28.sp)),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : colors[0].withOpacity(0.9),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTipsBanner(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 25.h, 20.w, 0),
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4facfe).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '🎉 Special Offer',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Get 20% Off',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'on your first consultation!',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Text(
                        'Book Now →',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4facfe),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.local_hospital_rounded,
                size: 80.sp,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtiesSection(bool isDark, bool isTablet) {
    final specialties = [
      {'emoji': '❤️', 'name': 'Cardio', 'color': const Color(0xFFFF6B6B)},
      {'emoji': '👁️', 'name': 'Eye', 'color': const Color(0xFF4ECDC4)},
      {'emoji': '🧠', 'name': 'Neuro', 'color': const Color(0xFF9B59B6)},
      {'emoji': '🦷', 'name': 'Dental', 'color': const Color(0xFF3498DB)},
      {'emoji': '👶', 'name': 'Child', 'color': const Color(0xFFFF9F43)},
      {'emoji': '🦴', 'name': 'Ortho', 'color': const Color(0xFF26de81)},
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Specialties',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Find by category',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => NavigationController.to.goToDoctors(),
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF667eea),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 110.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: specialties.length,
              itemBuilder: (context, index) {
                final spec = specialties[index];
                return _buildSpecialtyCard(
                  spec['emoji'] as String,
                  spec['name'] as String,
                  spec['color'] as Color,
                  isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyCard(String emoji, String name, Color color, bool isDark) {
    return GestureDetector(
      onTap: () => NavigationController.to.goToDoctors(),
      child: Container(
        width: 85.w,
        margin: EdgeInsets.only(right: 14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(isDark ? 0.25 : 0.15),
              color.withOpacity(isDark ? 0.1 : 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: TextStyle(fontSize: 24.sp)),
            ),
            SizedBox(height: 10.h),
            Text(
              name,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedDoctors(bool isDark, bool isTablet) {
    final doctorService = Get.find<DoctorService>();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 30.h, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Top Doctors',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text('⭐', style: TextStyle(fontSize: 18.sp)),
                      ],
                    ),
                    Text(
                      'Highly rated by patients',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => NavigationController.to.goToDoctors(),
                  child: Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF667eea),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 230.h,
            child: Obx(() {
              if (doctorService.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final topDoctors = doctorService.getTopDoctors(limit: 10);
              
              if (topDoctors.isEmpty) {
                return Center(
                  child: Text(
                    'No doctors available',
                    style: TextStyle(color: AppColors.grey),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: topDoctors.length,
                itemBuilder: (context, index) {
                  return _buildDoctorCard(topDoctors[index], isDark);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor, bool isDark) {
    return GestureDetector(
      onTap: () => Get.to(() => DoctorDetailScreen(doctor: doctor)),
      child: Container(
        width: 170.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image Section
            Container(
              height: 110.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667eea).withOpacity(0.2),
                    const Color(0xFF764ba2).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                      child: Image.network(
                        doctor.profileImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person_rounded,
                          size: 50.sp,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 14.sp),
                          SizedBox(width: 2.w),
                          Text(
                            doctor.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Online Badge
                  if (doctor.isAvailable)
                    Positioned(
                      top: 10.h,
                      left: 10.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF26de81),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.h,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      doctor.specialty,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF667eea),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.work_outline_rounded,
                            size: 12.sp, color: AppColors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          '${doctor.experienceYears} yrs',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isDark ? Colors.white54 : AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Rs.${doctor.consultationFee.toInt()}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF26de81),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointment(bool isDark) {
    final appointmentService = Get.find<AppointmentService>();

    return Obx(() {
      if (appointmentService.upcomingAppointments.isEmpty) {
        return const SizedBox.shrink();
      }

      final appointment = appointmentService.upcomingAppointments.first;

      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Upcoming Appointment',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(width: 8.w),
                Text('📅', style: TextStyle(fontSize: 18.sp)),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1E2D), const Color(0xFF2D2D44)]
                      : [Colors.white, const Color(0xFFF8F9FF)],
                ),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 70.w,
                    height: 70.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: appointment.doctorImage.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18.r),
                            child: Image.network(
                              appointment.doctorImage,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.person, color: Colors.white, size: 35.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          appointment.doctorSpecialty,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF667eea),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            _buildAppointmentInfo(
                              Icons.calendar_today_rounded,
                              '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}',
                              isDark,
                            ),
                            SizedBox(width: 16.w),
                            _buildAppointmentInfo(
                              Icons.access_time_rounded,
                              appointment.timeSlot,
                              isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark ? Colors.white30 : AppColors.grey,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAppointmentInfo(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.grey),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? Colors.white54 : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthArticles(bool isDark) {
    final articles = [
      {
        'title': '5 Tips for Better Sleep',
        'image': '😴',
        'color': const Color(0xFF667eea),
      },
      {
        'title': 'Healthy Eating Habits',
        'image': '🥗',
        'color': const Color(0xFF26de81),
      },
      {
        'title': 'Mental Wellness Tips',
        'image': '🧘',
        'color': const Color(0xFFf5576c),
      },
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 30.h, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Row(
              children: [
                Text(
                  'Health Articles',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(width: 8.w),
                Text('📚', style: TextStyle(fontSize: 18.sp)),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 140.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return _buildArticleCard(
                  article['title'] as String,
                  article['image'] as String,
                  article['color'] as Color,
                  isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(String title, String emoji, Color color, bool isDark) {
    return Container(
      width: 200.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isDark ? 0.3 : 0.15),
            color.withOpacity(isDark ? 0.1 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20.w,
            bottom: -20.h,
            child: Text(
              emoji,
              style: TextStyle(fontSize: 80.sp, color: color.withOpacity(0.3)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Article',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'Read More',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward_rounded, color: color, size: 14.sp),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
