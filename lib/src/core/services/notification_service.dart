import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:todo_app/main.dart';

class NotificationService {
  final DateTime dateTime;

  NotificationService(this.dateTime);

  // Initialize timezone data (call this in main.dart)
  static void initializeTimeZone() {
    tz.initializeTimeZones();
  }

  void scheduleAlarm({required Duration? timeDifference}) async {
    var scheduleNotificationDateTime = DateTime.now().add(timeDifference!);

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'alarm_notif', 'alarm_notif',
        channelDescription: 'Channel for Alarm notification',
        icon: 'todo_icon',
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        largeIcon: DrawableResourceAndroidBitmap('todo_icon'));

    // Updated iOS notification details
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
        sound: 'notification_sound.wav', // Changed from mp3 to wav
        presentAlert: true,
        presentBadge: true,
        presentSound: true);

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    // Use zonedSchedule instead of schedule
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Task Reminder',
        'Good morning! Time for your task',
        tz.TZDateTime.from(scheduleNotificationDateTime, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  // Method to show immediate notification
  void showImmediateNotification({
    required String title,
    required String body,
  }) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'immediate_notif', 'immediate_notif',
        channelDescription: 'Channel for immediate notifications',
        icon: 'todo_icon',
        importance: Importance.max,
        priority: Priority.high);

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        1, title, body, platformChannelSpecifics);
  }

  // Method to cancel scheduled notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Method to cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
