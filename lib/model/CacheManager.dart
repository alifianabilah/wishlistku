// ignore_for_file: file_names, constant_identifier_names

import 'package:get_storage/get_storage.dart';
import 'package:wishlistku/database/UserDB.dart';

mixin CacheManager {
  Future<bool> saveToken(UserAttrb? token) async {
    if (token == null) {
      return false;
    }

    final box = GetStorage();
    await box.write(CacheManagerKey.TOKEN.toString(), token.toMap());
    return true;
  }

  Map<String, dynamic> getToken() {
    final box = GetStorage();
    return box.read(CacheManagerKey.TOKEN.toString());
  }

  Future<void> removeToken() async {
    final box = GetStorage();
    await box.remove(CacheManagerKey.TOKEN.toString());
  }
}

enum CacheManagerKey { TOKEN }
