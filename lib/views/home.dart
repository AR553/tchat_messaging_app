import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tchat_messaging_app/services/auth.dart';

import '../nav.dart';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TChat"),
        actions: [
          IconButton(
              onPressed: () {
                Authentication.of(context).signOut(context: context).then((value) => Nav.login(context));
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) => ListTile(
            title: Text('${user.displayName}'),
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(user.photoURL),
            ),
          ),
        ),
      ),
    );
  }
}
