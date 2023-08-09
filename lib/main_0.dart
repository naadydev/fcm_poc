// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// // Topic messaging on Flutter -> https://firebase.google.com/docs/cloud-messaging/flutter/topic-messaging
//
// //#region LocalNotificationsPlugin
// //Global Initialization
// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // title
//     description: 'This channel is used for important notifications.', // description
//     importance: Importance.high,
//     playSound: true);
//
// // flutter local notification
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// //#endregion
//
// //#region backgroundMessageHandler
// @pragma('vm:entry-point')
// Future<void> _backgroundMessageHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//   print('background message ${message.notification!.body} - ${message.notification!.title}');
// }
// //#endregion
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   // Enable automatic initialization of Firebase Cloud Messaging (FCM), This means that FCM will automatically initialize and retrieve a device token when the app starts.
//   await FirebaseMessaging.instance.setAutoInitEnabled(true);
//   FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
//
//   // Firebase local notification plugin
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'FCM Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'FCM Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   late FirebaseMessaging messaging = FirebaseMessaging.instance;
//   String notificationMsg = "Waiting for notification";
//   String deviceRegistrationToken = "000";
//
//   @override
//   void initState() {
//     super.initState();
//     getDeviceRegistrationToken();
//     getNotificationMessage();
//   }
//
//   String? getDeviceRegistrationToken() {
//     // to send messages to individual users,
//     // then you need to get the registration token of the device.
//     // The token can change if
//     // 1-The app deletes Instance ID
//     // 3-The app is restored on a new device
//     // 4-The user uninstalls/reinstall the app
//     // 5-The user clears app data.
//     messaging.getToken().then((value) {
//       setState(() {
//         deviceRegistrationToken = value!;
//       });
//       print('DeviceRegistrationToken ->> $value');
//     });
//   }
//
//   Future<void> getNotificationMessage() async {
//     requestPermission();
//
//     //#region **** Foreground State ****
//     // If the device was in foreground state, then this will call onMessage callback.
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("onMessage Fired - Foreground State ..");
//       _handleMessage(messageStateType: MessageStateType.foreground, message: message);
//     });
//     //#endregion
//
//     //#region **** Terminated State ****
//     // Check AndroidManifest.xml File -> ~/android/app/src/main/AndroidManifest.xml
//     // Get any messages which caused the application to open from a terminated state.
//     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       print("initialMessage Fired - Terminated State ..");
//       _handleMessage(messageStateType: MessageStateType.terminated, message: initialMessage);
//     }
//     //#endregion
//
//     //#region **** Background State ****
//     // If the App in the Background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print("onMessageOpenedApp Fired  - Background State ..");
//       _handleMessage(messageStateType: MessageStateType.background, message: message);
//     });
//     //#endregion
//     // --------------------
//     //#region **** onTokenRefresh ****
//     FirebaseMessaging.instance.onTokenRefresh.listen((String fcmNewToken) {
//       print("onTokenRefresh Fired $fcmNewToken");
//       // TODO: If necessary send token to application server.
//       // Note: This callback is fired at each app startup and whenever a new  token is generated.
//     }).onError((err) {
//       // Error getting token.
//     });
//     //#endregion
//   }
//
//   void _handleMessage({required MessageStateType messageStateType, required RemoteMessage message}) {
//     // message.category
//     // message.from
//     // message.messageId
//     // message.senderId
//     // message.sentTime
//     // ----------------
//     //#region LocalNotificationsPlugin
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//     if (notification != null && android != null) {
//       if (messageStateType == MessageStateType.foreground) {
//         flutterLocalNotificationsPlugin.show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             NotificationDetails(
//               android: AndroidNotificationDetails(
//                 channel.id,
//                 channel.name,
//                 channelDescription: channel.description,
//                 color: Colors.blue,
//                 playSound: true,
//                 icon: '@mipmap/ic_lancher',
//               ),
//               // iOS: DarwinNotificationDetails()
//             ));
//       }
//       if (messageStateType == MessageStateType.background) {
//         showDialog(
//             context: context,
//             builder: (_) {
//               return AlertDialog(
//                 title: Text(notification.title!),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [Text(notification.body!)],
//                   ),
//                 ),
//               );
//             });
//       }
//       if (messageStateType == MessageStateType.terminated) {
//         // flutterLocalNotificationsPlugin.show(
//         //     notification.hashCode,
//         //     notification.title,
//         //     notification.body,
//         //     NotificationDetails(
//         //       android: AndroidNotificationDetails(
//         //         channel.id,
//         //         channel.name,
//         //         channelDescription: channel.description,
//         //         color: Colors.blue,
//         //         playSound: true,
//         //         icon: '@mipmap/ic_lancher',
//         //       ),
//         //     ));
//       }
//     }
//
//     //#endregion
//     // ----------------
//
//     if (message.data['type'] == 'student') {
//       // Do Some Logic ....
//     }
//     if (message.notification != null) {
//       print('Message also contained a notification: ${message.notification}');
//       setState(() {
//         notificationMsg = "title:${message.notification!.title!} - Body:${message.notification!.body}";
//       });
//     }
//     print(message.notification!.body);
//     print(message.data.values);
//     flutterLocalNotificationsPlugin.show(
//         0,
//         "Testing",
//         "This is an Flutter Push Notification",
//         NotificationDetails(
//             android: AndroidNotificationDetails(
//           channel.id,
//           channel.name,
//           channelDescription: channel.description,
//           importance: Importance.high,
//           color: Colors.blue,
//           playSound: true,
//           icon: '@mipmap/ic_launcher',
//         )));
// // **** OR
//     // showDialog(
//     //     context: context,
//     //     builder: (BuildContext context) {
//     //       return AlertDialog(
//     //         title: const Text("Notification"),
//     //         content: Text(notificationMsg),
//     //         actions: [
//     //           TextButton(
//     //             child: const Text("Ok"),
//     //             onPressed: () {
//     //               Navigator.of(context).pop();
//     //             },
//     //           )
//     //         ],
//     //       );
//     //     });
//   }
//
//   void subscribeToTopic(String topicName) {
//     messaging.subscribeToTopic(topicName);
//   }
//
//   void unsubscribeFromTopic(String topicName) {
//     messaging.subscribeToTopic(topicName);
//   }
//
//   Future<void> requestPermission() async {
//     // Request permission to receive messages (Apple & Web):
//     // On iOS, macOS and web, before FCM payloads can be received on your device, you must first ask the user's permission.
//     // FirebaseMessaging messaging = FirebaseMessaging.instance;
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       announcement: false,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//     );
//
//     print('User granted permission: ${settings.authorizationStatus}');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               deviceRegistrationToken,
//               style: Theme.of(context).textTheme.labelSmall,
//             ),
//             Text(
//               notificationMsg,
//               style: Theme.of(context).textTheme.headlineLarge,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// enum MessageStateType { foreground, background, terminated }
//
// // https://www.youtube.com/watch?v=m2zuJw5c7bw
// // https://firebase.google.com/docs/cloud-messaging/flutter/client
// // https://github.com/firebase/flutterfire/tree/master/packages/firebase_messaging/firebase_messaging/example/lib
//
// //#region **** States ****
// // -----------------------------
// // Foreground	-> When the application is open, in view and in use.
// // Background -> When the application is open, but in the background (minimized). This typically occurs when the user has pressed the "home" button on the device, has switched to another app using the app switcher, or has the application open in a different tab (web).
// // Terminated -> When the device is locked or the application is not running.
// // Check AndroidManifest.xml File -> ~/android/app/src/main/AndroidManifest.xml
// // -----------------------------
// // Handling Message In Background, If the application is in background stat
// //#endregion
//
// //#region **** Test Send Message ****
//
// // Firebase Notification messages
// // Users will receive notification messages even if they are outside of your app.
// // Send a notification message to instantly notify users of promotions or new features.
// // -----
// // Firebase In-App messages
// // Users will only be able to receive in-app messages inside of your app.
// // Send an In-App message to get active users in your app to subscribe, watch a video, complete a level, or buy an item.
// // ----------------
// // ** Send Notification to individual Device Using Firebase Console
// // Firebase console -> Cloud Messaging -> Firebase Notification messages
// // -> in the first step in the right side chose Send test message -> add your device registration message
// // ------
// // ** Send To Topic Using PostMan
// // POST https://fcm.googleapis.com/fcm/send
// // Authoritzation key="your_server_key"
// // {
// // "to": "/topics/messaging",
// // "notification": {
// // "title": "FCM",
// // "body": "messaging tutorial"
// // },
// // "data": {
// // "msgId": "msg_12342"
// // }
// // }
// //#endregion
//
// //#region Send Notification
// // Using SDK  -> https://firebase.flutter.dev/docs/messaging/notifications/#via-admin-sdks
// // Using REST -> https://firebase.flutter.dev/docs/messaging/notifications/#via-rest
// //#endregion
