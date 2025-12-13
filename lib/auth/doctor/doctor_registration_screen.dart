import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:doctorclinic/core/core.dart';

/// Doctor Registration Screen - Multi-step registration with document uploads
class DoctorRegistrationScreen extends StatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  State<DoctorRegistrationScreen> createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final PageController _pageController = PageController();
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _addressController = TextEditingController();
  final _aboutController = TextEditingController();

  // Selection Values
  String _selectedSpecialty = 'General Physician';
  List<String> _qualifications = [];
  final _qualificationController = TextEditingController();
  List<String> _selectedDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  // Image Files
  File? _profileImage;
  File? _licenseImage;
  List<File> _degreeImages = [];

  final _picker = ImagePicker();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  final List<String> _specialties = [
    'General Physician', 'Cardiologist', 'Dermatologist', 'Neurologist',
    'Pediatrician', 'Dentist', 'Ophthalmologist', 'Orthopedic',
    'ENT Specialist', 'Gynecologist', 'Psychiatrist', 'Urologist',
    'Gastroenterologist', 'Pulmonologist', 'Nephrologist', 'Oncologist',
  ];

  final List<String> _weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _hospitalController.dispose();
    _addressController.dispose();
    _aboutController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          _buildStepIndicator(isDark),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1BasicInfo(isDark),
                _buildStep2Professional(isDark),
                _buildStep3Schedule(isDark),
                _buildStep4Documents(isDark),
              ],
            ),
          ),
          _buildBottomButtons(isDark),
        ],
      ),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => _currentStep > 0 ? _previousStep() : Get.back(),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      title: Text(
        'Doctor Registration',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    final steps = ['Basic Info', 'Professional', 'Schedule', 'Documents'];
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? const LinearGradient(
                                colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                              )
                            : null,
                        color: isActive ? null : (isDark ? Colors.white24 : AppColors.lightGrey),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(Icons.check_rounded, color: Colors.white, size: 18.sp)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.white : AppColors.grey,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive
                            ? AppColors.primary
                            : (isDark ? Colors.white54 : AppColors.grey),
                      ),
                    ),
                  ],
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      color: index < _currentStep
                          ? AppColors.primary
                          : (isDark ? Colors.white24 : AppColors.lightGrey),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ============== STEP 1: BASIC INFO ==============
  Widget _buildStep1BasicInfo(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Personal Information', isDark),
            SizedBox(height: 20.h),
            
            // Profile Image
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: _profileImage != null
                          ? ClipOval(
                              child: Image.file(
                                _profileImage!,
                                width: 120.w,
                                height: 120.h,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.person, color: Colors.white, size: 50.sp),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(Icons.camera_alt_rounded, 
                            color: AppColors.primary, size: 20.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  'Tap to upload profile photo',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Dr. John Doe',
              icon: Icons.person_outline_rounded,
              validator: (v) => v!.isEmpty ? 'Name is required' : null,
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'doctor@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '+92 300 1234567',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Phone is required' : null,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  // ============== STEP 2: PROFESSIONAL ==============
  Widget _buildStep2Professional(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Professional Details', isDark),
            SizedBox(height: 20.h),
            
            // Specialty Dropdown
            _buildDropdown(
              label: 'Specialty',
              value: _selectedSpecialty,
              items: _specialties,
              onChanged: (v) => setState(() => _selectedSpecialty = v!),
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
            
            _buildTextField(
              controller: _licenseController,
              label: 'License Number',
              hint: 'PMC-12345',
              icon: Icons.badge_outlined,
              validator: (v) => v!.isEmpty ? 'License is required' : null,
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _experienceController,
                    label: 'Experience (Years)',
                    hint: '5',
                    icon: Icons.work_outline_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTextField(
                    controller: _feeController,
                    label: 'Fee (PKR)',
                    hint: '2000',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            _buildTextField(
              controller: _hospitalController,
              label: 'Hospital / Clinic Name',
              hint: 'City Hospital',
              icon: Icons.local_hospital_outlined,
              validator: (v) => v!.isEmpty ? 'Required' : null,
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
            
            _buildTextField(
              controller: _addressController,
              label: 'Hospital Address',
              hint: '123 Main Street, City',
              icon: Icons.location_on_outlined,
              maxLines: 2,
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
            
            _buildTextField(
              controller: _aboutController,
              label: 'About Yourself',
              hint: 'Tell patients about your experience...',
              icon: Icons.info_outline_rounded,
              maxLines: 4,
              isDark: isDark,
            ),
            SizedBox(height: 20.h),
            
            // Qualifications
            _buildSectionTitle('Qualifications', isDark),
            SizedBox(height: 12.h),
            _buildQualificationsInput(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildQualificationsInput(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _qualificationController,
                label: 'Add Qualification',
                hint: 'MBBS, MD, etc.',
                icon: Icons.school_outlined,
                isDark: isDark,
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () {
                if (_qualificationController.text.isNotEmpty) {
                  setState(() {
                    _qualifications.add(_qualificationController.text);
                    _qualificationController.clear();
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.add_rounded, color: Colors.white, size: 24.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _qualifications.map((q) {
            return Chip(
              label: Text(q, style: TextStyle(fontSize: 12.sp)),
              deleteIcon: Icon(Icons.close, size: 16.sp),
              onDeleted: () {
                setState(() => _qualifications.remove(q));
              },
              backgroundColor: AppColors.primary.withOpacity(0.1),
              deleteIconColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============== STEP 3: SCHEDULE ==============
  Widget _buildStep3Schedule(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Available Days', isDark),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _weekDays.map((day) {
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                            )
                          : null,
                      color: isSelected ? null : (isDark ? Colors.white12 : AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(25.r),
                      border: isSelected ? null : Border.all(
                        color: isDark ? Colors.white24 : Colors.transparent,
                      ),
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
            SizedBox(height: 30.h),
            
            _buildSectionTitle('Working Hours', isDark),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _buildTimePicker('Start Time', _startTime, true, isDark)),
                SizedBox(width: 16.w),
                Expanded(child: _buildTimePicker('End Time', _endTime, false, isDark)),
              ],
            ),
            SizedBox(height: 30.h),
            
            // Preview
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Schedule Preview',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Available: ${_selectedDays.map((d) => d.substring(0, 3)).join(", ")}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Timing: ${_formatTime(_startTime)} - ${_formatTime(_endTime)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
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

  Widget _buildTimePicker(String label, TimeOfDay time, bool isStart, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          setState(() {
            if (isStart) {
              _startTime = picked;
            } else {
              _endTime = picked;
            }
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.grey)),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.access_time_rounded, color: AppColors.primary, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============== STEP 4: DOCUMENTS ==============
  Widget _buildStep4Documents(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Upload Documents', isDark),
            SizedBox(height: 8.h),
            Text(
              'Upload clear images of your medical license and degree certificates for verification.',
              style: TextStyle(fontSize: 13.sp, color: AppColors.grey),
            ),
            SizedBox(height: 24.h),
            
            // License Upload
            _buildDocumentUpload(
              title: 'Medical License',
              subtitle: 'PMC/PMDC Registration',
              icon: Icons.badge_rounded,
              image: _licenseImage,
              onTap: _pickLicenseImage,
              isDark: isDark,
              required: true,
            ),
            SizedBox(height: 20.h),
            
            // Degree Uploads
            _buildSectionTitle('Degree Certificates', isDark),
            SizedBox(height: 12.h),
            
            if (_degreeImages.isEmpty)
              _buildDocumentUpload(
                title: 'Add Degree Certificate',
                subtitle: 'MBBS, MD, Specialization, etc.',
                icon: Icons.school_rounded,
                image: null,
                onTap: _pickDegreeImage,
                isDark: isDark,
              )
            else
              Column(
                children: [
                  ..._degreeImages.asMap().entries.map((entry) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.file(
                              entry.value,
                              width: 60.w,
                              height: 60.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Degree Certificate ${entry.key + 1}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() => _degreeImages.removeAt(entry.key));
                            },
                            icon: Icon(Icons.delete_rounded, color: Colors.red, size: 22.sp),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _pickDegreeImage,
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, color: AppColors.primary, size: 22.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Add Another Degree',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 30.h),
            
            // Info Box
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.amber.shade700, size: 22.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Your profile will be reviewed by our admin team. Once approved, you will be able to receive appointments.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.amber.shade700,
                      ),
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

  Widget _buildDocumentUpload({
    required String title,
    required String subtitle,
    required IconData icon,
    File? image,
    required VoidCallback onTap,
    required bool isDark,
    bool required = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: image != null ? Colors.green : AppColors.primary.withOpacity(0.3),
            width: image != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(image, width: 70.w, height: 70.h, fit: BoxFit.cover),
              )
            else
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 30.sp),
              ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      if (required)
                        Text(' *', style: TextStyle(color: Colors.red, fontSize: 16.sp)),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    image != null ? 'Tap to change' : subtitle,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              image != null ? Icons.check_circle_rounded : Icons.upload_rounded,
              color: image != null ? Colors.green : AppColors.primary,
              size: 28.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ============== BOTTOM BUTTONS ==============
  Widget _buildBottomButtons(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('Previous', style: TextStyle(fontSize: 16.sp)),
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 16.w),
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (_currentStep < 3 ? _nextStep : _submitRegistration),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _currentStep < 3 ? 'Next' : 'Submit Registration',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============== HELPER WIDGETS ==============
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 15.sp,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.grey),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 22.sp),
            filled: true,
            fillColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: isDark ? Colors.white12 : AppColors.lightGrey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ============== ACTIONS ==============
  void _nextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  Future<void> _pickLicenseImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );
    if (image != null) {
      setState(() => _licenseImage = File(image.path));
    }
  }

  Future<void> _pickDegreeImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );
    if (image != null) {
      setState(() => _degreeImages.add(File(image.path)));
    }
  }

  Future<void> _submitRegistration() async {
    // Validate
    if (_licenseImage == null) {
      Get.snackbar('Error', 'Please upload your medical license',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_degreeImages.isEmpty) {
      Get.snackbar('Error', 'Please upload at least one degree certificate',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userId = credential.user!.uid;

      // 2. Upload profile image
      String profileImageUrl = '';
      if (_profileImage != null) {
        final profileRef = _storage.ref().child('doctor_images/$userId/profile.jpg');
        await profileRef.putFile(_profileImage!);
        profileImageUrl = await profileRef.getDownloadURL();
      }

      // 3. Upload license image
      final licenseRef = _storage.ref().child('doctor_documents/$userId/license.jpg');
      await licenseRef.putFile(_licenseImage!);
      final licenseUrl = await licenseRef.getDownloadURL();

      // 4. Upload degree images
      List<String> degreeUrls = [];
      for (int i = 0; i < _degreeImages.length; i++) {
        final degreeRef = _storage.ref().child('doctor_documents/$userId/degree_$i.jpg');
        await degreeRef.putFile(_degreeImages[i]);
        final url = await degreeRef.getDownloadURL();
        degreeUrls.add(url);
      }

      // 5. Create doctor document
      await _firestore.collection('doctors').doc(userId).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'specialty': _selectedSpecialty,
        'licenseNumber': _licenseController.text.trim(),
        'experienceYears': int.tryParse(_experienceController.text) ?? 0,
        'consultationFee': double.tryParse(_feeController.text) ?? 0,
        'hospitalName': _hospitalController.text.trim(),
        'hospitalAddress': _addressController.text.trim(),
        'about': _aboutController.text.trim(),
        'qualifications': _qualifications,
        'availableDays': _selectedDays,
        'startTime': '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        'endTime': '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
        'profileImage': profileImageUrl,
        'licenseDocument': licenseUrl,
        'degreeImages': degreeUrls,
        'rating': 0.0,
        'totalReviews': 0,
        'isAvailable': true,
        'isVerified': false,
        'verificationStatus': 'pending',
        'rejectionReason': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 6. Send verification email
      await credential.user!.sendEmailVerification();

      developer.log('✅ Doctor registration successful', name: 'DoctorRegistration');

      // Show success dialog
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, color: Colors.green, size: 50.sp),
              ),
              SizedBox(height: 20.h),
              Text(
                'Registration Submitted!',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'Your profile is under review. We will notify you once approved by admin.',
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

    } on FirebaseAuthException catch (e) {
      developer.log('❌ Auth error: ${e.message}', name: 'DoctorRegistration');
      Get.snackbar('Error', e.message ?? 'Registration failed',
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      developer.log('❌ Registration error: $e', name: 'DoctorRegistration');
      Get.snackbar('Error', 'Registration failed. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
