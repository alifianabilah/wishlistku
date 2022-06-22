// ignore_for_file: file_names

import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wishlistku/database/db_function.dart';

class Wishlist {
  final Database _database;
  static const String tblName = "tbl_wishlist";

  late DBFunction _dbFunction;

  Wishlist(this._database) {
    _dbFunction = DBFunction(_database, Wishlist.tblName);
  }

  static Future<Wishlist> initDatabase() async {
    return Wishlist(await DBFunction.getDatabase());
  }

  Future<WishlistAttrb> getById(int id) async {
    return WishlistAttrb(
        await _dbFunction.getData(where: "id = ?", whereArg: [id]));
  }

  Future<List<WishlistAttrb>> getByUserID(String id) async {
    print(id);
    List<dynamic> temp =
        await _dbFunction.getData(where: "user_id = ?", whereArg: [id]);
    List<WishlistAttrb> output = [];
    for (Map<String, dynamic> item in temp) {
      output.add(WishlistAttrb(item));
    }
    return output;
  }

  Future<List<WishlistAttrb>> getData() async {
    List<dynamic> temp = await _dbFunction.getData();
    List<WishlistAttrb> output = [];
    for (Map<String, dynamic> item in temp) {
      output.add(WishlistAttrb(item));
    }
    return output;
  }

  Future<void> insertData(Map<String, String> data) async {
    await _dbFunction.insertData(data);
  }

  Future<void> updateData(id, Map<String, String> data) async {
    await _dbFunction.updateData(id, data);
  }

  Future<WishlistAttrb> updateDataByValue(index,
      {required String userId,
      required String title,
      required String description,
      required String price,
      required double lat,
      required double lng,
      required String location,
      required int idKategori,
      required String time}) async {
    Map<String, String> data = {
      "user_id": userId.toString(),
      "id_kategori": idKategori.toString(),
      "title": title,
      "description": description,
      "time": time,
      "price": price,
      "lat": lat.toString(),
      "lng": lng.toString(),
      "location": location,
      "status": "0"
    };
    int id = await _dbFunction.updateData(index, data);
    data["id"] = id.toString();
    return WishlistAttrb(data);
  }

  Future<WishlistAttrb> insertDataByValue(
      {required String userId,
      required String title,
      required String description,
      required String price,
      required double lat,
      required double lng,
      required String location,
      required int idKategori,
      required String time}) async {
    Map<String, String> data = {
      "user_id": userId.toString(),
      "id_kategori": idKategori.toString(),
      "title": title,
      "description": description,
      "time": time,
      "price": price,
      "lat": lat.toString(),
      "lng": lng.toString(),
      "location": location,
      "status": "0"
    };
    print(data);
    int id = await _dbFunction.insertData(data);
    data["id"] = id.toString();
    return WishlistAttrb(data);
  }

  Future<void> deleteData(dynamic id) async {
    await _dbFunction.deleteData(id);
  }

  Future<String> generateBackup() async {
    return await _dbFunction.generateBackup();
  }
}

class WishlistAttrb {
  final Map<String, dynamic> _data;

  WishlistAttrb(this._data);

  dynamic get id => _data["id"];
  dynamic get userId => _data["user_id"];
  dynamic get idKategori => _data["id_kategori"];
  String get title => _data["title"];
  String get description => _data["description"];
  String get price => _data["price"];
  double get lat => double.parse(_data["lat"]);
  double get lng => double.parse(_data["lng"]);
  String get location => _data["location"];
  DateTime get time =>
      DateFormat(DateFormat.YEAR_MONTH_DAY).parse(_data["time"]);
  dynamic get status => int.parse(_data["status"]);

  Map toMap() {
    return {
      "user_id": userId,
      "id_kategori": idKategori,
      "title": title,
      "description": description,
      "price": price,
      "time": time,
      "lat": lat,
      "lng": lng,
      "location": location,
      "status": status
    };
  }

  @override
  String toString() {
    return toMap.toString();
  }
}
