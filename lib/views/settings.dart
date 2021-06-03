import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:tchat_messaging_app/models/app_theme.dart';
import 'package:tchat_messaging_app/services/auth.dart';
import 'package:tchat_messaging_app/utilities/functions.dart';

import '../nav.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key key}) : super(key: key);
  final user = FirebaseAuth.instance.currentUser;
  final AppTheme appTheme = Get.find();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings"
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                width: width <= 400 ? width * .7 : 400,
                height: width <= 300 ? width * .7 : 300,
                decoration: BoxDecoration(
                  image: DecorationImage(image: Image.network(user.photoURL).image, fit: BoxFit.cover),
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
                      Container(
                        transform: Matrix4.translationValues(0, -70, 0),
                        child: CircleAvatar(
                          maxRadius: 70,
                          minRadius: 70,
                          backgroundColor: Colors.grey,
                          backgroundImage: Image.network(user.photoURL).image,
                        ),
                      ),
                      SizedBox(width: 10),
                      Transform.translate(
                        offset: Offset(0,-50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Fns.camelcase(user.displayName.split('-').last),
                              style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 20),
                            ),
                            Text(user.email, style: Theme.of(context).textTheme.bodyText1),
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
                      title: Text('Theme', style: Theme.of(context).textTheme.bodyText1),
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
                        dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                        items: [
                          DropdownMenuItem(child: Text('System ', style: Theme.of(context).textTheme.bodyText1), value: ThemeMode.system),
                          DropdownMenuItem(child: Text('Light ', style: Theme.of(context).textTheme.bodyText1), value: ThemeMode.light),
                          DropdownMenuItem(child: Text('Dark ', style: Theme.of(context).textTheme.bodyText1), value: ThemeMode.dark),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text('Logout', style: Theme.of(context).textTheme.bodyText1),
                      onTap: () {
                        Nav.login(context);
                        Authentication.of(context).signOut(context: context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
