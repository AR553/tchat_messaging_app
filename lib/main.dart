import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tchat_messaging_app/services/auth.dart';
import 'package:tchat_messaging_app/views/home.dart';
import 'package:tchat_messaging_app/views/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<void> _initialization() async {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  @override
  Widget build(BuildContext context) {
    return Authentication(
      child: MaterialApp(
        title: 'TCat Messaging',
        home: FutureBuilder(
          future: _initialization(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              FirebaseAuth auth = FirebaseAuth.instance;
              if (auth.currentUser != null) return HomePage(user: auth.currentUser);
              return LoginPage();
            } else if (snapshot.hasError) {
              return Center(child: Text('Something went wrong...'));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}


