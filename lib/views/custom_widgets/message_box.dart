import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tchat_messaging_app/models/message.dart';
import 'package:video_viewer/video_viewer.dart';

class MessageBox extends StatelessWidget {
  MessageBox(this.message, {Key key}) : super(key: key);
  final String myId = FirebaseAuth.instance.currentUser.uid;
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: Align(
        alignment: (message.receiverId == myId ? Alignment.topLeft : Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (message.receiverId == myId ? Colors.blueGrey.shade200 : Colors.blue[200]),
          ),
          padding: EdgeInsets.all(16),
          child: message.type == MessageType.text
              ? TextMessageBox(message.content)
              : message.type == MessageType.audio
                  ? AudioMessageBox(message.content)
                  : message.type == MessageType.image
                      ? ImageMessageBox(message.content)
                      : message.type == MessageType.video
                          ? VideoMessageBox(message.content)
                          : FileMessageBox(message.content),
        ),
      ),
    );
  }
}

class AudioMessageBox extends StatefulWidget {
  final String url;

  AudioMessageBox(this.url);

  @override
  _AudioMessageBoxState createState() => _AudioMessageBoxState();
}

class _AudioMessageBoxState extends State<AudioMessageBox> {
  final audioPlayer = AudioPlayer();
  Duration duration;
  IconData icon = Icons.play_arrow;

  @override
  void initState() {
    audioPlayer.setUrl(widget.url).then((value) {
      duration = value;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .4,
      height: 20,
      child: Row(
        children: [
          IconButton(
            icon: StreamBuilder(
                stream: audioPlayer.positionStream,
                builder: (context, AsyncSnapshot<Duration> snapshot) {
                  if (snapshot.hasData && duration != null && snapshot.data.inSeconds == duration.inSeconds) {
                    print('equal');
                    icon = Icons.play_arrow;
                    audioPlayer.stop();
                  }
                  return Icon(icon);
                }),
            onPressed: () async {
              if (duration != null) {
                if (audioPlayer.playing) {
                  audioPlayer.pause();
                  icon = Icons.play_arrow;
                } else {
                  audioPlayer.play();
                  icon = Icons.pause;
                }
                setState(() {});
              }
            },
            padding: EdgeInsets.zero,
          ),
          StreamBuilder(
              stream: audioPlayer.positionStream,
              builder: (context, AsyncSnapshot<Duration> snapshot) {
                if (snapshot.hasData && snapshot.data != null && duration != null) {
                  return Expanded(
                    child: Slider(
                      onChanged: (_) {
                        setState(() {});
                      },
                      value: (snapshot.data.inSeconds / duration.inSeconds) * 10,
                      max: 10,
                    ),
                  );
                } else
                  return CircularProgressIndicator();
              })
        ],
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}

class VideoMessageBox extends StatelessWidget {
  final String url;

  VideoMessageBox(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: VideoViewer(
                  source: {'360': VideoSource(video: VideoPlayerController.network(url))},
                ),
              ),
            ),
          )),
      child: Container(
        child: Icon(Icons.play_arrow, size: 40),
        color: Colors.black54,
        width: 200,
        height: 200,
      ),
    ));
  }
}

class FileMessageBox extends StatelessWidget {
  final String url;

  FileMessageBox(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(child: Column(children: [Icon(Icons.file_copy, size: 30), SizedBox(height: 5), Text('file')]));
  }
}

class ImageMessageBox extends StatelessWidget {
  const ImageMessageBox(this.url);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .4,
      height: MediaQuery.of(context).size.width * .4,
      child: Material(
        child: Image.network(url),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }
}

class TextMessageBox extends StatelessWidget {
  const TextMessageBox(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text ?? '',
      style: TextStyle(fontSize: 15),
    );
  }
}
