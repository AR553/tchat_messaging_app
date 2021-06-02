import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:tchat_messaging_app/services/auth.dart';
import 'package:tchat_messaging_app/views/home.dart';
import 'package:tchat_messaging_app/views/login.dart';

import 'models/app_theme.dart';
import 'services/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
  if (isLoggedIn) Database().storeUserData();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) Get.put(FlutterLocalNotificationsPlugin());
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage event) async {
  await Firebase.initializeApp();

  var android = AndroidNotificationDetails('0', 'firebase', "Test notification",
      priority: Priority.high, importance: Importance.max);
  var iOS = IOSNotificationDetails();
  var platform = new NotificationDetails(android: android, iOS: iOS);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = Get.find();
  await flutterLocalNotificationsPlugin.show(0, event.notification.title, event.notification.body, platform);
  print("Handling a background message: ${event.messageId}");
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
  final appTheme = Get.put(AppTheme());

  static void sendNotification(RemoteMessage event) async {
    var android = AndroidNotificationDetails('0', 'firebase', "Test notification",
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = Get.find();
    await flutterLocalNotificationsPlugin.show(0, event.notification.title, event.notification.body, platform);
  }

  @override
  void initState() {
    print('wow......................');
    super.initState();
    var initializationSettingsAndroid = AndroidInitializationSettings('flutter_devs');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
    if(!kIsWeb){
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = Get.find();
      flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: (str) async {
        print(str);
        return true;
      });
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      print('data: ${event.data}');
      print('msgType: ${event.messageType}');
      sendNotification(event);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('data1: ${event.data}');
      print('msgType 1: ${event.messageType}');
      sendNotification(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.instance.getToken().then((value) => print(value));
    return Authentication(
      child: AdaptiveTheme(
        initial: AdaptiveThemeMode.system,
        light: ThemeData(
          primaryColor: Colors.blueGrey[300],
          accentColor: Colors.grey,
          scaffoldBackgroundColor: Colors.grey[200],
        ),
        dark: ThemeData(
            primaryColor: Colors.blueGrey[900],
            accentColor: Colors.grey,
            scaffoldBackgroundColor: Colors.blueGrey[500]),
        builder: (light, dark) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TChat Messaging',
          home: isLoggedIn ? HomePage() : LoginPage(),
          darkTheme: dark,
          theme: light,
          themeMode: appTheme.mode,
        ),
      ),
    );
  }
}
