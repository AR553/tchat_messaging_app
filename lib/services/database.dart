import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tchat_messaging_app/models/message.dart';
import 'package:tchat_messaging_app/models/user.dart';
import 'package:tchat_messaging_app/utilities/functions.dart';

class Database {
  static final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
  static final CollectionReference _messageCollection = FirebaseFirestore.instance.collection('messages');

  storeUserData() async {
    var mySelf = FirebaseAuth.instance.currentUser;
    DocumentReference documentReference = _userCollection.doc(mySelf.uid);
    User user = User(
      name: mySelf.displayName,
      uid: mySelf.uid,
      presence: true,
      lastSeenInEpoch: DateTime.now().microsecondsSinceEpoch,
      email: mySelf.email,
      photoURL: mySelf.photoURL,
    );
    var data = user.toJson();
    await documentReference.set(data).whenComplete(() {
      print("User Data added to cloud firestore.");
    }).catchError((e) => print("Error firestore: $e"));
  }

  Stream<QuerySnapshot> retrieveUsers() {
    Stream<QuerySnapshot> queryUsers = _userCollection.orderBy('last_seen', descending: true).snapshots();
    return queryUsers;
  }

  updateUserPresence(bool presence) async {
    Map<String, dynamic> data = {
      'presence': presence,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
    };

    var mySelf = FirebaseAuth.instance.currentUser;
    DocumentReference documentReference = _userCollection.doc(mySelf.uid);
    await documentReference.update(data).whenComplete(() {
      print("User Data updated to cloud firestore.");
    }).catchError((e) => print("Error firestore: $e"));
  }

  void onSendMessage(Message msg, String recipientId) {
    String chatId = Fns.getChatId(recipientId);
    var documentReference = _messageCollection.doc(chatId).collection(chatId);

    if (msg.type != MessageType.text) {
      String filePath = msg.content;
      String fileName = msg.content.split('/').last;
      File image = File(filePath);
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(image);
      TaskSnapshot taskSnapshot;
      uploadTask.then((value) {
        if (value != null) {
          taskSnapshot = value;
          taskSnapshot.ref.getDownloadURL().then((downloadUrl) {
            msg = Message(
              timestamp: msg.timestamp,
              receiverId: msg.receiverId,
              type: msg.type,
              senderId: msg.senderId,
              content: downloadUrl,
            );
            FirebaseFirestore.instance.runTransaction((transaction) async {
              transaction.set(
                documentReference.doc(DateTime.now().millisecondsSinceEpoch.toString()),
                msg.toJson(),
              );
            }).whenComplete(() => print('Message sent: ${msg.toJson()}'));
          });
        }
      });
    } else {
      FirebaseFirestore.instance
          .runTransaction((transaction) async {
            transaction.set(
              documentReference.doc(DateTime.now().millisecondsSinceEpoch.toString()),
              msg.toJson(),
            );
          })
          .whenComplete(() => print('Message sent: ${msg.toJson()}'))
          .onError((error, stackTrace) {
            return;
          });
    }
    int count = 0;
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction
          .get(
        documentReference.doc(recipientId),
      )
          .then((value) {
        print('Got unread count: ${value.data()}');
        if (value.data().containsKey('unread_count')) count = value.data()['unread_count'];
        count++;
        FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(
            documentReference.doc(recipientId),
            {'unread_count': count},
          );
        }).whenComplete(() {
          print('Updated unread count to: $count');
        }).onError((error, stackTrace) {
          return;
        });
      });
    });
    Database().updateTypingStatus(chatId, false);


    // listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Future<void> resetUnread(String recipientId) async {
    String chatId = Fns.getChatId(recipientId);
    String myId = FirebaseAuth.instance.currentUser.uid;
    var documentReference = _messageCollection.doc(chatId).collection(chatId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(
        documentReference.doc(myId),
        {'unread_count': 0},
      );
    }).whenComplete(() {
      print('Unread count reset');
    }).onError((error, stackTrace) {
      return;
    });
  }

  void updateInChatStatus(String recipientId, bool inChat){
    //recipientId not to be used elsewhere
    String chatId = Fns.getChatId(recipientId);
    String myId = FirebaseAuth.instance.currentUser.uid;
    var documentReference = _messageCollection.doc(chatId).collection(chatId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(
        documentReference.doc(myId),
        {'in-chat': inChat},
      );
    }).whenComplete(() {
      print('Updating');
    });
  }

  Future<QuerySnapshot> getLastMessage(String hisId) async {
    String chatId = Fns.getChatId(hisId);
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('messages').doc(chatId).collection(chatId);
    return await collectionReference
        .orderBy('timestamp', descending: true)
        .where('sender_id', isEqualTo: hisId)
        .limit(1)
        .get();
  }

  void updateTypingStatus(String chatId, bool isTyping) {
    String myId = FirebaseAuth.instance.currentUser.uid;
    var documentReference = _messageCollection.doc(chatId).collection(chatId).doc(myId);
    if (isTyping) updateUserPresence(true);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      var data = await transaction.get(documentReference);
      if (data.data() == null)
        transaction.set(documentReference, {'typing_status': isTyping});
      else
        transaction.update(documentReference, {'typing_status': isTyping});
    }).whenComplete(() => print('Typing status updated to: $isTyping'));
  }
}
