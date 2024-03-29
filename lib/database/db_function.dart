import 'dart:developer' as developer;
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:wishlistku/database/kategoriDB.dart';
import 'package:wishlistku/database/wishlistDB.dart';
import 'package:wishlistku/database/UserDB.dart';

class DBFunction {
  final Database _database;
  final String _tblName;
  final List<String> tables = [
    Kategori.tblName,
    Wishlist.tblName,
    User.tblName,
  ];

  DBFunction(this._database, this._tblName);

  Future<int> insertData(Map<String, String> data) async {
    return await _database.insert(_tblName, data);
  }

  Future<int> deleteData(dynamic id) async {
    return await _database.delete(_tblName, where: "id = ?", whereArgs: [id]);
  }

  Future<dynamic> getData({String? where, List<dynamic>? whereArg}) async {
    return await _database.query(_tblName,
        where: where, whereArgs: whereArg ?? []);
  }

  Future<int> updateData(dynamic id, Map<String, String> data) async {
    return await _database
        .update(_tblName, data, where: "id = ?", whereArgs: [id]);
  }

  static Future<Database> getDatabase() async {
    return await openDatabase(join(await getDatabasesPath(), "db_wishlist"),
        onCreate: (db, version) async {
      String userTable = User.tblName;
      String wishListTable = Wishlist.tblName;
      String kategoriTable = Kategori.tblName;
      try {
        await db.execute("""
            CREATE TABLE $userTable(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL,
                password TEXT NOT NULL
                );
            """);

        await db.execute("""
          CREATE TABLE $kategoriTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL, 
              description TEXT NOT NULL, 
              iconType CHAR(1) NOT NULL DEFAULT '0', 
              iconVal TEXT NOT NULL)
          """);

        await db.execute("""
          CREATE TABLE $wishListTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              user_id INTEGER NOT NULL ,
              id_kategori INTEGER NOT NULL, 
              title TEXT NOT NULL, 
              description TEXT NOT NULL, 
              price TEXT NOT NULL, 
              time TEXT NOT NULL,
              lat TEXT NOT NULL,
              lng TEXT NOT NULL,
              location TEXT NOT NULL, 
              status CHAR(1) NOT NULL DEFAULT '0', 
              FOREIGN KEY(id_kategori) REFERENCES tbl_kategori(id) ON DELETE CASCADE ON UPDATE CASCADE
              )
        """);

        await db.insert(kategoriTable, {
          "title": "Makanan",
          "description": "Makanan yang diinginkan",
          "iconType": "1",
          "iconVal": "md-pizza"
        });

        await db.insert(kategoriTable, {
          "title": "Kendaraan",
          "description": "Kendaraan yang diinginkan",
          "iconType": "3",
          "iconVal": "car"
        });

        await db.insert(kategoriTable, {
          "title": "Rumah",
          "description": "Tempat tinggal idaman",
          "iconType": "3",
          "iconVal": "home"
        });

        await db.insert(kategoriTable, {
          "title": "Traveling",
          "description": "Jalan-Jalan kesuatu tempat",
          "iconType": "3",
          "iconVal": "subway"
        });

        await db.insert(userTable, {"username": "admin", "password": "admin"});
      } catch (e) {
        // append error log to file
        developer.log(
          'log me',
          name: 'my.app.category',
          error: jsonEncode(e),
        );
      }
    }, version: 1);
  }

  Future<String> generateBackup() async {
    var dbs = _database;
    String userTable = User.tblName;
    String wishListTable = Wishlist.tblName;
    String kategoriTable = Kategori.tblName;
    String data = """
            CREATE TABLE $userTable(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL,
                password TEXT NOT NULL
                );

          CREATE TABLE $kategoriTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL, 
              description TEXT NOT NULL, 
              iconType CHAR(1) NOT NULL DEFAULT '0', 
              iconVal TEXT NOT NULL);

          CREATE TABLE $wishListTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              user_id INTEGER NOT NULL ,
              id_kategori INTEGER NOT NULL, 
              title TEXT NOT NULL, 
              description TEXT NOT NULL, 
              price TEXT NOT NULL, 
              time TEXT NOT NULL, 
              lat TEXT NOT NULL,
              lng TEXT NOT NULL,
              location TEXT NOT NULL, 
              status CHAR(1) NOT NULL DEFAULT '0', 
              FOREIGN KEY(id_kategori) REFERENCES tbl_kategori(id) ON DELETE CASCADE ON UPDATE CASCADE);


                """;

    List<Map<String, dynamic>> listMaps = [];

    for (var i = 0; i < tables.length; i++) {
      listMaps = await dbs.query(tables[i]);
      data += "INSERT INTO ${tables[i]} VALUES ";
      for (var j = 0; j < listMaps.length; j++) {
        List values = listMaps[j].values.toList();
        data += "(";
        for (var k = 0; k < values.length; k++) {
          if (values[k] == "") {
            // delete empty value
            values.removeAt(k);
          } else if (values[k] is String) {
            values[k] = "'${values[k]}'";
          }
        }
        data += values.join(",");
        data += ")";
        if (j < listMaps.length - 1) {
          data += ",";
        }
      }
      data += ";\r\n";
    }

    return data;
  }
}
