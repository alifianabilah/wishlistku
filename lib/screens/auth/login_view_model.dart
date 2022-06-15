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

  Future<void> loginUser(UserAttrb user) async {
    _authManager.login(user.id);
  }
}
