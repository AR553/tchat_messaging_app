import 'dart:async';
import 'dart:core';

import 'package:floor/floor.dart';
import 'package:tchat_messaging_app/models/message.dart';

@dao
abstract class MessageDao{
  @Query('SELECT * FROM Message WHERE chatId = :chatId ORDER BY timestamp DESC')
  Future<List<Message>> getChatMessages(String chatId);

  @Query('SELECT * FROM Message WHERE chatId = :chatId ORDER BY timestamp DESC')
  Stream<List<Message>> getChatMessagesAsStream(String chatId);

  @Query('SELECT * FROM Message')
  Future<List<Message>> getAllMessages();

  @Query('SELECT * FROM Message')
  Stream<List<Message>> getAllMessagesAsStream();

  @insert
  Future<void> insertMessage(Message message);

  @insert
  Future<void> insertMessages(List<Message> messages);

  @delete
  Future<void> clear(List<Message> messages);

}