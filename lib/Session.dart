
import 'package:sqflite/sqflite.dart';

final String tableSession = 'session';
final String columnId = 'sessionId';
final String columnTitle = 'sessionTitle';
final String columnUrlString = 'sessionUrlString';

class Session {
  int sessionId;
  String sessionTitle;
  String sessionUrlString;
  bool isFavorite = false;

  Session() {}

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      columnTitle:sessionTitle,
      columnUrlString:sessionUrlString,
    };
    if (sessionId != null) {
      map[columnId] = sessionId;
    }
    return map;
  }

  Session.fromMap(Map<String, dynamic> map) {
    sessionId = map[columnId];
    sessionTitle = map[columnTitle];
    sessionUrlString = map[columnUrlString];
  }
}

class SessionProvider {
  Database db;
  Future open(String path) async {
    db = await openDatabase(path,version: 1,onCreate: (Database db, int version) async {
      await db.execute('''
        create table $tableSession {
          $columnId integer primary key autoincrement,
          $columnTitle text not null,
          $columnUrlString text not null,
        }
      ''');
    });
  }

  Future<Session> insert(Session session) async {
    session.sessionId = await db.insert(tableSession, session.toMap()); 
    return session;
  }

  Future<Session> getSession(int sessionId) async {
    List<Map> maps = await db.query(
      tableSession,
      columns: [columnId, columnTitle,columnUrlString],
      where: '$columnId = ?',
      whereArgs: [sessionId]
    );
    if (maps.length > 0) {
      return Session.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int sessionId) async {
    return await db.delete(tableSession,where: '$columnId = ?',whereArgs: [sessionId]);
  }

  Future<int> update(Session session) async{
    return await db.update(tableSession, session.toMap(),where: '$columnId = ?',whereArgs: [session.sessionId]);
  }
}