import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
  final appTheme = Get.put(AppTheme());

  @override
  Widget build(BuildContext context) {
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
          scaffoldBackgroundColor: Colors.blueGrey[500]
        ),
        builder: (light, dark) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TCat Messaging',
          home: isLoggedIn ? HomePage() : LoginPage(),
          darkTheme: dark,
          theme: light,
          themeMode: appTheme.mode,
        ),
      ),
    );
  }
}


