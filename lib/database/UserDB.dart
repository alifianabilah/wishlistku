// ignore_for_file: file_names, unused_import

import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wishlistku/database/db_function.dart';

class User {
  final Database _database;
  static const String tblName = "tbl_user_login";

  late DBFunction _dbFunction;

  User(this._database) {
    _dbFunction = DBFunction(_database, User.tblName);
  }

  static Future<User> initDatabase() async {
    return User(await DBFunction.getDatabase());
  }

  Future<UserAttrb?> login(dynamic username, dynamic password) async {
    var data = await _dbFunction.getData(
        where: "username = ? and password = ?", whereArg: [username, password]);
    if (data.length == 0) {
      return null;
    }
    return UserAttrb(data.first);
  }

  Future<UserAttrb?> register(
      {required dynamic username, required dynamic password}) async {
    Map<String, String> data = {
      "username": username,
      "password": password,
    };
    int id = await _dbFunction.insertData(data);
    data["id"] = id.toString();
    return UserAttrb(data);
  }

  Future<UserAttrb?> getById(dynamic id) async {
    var item = await _dbFunction.getData(where: "id = ?", whereArg: [id]);
    if (item.length == 0) {
      return null;
    }
    return UserAttrb(item.first);
  }

  Future<List<UserAttrb>> getData() async {
    List<dynamic> temp = await _dbFunction.getData();
    List<UserAttrb> output = [];
    for (Map<String, dynamic> item in temp) {
      output.add(UserAttrb(item));
    }
    return output;
  }
}

class UserAttrb {
  final Map<String, dynamic> _data;

  UserAttrb(this._data);

  dynamic get id => _data["id"];
  dynamic get username => _data["username"];
  dynamic get password => _data["password"];

  Map toMap() {
    return {
      "username": username,
      "password": password,
    };
  }

  @override
  String toString() {
    return toMap.toString();
  }
}
