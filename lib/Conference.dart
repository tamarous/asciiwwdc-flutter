import 'Track.dart';
import 'package:sqflite/sqflite.dart';

final String tableConference = 'conference';
final String columnId = 'conferenceId';
final String columnName = 'conferenceName';
final String columnShortDescription = 'conferenceShortDescription';
final String columnLogoUrl = 'conferenceLogoUrl';
final String columnTime = 'conferenceTime';


class Conference {
  int conferenceId;
  String conferenceName;
  String conferenceLogoUrl;
  String conferenceShortDescription;
  String conferenceTime;
  List<Track> tracks;

  Conference() {}

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      columnName:conferenceName,
      columnLogoUrl:conferenceLogoUrl,
      columnShortDescription:conferenceShortDescription,
      columnTime:conferenceTime
    };
    if (conferenceId != null) {
      map[columnId] = conferenceId;
    }

    return map;
  }

  Conference.fromMap(Map<String, dynamic> map) {
    conferenceId = map[columnId];
    conferenceLogoUrl = map[columnLogoUrl];
    conferenceName = map[columnName];
    conferenceShortDescription = map[columnShortDescription];
  }
}

class ConferenceProvider {
  Database db;
  Future open(String path) async{
    db = await openDatabase(path, version:1, onCreate: (Database db, int version) async {
      await db.execute('''
        create table $tableConference {
          $columnId integer primary key autoincrement,
          $columnName text not null,
          $columnLogoUrl text not null,
          $columnShortDescription text not null,
          $columnTime text not null,
        }
      ''');
    });
    return db;
  }

  Future<Conference> insert(Conference conference) async {
    conference.conferenceId = await db.insert(tableConference, conference.toMap());
    return conference;
  }

  Future<Conference> getConference(int conferenceId) async {
    List<Map> maps = await db.query(
      tableConference,
      columns: [columnId,columnName,columnLogoUrl,columnShortDescription,columnTime],
      where: '$columnId = ?',
      whereArgs: [conferenceId],
    );

    if (maps.length > 0) {
      return Conference.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int conferenceId) async {
    return await db.delete(tableConference, where: '$columnId = ?', whereArgs: [conferenceId]);
  }

  Future<int> update(Conference conference) async {
    return await db.update(tableConference, conference.toMap(), where:'$columnId = ?', whereArgs: [conference.conferenceId]);
  }
}