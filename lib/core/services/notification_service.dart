import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/appointment_model.dart';

/// Notification Service using Alarm Manager for scheduling appointment reminders
class NotificationService extends GetxController {
  static NotificationService get to => Get.find<NotificationService>();
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // Notification Channel Details
  static const String _channelId = 'appointment_reminders';
  static const String _channelName = 'Appointment Reminders';
  static const String _channelDescription = 'Notifications for appointment reminders';
  
  // Notification IDs
  static const int _24hourReminderId = 1000;
  static const int _1hourReminderId = 2000;
  
  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
    _initializeTimezone();
  }
  
  /// Initialize timezone data
  void _initializeTimezone() {
    tz.initializeTimeZones();
    developer.log('✅ Timezone initialized', name: 'NotificationService');
  }
  
  /// Initialize notification plugin
  Future<void> _initializeNotifications() async {
    // Android settings
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Initialize
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channel for Android
    await _createNotificationChannel();
    
    developer.log('✅ Notifications initialized', name: 'NotificationService');
  }
  
  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    developer.log('🔔 Notification tapped: ${response.payload}', name: 'NotificationService');
    // Navigate to appointment details if needed
    // Get.to(() => AppointmentDetailsScreen(appointmentId: response.payload));
  }
  
  /// Request notification permission (Android 13+)
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    
    if (status.isGranted) {
      developer.log('✅ Notification permission granted', name: 'NotificationService');
      return true;
    } else {
      developer.log('❌ Notification permission denied', name: 'NotificationService');
      Get.snackbar(
        'Permission Required',
        'Please enable notifications to receive appointment reminders',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  /// Schedule appointment reminder using Alarm Manager
  Future<void> scheduleAppointmentReminder(AppointmentModel appointment) async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return;
      
      final appointmentDateTime = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
        int.parse(appointment.timeSlot.split(':')[0]),
        int.parse(appointment.timeSlot.split(':')[1]),
      );
      
      // Schedule 24-hour reminder
      final reminder24h = appointmentDateTime.subtract(const Duration(hours: 24));
      if (reminder24h.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: _24hourReminderId + appointment.id.hashCode,
          title: '📅 Appointment Tomorrow',
          body: 'Your appointment with ${appointment.doctorName} is tomorrow at ${appointment.timeSlot}',
          scheduledTime: reminder24h,
          payload: appointment.id,
        );
        developer.log('✅ 24h reminder scheduled for ${reminder24h}', name: 'NotificationService');
      }
      
      // Schedule 1-hour reminder
      final reminder1h = appointmentDateTime.subtract(const Duration(hours: 1));
      if (reminder1h.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: _1hourReminderId + appointment.id.hashCode,
          title: '⏰ Appointment in 1 Hour',
          body: 'Your appointment with ${appointment.doctorName} is in 1 hour at ${appointment.timeSlot}',
          scheduledTime: reminder1h,
          payload: appointment.id,
        );
        developer.log('✅ 1h reminder scheduled for ${reminder1h}', name: 'NotificationService');
      }
      
      // Schedule exact time reminder
      if (appointmentDateTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: appointment.id.hashCode,
          title: '🏥 Appointment Now',
          body: 'Your appointment with ${appointment.doctorName} is starting now!',
          scheduledTime: appointmentDateTime,
          payload: appointment.id,
        );
        developer.log('✅ Exact time reminder scheduled for ${appointmentDateTime}', name: 'NotificationService');
      }
      
      Get.snackbar(
        'Reminder Set',
        'You will be reminded before your appointment',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      developer.log('❌ Error scheduling reminder: $e', name: 'NotificationService');
    }
  }
  
  /// Schedule a notification at specific time
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(body),
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
  
  /// Cancel appointment reminders
  Future<void> cancelAppointmentReminder(String appointmentId) async {
    try {
      final idHash = appointmentId.hashCode;
      
      await _notificationsPlugin.cancel(_24hourReminderId + idHash);
      await _notificationsPlugin.cancel(_1hourReminderId + idHash);
      await _notificationsPlugin.cancel(idHash);
      
      developer.log('✅ Reminders cancelled for appointment: $appointmentId', name: 'NotificationService');
    } catch (e) {
      developer.log('❌ Error cancelling reminder: $e', name: 'NotificationService');
    }
  }
  
  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    developer.log('✅ All notifications cancelled', name: 'NotificationService');
  }
  
  /// Show instant notification (for testing)
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return;
    
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
    
    developer.log('✅ Instant notification shown', name: 'NotificationService');
  }
  
  /// Show appointment booked notification
  Future<void> showAppointmentBookedNotification(AppointmentModel appointment) async {
    await showInstantNotification(
      title: '✅ Appointment Booked!',
      body: 'Your appointment with ${appointment.doctorName} on ${_formatDate(appointment.appointmentDate)} at ${appointment.timeSlot} has been confirmed.',
      payload: appointment.id,
    );
  }
  
  /// Show appointment cancelled notification
  Future<void> showAppointmentCancelledNotification(AppointmentModel appointment) async {
    await showInstantNotification(
      title: '❌ Appointment Cancelled',
      body: 'Your appointment with ${appointment.doctorName} has been cancelled.',
      payload: appointment.id,
    );
  }
  
  /// Show appointment confirmed notification (for patient)
  Future<void> showAppointmentConfirmedNotification(AppointmentModel appointment) async {
    await showInstantNotification(
      title: '✅ Appointment Confirmed',
      body: 'Dr. ${appointment.doctorName} has confirmed your appointment on ${_formatDate(appointment.appointmentDate)} at ${appointment.timeSlot}.',
      payload: appointment.id,
    );
  }
  
  /// Format date for display
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }
  
  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}

// ============== ALARM MANAGER CALLBACK ==============
// This must be a top-level function (not inside a class)

/// Callback for Alarm Manager (runs in background isolate)
@pragma('vm:entry-point')
void alarmCallback() {
  developer.log('⏰ Alarm triggered!', name: 'AlarmManager');
  // Note: For complex operations, use WorkManager instead
}
