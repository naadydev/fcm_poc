import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'common/notification_manager.dart';

// Topic messaging on Flutter -> https://firebase.google.com/docs/cloud-messaging/flutter/topic-messaging

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // // Enable automatic initialization of Firebase Cloud Messaging (FCM), This means that FCM will automatically initialize and retrieve a device token when the app starts.
  // await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  await NotificationManager().initialize(); // Initialize the NotificationManager
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FCM Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FCM Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging = FirebaseMessaging.instance;
  String notificationMsg = "Waiting for notification";
  String deviceRegistrationToken = "000";
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    NotificationManager().getDeviceRegistrationToken().then((value) {
      print('DeviceRegistrationToken ->> $value');
      setState(() {
        deviceRegistrationToken = value ?? "000";
        myController.text = deviceRegistrationToken;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              deviceRegistrationToken,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            TextField(
              controller: myController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'deviceRegistrationToken',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Subscribe to a topic
                await NotificationManager().subscribeToTopic('news');
                print('Subscribed to news topic');
              },
              child: const Text('Subscribe to News'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Unsubscribe from a topic
                await NotificationManager().unsubscribeFromTopic('news');
                print('Unsubscribed from news topic');
              },
              child: const Text('Unsubscribe from News'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Show a local notification
                await NotificationManager().showLocalNotification(
                  id: 1,
                  title: 'Local Notification',
                  body: 'This is a local notification example.',
                );
              },
              child: const Text('Show Local Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
