import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:tchat_messaging_app/models/message.dart';
import 'package:tchat_messaging_app/models/user.dart';
import 'package:tchat_messaging_app/utilities/functions.dart';

class Database {
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  storeUserData() async {
    var u = FirebaseAuth.instance.currentUser;
    DocumentReference documentReference = userCollection.doc(u.uid);
    User user = User(
      name: u.displayName,
      uid: u.uid,
      presence: true,
      lastSeenInEpoch: DateTime.now().microsecondsSinceEpoch,
      email: u.email,
      photoURL: u.photoURL,
    );
    var data = user.toJson();
    await documentReference.set(data).whenComplete(() {
      print("User Data added to cloud firestore.");
    }).catchError((e) => print("Error firestore: $e"));

  }

  Stream<QuerySnapshot> retrieveUsers() {
    Stream<QuerySnapshot> queryUsers = userCollection.orderBy('last_seen', descending: true).snapshots();
    return queryUsers;
  }

  updateUserPresence(bool presence) async {
    Map<String, dynamic> data = {
      'presence': presence,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
    };

    var u = FirebaseAuth.instance.currentUser;
    DocumentReference documentReference = userCollection.doc(u.uid);
    await documentReference.update(data).whenComplete(() {
      print("User Data updated to cloud firestore.");
    }).catchError((e) => print("Error firestore: $e"));
  }

  void onSendMessage(Message msg, String recipientId) {
    String chatId = Fns.getChatId(recipientId);
    var documentReference = FirebaseFirestore.instance.collection('messages').doc(chatId).collection(chatId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference.doc(DateTime.now().millisecondsSinceEpoch.toString()),
        msg.toJson(),
      );
    }).whenComplete(() => print('completed....'));
    int count = 0;
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction
          .get(
        documentReference.doc(recipientId),
      )
          .then((value) {
        print('data: ${value.data()}');
        if (value.data().containsKey('unread_count')) count = value.data()['unread_count'];
        count++;
        FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(
            documentReference.doc(recipientId),
            {'unread_count': count},
          );
        }).whenComplete(() {
          print('completed....$count');
        });
      });
    });
    Database().updateTypingStatus(chatId, false);


    // listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void resetUnread(String recipientId) {
    String chatId = Fns.getChatId(recipientId);
    String myId = FirebaseAuth.instance.currentUser.uid;
    var documentReference = FirebaseFirestore.instance.collection('messages').doc(chatId).collection(chatId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(
        documentReference.doc(myId),
        {'unread_count': 0},
      );
    }).whenComplete(() {
      print('reset completed....');
    });
  }
  void updateInChatStatus(String recipientId, bool inChat){
    //recipientId not to be used elsewhere
    String chatId = Fns.getChatId(recipientId);
    String myId = FirebaseAuth.instance.currentUser.uid;
    var documentReference = FirebaseFirestore.instance.collection('messages').doc(chatId).collection(chatId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(
        documentReference.doc(myId),
        {'in-chat': inChat},
      );
    }).whenComplete(() {
      print('reset completed....');
    });
  }

  void updateTypingStatus(String chatId, bool isTyping) {
    String id = FirebaseAuth.instance.currentUser.uid;
    var documentReference = FirebaseFirestore.instance.collection('messages').doc(chatId).collection(chatId).doc(id);
    if (isTyping) updateUserPresence(true);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(documentReference, {'typing_status': isTyping});
    }).whenComplete(() => print('completed....'));
  }
}
