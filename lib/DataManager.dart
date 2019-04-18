import 'package:sqflite/sqflite.dart';
import 'dart:io';

import 'package:path/path.dart';
class DataManager {


    factory DataManager() => _getInstance();
    static DataManager _instance;

    static DataManager get instance => _getInstance();

    DataManager._internal() ;

    static DataManager _getInstance() {
      if (_instance == null) {
        _instance = new DataManager._internal();
      }

      return _instance;
    }

    String _databaseForSessionsFullPath;
    String _databaseForTracksFullPath;
    String _databaseForConferencesFullPath;

    Future<String> get databaseForSessionsFullPath async {

      if (_databaseForSessionsFullPath != null) {
        return _databaseForSessionsFullPath;
      }

      var databasePath = await getDatabasesPath();
      _databaseForSessionsFullPath = join(databasePath, 'sessions.db');

      if (await Directory(dirname(_databaseForSessionsFullPath)).exists()) {
      } else {
        try {
          await Directory(dirname(_databaseForSessionsFullPath)).create();
        } catch (e) {
          _databaseForSessionsFullPath = null;
        }
      }

      return _databaseForSessionsFullPath;
    }

    Future<String> get databaseForTracksFullPath async {

      if (_databaseForTracksFullPath != null) {
        return _databaseForTracksFullPath;
      }

      var databasePath = await getDatabasesPath();
      _databaseForTracksFullPath = join(databasePath, 'tracks.db');

      if (await Directory(dirname(_databaseForTracksFullPath)).exists()) {

      } else {
        try {
          await Directory(dirname(_databaseForTracksFullPath)).create();
        } catch (e) {
          _databaseForTracksFullPath = null;
          print(e);
        }
      }

      return _databaseForTracksFullPath;
    }

    Future<String> get databaseForConferencesFullPath async {

      if (_databaseForConferencesFullPath != null) {
        return _databaseForConferencesFullPath;
      }

      var databasePath = await getDatabasesPath();
      _databaseForConferencesFullPath = join(databasePath, 'conferences.db');

      if (await Directory(dirname(_databaseForConferencesFullPath)).exists()) {

      } else {
        try {
          await Directory(dirname(_databaseForConferencesFullPath)).create();
        } catch (e) {
          _databaseForConferencesFullPath = null;
          print(e);
        }
      }

      return _databaseForConferencesFullPath;
    }

}