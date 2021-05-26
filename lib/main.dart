import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tchat_messaging_app/services/auth.dart';
import 'package:tchat_messaging_app/views/home.dart';
import 'package:tchat_messaging_app/views/login.dart';

import 'services/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
  if (isLoggedIn) Database().storeUserData();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  @override
  Widget build(BuildContext context) {
    return Authentication(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TCat Messaging',
        home: isLoggedIn ? HomePage() : LoginPage(),
      ),
    );
  }
}


