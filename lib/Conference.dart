import 'Track.dart';
import 'package:sqflite/sqflite.dart';
import 'DataManager.dart';


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

  Conference() ;

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

  @override
  String toString() {
    String conferenceString = 'name: $conferenceName, logoUrl: $conferenceLogoUrl, shortDesc: $conferenceShortDescription, time: $conferenceTime';
    return conferenceString;
  }
}

class ConferenceProvider {


  static ConferenceProvider _instance;

  static ConferenceProvider get instance => _getInstance();

  ConferenceProvider._internal();

  static ConferenceProvider _getInstance() {
    if (_instance == null) {
      _instance = ConferenceProvider._internal();
    }
    return _instance;
  }

  Database db;


  Future open() async{

    String path = await DataManager.instance.databaseForConferencesFullPath;

    db = await openDatabase(path, version:1, onCreate: (Database db, int version) async {
      await db.execute('''
        create table $tableConference (
          $columnId integer primary key autoincrement,
          $columnName text not null,
          $columnLogoUrl text not null,
          $columnShortDescription text not null,
          $columnTime text
        )
      ''');
    });
    return db;
  }

  Future<Conference> insert(Conference conference) async {
    if (db == null || !db.isOpen) {
      await open();
    }

    conference.conferenceId = await db.insert(tableConference, conference.toMap());

    for(int i = 0; i < conference.tracks.length;i++) {
      conference.tracks[i].conferenceId = conference.conferenceId;

      await TrackProvider.instance.insert(conference.tracks[i]);
    }

    await TrackProvider.instance.close();

    return conference;
  }

  Future<Conference> getConference(int conferenceId) async {
    if (db == null || !db.isOpen) {
      await open();
    }

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


  Future<List<Conference>> getConferences(String queryString) async {

    List<Conference> conferences;

    if (db == null || !db.isOpen) {
      await open();
    }

    List<Map> conferenceMaps = await db.query(
      tableConference,
      columns: [columnId,columnName,columnLogoUrl,columnShortDescription,columnTime],
      where: queryString,
    );

    if (conferenceMaps.length > 0) {
      conferences = conferenceMaps.map((conferenceMap) => Conference.fromMap(conferenceMap)).toList();
      for(int i = 0; i < conferences.length;i++) {
        conferences[i].tracks = await TrackProvider.instance.getTracks('conferenceId = ${conferences[i].conferenceId}');
      }
      
      await TrackProvider.instance.close();
      return conferences;
    }
    return null;
    
  }

  Future<int> delete(int conferenceId) async {
    if (db == null || !db.isOpen) {
      await open();
    }

    int result = await db.delete(tableConference, where: '$columnId = ?', whereArgs: [conferenceId]);


    return result;
  }

  Future<int> update(Conference conference) async {
    if (!db.isOpen) {
      await open();
    }
    int result = await db.update(tableConference, conference.toMap(), where:'$columnId = ?', whereArgs: [conference.conferenceId]);

    return result;
  }

  Future close() async {
    if (db != null && db.isOpen) {
      await db.close();
    }
  }
}