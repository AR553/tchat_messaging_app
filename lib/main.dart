import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tchat_messaging_app/views/home.dart';
import 'package:tchat_messaging_app/views/login.dart';

import 'services/database.dart';
import 'services/firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
  if (isLoggedIn) Firestore.storeUserData();
  AppDatabase database = await $FloorAppDatabase.databaseBuilder('tchat_app.db').build();
  Get.put(database, tag: 'database');
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final AppDatabase database = Get.find(tag: 'database');

  MyApp({Key key, this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TCat Messaging',
      home: isLoggedIn ? HomePage() : LoginPage(),
    );
  }
}


