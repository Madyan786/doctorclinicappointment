import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorclinic/core/core.dart';

class DoctorScheduleTab extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorScheduleTab({super.key, required this.doctor});

  @override
  State<DoctorScheduleTab> createState() => _DoctorScheduleTabState();
}

class _DoctorScheduleTabState extends State<DoctorScheduleTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<String> _selectedDays;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _feeController;
  late bool _isAvailable;
  bool _isLoading = false;

  final List<String> _allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    super.initState();
    _selectedDays = List.from(widget.doctor.availableDays);
    _startTimeController = TextEditingController(text: widget.doctor.startTime);
    _endTimeController = TextEditingController(text: widget.doctor.endTime);
    _feeController = TextEditingController(text: widget.doctor.consultationFee.toInt().toString());
    _isAvailable = widget.doctor.isAvailable;
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _saveSchedule() async {
    setState(() => _isLoading = true);
    
    try {
      await _firestore.collection('doctors').doc(widget.doctor.id).update({
        'availableDays': _selectedDays,
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'consultationFee': double.tryParse(_feeController.text) ?? widget.doctor.consultationFee,
        'isAvailable': _isAvailable,
      });
      
      Get.snackbar('Success', 'Schedule updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update schedule');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'My Schedule',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Set your availability for patients',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 30.h),

                  // Availability Toggle
                  _buildSection(
                    'Availability Status',
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: (_isAvailable ? Colors.green : Colors.red).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              _isAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: _isAvailable ? Colors.green : Colors.red,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isAvailable ? 'Available' : 'Not Available',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _isAvailable 
                                      ? 'Patients can book appointments' 
                                      : 'Bookings are disabled',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isAvailable,
                            onChanged: (value) => setState(() => _isAvailable = value),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    isDark,
                  ),
                  SizedBox(height: 25.h),

                  // Working Days
                  _buildSection(
                    'Working Days',
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                                      )
                                    : null,
                                color: isSelected ? null : (isDark ? Colors.white12 : AppColors.lightGrey),
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : AppColors.textSecondary),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    isDark,
                  ),
                  SizedBox(height: 25.h),

                  // Working Hours
                  _buildSection(
                    'Working Hours',
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTimeField('Start Time', _startTimeController, isDark),
                          ),
                          SizedBox(width: 16.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'TO',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildTimeField('End Time', _endTimeController, isDark),
                          ),
                        ],
                      ),
                    ),
                    isDark,
                  ),
                  SizedBox(height: 25.h),

                  // Consultation Fee
                  _buildSection(
                    'Consultation Fee',
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Rs.',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: TextField(
                              controller: _feeController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: '1000',
                                hintStyle: TextStyle(color: AppColors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    isDark,
                  ),
                  SizedBox(height: 40.h),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }

  Widget _buildTimeField(String label, TextEditingController controller, bool isDark) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                controller.text.isEmpty ? '00:00' : controller.text,
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
    );
  }
}
