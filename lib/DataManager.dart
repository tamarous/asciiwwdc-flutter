import 'package:sqflite/sqflite.dart';
import 'dart:io';

import 'package:path/path.dart';
class DataManager {

    String _databaseName;
    String databaseFullPath;

    DataManager(this._databaseName);

    Future<String> get getDatabaseFullPath async{

      if (databaseFullPath != null) {
        return databaseFullPath;
      }

      if (_databaseName == null) {
        _databaseName = 'tracks.db';
      }

      var databasePath = await getDatabasesPath();
      databaseFullPath = join(databasePath, _databaseName);

      if (await Directory(dirname(databaseFullPath)).exists()) {

      } else {
        try {
          await Directory(dirname(databaseFullPath)).create();
        } catch (e) {
          databaseFullPath = null;
          print(e);
        }
      }

      return databaseFullPath;
      
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