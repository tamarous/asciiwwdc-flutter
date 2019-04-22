import 'package:sqflite/sqflite.dart';
import 'DataManager.dart';

final String tableSession = 'session';
final String columnId = 'sessionId';
final String columnTitle = 'sessionTitle';
final String columnUrlString = 'sessionUrlString';
final String columnFavorite = 'sessionIsFavorite';
final String columnTrackId = 'trackId';
final String columnConferenceName = 'conferenceName';

class Session {
  int sessionId;
  String sessionTitle;
  String sessionUrlString;
  String sessionConferenceName;
  bool _isFavorite = false;
  int trackId;

  Session();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: sessionTitle,
      columnUrlString: sessionUrlString,
      columnFavorite: _isFavorite == true ? 1 : 0,
      columnConferenceName: sessionConferenceName,
    };
    if (sessionId != null) {
      map[columnId] = sessionId;
    }
    if (trackId != null) {
      map[columnTrackId] = trackId;
    }
    return map;
  }

  Session.fromMap(Map<String, dynamic> map) {
    sessionId = map[columnId];
    sessionTitle = map[columnTitle];
    sessionUrlString = map[columnUrlString];
    _isFavorite = map[columnFavorite] == 1;
    trackId = map[columnTrackId];
    sessionConferenceName = map[columnConferenceName];
  }

  set favorite(bool favorite) {
    _isFavorite = favorite;

    if (sessionId == null) {
      SessionProvider.instance.insert(this);
    } else {
      SessionProvider.instance.update(this);
    }
  }

  void toggleFavorite() async {
    _isFavorite = !_isFavorite;

    if (sessionId == null) {
      await SessionProvider.instance.insert(this);
    } else {
      await SessionProvider.instance.update(this);
    }

    await SessionProvider.instance.close();
  }

  bool get isFavorite {
    return _isFavorite;
  }
}

class SessionProvider {
  factory SessionProvider() => _getInstance();

  static SessionProvider _instance;

  static SessionProvider get instance => _getInstance();

  SessionProvider._internal();

  static SessionProvider _getInstance() {
    if (_instance == null) {
      _instance = new SessionProvider._internal();
    }
    return _instance;
  }

  Database db;
  Future open() async {
    String path = await DataManager.instance.databaseForSessionsFullPath;

    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        create table $tableSession (
          $columnId integer primary key autoincrement,
          $columnTitle text not null,
          $columnUrlString text not null,
          $columnFavorite integer not null,
          $columnTrackId integer not null,
          $columnConferenceName text not null
        )
      ''');
    });
  }

  Future<Session> insert(Session session) async {
    if (db == null || !db.isOpen) {
      await open();
    }

    session.sessionId = await db.insert(tableSession, session.toMap());

    return session;
  }

  Future<Session> getSession(int sessionId) async {
    if (db == null || !db.isOpen) {
      await open();
    }

    List<Map> maps = await db.query(tableSession,
        columns: [
          columnId,
          columnTitle,
          columnUrlString,
          columnFavorite,
          columnConferenceName
        ],
        where: '$columnId = ?',
        whereArgs: [sessionId]);

    if (maps.length > 0) {
      return Session.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Session>> getSessions(String queryString) async {
    if (db == null || !db.isOpen) {
      await open();
    }

    List<Map> sessionMaps = await db.query(tableSession,
        columns: [
          columnId,
          columnTitle,
          columnUrlString,
          columnFavorite,
          columnConferenceName
        ],
        where: queryString);

    if (sessionMaps.length > 0) {
      return sessionMaps
          .map((sessionMap) => Session.fromMap(sessionMap))
          .toList();
    }

    return null;
  }

  Future<int> delete(int sessionId) async {
    if (!db.isOpen) {
      await open();
    }

    int result = await db
        .delete(tableSession, where: '$columnId = ?', whereArgs: [sessionId]);

    return result;
  }

  Future<int> update(Session session) async {
    if (db == null || !db.isOpen) {
      await open();
    }

    int result = await db.update(tableSession, session.toMap(),
        where: '$columnId = ?', whereArgs: [session.sessionId]);

    return result;
  }

  Future close() async {
    if (db != null && db.isOpen) {
      await db.close();
    }
  }
}
