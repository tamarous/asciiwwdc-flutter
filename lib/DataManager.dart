import 'package:sqflite/sqflite.dart';
import 'dart:io';

import 'package:path/path.dart';
class DataManager {


    factory DataManager() => _getInstance();
    static DataManager _instance;

    static DataManager get instance => _getInstance();

    DataManager._internal() {
      this._databaseName = 'sessions.db';
    }

    static DataManager _getInstance() {
      if (_instance == null) {
        _instance = new DataManager._internal();
      }

      return _instance;
    }

    String _databaseName;
    String _databaseFullPath;

    Future<String> get databaseFullPath async {

      if (_databaseFullPath != null) {
        return _databaseFullPath;
      }

      if (_databaseName == null) {
        _databaseName = 'sessions.db';
      }

      var databasePath = await getDatabasesPath();
      _databaseFullPath = join(databasePath, _databaseName);

      if (await Directory(dirname(_databaseFullPath)).exists()) {

      } else {
        try {
          await Directory(dirname(_databaseFullPath)).create();
        } catch (e) {
          _databaseFullPath = null;
          print(e);
        }
      }

      return _databaseFullPath;
      
    }

  // final String _databaseName;
  // final String _databasePath;
  // var _databaseExists = false;

  // DataManager(this._databaseName);

  // void _createDataBase() async {
  //   var databasePath = await getDatabasesPath();
  //   _databasePath = join(databasePath,_databaseName);
    
  //   if (await Directory(dirname(_databasePath)).exists()) {
  //   } else {
  //     try{
  //       await Directory(dirname(_databasePath)).create();
  //       _databaseExists = true;
  //     } catch(e) {
  //       print(e);
  //     }
  //   }
  // }

  // void _createTable(String tableName, String statement) async{
  //   if (!_databaseExists) {
  //     _createDataBase();
  //   }

  //   Database database = await openDatabase(_databasePath,version:1,onCreate:(Database db, int version) async {
  //     await db.execute(statement);
  //   });

  // }


}