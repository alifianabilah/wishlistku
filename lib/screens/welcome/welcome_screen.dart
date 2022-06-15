// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wishlistku/database/UserDB.dart';
import 'package:wishlistku/screens/auth/login_screen.dart';
import 'package:wishlistku/screens/auth/register_screen.dart';
import 'package:wishlistku/screens/whitelist/ListWhiteList.dart';
import 'package:wishlistku/values/bahasa.dart';
import 'package:wishlistku/model/authentication_manager.dart';
import 'package:wishlistku/screens/auth/login_view_model.dart';
import 'package:http/http.dart' as http;

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
);

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';
  late User dbUser;
  LoginViewModel _viewModel = Get.put(LoginViewModel());

  @override
  void initState() {
    super.initState();
    initDb();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> initDb() async {
    dbUser = await User.initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    Size dim = MediaQuery.of(context).size;
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            // add padding to the container
            padding: EdgeInsets.only(
              top: 0,
              left: 0,
              right: 0,
              bottom: dim.height * 0.1,
            ),
            // add column to the container
            child: Column(
              // add mainAxisAlignment to the column
              mainAxisAlignment: MainAxisAlignment.center,
              // add crossAxisAlignment to the column
              crossAxisAlignment: CrossAxisAlignment.center,
              // add children to the column
              children: <Widget>[
                // Container(
                //   width: dim.width,
                //   height: dim.height * 0.2,
                //   color: Color(0xff0099ff),
                // ),
                // SvgPicture.asset(
                //   'assets/images/wave.svg',
                //   alignment: Alignment.topCenter,
                //   height: dim.height * 0.2,
                //   width: dim.width,
                // ),
                SizedBox(
                  // add height to the SizedBox
                  height: dim.height * 0.1,
                ),
                Image.asset(
                  'assets/images/welcome.webp',
                  // height: dim.height * 0.15,
                ),
                SizedBox(
                  // add height to the SizedBox
                  height: dim.height * 0.02,
                ),
                // add text to the column
                Text(
                  Bahasa.welcomeText,
                  // add style to the text
                  style: TextStyle(
                    // add fontSize to the text
                    fontSize: dim.height * 0.045,
                    // add fontWeight to the text
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  // add height to the SizedBox
                  height: dim.height * 0.05,
                ),
                // add row to the column
                Row(
                  // add mainAxisAlignment to the row
                  mainAxisAlignment: MainAxisAlignment.center,
                  // add crossAxisAlignment to the row
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // add children to the row
                  children: <Widget>[
                    // add space between the text and the button
                    SizedBox(
                      height: dim.height * 0.05,
                    ),
                    // add button to the column
                    RawMaterialButton(
                      onPressed: () => {
                        // add navigation to the button
                        _navigateScreen(context, const LoginScreen()),
                      },
                      fillColor: Theme.of(context).primaryColor,
                      splashColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(dim.height * 0.01),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: dim.height * 0.01,
                          horizontal: dim.width * 0.05,
                        ),
                        child: Text(
                          Bahasa.login,
                          style: TextStyle(
                            fontSize: dim.height * 0.02,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // add space between the button and the text
                    SizedBox(
                      width: dim.width * 0.03,
                    ),
                    // add button to the column
                    RawMaterialButton(
                      onPressed: () => {
                        // add navigation to the button
                        _loginGoole(context),
                      },
                      fillColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(dim.height * 0.01),
                      ),
                      splashColor: Colors.blue[900],
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: dim.height * 0.01,
                          horizontal: dim.width * 0.05,
                        ),
                        child: Text(
                          Bahasa.loginGoogle,
                          style: TextStyle(
                            fontSize: dim.height * 0.02,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // add space between the button and the text
                    SizedBox(
                      width: dim.width * 0.03,
                    ),
                    // add button to the column
                    RawMaterialButton(
                      onPressed: () => {
                        // add navigation to the button
                        _navigateScreen(context, const RegisterScreen()),
                      },
                      fillColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(dim.height * 0.01),
                      ),
                      splashColor: Colors.blue[900],
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: dim.height * 0.01,
                          horizontal: dim.width * 0.05,
                        ),
                        child: Text(
                          Bahasa.register,
                          style: TextStyle(
                            fontSize: dim.height * 0.02,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loginGoole(BuildContext context) async {
    // login google with google_sign_in
    try {
      await _googleSignIn.signIn();
      _loginLocal(_currentUser?.email, _currentUser?.id);
      print(_currentUser);
    } catch (error) {
      print(error);
    }
  }

  // object to json
  String objectToJson(Map<String, dynamic> object) => json.encode(object);

  void _navigateScreen(BuildContext context, Widget screen) {
    Route route = MaterialPageRoute(builder: (context) => screen);
    Navigator.pushReplacement(context, route);
  }

  void _navigateReplace(BuildContext context, Widget widget) {
    Route route = MaterialPageRoute(builder: (context) => widget);
    Navigator.pushReplacement(context, route);
  }

  void _loginLocal(_username, _password) async {
    UserAttrb? user = await dbUser.login(_username, _password);

    if (user != null) {
      _viewModel.loginUser(user);
      _navigateReplace(context, const ListWhiteList());
    } else {
      user = await dbUser.register(username: _username, password: _password);
      if (user != null) {
        _viewModel.loginUser(user);
        _navigateReplace(context, const ListWhiteList());
      }
    }
  }
}
