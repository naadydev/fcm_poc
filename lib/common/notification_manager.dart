import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//#region backgroundMessageHandler
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(); // Don't remove this
  await NotificationManager().showLocalNotification(
    id: 1,
    title: message.notification!.title!,
    body: message.notification!.body!,
  );
}

//#endregion

class NotificationManager {
  final FirebaseMessaging _firebaseMessagingInstance = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _configureLocalNotifications();
    _configureFirebaseMessaging();
  }

  Future<void> _configureLocalNotifications() async {
    requestUserPermission();

    // Enable automatic initialization of Firebase Cloud Messaging (FCM), This means that FCM will automatically initialize and retrieve a device token when the app starts.
    await _firebaseMessagingInstance.setAutoInitEnabled(true);

    await _firebaseMessagingInstance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    //#region **** Terminated State2 ****
    // Check AndroidManifest.xml File -> ~/android/app/src/main/AndroidManifest.xml
    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage = await _firebaseMessagingInstance.getInitialMessage();
    if (initialMessage != null) {
      print("initialMessage Code1 - Terminated State 111 ..");
      _handleMessage(messageStateType: MessageStateType.terminated, message: initialMessage);
    }
    //#endregion

    // ------------
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  void _configureFirebaseMessaging() {
    // **** Foreground State ****
    FirebaseMessaging.onMessage.listen(_onMessage);
    // **** Terminated State ****
    FirebaseMessaging.onMessageOpenedApp.listen(_onLaunchOrResume);
    // **** Background State ****
    // FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    // **** onTokenRefresh ****
    _firebaseMessagingInstance.onTokenRefresh.listen(_onTokenRefresh);
  }

  Future<void> requestUserPermission() async {
    // Request permission to receive messages (Apple & Web):
    // On iOS, macOS and web, before FCM payloads can be received on your device, you must first ask the user's permission.
    // FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await _firebaseMessagingInstance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    print('requestUserPermission Code2: ${settings.authorizationStatus}');
  }

  ///*** **** Foreground State **** If the device in foreground state, then this will call onMessage callback.
  Future<void> _onMessage(RemoteMessage message) async {
    // Handle incoming message while app is in the foreground
    print("_onMessage Code3 - Foreground State ..");
    _handleMessage(messageStateType: MessageStateType.foreground, message: message);
  }

  /// *** Handle launching the app from a terminated or background state You can navigate to a specific screen or handle the data
  Future<void> _onLaunchOrResume(RemoteMessage message) async {
    print("_onLaunchOrResume Code4 - Terminated State 222 ..");
    _handleMessage(messageStateType: MessageStateType.terminated, message: message);
  }

  Future<void> _onTokenRefresh(String token) async {
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new  token is generated.
    print("_onTokenRefresh Code5 Fired $token");
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Notification Payload',
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessagingInstance.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessagingInstance.unsubscribeFromTopic(topic);
  }

  Future<String?> getDeviceRegistrationToken() async {
    // to send messages to individual users, then you need to get the registration token of the device.
    // The token can change if:
    // 1-The app deletes Instance ID
    // 3-The app is restored on a new device
    // 4-The user uninstalls/reinstall the app
    // 5-The user clears app data.
    String? deviceRegistrationToken = await _firebaseMessagingInstance.getToken();
    print('DeviceRegistrationToken ->> $deviceRegistrationToken');
    return deviceRegistrationToken;
  }

  Future<void> _handleMessage({required MessageStateType messageStateType, required RemoteMessage message}) async {
    // message.category
    // message.from
    // message.messageId
    // message.senderId
    // message.sentTime

    final notification = message.notification;
    if (notification != null) {
      final title = notification?.title ?? 'Default Title';
      final body = notification?.body ?? 'Default Body';
      AndroidNotification? android = message.notification?.android;
      Map<String, dynamic> notificationData = message.data;
      print(message.data.values);
      if (message.data['type'] == 'student') {
        // Do Some Logic ....
      }
      print("_handleMessage Code8");
      print("title:$title - body: $body");
      await showLocalNotification(id: notification.hashCode, title: title, body: body); // Display the notification
    }
  }
}

enum MessageStateType { foreground, background, terminated }

//#region **** States ****
// -----------------------------
// Foreground	-> When the application is open, in view and in use.
// Background -> When the application is open, but in the background (minimized). This typically occurs when the user has pressed the "home" button on the device, has switched to another app using the app switcher, or has the application open in a different tab (web).
// Terminated -> When the device is locked or the application is not running.
// Check AndroidManifest.xml File -> ~/android/app/src/main/AndroidManifest.xml
// -----------------------------
// Handling Message In Background, If the application is in background stat
//#endregion

//#region **** Test Send Message ****

// Firebase Notification messages
// Users will receive notification messages even if they are outside of your app.
// Send a notification message to instantly notify users of promotions or new features.
// -----
// Firebase In-App messages
// Users will only be able to receive in-app messages inside of your app.
// Send an In-App message to get active users in your app to subscribe, watch a video, complete a level, or buy an item.
// ----------------
// ** Send Notification to individual Device Using Firebase Console
// Firebase console -> Cloud Messaging -> Firebase Notification messages
// -> in the first step in the right side chose Send test message -> add your device registration message
// ------
// ** Send To Topic Using PostMan
// POST https://fcm.googleapis.com/fcm/send
// Authoritzation key="your_server_key"
// {
// "to": "/topics/messaging",
// "notification": {
// "title": "FCM",
// "body": "messaging tutorial"
// },
// "data": {
// "msgId": "msg_12342"
// }
// }
//#endregion

//#region Send Notification
// Using SDK  -> https://firebase.flutter.dev/docs/messaging/notifications/#via-admin-sdks
// Using REST -> https://firebase.flutter.dev/docs/messaging/notifications/#via-rest
//#endregion

// https://www.youtube.com/watch?v=m2zuJw5c7bw
// https://firebase.google.com/docs/cloud-messaging/flutter/client
// https://github.com/firebase/flutterfire/tree/master/packages/firebase_messaging/firebase_messaging/example/lib
