import 'package:floor/floor.dart';
import 'package:tchat_messaging_app/models/user.dart';

@dao
abstract class UserDao{
  @Query('SELECT * FROM User')
  Future<List<User>> findAllUsers();

  @Query('SELECT * FROM User WHERE uid = :uid')
  Stream<User> findUserById(int uid);

  @insert
  Future<void> insertUser(User user);

  @update
  Future<void> updateUser(User user);
}