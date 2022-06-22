// ignore_for_file: unnecessary_null_comparison

import 'package:get/get.dart';
import 'package:wishlistku/database/UserDB.dart';
import 'package:wishlistku/model/CacheManager.dart';

class AuthenticationManager extends GetxController with CacheManager {
  final isLogged = false.obs;

  void logOut() {
    isLogged.value = false;
    removeToken();
  }

  void login(UserAttrb? token) async {
    isLogged.value = true;
    //Token is cached
    await saveToken(token);
  }

  void checkLoginStatus() {
    final token = getToken();
    if (token != null) {
      isLogged.value = true;
    }
  }
}
