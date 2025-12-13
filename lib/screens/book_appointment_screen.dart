import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doctorclinic/core/core.dart';

class BookAppointmentScreen extends StatefulWidget {
  final DoctorModel doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String? selectedTimeSlot;
  final TextEditingController notesController = TextEditingController();
  final AppointmentService _appointmentService = Get.find<AppointmentService>();
  List<String> bookedSlots = [];
  bool isLoadingSlots = false;
  File? _paymentSlipImage;
  bool isUploadingSlip = false;

  @override
  void initState() {
    super.initState();
    _loadBookedSlots();
  }

  Future<void> _loadBookedSlots() async {
    setState(() => isLoadingSlots = true);
    bookedSlots = await _appointmentService.getBookedSlots(widget.doctor.id, selectedDate);
    setState(() => isLoadingSlots = false);
  }

  List<String> get availableTimeSlots {
    final slots = <String>[];
    final startParts = widget.doctor.startTime.split(':');
    final endParts = widget.doctor.endTime.split(':');

    int startHour = int.tryParse(startParts[0]) ?? 9;
    int endHour = int.tryParse(endParts[0]) ?? 17;

    for (int hour = startHour; hour < endHour; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      slots.add('${hour.toString().padLeft(2, '0')}:30');
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
        ),
        title: Text(
          'Book Appointment',
          style: TextStyle(
            fontSize: isTablet ? 20.sp : 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(isTablet ? 30.w : 20.w),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Card
            _buildDoctorCard(isDark),
            SizedBox(height: 25.h),

            // Select Date
            _buildSectionTitle('Select Date', isDark),
            SizedBox(height: 12.h),
            _buildDateSelector(isDark),
            SizedBox(height: 25.h),

            // Select Time
            _buildSectionTitle('Select Time', isDark),
            SizedBox(height: 12.h),
            _buildTimeSlots(isDark),
            SizedBox(height: 25.h),

            // Notes
            _buildSectionTitle('Notes (Optional)', isDark),
            SizedBox(height: 12.h),
            _buildNotesField(isDark),
            SizedBox(height: 25.h),

            // Fee Summary
            _buildFeeSummary(isDark),
            SizedBox(height: 25.h),

            // Payment Slip Upload
            _buildSectionTitle('Payment Slip (Required)', isDark),
            SizedBox(height: 12.h),
            _buildPaymentSlipUpload(isDark),
            SizedBox(height: 100.h),
          ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildDoctorCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355CE4).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 35.r,
              backgroundImage: widget.doctor.profileImage.isNotEmpty ? NetworkImage(widget.doctor.profileImage) : null,
              child: widget.doctor.profileImage.isEmpty ? Icon(Icons.person, color: Colors.white, size: 30.sp) : null,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.doctor.specialty,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 16.sp),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        '${widget.doctor.rating} (${widget.doctor.totalReviews} reviews)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDateSelector(bool isDark) {
    return SizedBox(
      height: 90.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index + 1));
          final isSelected = selectedDate.day == date.day &&
              selectedDate.month == date.month &&
              selectedDate.year == date.year;
          final dayName = DateFormat('EEE').format(date);
          final dayNum = DateFormat('dd').format(date);
          final month = DateFormat('MMM').format(date);

          // Check if doctor is available on this day
          final fullDayName = DateFormat('EEEE').format(date);
          final isAvailable = widget.doctor.availableDays.isEmpty ||
              widget.doctor.availableDays.contains(fullDayName);

