import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:wishlistku/model/authentication_manager.dart';
import 'package:wishlistku/screens/welcome/welcome_screen.dart';
import 'package:wishlistku/screens/whitelist/ListWhiteList.dart';

class OnBoard extends StatelessWidget {
  const OnBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthenticationManager _authManager = Get.find();

    return Obx(() {
      return _authManager.isLogged.value
          ? const ListWhiteList()
          : const WelcomeScreen();
    });
  }
}
