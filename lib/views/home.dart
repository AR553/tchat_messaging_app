import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:tchat_messaging_app/models/user.dart';
import 'package:tchat_messaging_app/services/database.dart';

import '../nav.dart';
import 'custom_widgets/chat_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Database().updateUserPresence(true);
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        Database().updateUserPresence(true);
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        Database().updateUserPresence(false);

        print("app in paused");
        break;
      case AppLifecycleState.detached:
        Database().updateUserPresence(false);
        print("app in detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TChat"),
        actions: [
          IconButton(
              onPressed: () {
                Nav.setting(context);
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
            stream: Database().retrieveUsers(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return Center(child: Text(snapshot.error));
              else if (snapshot.hasData)
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    User user = User.fromJson(snapshot.data.docs[index].data());
                    if (user.uid == FirebaseAuth.instance.currentUser.uid)
                      return Container();
                    else
                      return ChatTile(user: user);
                  },
                );
              else
                return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}

