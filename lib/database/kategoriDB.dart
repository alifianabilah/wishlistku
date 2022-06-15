// ignore_for_file: import_of_legacy_library_into_null_safe, file_names

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wishlistku/database/db_function.dart';

class Kategori {
  final Database _database;
  static const String tblName = "tbl_kategori";

  late DBFunction _dbFunction;

  Kategori(this._database) {
    _dbFunction = DBFunction(_database, Kategori.tblName);
  }

  static Future<Kategori> initDatabase() async {
    return Kategori(await DBFunction.getDatabase());
  }

  Future<KategoriAttrb?> getById(dynamic id) async {
    var item = await _dbFunction.getData(where: "id = ?", whereArg: [id]);
    if (item.length == 0) {
      return null;
    }
    return KategoriAttrb(item.first);
  }

  Future<List<KategoriAttrb>> getData() async {
    List<dynamic> temp = await _dbFunction.getData();
    List<KategoriAttrb> output = [];
    for (Map<String, dynamic> item in temp) {
      output.add(KategoriAttrb(item));
    }
    return output;
  }

  Future<void> insertData(KategoriAttrb data) async {
    await _dbFunction.insertData(data.toMap());
  }

  Future<void> deleteData(dynamic id) async {
    await _dbFunction.deleteData(id);
  }

  Future<KategoriAttrb> insertDataByValue({
    required String title,
    required String description,
    required int iconType,
    required String iconValue,
  }) async {
    Map<String, String> data = {
      "title": title,
      "description": description,
      "iconType": iconType.toString(),
      "iconVal": iconValue,
    };
    int id = await _dbFunction.insertData(data);
    data["id"] = id.toString();
    return KategoriAttrb(data);
  }
}

class KategoriAttrb {
  final Map<String, dynamic> _data;

  KategoriAttrb(this._data);

  int get id => _data["id"];
  String get title => _data["title"];
  String get description => _data["description"];
  String get iconType => _data["iconType"];
  String get iconValue => _data["iconVal"];
  IconData get icon {
    switch (iconType) {
      case "0":
        return MaterialIcons.hasIconData(iconValue)
            ? MaterialIcons.getIconData(iconValue)
            : Icons.warning;
      case "1":
        return Ionicons.hasIconData(iconValue)
            ? Ionicons.getIconData(iconValue)
            : Icons.warning;
      case "2":
        return AntDesign.hasIconData(iconValue)
            ? AntDesign.getIconData(iconValue)
            : Icons.warning;
      case "3":
        return FontAwesome.hasIconData(iconValue)
            ? FontAwesome.getIconData(iconValue)
            : Icons.warning;
      case "4":
        return FontAwesome5.hasIconData(iconValue)
            ? FontAwesome5.getIconData(iconValue)
            : Icons.warning;
      default:
        return MaterialIcons.hasIconData(iconValue)
            ? MaterialIcons.getIconData(iconValue)
            : Icons.warning;
    }
  }

  Map<String, String> toMap() {
    return {
      "title": title,
      "description": description,
      "iconType": iconType,
      "iconVal": iconValue
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
