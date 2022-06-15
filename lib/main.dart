// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, avoid_print
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wishlistku/screens/welcome/splash_screen.dart';

void main() async {
  await GetStorage.init();

  return runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff3f3d56),
        accentColor: Color(0xffffc107),
        textTheme: TextTheme(
          button: TextStyle(
            color: Color(0xff3f3d56),
          ),
        ),
        buttonColor: Color(0xffffc107),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xffffc107),
        ),
      ),
      home: SplashScreen(),
    ),
  );
}
