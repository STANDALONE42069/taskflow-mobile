import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    await _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> showTaskDoneNotification(String taskTitle) async {
    final status = await Permission.notification.status;
    if (!status.isGranted) return;

    const androidDetails = AndroidNotificationDetails(
      'task_done_channel',
      'Task Completed',
      channelDescription: 'Notifications when a task is marked as done',
      importance: Importance.max,   
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF9B1B30),
      enableLights: true,
      enableVibration: true,
      playSound: true,
      ticker: 'Task completed',
    );

    const notifDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '✅ Task Completed!',
      '"$taskTitle" has been marked as done.',
      notifDetails,
    );
  }

  Future<void> showTaskAssignedNotification(
      String taskTitle, String assigneeName) async {
    final status = await Permission.notification.status;
    if (!status.isGranted) return;

    const androidDetails = AndroidNotificationDetails(
      'task_assigned_channel',
      'Task Assigned',
      channelDescription: 'Notifications when a task is assigned',
      importance: Importance.high,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const notifDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '👥 Task Assigned',
      '"$taskTitle" assigned to $assigneeName',
      notifDetails,
    );
  }
}