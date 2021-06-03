import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:tchat_messaging_app/models/message.dart';
import 'package:tchat_messaging_app/models/user.dart';
import 'package:tchat_messaging_app/services/database.dart';
import 'package:tchat_messaging_app/utilities/functions.dart';

import 'custom_widgets/chat_app_bar.dart';
import 'custom_widgets/message_box.dart';

class ChatPage extends StatefulWidget {
  final User user;

  ChatPage({Key key, this.user}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final myself = FirebaseAuth.instance.currentUser;
  final _messageController = TextEditingController();

  Future<String> getFile(FileType fileType) async {
    FilePickerResult result = await FilePicker.platform
        .pickFiles(type: fileType, withData: true, allowCompression: true, onFileLoading: (status) => Center(child: Text('Loading')));
    if (result != null) {
      Uint8List fileBytes = result.files.first.bytes;
      return base64Encode(fileBytes);
    } else {
      return null;
    }
  }

  bool attachMedia = false;
  String chatId;

  @override
  void initState() {
    chatId = Fns.getChatId(widget.user.uid);
    Database().resetUnread(widget.user.uid);
    Database().updateTypingStatus(chatId, false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await Database().resetUnread(widget.user.uid);
        return true;
      },
      child: Scaffold(
        appBar: ChatAppBar(chatId, widget.user),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .doc(chatId)
                    .collection(chatId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error));
                  } else if (snapshot.hasData) {
                    List<Message> messages = [];
                    snapshot.data.docs.forEach((element) {
                      messages.add(Message.fromJson(element.data()));
                    });
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) {
                        return MessageBox(messages[index]);
                      },
                      itemCount: messages.length,
                      reverse: true,
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () => setState(() {
                      attachMedia = !attachMedia;
                    }),
                    child: Icon(
                      attachMedia ? Icons.close : Icons.attach_file,
                      color: attachMedia ? Colors.blue : Colors.white,
                      size: 18,
                    ),
                    backgroundColor: attachMedia ? Colors.grey[300] : Colors.blue,
                    elevation: 0,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border:
                            OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25)),
                        filled: true,
                        fillColor: Colors.grey[300],
                      ),
                      onChanged: (value) {
                        value = value.trim();
                        Database().updateTypingStatus(chatId, value.isNotEmpty);
                      },
                      onSubmitted: (value) {
                        send(_messageController.text, MessageType.text);
                      },
                    ),
                  ),
                  SizedBox(width: 15),
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () => send(_messageController.text, MessageType.text),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],
              ),
            ),
            if (attachMedia)
              Container(
                  padding: EdgeInsets.only(top: 5.0),
                  color: Colors.white,
                  height: 90,
                  child: Center(
                    child: Row(
                      children: [
                        _buildAttachItem(FileType.image, Icons.image),
                        _buildAttachItem(FileType.audio, Icons.mic),
                        _buildAttachItem(FileType.video, Icons.video_call),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void send(String content, String type) {
    if (content != null && content.trim().isNotEmpty) {
      content = content.trim();
      var message = Message(
          content: content,
          senderId: myself.uid,
          type: type,
          receiverId: widget.user.uid,
          timestamp: DateTime.now().millisecondsSinceEpoch);

      if (type == MessageType.text) _messageController.clear();

      Database().onSendMessage(message, widget.user.uid);
      setState(() {
        attachMedia = false;
      });
    } else {
      //TODO
      // Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget _buildAttachItem(FileType fileType, IconData icon) {
    String messageType = fileType.toString().replaceFirst('FileType.', '');
    Color color = Colors.blueAccent[700];
    if (messageType == MessageType.audio)
      color = Colors.purpleAccent[700];
    else if (messageType == MessageType.video) color = Colors.orangeAccent[700];
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: null,
            backgroundColor: color,
            onPressed: () {
              getFile(fileType).then((value) => send(value, messageType));
            },
            child: Icon(icon, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(Fns.camelcase(messageType))
        ],
      ),
    );
  }
}
