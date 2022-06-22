import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:wishlistku/database/UserDB.dart';
import 'package:wishlistku/model/authentication_manager.dart';

class LoginViewModel extends GetxController {
  late final AuthenticationManager _authManager;

  @override
  void onInit() {
    super.onInit();
    _authManager = Get.find();
  }

  void loginUser(UserAttrb user) {
    _authManager.login(user);
  }

  Map<String, dynamic> getData() {
    return _authManager.getToken();
  }

  void logOut() {
    _authManager.logOut();
  }
}
