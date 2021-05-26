import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tchat_messaging_app/services/auth.dart';

import '../nav.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({Key key, this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      body: Column(
        children: [
          StreamBuilder(
            stream: FirebaseMessaging.onMessage,
            builder: (context, AsyncSnapshot<RemoteMessage> snapshot) =>
                Column(
                  children: [
                    Text('${snapshot.data?.data}'),
                    Text('${snapshot.data?.notification?.title}'),
                    Text('${snapshot.data?.notification?.body}'),
                  ],
                ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) => ChatTile(user: widget.user),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  const ChatTile({
    Key key,
    @required this.user,
  }) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${user.displayName}'),
      leading: CircleAvatar(
        backgroundColor: Colors.grey,
        backgroundImage: NetworkImage(user.photoURL),
      ),
    );
  }
}
