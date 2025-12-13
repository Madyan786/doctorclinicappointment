import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

/// Admin Reviews Tab - Moderate User Reviews
class AdminReviewsTab extends StatefulWidget {
  const AdminReviewsTab({super.key});

  @override
  State<AdminReviewsTab> createState() => _AdminReviewsTabState();
}

class _AdminReviewsTabState extends State<AdminReviewsTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildStatsHeader(isDark),
        _buildFilterChips(isDark),
        Expanded(child: _buildReviewsList(isDark)),
      ],
    );
  }

  Widget _buildStatsHeader(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('reviews').snapshots(),
      builder: (context, snapshot) {
        int total = 0, pending = 0, approved = 0;
        double avgRating = 0;

        if (snapshot.hasData) {
          total = snapshot.data!.docs.length;
          double totalRating = 0;
          
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['isApproved'] == true) {
              approved++;
            } else {
              pending++;
            }
            totalRating += (data['rating'] ?? 0).toDouble();
          }
          
          if (total > 0) avgRating = totalRating / total;
        }

        return Container(
          margin: EdgeInsets.all(20.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildStatItem('Total', total.toString(), Icons.rate_review_rounded),
              _buildDivider(),
              _buildStatItem('Pending', pending.toString(), Icons.hourglass_top_rounded),
              _buildDivider(),
              _buildStatItem('Approved', approved.toString(), Icons.check_circle_rounded),
              _buildDivider(),
              _buildStatItem('Avg Rating', avgRating.toStringAsFixed(1), Icons.star_rounded),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50.h,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = [
      {'label': 'All Reviews', 'value': 'all'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Approved', 'value': 'approved'},
    ];

    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 10.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['value'];
          
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter['value']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)])
                    : null,
                color: isSelected ? null : (isDark ? const Color(0xFF1A1A2E) : Colors.white),
                borderRadius: BorderRadius.circular(25.r),
                border: isSelected ? null : Border.all(
                  color: isDark ? Colors.white24 : AppColors.lightGrey,
                ),
              ),
              child: Text(
                filter['label']!,
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

  Widget _buildReviewsList(bool isDark) {
    // Simple query without orderBy to avoid index requirement
    Stream<QuerySnapshot> stream;
    if (_selectedFilter == 'pending') {
      stream = _firestore.collection('reviews').where('isApproved', isEqualTo: false).snapshots();
    } else if (_selectedFilter == 'approved') {
      stream = _firestore.collection('reviews').where('isApproved', isEqualTo: true).snapshots();
    } else {
      stream = _firestore.collection('reviews').snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 50.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 14.sp)),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(isDark);
        }

        var reviews = snapshot.data!.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList();

        // Sort locally by date
        reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            
            if (isTablet) {
              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 0.9,
                ),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return _buildReviewCard(reviews[index], isDark);
                },
              );
            }
            
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return _buildReviewCard(reviews[index], isDark);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_rounded, size: 50.sp, color: Colors.amber),
          ),
          SizedBox(height: 20.h),
          Text(
            'No reviews found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: review.isApproved 
              ? Colors.green.withOpacity(0.3) 
              : Colors.orange.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  backgroundImage: review.patientImage.isNotEmpty 
                      ? NetworkImage(review.patientImage) 
                      : null,
                  child: review.patientImage.isEmpty
                      ? Icon(Icons.person, color: AppColors.primary, size: 24.sp)
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.patientName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Reviewed Dr. ${review.doctorName}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Rating Stars
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 18.sp,
                        );
                      }),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: (review.isApproved ? Colors.green : Colors.orange).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        review.isApproved ? 'APPROVED' : 'PENDING',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: review.isApproved ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Review Content
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote_rounded, color: AppColors.grey, size: 20.sp),
                SizedBox(height: 8.h),
                Text(
                  review.comment,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Footer
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(review.createdAt),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.grey,
                  ),
                ),
                Row(
                  children: [
                    if (!review.isApproved) ...[
                      _buildActionButton(
                        icon: Icons.check_rounded,
                        color: Colors.green,
                        onTap: () => _approveReview(review.id),
                      ),
                      SizedBox(width: 10.w),
                    ],
                    _buildActionButton(
                      icon: Icons.delete_rounded,
                      color: Colors.red,
                      onTap: () => _showDeleteDialog(review),
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
    );
  }

  Future<void> _approveReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'isApproved': true,
      });
      Get.snackbar(
        'Success',
        'Review approved',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve review');
    }
  }

  void _showDeleteDialog(ReviewModel review) {
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
              child: const Icon(Icons.delete_rounded, color: Colors.red),
            ),
            SizedBox(width: 12.w),
            const Text('Delete Review'),
          ],
        ),
        content: const Text('Are you sure you want to delete this review? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteReview(review.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
      Get.snackbar(
        'Success',
        'Review deleted',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete review');
    }
  }
}
