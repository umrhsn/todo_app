import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app.dart';
import 'package:todo_app/bloc_observer.dart';
import 'package:todo_app/src/core/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone for notifications
  NotificationService.initializeTimeZone();

  // Set up BlocObserver for debugging
  Bloc.observer = AppBlocObserver();

  // Updated initialization settings
  const androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const darwinInitializationSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: darwinInitializationSettings,
    macOS: darwinInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  );

  runApp(const TodoApp());
}

// Updated notification response handler
void onDidReceiveNotificationResponse(NotificationResponse response) async {
  final String? payload = response.payload;
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
}
