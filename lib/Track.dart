import 'Session.dart';
import 'package:sqflite/sqflite.dart';

final String tableTrack = 'track';
final String columnTrackId = 'trackId';
final String columnTrackName = 'trackName';

class Track {
  int trackId;
  String trackName;
  List<Session> sessions;


  Track() {}

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
  Database db;
  Future open(String path) async {
    db = await openDatabase(path, version:1, onCreate: (Database db, int version) async {
      await db.execute('''
        create table $tableTrack {
          $columnTrackId integer primary key autoincrement, 
          $columnTrackName text not null,
        }
      ''');
    });
  }

  Future<Track> insert(Track track) async{
    track.trackId = await db.insert(tableTrack, track.toMap());
    return track;
  }

  Future<Track> getTrack(int trackId) async {
    List<Map> maps = await db.query(
      tableTrack,
      columns: [columnTrackId, columnTrackName],
      where: '$columnTrackId = ?',
      whereArgs: [trackId]
    );
    if (maps.length > 0) {
      return Track.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int trackId) async {
    return await db.delete(tableTrack,where: '$columnTrackId = ?',whereArgs: [trackId]);
  }

  Future<int> update(Track track) async{
    return await db.update(tableTrack, track.toMap(),where: '$columnTrackId = ?',whereArgs: [track.trackId]);
  }
}