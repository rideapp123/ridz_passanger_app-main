// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
//
// import '../../models/common/restaurant/visiting_history.dart';
// import '../../stores/users/user_store.dart';
// import '../constants/strings_constant.dart';
// import '../enums/local_notification_payload_type.dart';
// import 'dialog_service.dart';
// import 'local_notification_payload.dart';
//
// class LocalNotificationService {
//   LocalNotificationService._();
//
//   // Instance of Flutter-notification plugin
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
//     'high_importance_channel',
//     'LesGo High Importance Notifications',
//     description: 'This channel is used for important notifications.',
//     importance: Importance.max,
//   );
//
//   static final _notificationDetails = NotificationDetails(
//     android: AndroidNotificationDetails(
//       _channel.id,
//       _channel.name,
//       channelDescription: _channel.description,
//       importance: _channel.importance,
//       priority: Priority.high,
//       // color: Colors.white,
//       enableLights: true,
//     ),
//     iOS: const DarwinNotificationDetails(
//       presentAlert: true,
//       presentSound: true,
//       presentBadge: true,
//     ),
//   );
//
//   static Future<void> onDidReceiveNotificationResponse(
//       NotificationResponse? notificationResponse) async {
//     if (notificationResponse?.payload != null &&
//         notificationResponse!.payload!.isNotEmpty) {
//       debugPrint('Payload: $notificationResponse');
//       debugPrint('Payload: ${notificationResponse.payload}');
//
//       if (userStoreProvider().loggedInUser == null) {
//         return;
//       }
//       final payload = LocalNotificationPayload.fromJson(
//           jsonDecode(notificationResponse!.payload!));
//       if (payload.title == LocalNotificationPayloadType.reviewPage.message) {
//         final details = VisitingHistory.fromJson(payload.details);
//         DialogService.showLeaveAReviewDialog(details);
//       }
//       if (payload.title ==
//           LocalNotificationPayloadType.appFeedbackPage.message) {
//         DialogService.showAppFeedBackDialog();
//       }
//     }
//   }
//
//   static Future<void> onDidReceiveLocalNotification(
//       int id, String? title, String? body, String? payload) async {
//     if (payload != null && payload.isNotEmpty) {
//       if (userStoreProvider().loggedInUser == null) {
//         return;
//       }
//       final response = LocalNotificationPayload.fromJson(jsonDecode(payload));
//       if (response.title == LocalNotificationPayloadType.reviewPage.message) {
//         final details = VisitingHistory.fromJson(response.details);
//         DialogService.showLeaveAReviewDialog(details);
//       }
//       if (response.title ==
//           LocalNotificationPayloadType.appFeedbackPage.message) {
//         DialogService.showAppFeedBackDialog();
//       }
//     }
//   }
//
//   @pragma('vm:entry-point')
//   static Future<void> onDidReceiveBackgroundNotificationResponse(
//       NotificationResponse? notificationResponse) async {
//     if (notificationResponse?.payload != null &&
//         notificationResponse!.payload!.isNotEmpty) {
//       final payload = LocalNotificationPayload.fromJson(
//           jsonDecode(notificationResponse.payload!));
//       if (payload.title == LocalNotificationPayloadType.reviewPage.message) {
//         final details = VisitingHistory.fromJson(payload.details);
//         Future.delayed(const Duration(seconds: 3)).then((value) {
//           DialogService.showLeaveAReviewDialog(details);
//         });
//       }
//       if (payload.title ==
//           LocalNotificationPayloadType.appFeedbackPage.message) {
//         Future.delayed(const Duration(seconds: 3)).then((value) {
//           DialogService.showAppFeedBackDialog();
//         });
//       }
//     }
//   }
//
//   ///Requesting permissions on Android 13 or higher
//   static Future<bool?> requestPermission() async {
//     try {
//       return await _notificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.requestNotificationsPermission();
//     } on Exception {
//       return null;
//       // throw PermissionException();
//     }
//   }
//
//   /// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
//   static Future<void> initialize() async {
//     //Android
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings(
//       'ic_launcher',
//     ); //icon
//     //ios
//     const DarwinInitializationSettings initializationSettingsDarwin =
//         DarwinInitializationSettings(
//       onDidReceiveLocalNotification: onDidReceiveLocalNotification,
//       requestAlertPermission: false,
//       requestBadgePermission: false,
//       requestSoundPermission: false,
//     );
//
//     //linux
//     const LinuxInitializationSettings initializationSettingsLinux =
//         LinuxInitializationSettings(
//       defaultActionName: 'Open notification',
//     );
//
//     //initialization settings
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsDarwin,
//       macOS: initializationSettingsDarwin,
//       linux: initializationSettingsLinux,
//     );
//
//     await _notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
//       onDidReceiveBackgroundNotificationResponse:
//           onDidReceiveBackgroundNotificationResponse,
//     );
//
//     final bgTerminatedTap =
//         await _notificationsPlugin.getNotificationAppLaunchDetails();
//     if (bgTerminatedTap != null) {
//       onDidReceiveBackgroundNotificationResponse(
//           bgTerminatedTap.notificationResponse);
//     }
//   }
//
//   ///Show a notification
//   static Future<void> showLocalNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     return _notificationsPlugin.show(
//       id,
//       title,
//       body,
//       _notificationDetails,
//       payload: payload,
//     );
//   }
//
//   ///Show a notification after a specific duration
//   static Future<void> showScheduledNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//     String? payload,
//   }) async {
//     return _notificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(scheduledDate, tz.local),
//       _notificationDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       payload: payload,
//     );
//   }
//
//   ///Show Feedback Notification
//   static Future<void> showFeedbackNotification({
//     int? minutes,
//   }) async {
//     return await LocalNotificationService.showScheduledNotification(
//       id: 'feedback_${userStoreProvider().loggedInUser?.id}'.hashCode,
//       title: AppStrings.APP_FEEDBACK_TITLE,
//       body: AppStrings.APP_FEEDBACK_SUBTITLE,
//       scheduledDate: DateTime.now().add(
//         Duration(minutes: minutes ?? 10),
//       ),
//       payload: jsonEncode(LocalNotificationPayload(
//         title: LocalNotificationPayloadType.appFeedbackPage.message,
//         details: null,
//       ).toJson()),
//     );
//   }
//
//   static Future<bool> isFeedbackNotificationScheduled() async {
//     final pendingNotifications = await getPendingNotifications();
//     final feedbackNotification = pendingNotifications.firstWhere(
//       (element) =>
//           element.id ==
//           'feedback_${userStoreProvider().loggedInUser?.id}'.hashCode,
//     );
//     if (feedbackNotification != null) {
//       return true;
//     }
//     return false;
//   }
//
//   ///Show a notification periodically at a specific time
//   static Future<void> showPeriodicNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//     String? payload,
//     RepeatInterval repeatInterval = RepeatInterval.daily,
//   }) async {
//     return _notificationsPlugin.periodicallyShow(
//       id,
//       title,
//       body,
//       repeatInterval,
//       _notificationDetails,
//       payload: payload,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }
//
//   //Retrieve the list of active notifications
//   static Future<List<ActiveNotification>> getActiveNotifications() async =>
//       await _notificationsPlugin.getActiveNotifications();
//
//   //Retrieve the list of scheduled/pending notifications
//   static Future<List<PendingNotificationRequest>>
//       getPendingNotifications() async =>
//           await _notificationsPlugin.pendingNotificationRequests();
//
//   // Cancel a notification
//   static Future<void> cancelNotification(int id) async {
//     await _notificationsPlugin.cancel(id);
//   }
//
//   // Cancel all notifications
//   static Future<void> cancelAllNotifications() async {
//     await _notificationsPlugin.cancelAll();
//   }
//
//   //Getting details on if the app was launched via a notification created by this plugin
//   static Future<NotificationAppLaunchDetails?>
//       getNotificationAppLaunchDetails() async =>
//           await _notificationsPlugin.getNotificationAppLaunchDetails();
//
//   static Future<void> onLogout() async => cancelAllNotifications();
// }
