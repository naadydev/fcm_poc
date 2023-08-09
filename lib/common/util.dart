import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// // https://www.youtube.com/watch?v=m2zuJw5c7bw
// https://blog.logrocket.com/add-flutter-push-notifications-firebase-cloud-messaging/
// https://vhhullatti94.medium.com/push-notification-in-flutter-using-firebase-cloud-messaging-and-flutter-local-notifications-5ffe96cfa76e
// https://firebase.flutter.dev/docs/messaging/notifications/#via-rest
// https://blog.devgenius.io/fcm-push-notifications-using-firebase-functions-3a6b93a8336a
// https://www.fluttercampus.com/guide/246/push-local-notification-firebase-fcm/
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  void initialize() {
    const InitializationSettings initializationSettings = InitializationSettings(android: AndroidInitializationSettings("@minmap/ic_launcher"));
    // _otificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? payload) {
    //
    // });
  }
}
