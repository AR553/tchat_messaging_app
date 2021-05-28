import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:get/get.dart';
import 'package:tchat_messaging_app/models/message.dart';
import 'package:tchat_messaging_app/models/user.dart';
import 'package:tchat_messaging_app/services/database.dart';
import 'package:tchat_messaging_app/utilities/functions.dart';

abstract class Firestore {
  static final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
  static final CollectionReference _messageCollection = FirebaseFirestore.instance.collection('messages');
  static String _myId = FirebaseAuth.instance.currentUser.uid;

  static Future<QuerySnapshot> getMessages(String chatId) async {
    return _messageCollection.doc(chatId).collection(chatId).orderBy('timestamp', descending: true).get();

    // var documentReference = _messageCollection.doc(chatId);
    // return FirebaseFirestore.instance.runTransaction((transaction) async {
    //   transaction.get(documentReference);
    // }).whenComplete(() => print('got messages from firestore....'));
  }

  static void storeUserData() async {
    var u = FirebaseAuth.instance.currentUser;
    DocumentReference documentReference = _userCollection.doc(u.uid);
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
    AppDatabase database = Get.find(tag: 'database');
    database.userDao.insertUser(user);
  }

  static Stream<QuerySnapshot> retrieveUsers() {
    Stream<QuerySnapshot> queryUsers = _userCollection.orderBy('last_seen', descending: true).snapshots();
    return queryUsers;
  }

  static void updateUserPresence(bool presence) async {
    Map<String, dynamic> data = {
      'presence': presence,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
    };

    var u = FirebaseAuth.instance.currentUser;
    DocumentReference documentReference = _userCollection.doc(u.uid);
    await documentReference.update(data).whenComplete(() {
      print("User Data updated to cloud firestore.");
    }).catchError((e) => print("Error firestore: $e"));
  }

  static void onSendMessage(Message msg, String recipientId) async {
    String chatId = Fns.getChatId(recipientId);
    var documentReference = _messageCollection.doc(chatId).collection(chatId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference.doc(DateTime.now().millisecondsSinceEpoch.toString()),
        msg.toJson(),
      );
    }).whenComplete(() => print('message sent to firestore....'));
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
    AppDatabase database = Get.find(tag: 'database');
    database.messageDao.insertMessage(msg);
    updateTypingStatus(chatId, false);
    // listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  static void resetUnread(String recipientId) {
    String chatId = Fns.getChatId(recipientId);
    var documentReference = _messageCollection.doc(chatId).collection(chatId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(
        documentReference.doc(_myId),
        {'unread_count': 0},
      );
    }).whenComplete(() {
      print('reset completed....');
    });
  }

  static void updateInChatStatus(String recipientId, bool inChat) {
    //recipientId not to be used elsewhere
    String chatId = Fns.getChatId(recipientId);
    var documentReference = _messageCollection.doc(chatId).collection(chatId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(
        documentReference.doc(_myId),
        {'in-chat': inChat},
      );
    }).whenComplete(() {
      print('reset completed....');
    });
  }

  static void updateTypingStatus(String chatId, bool isTyping) {
    var documentReference = _messageCollection.doc(chatId).collection(chatId).doc(_myId);
    if (isTyping) updateUserPresence(true);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(documentReference, {'typing_status': isTyping});
    }).whenComplete(() => print('completed....'));
  }
}
