import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  /// INIT (PUT CHANNEL HERE ✅)
  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    // 🔥 IMPORTANT (FOR REALME DEVICES)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'todo_channel',
      'Todo Notifications',
      description: 'Task reminder',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// PERMISSION
  static Future<void> requestPermission() async {
    await Permission.notification.request();
  }

  /// INSTANT TEST
  static Future<void> instant() async {
    await _plugin.show(
      0,
      "Instant Notification",
      "It works!",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel',
          'Todo Notifications',
          channelDescription: 'Test',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }

  /// SCHEDULE
  static Future<void> schedule(
      int id,
      String title,
      DateTime dateTime,
      ) async {

    final delay = dateTime.difference(DateTime.now());

    if (delay.isNegative) return;

    Future.delayed(delay, () async {
      await _plugin.show(
        id,
        title,
        "Reminder",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'todo_channel',
            'Todo Notifications',
            channelDescription: 'Task reminder',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
    });
  }

}