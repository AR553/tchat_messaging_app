import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';

import './custom_widgets/chat_tile.dart';
import '../models/user.dart';
import '../nav.dart';
import '../services/database.dart';

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
        toolbarHeight: 100,
        flexibleSpace: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            padding: EdgeInsets.all(20),
              child: Text("TChat Messaging", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)),
        ),
        actions: [
          Align(
            alignment: Alignment.topCenter,
            child: IconButton(
                onPressed: () {
                  Nav.setting(context);
                },
                icon: Icon(Icons.settings)),
          )
        ],
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
            stream: Database().retrieveUsers(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return Center(child: Text(snapshot.error));
              else if (snapshot.hasData) {
                return ListView.separated(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    User user = User.fromJson(snapshot.data.docs[index].data());
                    if (user.uid == FirebaseAuth.instance.currentUser.uid)
                      return Container();
                    else
                      return ChatTile(user: user);
                  }, separatorBuilder: (BuildContext context, int index) {
                  User user = User.fromJson(snapshot.data.docs[index].data());
                  if (user.uid == FirebaseAuth.instance.currentUser.uid)
                    return Container();
                  else
                    return Divider(indent: 50,endIndent: 50,height: 0,);
                  },
                );
              } else
                return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}

