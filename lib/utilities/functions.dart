import 'package:firebase_auth/firebase_auth.dart';

class Fns {
  static String camelcase(String name) {
    String n = '';
    name.split(' ').forEach((word) => n += word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase() + " ");
    return n.substring(0, n.length - 1);
  }

  static
  String lastSeen(int lastSeenInEpoch, bool presence) {
    DateTime lastSeen =
    DateTime.fromMillisecondsSinceEpoch(lastSeenInEpoch);
    DateTime currentDateTime = DateTime.now();

    Duration differenceDuration = currentDateTime.difference(lastSeen);
    String durationString = differenceDuration.inSeconds > 59
        ? differenceDuration.inMinutes > 59
        ? differenceDuration.inHours > 23
        ? '${differenceDuration.inDays} ${differenceDuration.inDays == 1 ? 'day' : 'days'}'
        : '${differenceDuration.inHours} ${differenceDuration.inHours == 1 ? 'hour' : 'hours'}'
        : '${differenceDuration.inMinutes} ${differenceDuration.inMinutes == 1 ? 'minute' : 'minutes'}'
        : 'few moments';

    String presenceString = presence ? 'Online' : '$durationString ago';
    return presenceString;
  }

  static String getChatId(String receiverId) {
    String senderId = FirebaseAuth.instance.currentUser.uid;
    if(senderId.codeUnitAt(0)>receiverId.codeUnitAt(0))
      return senderId+receiverId;
    else
      return receiverId+senderId;
  }
}