          return GestureDetector(
            onTap: isAvailable
                ? () {
                    setState(() {
                      selectedDate = date;
                      selectedTimeSlot = null;
                    });
                    _loadBookedSlots();
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 65.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Opacity(
                opacity: isAvailable ? 1.0 : 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : (isDark ? Colors.white60 : AppColors.textSecondary),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      dayNum,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      month,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : (isDark ? Colors.white60 : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots(bool isDark) {
    if (isLoadingSlots) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: availableTimeSlots.map((slot) {
        final isBooked = bookedSlots.contains(slot);
        final isSelected = selectedTimeSlot == slot;

        return GestureDetector(
          onTap: isBooked
              ? null
              : () {
                  setState(() {
                    selectedTimeSlot = slot;
                  });
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 75.w,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                    )
                  : null,
              color: isSelected
                  ? null
                  : isBooked
                      ? (isDark ? Colors.red.withOpacity(0.2) : Colors.red.withOpacity(0.1))
                      : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : isBooked
                        ? Colors.red.withOpacity(0.3)
                        : (isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey),
              ),
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
            child: Column(
              children: [
                Text(
                  slot,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : isBooked
                            ? Colors.red
                            : (isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ),
                if (isBooked) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Booked',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
        ),
      ),
      child: TextField(
        controller: notesController,
        maxLines: 3,
        style: TextStyle(
          fontSize: 14.sp,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Any specific concerns or symptoms...',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white38 : AppColors.grey,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.w),
        ),
      ),
    );
  }

  Widget _buildFeeSummary(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
        ),
      ),
      child: Column(
        children: [
          _buildFeeRow('Consultation Fee', 'Rs. ${widget.doctor.consultationFee.toInt()}', isDark),
          SizedBox(height: 12.h),
          _buildFeeRow('Service Charge', 'Rs. 50', isDark),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(
              color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey,
            ),
          ),
          _buildFeeRow(
            'Total',
            'Rs. ${(widget.doctor.consultationFee + 50).toInt()}',
            isDark,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, bool isDark, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : (isDark ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSlipUpload(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _paymentSlipImage != null 
              ? Colors.green.withOpacity(0.5)
              : (isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGrey),
          width: _paymentSlipImage != null ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (_paymentSlipImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                _paymentSlipImage!,
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Slip Uploaded',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: _pickPaymentSlip,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Change',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            GestureDetector(
              onTap: _pickPaymentSlip,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: Column(
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload_rounded,
                        color: AppColors.primary,
                        size: 35.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Upload Payment Slip',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Take a photo or choose from gallery',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickPaymentSlip() async {
    final ImagePicker picker = ImagePicker();
    
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF1E1E1E) 
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Select Payment Slip',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Get.back();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() {
                          _paymentSlipImage = File(image.path);
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 40.sp),
                          SizedBox(height: 10.h),
                          Text(
                            'Camera',
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
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Get.back();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() {
                          _paymentSlipImage = File(image.path);
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library_rounded, color: Colors.orange, size: 40.sp),
                          SizedBox(height: 10.h),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final bool canBook = selectedTimeSlot != null && _paymentSlipImage != null;
    
    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_paymentSlipImage == null && selectedTimeSlot != null)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Please upload payment slip to book appointment',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: canBook
                    ? const LinearGradient(
                        colors: [Color(0xFF355CE4), Color(0xFF5F6FFF)],
                      )
                    : null,
                color: canBook ? null : AppColors.grey,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: canBook
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Obx(() => ElevatedButton(
                    onPressed: canBook && !_appointmentService.isLoading.value && !isUploadingSlip
                        ? _confirmBooking
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: (_appointmentService.isLoading.value || isUploadingSlip)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                isUploadingSlip ? 'Uploading Slip...' : 'Booking...',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 22.sp),
                              SizedBox(width: 10.w),
                              Text(
                                'Confirm Booking',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    if (selectedTimeSlot == null) {
      Get.snackbar('Error', 'Please select a time slot');
      return;
    }

    if (_paymentSlipImage == null) {
      Get.snackbar('Error', 'Please upload payment slip');
      return;
    }

    // Upload payment slip first
    setState(() => isUploadingSlip = true);
    
    final paymentSlipUrl = await _appointmentService.uploadPaymentSlip(
      _paymentSlipImage!,
      widget.doctor.id,
    );

    if (paymentSlipUrl == null) {
      setState(() => isUploadingSlip = false);
      Get.snackbar('Error', 'Failed to upload payment slip. Please try again.');
      return;
    }

    setState(() => isUploadingSlip = false);

    final success = await _appointmentService.bookAppointment(
      doctor: widget.doctor,
      date: selectedDate,
      timeSlot: selectedTimeSlot!,
      notes: notesController.text.isNotEmpty ? notesController.text : null,
      paymentSlipUrl: paymentSlipUrl,
    );

    if (success) {
      Get.back();
      Get.back();
      // Show success dialog
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.hourglass_top_rounded, color: Colors.orange, size: 50.sp),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Request Sent!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Your appointment request with ${widget.doctor.name} for ${DateFormat('MMM dd, yyyy').format(selectedDate)} at $selectedTimeSlot has been sent.\n\nThe doctor will review your payment slip and confirm your appointment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
        ),
      );
    }
  }
}
