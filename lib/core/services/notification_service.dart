import 'dart:convert';
import 'dart:developer' show log;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  FirebaseNotificationService();
  //
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeFirebaseMessaging() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> registerNotification() async {
    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      await firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await firebaseMessaging.getToken();
    } catch (e) {
      // 'Error loading token -> $e'.log();
      log('Error loading token -> $e');
    }
  }

  Future<void> setupInteractedMessage() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: android,
      iOS: iOS,
    );

    //
    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    //
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    //foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (message.notification != null) {
        log("${notification?.title ?? 'No title'} message ${notification?.body ?? 'No body'} id${notification.hashCode}");
        log('$android');
        log('onMessage listen -- >${message.data}');

        Map<String, dynamic> payload = {'type': message.data['type']};

        String jsonEncodedString = json.encode(payload);
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification?.title ?? 'No title',
          notification?.body ?? 'No body',
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.high,
            ),
          ),
          payload: jsonEncodedString,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _onSelectNotification(
    NotificationResponse? notificationJson,
  ) async {
    if (notificationJson?.payload == null) return;
    log('_onSelectNotification : : ${json.decode(notificationJson!.payload!)}');

    Map<String, dynamic> jsonDecodedMap =
        json.decode(notificationJson.payload!);

    log("--$jsonDecodedMap");
  }

  void _handleMessage(RemoteMessage message) {
    log('handle message : : ${message.toMap()}');
    log("--${message.data}");
  }
}
