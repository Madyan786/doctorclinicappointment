import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/admin/tabs/admin_overview_tab.dart';
import 'package:doctorclinic/admin/tabs/admin_doctors_tab.dart';
import 'package:doctorclinic/admin/tabs/admin_appointments_tab.dart';
import 'package:doctorclinic/admin/tabs/admin_reviews_tab.dart';
import 'package:doctorclinic/admin/tabs/admin_users_tab.dart';
import 'package:doctorclinic/admin/tabs/admin_settings_tab.dart';
import 'package:doctorclinic/auth/user_type_selection_screen.dart';

/// Main Admin Panel - Professional Grade Dashboard
class AdminMain extends StatefulWidget {
  const AdminMain({super.key});

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Overview'),
    _NavItem(icon: Icons.medical_services_rounded, label: 'Doctors'),
    _NavItem(icon: Icons.calendar_month_rounded, label: 'Appointments'),
    _NavItem(icon: Icons.star_rounded, label: 'Reviews'),
    _NavItem(icon: Icons.people_rounded, label: 'Users'),
    _NavItem(icon: Icons.settings_rounded, label: 'Settings'),
  ];

  final List<Widget> _pages = [
    const AdminOverviewTab(),
    const AdminDoctorsTab(),
    const AdminAppointmentsTab(),
    const AdminReviewsTab(),
    const AdminUsersTab(),
    const AdminSettingsTab(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (_selectedIndex != index) {
      _animationController.reset();
      setState(() => _selectedIndex = index);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF0F2F5),
      drawer: isDesktop ? null : _buildDrawer(isDark),
      body: Row(
        children: [
          // Sidebar for Desktop
          if (isDesktop) _buildSidebar(isDark),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                _buildTopBar(isDark, isDesktop),
                
                // Page Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _pages[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation for Mobile
      bottomNavigationBar: !isTablet ? _buildBottomNav(isDark) : null,
    );
  }

  Widget _buildSidebar(bool isDark) {
    return Container(
      width: 260.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFF667eea), const Color(0xFF764ba2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          // Logo & Title
          _buildLogo(),
          SizedBox(height: 40.h),
          // Nav Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                return _buildNavItem(index, _navItems[index], true);
              },
            ),
          ),
          // Logout Button
          _buildLogoutButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFF667eea),
      child: Column(
        children: [
          SizedBox(height: 60.h),
          _buildLogo(),
          SizedBox(height: 30.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                return _buildNavItem(index, _navItems[index], false);
              },
            ),
          ),
          _buildLogoutButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 70.w,
          height: 70.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(
            Icons.admin_panel_settings_rounded,
            color: Colors.white,
            size: 35.sp,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Doctor Clinic',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        Text(
          'Admin Panel',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, _NavItem item, bool isDesktop) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        _onNavItemTapped(index);
        if (!isDesktop) Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected 
              ? Border.all(color: Colors.white.withOpacity(0.3)) 
              : null,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              size: 22.sp,
            ),
            SizedBox(width: 14.w),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                width: 6.w,
                height: 6.h,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: _showLogoutDialog,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.red.shade300, size: 20.sp),
              SizedBox(width: 10.w),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (!isDesktop)
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: Icon(
                    Icons.menu_rounded,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            if (!isDesktop) SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _navItems[_selectedIndex].label,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  _getSubtitle(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Notification Bell
            _buildIconButton(
              icon: Icons.notifications_rounded,
              badge: '3',
              isDark: isDark,
              onTap: () {},
            ),
            SizedBox(width: 12.w),
            // Admin Profile
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 18.sp),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
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

  Widget _buildIconButton({
    required IconData icon,
    String? badge,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              size: 22.sp,
            ),
          ),
          if (badge != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => _onNavItemTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16.w : 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withOpacity(0.1) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _navItems[index].icon,
                        color: isSelected 
                            ? AppColors.primary 
                            : (isDark ? Colors.white54 : AppColors.grey),
                        size: 22.sp,
                      ),
                      if (isSelected) ...[
                        SizedBox(height: 4.h),
                        Text(
                          _navItems[index].label,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  String _getSubtitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Welcome back, Admin!';
      case 1:
        return 'Manage doctor verifications';
      case 2:
        return 'View all appointments';
      case 3:
        return 'Moderate user reviews';
      case 4:
        return 'Manage registered users';
      case 5:
        return 'App configuration';
      default:
        return '';
    }
  }

  void _showLogoutDialog() {
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
              child: const Icon(Icons.logout_rounded, color: Colors.red),
            ),
            SizedBox(width: 12.w),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout from Admin Panel?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<AuthService>().clearUserType();
              Get.offAll(() => const UserTypeSelectionScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
