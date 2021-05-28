import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../dao/message_dao.dart';
import '../dao/user_dao.dart';
import '../models/message.dart';
import '../models/user.dart';

part 'database.g.dart';

@Database(version: 1, entities: [User, Message])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;

  MessageDao get messageDao;
}
