import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:tchat_messaging_app/models/app_theme.dart';
import 'package:tchat_messaging_app/services/auth.dart';

import '../nav.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key key}) : super(key: key);
  final user = FirebaseAuth.instance.currentUser;
  final AppTheme appTheme = Get.find();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.width * .7,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(user.photoURL), fit: BoxFit.cover),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(.35),
                      Colors.white30,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black, spreadRadius: 0.5)],
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              transform: Matrix4.translationValues(0, -35, 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0.0),
                child: Row(
                  children: [
                    Transform.translate(
                      offset: Offset(0, -MediaQuery.of(context).size.width * .15),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: MediaQuery.of(context).size.width * .15,
                        backgroundImage: Image.network(user.photoURL).image,
                      ),
                    ),
                    SizedBox(width: 10),
                    Transform.translate(
                      offset: Offset(0, -MediaQuery.of(context).size.width * .1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(user.displayName, style: TextStyle(fontSize: 20)),
                          Text(user.email),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0, -95, 0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  ListTile(
                    title: Text('Theme'),
                    trailing: DropdownButton(
                      value: appTheme.mode,
                      onChanged: (value) {
                        appTheme.updateThemeMode(value);
                        if (value == ThemeMode.system)
                          AdaptiveTheme.of(context).setSystem();
                        else if (value == ThemeMode.light)
                          AdaptiveTheme.of(context).setLight();
                        else if (value == ThemeMode.dark) AdaptiveTheme.of(context).setDark();
                      },
                      items: [
                        DropdownMenuItem(child: Text('System '), value: ThemeMode.system),
                        DropdownMenuItem(child: Text('Light '), value: ThemeMode.light),
                        DropdownMenuItem(child: Text('Dark '), value: ThemeMode.dark),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text('Logout'),
                    onTap: () {
                      Authentication.of(context).signOut(context: context).then((value) => Nav.login(context));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
