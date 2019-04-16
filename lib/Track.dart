import 'Session.dart';
import 'package:sqflite/sqflite.dart';
import 'DataManager.dart';
final String tableTrack = 'track';
final String columnTrackId = 'trackId';
final String columnTrackName = 'trackName';

class Track {
  int trackId;
  String trackName;
  List<Session> sessions;


  Track() ;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTrackName:trackName,
    };
    if (trackId != null) {
      map[columnTrackId] = trackId;
    }
    return map;
  }

  Track.fromMap(Map<String, dynamic> map) {
    trackName = map[columnTrackName];
    trackId = map[columnTrackId];
  }


}

class TrackProvider {

  factory TrackProvider() => _getInstance();
  static TrackProvider _instance;

  TrackProvider._internal() ;

  static TrackProvider _getInstance() {
    if (_instance == null) {
      _instance = new TrackProvider._internal();
    }

    return _instance;
  }

  TrackProvider get instance => _getInstance();

  Database db;
  Future open() async {

    String path = await DataManager.instance.databaseFullPath;

    db = await openDatabase(path, version:1, onCreate: (Database db, int version) async {
      await db.execute('''
        create table $tableTrack (
          $columnTrackId integer primary key autoincrement, 
          $columnTrackName text not null,
        )
      ''');
    });
  }

  Future<Track> insert(Track track) async{
    if (db == null || !db.isOpen) {
      await open();
    }

    track.trackId = await db.insert(tableTrack, track.toMap());

    close();
    return track;
  }

  Future<Track> getTrack(int trackId) async {
    if (db == null || !db.isOpen) {
      await open();
    }

    List<Map> maps = await db.query(
      tableTrack,
      columns: [columnTrackId, columnTrackName],
      where: '$columnTrackId = ?',
      whereArgs: [trackId]
    );
    if (maps.length > 0) {
      return Track.fromMap(maps.first);
    }

    close();
    return null;
  }

  Future<int> delete(int trackId) async {
    if (db == null || !db.isOpen) {
      await open();
    }
    int result = await db.delete(tableTrack,where: '$columnTrackId = ?',whereArgs: [trackId]);

    close();

    return result;
  }

  Future<int> update(Track track) async{
    if (db == null || !db.isOpen) {
      await open();
    }

    int result = await db.update(tableTrack, track.toMap(),where: '$columnTrackId = ?',whereArgs: [track.trackId]);
    return result;
  }

  Future close() async {
    if (db.isOpen) {
      await db.close();
    }
  }
}