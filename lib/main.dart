// main.dart (Updated to properly initialize DI)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app.dart';
import 'package:todo_app/bloc_observer.dart';
import 'package:todo_app/error_app.dart';
import 'package:todo_app/src/core/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'injection_container.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize dependency injection and wait for completion
    print('Initializing dependency injection...');
    await di.init();
    print('Dependency injection initialized successfully');

    // Initialize timezone for notifications
    NotificationService.initializeTimeZone();

    // Set up BlocObserver for debugging
    Bloc.observer = AppBlocObserver();

    // Initialize notifications
    await _initializeNotifications();

    print('Starting app...');
    runApp(const ToDoApp());
  } catch (e, stackTrace) {
    print('Error during app initialization: $e');
    print('Stack trace: $stackTrace');

    // Show error app
    runApp(ErrorApp(error: e.toString()));
  }
}

Future<void> _initializeNotifications() async {
  const androidInitializationSettings = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

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
}

void onDidReceiveNotificationResponse(NotificationResponse response) async {
  final String? payload = response.payload;
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
}
