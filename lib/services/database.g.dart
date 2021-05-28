// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao _userDaoInstance;

  MessageDao _messageDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`id` INTEGER, `uid` TEXT, `name` TEXT, `presence` INTEGER, `photoURL` TEXT, `lastSeenInEpoch` INTEGER, `email` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Message` (`content` TEXT, `receiverId` TEXT, `senderId` TEXT, `chatId` TEXT, `timestamp` INTEGER, `type` TEXT, PRIMARY KEY (`timestamp`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  MessageDao get messageDao {
    return _messageDaoInstance ??= _$MessageDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (User item) => <String, dynamic>{
                  'id': item.id,
                  'uid': item.uid,
                  'name': item.name,
                  'presence':
                      item.presence == null ? null : (item.presence ? 1 : 0),
                  'photoURL': item.photoURL,
                  'lastSeenInEpoch': item.lastSeenInEpoch,
                  'email': item.email
                },
            changeListener),
        _userUpdateAdapter = UpdateAdapter(
            database,
            'User',
            ['id'],
            (User item) => <String, dynamic>{
                  'id': item.id,
                  'uid': item.uid,
                  'name': item.name,
                  'presence':
                      item.presence == null ? null : (item.presence ? 1 : 0),
                  'photoURL': item.photoURL,
                  'lastSeenInEpoch': item.lastSeenInEpoch,
                  'email': item.email
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  final UpdateAdapter<User> _userUpdateAdapter;

  @override
  Future<List<User>> findAllUsers() async {
    return _queryAdapter.queryList('SELECT * FROM User',
        mapper: (Map<String, dynamic> row) => User(
            uid: row['uid'] as String,
            name: row['name'] as String,
            presence:
                row['presence'] == null ? null : (row['presence'] as int) != 0,
            photoURL: row['photoURL'] as String,
            lastSeenInEpoch: row['lastSeenInEpoch'] as int,
            email: row['email'] as String));
  }

  @override
  Stream<User> findUserById(int uid) {
    return _queryAdapter.queryStream('SELECT * FROM User WHERE uid = ?',
        arguments: <dynamic>[uid],
        queryableName: 'User',
        isView: false,
        mapper: (Map<String, dynamic> row) => User(
            uid: row['uid'] as String,
            name: row['name'] as String,
            presence:
                row['presence'] == null ? null : (row['presence'] as int) != 0,
            photoURL: row['photoURL'] as String,
            lastSeenInEpoch: row['lastSeenInEpoch'] as int,
            email: row['email'] as String));
  }

  @override
  Future<void> insertUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUser(User user) async {
    await _userUpdateAdapter.update(user, OnConflictStrategy.abort);
  }
}

class _$MessageDao extends MessageDao {
  _$MessageDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _messageInsertionAdapter = InsertionAdapter(
            database,
            'Message',
            (Message item) => <String, dynamic>{
                  'content': item.content,
                  'receiverId': item.receiverId,
                  'senderId': item.senderId,
                  'chatId': item.chatId,
                  'timestamp': item.timestamp,
                  'type': item.type
                },
            changeListener),
        _messageDeletionAdapter = DeletionAdapter(
            database,
            'Message',
            ['timestamp'],
            (Message item) => <String, dynamic>{
                  'content': item.content,
                  'receiverId': item.receiverId,
                  'senderId': item.senderId,
                  'chatId': item.chatId,
                  'timestamp': item.timestamp,
                  'type': item.type
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Message> _messageInsertionAdapter;

  final DeletionAdapter<Message> _messageDeletionAdapter;

  @override
  Future<List<Message>> getChatMessages(String chatId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Message WHERE chatId = ? ORDER BY timestamp DESC',
        arguments: <dynamic>[chatId],
        mapper: (Map<String, dynamic> row) => Message(
            type: row['type'] as String,
            content: row['content'] as String,
            receiverId: row['receiverId'] as String,
            senderId: row['senderId'] as String,
            timestamp: row['timestamp'] as int));
  }

  @override
  Stream<List<Message>> getChatMessagesAsStream(String chatId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM Message WHERE chatId = ? ORDER BY timestamp DESC',
        arguments: <dynamic>[chatId],
        queryableName: 'Message',
        isView: false,
        mapper: (Map<String, dynamic> row) => Message(
            type: row['type'] as String,
            content: row['content'] as String,
            receiverId: row['receiverId'] as String,
            senderId: row['senderId'] as String,
            timestamp: row['timestamp'] as int));
  }

  @override
  Future<List<Message>> getAllMessages() async {
    return _queryAdapter.queryList('SELECT * FROM Message',
        mapper: (Map<String, dynamic> row) => Message(
            type: row['type'] as String,
            content: row['content'] as String,
            receiverId: row['receiverId'] as String,
            senderId: row['senderId'] as String,
            timestamp: row['timestamp'] as int));
  }

  @override
  Stream<List<Message>> getAllMessagesAsStream() {
    return _queryAdapter.queryListStream('SELECT * FROM Message',
        queryableName: 'Message',
        isView: false,
        mapper: (Map<String, dynamic> row) => Message(
            type: row['type'] as String,
            content: row['content'] as String,
            receiverId: row['receiverId'] as String,
            senderId: row['senderId'] as String,
            timestamp: row['timestamp'] as int));
  }

  @override
  Future<void> insertMessage(Message message) async {
    await _messageInsertionAdapter.insert(message, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertMessages(List<Message> messages) async {
    await _messageInsertionAdapter.insertList(
        messages, OnConflictStrategy.abort);
  }

  @override
  Future<void> clear(List<Message> messages) async {
    await _messageDeletionAdapter.deleteList(messages);
  }
}
