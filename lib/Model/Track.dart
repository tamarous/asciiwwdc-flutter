
import 'package:sqflite/sqflite.dart';

import 'Session.dart';
import 'DataManager.dart';

final String tableTrack = 'track';
final String columnTrackId = 'trackId';
final String columnTrackName = 'trackName';
final String columnConferenceId = 'conferenceId';

class Track {
  int trackId;
  String trackName;
  int conferenceId;
  List<Session> sessions;


  Track() ;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTrackName:trackName,
    };
    if (trackId != null) {
      map[columnTrackId] = trackId;
    }
    if (conferenceId != null) {
      map[columnConferenceId] = conferenceId;
    }

    return map;
  }

  Track.fromMap(Map<String, dynamic> map) {
    trackName = map[columnTrackName];
    trackId = map[columnTrackId];
    conferenceId = map[columnConferenceId];
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

  static TrackProvider get instance => _getInstance();

  Database db;
  Future open() async {

    String path = await DataManager.instance.databaseForTracksFullPath;

    db = await openDatabase(path, version:1, onCreate: (Database db, int version) async {
      await db.execute('''
        create table $tableTrack (
          $columnTrackId integer primary key autoincrement, 
          $columnTrackName text not null,
          $columnConferenceId integer not null
        )
      ''');
    });
  }

  Future<Track> insert(Track track) async{
    if (db == null || !db.isOpen) {
      await open();
    }

    track.trackId = await db.insert(tableTrack, track.toMap());

    for(int i = 0; i < track.sessions.length;i++) {
      track.sessions[i].trackId = track.trackId;
      track.sessions[i] = await SessionProvider.instance.insert(track.sessions[i]);
    }

    await SessionProvider.instance.close();

    return track;
  }

  Future<Track> getTrack(int trackId) async {
    if (db == null || !db.isOpen) {
      await open();
    }

    List<Map> maps = await db.query(
      tableTrack,
      columns: [columnTrackId, columnTrackName, columnConferenceId],
      where: '$columnTrackId = ?',
      whereArgs: [trackId]
    );


    if (maps.length > 0) {
      return Track.fromMap(maps.first);
    }

    return null;
  }

  Future<List<Track>> getTracks(String queryString) async {

    List<Track> tracks;

    if (db == null || !db.isOpen) {
      await open();
    }

    List<Map> trackMaps = await db.query(
      tableTrack,
      columns: [columnTrackId, columnTrackName, columnConferenceId],
      where: queryString
    );

    if (trackMaps.length > 0) {
      tracks = trackMaps.map((trackMap) => Track.fromMap(trackMap)).toList();

      for(int i = 0; i < tracks.length; i++) {

        tracks[i].sessions = await SessionProvider.instance.getSessions('trackId = ${tracks[i].trackId}');
      }

      await SessionProvider.instance.close();

      return tracks;

    }
  
    return null;
  }


  Future<int> delete(int trackId) async {
    if (db == null || !db.isOpen) {
      await open();
    }
    int result = await db.delete(tableTrack,where: '$columnTrackId = ?',whereArgs: [trackId]);

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
    if (db != null && db.isOpen) {
      await db.close();
    }
  }
}