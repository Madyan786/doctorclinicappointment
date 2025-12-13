import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorclinic/core/core.dart';
import 'package:doctorclinic/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

/// Admin Users Tab - Manage Registered Users
class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildSearchBar(isDark),
        _buildStatsRow(isDark),
        Expanded(child: _buildUsersList(isDark)),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white : AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search users by name or email...',
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.grey),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.grey),
          suffixIcon: Container(
            margin: EdgeInsets.all(8.w),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.filter_list_rounded, color: Colors.white, size: 18.sp),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        int totalUsers = 0;
        int newThisWeek = 0;
        
        if (snapshot.hasData) {
          totalUsers = snapshot.data!.docs.length;
          final weekAgo = DateTime.now().subtract(const Duration(days: 7));
          
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['createdAt'] != null) {
              final createdAt = (data['createdAt'] as Timestamp).toDate();
              if (createdAt.isAfter(weekAgo)) newThisWeek++;
            }
          }
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  'Total Users',
                  totalUsers.toString(),
                  Icons.people_rounded,
                  [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                  isDark,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildMiniStatCard(
                  'New This Week',
                  newThisWeek.toString(),
                  Icons.person_add_rounded,
                  [const Color(0xFFf093fb), const Color(0xFFf5576c)],
                  isDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStatCard(String title, String value, IconData icon, List<Color> gradient, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
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

        var users = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        // Filter by appId (only show this app's users)
        users = users.where((u) => u['appId'] == APP_ID || u['appId'] == null).toList();

        // Sort by createdAt locally
        users.sort((a, b) {
          final dateA = a['createdAt'] as Timestamp?;
          final dateB = b['createdAt'] as Timestamp?;
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });

        // Filter by search
        if (_searchQuery.isNotEmpty) {
          users = users.where((u) =>
              (u['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (u['email'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        if (users.isEmpty) {
          return _buildEmptyState(isDark);
        }

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
                  childAspectRatio: 2.0,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _buildUserCard(users[index], isDark);
                },
              );
            }
            
            return ListView.builder(
              padding: EdgeInsets.all(20.w),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return _buildUserCard(users[index], isDark);
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
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline_rounded, size: 50.sp, color: AppColors.primary),
          ),
          SizedBox(height: 20.h),
          Text(
            'No users found',
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

  Widget _buildUserCard(Map<String, dynamic> user, bool isDark) {
    final createdAt = user['createdAt'] != null 
        ? (user['createdAt'] as Timestamp).toDate()
        : DateTime.now();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: CircleAvatar(
          radius: 28.r,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          backgroundImage: user['profileImage'] != null && user['profileImage'].toString().isNotEmpty
              ? NetworkImage(user['profileImage'])
              : null,
          child: user['profileImage'] == null || user['profileImage'].toString().isEmpty
              ? Text(
                  (user['name'] ?? 'U')[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        title: Text(
          user['name'] ?? 'Unknown User',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 14.sp, color: AppColors.grey),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    user['email'] ?? 'No email',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14.sp, color: AppColors.grey),
                SizedBox(width: 4.w),
                Text(
                  'Joined ${DateFormat('MMM dd, yyyy').format(createdAt)}',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white54 : AppColors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (context) => [
            _buildPopupItem(Icons.visibility_rounded, 'View Details', Colors.blue),
            _buildPopupItem(Icons.block_rounded, 'Suspend User', Colors.orange),
            _buildPopupItem(Icons.delete_rounded, 'Delete User', Colors.red),
          ],
          onSelected: (value) {
            if (value == 'Delete User') {
              _showDeleteDialog(user['id']);
            }
          },
        ),
      ),
    );
  }

  PopupMenuItem _buildPopupItem(IconData icon, String text, Color color) {
    return PopupMenuItem(
      value: text,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 10.w),
          Text(text, style: TextStyle(fontSize: 14.sp)),
        ],
      ),
    );
  }

  void _showDeleteDialog(String userId) {
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
            const Text('Delete User'),
          ],
        ),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteUser(userId);
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

  Future<void> _deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      Get.snackbar(
        'Success',
        'User deleted',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user');
    }
  }
}
