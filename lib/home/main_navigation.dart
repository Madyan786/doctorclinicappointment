import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/home/home_tab.dart';
import 'package:doctorclinic/home/profile_tab.dart';
import 'package:doctorclinic/home/settings_tab.dart';
import 'package:doctorclinic/home/appointment_tab.dart';
import 'package:doctorclinic/home/all_doctors_tab.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static final List<Widget> _screens = [
    const HomeTab(),
    const ProfileTab(),
    const SettingsTab(),
    const AppointmentTab(),
    const AllDoctorsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navController = Get.put(NavigationController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    // Tablet layout with NavigationRail
    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            // Side Navigation Rail for tablets
            _buildNavigationRail(isDark, navController),
            // Main content
            Expanded(
              child: Obx(() => _screens[navController.currentIndex.value]),
            ),
          ],
        ),
      );
    }
    
    // Phone layout with bottom navigation
    return Scaffold(
      body: Obx(() => _screens[navController.currentIndex.value]),
      bottomNavigationBar: Container(
        height: 75.h,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home', isDark),
              _buildNavItem(1, Icons.person_rounded, 'Profile', isDark),
              _buildNavItem(2, Icons.settings_rounded, 'Settings', isDark),
              _buildNavItem(3, Icons.calendar_month_rounded, 'Appoint', isDark),
              _buildNavItem(4, Icons.people_rounded, 'Doctors', isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    return Obx(() {
      final isSelected = NavigationController.to.currentIndex.value == index;
      return GestureDetector(
        onTap: () => NavigationController.to.changePage(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 16.w : 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withOpacity(0.15) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22.sp,
                color: isSelected 
                    ? AppColors.primary 
                    : (isDark ? Colors.white54 : AppColors.grey),
              ),
              if (isSelected) ...[
                SizedBox(width: 6.w),
                CustomText(
                  label,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNavigationRail(bool isDark, NavigationController navController) {
    return Obx(() => NavigationRail(
      selectedIndex: navController.currentIndex.value,
      onDestinationSelected: (index) => navController.changePage(index),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 4,
      minWidth: 80,
      leading: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
            ),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Icon(Icons.local_hospital_rounded, color: Colors.white, size: 28.sp),
        ),
      ),
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined, size: 24.sp),
          selectedIcon: Icon(Icons.home_rounded, size: 24.sp, color: AppColors.primary),
          label: Text('Home', style: TextStyle(fontSize: 12.sp)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline, size: 24.sp),
          selectedIcon: Icon(Icons.person_rounded, size: 24.sp, color: AppColors.primary),
          label: Text('Profile', style: TextStyle(fontSize: 12.sp)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined, size: 24.sp),
          selectedIcon: Icon(Icons.settings_rounded, size: 24.sp, color: AppColors.primary),
          label: Text('Settings', style: TextStyle(fontSize: 12.sp)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_month_outlined, size: 24.sp),
          selectedIcon: Icon(Icons.calendar_month_rounded, size: 24.sp, color: AppColors.primary),
          label: Text('Appointments', style: TextStyle(fontSize: 12.sp)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline, size: 24.sp),
          selectedIcon: Icon(Icons.people_rounded, size: 24.sp, color: AppColors.primary),
          label: Text('Doctors', style: TextStyle(fontSize: 12.sp)),
        ),
      ],
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 12.sp,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: isDark ? Colors.white54 : AppColors.grey,
        fontSize: 11.sp,
      ),
      indicatorColor: AppColors.primary.withOpacity(0.15),
    ));
  }
}
