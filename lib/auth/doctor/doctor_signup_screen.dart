import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/auth/doctor/doctor_login_screen.dart';

class DoctorSignupScreen extends StatefulWidget {
  const DoctorSignupScreen({super.key});

  @override
  State<DoctorSignupScreen> createState() => _DoctorSignupScreenState();
}

class _DoctorSignupScreenState extends State<DoctorSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers - Personal Info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Controllers - Professional Info
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _qualificationsController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _consultationFeeController = TextEditingController();

  // Controllers - Hospital Info
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _hospitalAddressController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  // Selected days
  List<String> _selectedDays = [];
  final List<String> _allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  // Specialties List
  final List<String> _specialties = [
    'Cardiologist',
    'Dermatologist',
    'General Physician',
    'Neurologist',
    'Orthopedic',
    'Pediatrician',
    'Psychiatrist',
    'Dentist',
    'ENT Specialist',
    'Gynecologist',
    'Ophthalmologist',
    'Urologist',
  ];

  bool _isLoading = false;
  final AuthService _authService = Get.find<AuthService>();
  final DoctorService _doctorService = Get.find<DoctorService>();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _qualificationsController.dispose();
    _aboutController.dispose();
    _consultationFeeController.dispose();
    _hospitalNameController.dispose();
    _hospitalAddressController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _onRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create Firebase Auth account
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Create doctor profile in Firestore
      final doctor = DoctorModel(
        id: '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        specialty: _specialtyController.text.trim(),
        about: _aboutController.text.trim(),
        profileImage: '',
        experienceYears: int.tryParse(_experienceController.text) ?? 0,
        rating: 0,
        totalReviews: 0,
        consultationFee: double.tryParse(_consultationFeeController.text) ?? 500,
        isAvailable: true,
        availableDays: _selectedDays,
        startTime: _startTimeController.text.isNotEmpty ? _startTimeController.text : '09:00',
        endTime: _endTimeController.text.isNotEmpty ? _endTimeController.text : '17:00',
        hospitalName: _hospitalNameController.text.trim(),
        hospitalAddress: _hospitalAddressController.text.trim(),
        qualifications: _qualificationsController.text.split(',').map((e) => e.trim()).toList(),
        createdAt: DateTime.now(),
      );

      await _doctorService.createDoctor(doctor);

      Get.snackbar('Success', 'Account created! Please login.');
      Get.off(() => const DoctorLoginScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => _currentPage > 0 ? _previousPage() : Get.back(),
        ),
        title: Text(
          'Doctor Registration',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 500 : double.infinity),
            child: Column(
              children: [
                // Progress Indicator
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Row(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Container(
                          height: 4.h,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            color: index <= _currentPage
                                ? AppColors.primary
                                : (isDark ? Colors.white24 : AppColors.lightGrey),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Page View
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    children: [
                      _buildPersonalInfoPage(isDark),
                      _buildProfessionalInfoPage(isDark),
                      _buildHospitalInfoPage(isDark),
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

  Widget _buildPersonalInfoPage(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitle('Personal Information', 'Enter your basic details', isDark),
          SizedBox(height: 30.h),
          _buildLabel('Full Name', isDark),
          _buildTextField(_nameController, 'Dr. John Doe', Icons.person_outline, isDark),
          SizedBox(height: 20.h),
          _buildLabel('Email Address', isDark),
          _buildTextField(_emailController, 'doctor@example.com', Icons.email_outlined, isDark),
          SizedBox(height: 20.h),
          _buildLabel('Phone Number', isDark),
          _buildTextField(_phoneController, '+92 300 1234567', Icons.phone_outlined, isDark),
          SizedBox(height: 20.h),
          _buildLabel('Password', isDark),
          _buildTextField(_passwordController, 'Min 6 characters', Icons.lock_outline, isDark, isPassword: true),
          SizedBox(height: 20.h),
          _buildLabel('Confirm Password', isDark),
          _buildTextField(_confirmPasswordController, 'Re-enter password', Icons.lock_outline, isDark, isPassword: true),
          SizedBox(height: 40.h),
          _buildNextButton('Continue', _nextPage, isDark),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoPage(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitle('Professional Details', 'Tell us about your expertise', isDark),
          SizedBox(height: 30.h),
          _buildLabel('Specialty', isDark),
          _buildDropdownField(isDark),
          SizedBox(height: 20.h),
          _buildLabel('Experience (Years)', isDark),
          _buildTextField(_experienceController, '5', Icons.work_outline, isDark, isNumber: true),
          SizedBox(height: 20.h),
          _buildLabel('Qualifications (comma separated)', isDark),
          _buildTextField(_qualificationsController, 'MBBS, MD, FCPS', Icons.school_outlined, isDark),
          SizedBox(height: 20.h),
          _buildLabel('Consultation Fee (Rs.)', isDark),
          _buildTextField(_consultationFeeController, '1000', Icons.payments_outlined, isDark, isNumber: true),
          SizedBox(height: 20.h),
          _buildLabel('About You', isDark),
          _buildTextArea(_aboutController, 'Write about your experience and expertise...', isDark),
          SizedBox(height: 40.h),
          _buildNextButton('Continue', _nextPage, isDark),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildHospitalInfoPage(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageTitle('Hospital & Schedule', 'Set your availability', isDark),
          SizedBox(height: 30.h),
          _buildLabel('Hospital/Clinic Name', isDark),
          _buildTextField(_hospitalNameController, 'City Hospital', Icons.local_hospital_outlined, isDark),
          SizedBox(height: 20.h),
          _buildLabel('Hospital Address', isDark),
          _buildTextField(_hospitalAddressController, 'Street, City', Icons.location_on_outlined, isDark),
          SizedBox(height: 20.h),
          _buildLabel('Available Days', isDark),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _allDays.map((day) {
              final isSelected = _selectedDays.contains(day);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(day);
                    } else {
                      _selectedDays.add(day);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : (isDark ? Colors.white12 : AppColors.lightGrey),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    day.substring(0, 3),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textSecondary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Start Time', isDark),
                    _buildTimeField(_startTimeController, '09:00', isDark),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('End Time', isDark),
                    _buildTimeField(_endTimeController, '17:00', isDark),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 40.h),
          _buildNextButton(
            _isLoading ? 'Creating Account...' : 'Create Account',
            _isLoading ? null : _onRegister,
            isDark,
          ),
          SizedBox(height: 20.h),
          // Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () => Get.off(() => const DoctorLoginScreen()),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildPageTitle(String title, String subtitle, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    bool isDark, {
    bool isPassword = false,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          fontSize: 15.sp,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 15.sp, color: AppColors.grey),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 22.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        ),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller, String hint, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: TextStyle(
          fontSize: 15.sp,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 15.sp, color: AppColors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.w),
        ),
      ),
    );
  }

  Widget _buildDropdownField(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _specialtyController.text.isEmpty ? null : _specialtyController.text,
          hint: Text('Select Specialty', style: TextStyle(fontSize: 15.sp, color: AppColors.grey)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          items: _specialties.map((specialty) {
            return DropdownMenuItem(
              value: specialty,
              child: Text(specialty,
                  style: TextStyle(fontSize: 15.sp, color: isDark ? Colors.white : AppColors.textPrimary)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _specialtyController.text = value ?? '');
          },
        ),
      ),
    );
  }

  Widget _buildTimeField(TextEditingController controller, String hint, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          controller.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          setState(() {});
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded, color: AppColors.primary, size: 22.sp),
            SizedBox(width: 12.w),
            Text(
              controller.text.isEmpty ? hint : controller.text,
              style: TextStyle(
                fontSize: 15.sp,
                color: controller.text.isEmpty ? AppColors.grey : (isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(String text, VoidCallback? onPressed, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
