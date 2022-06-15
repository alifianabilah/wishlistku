// ignore_for_file: unnecessary_new, avoid_unnecessary_containers, unused_import, unused_field

import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wishlistku/database/UserDB.dart';
import 'package:wishlistku/database/whitelistDB.dart';
import 'package:wishlistku/model/authentication_manager.dart';
import 'package:wishlistku/screens/auth/login_view_model.dart';
import 'package:wishlistku/screens/auth/register_screen.dart';
import 'package:wishlistku/screens/whitelist/ListWhiteList.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  LoginViewModel _viewModel = Get.put(LoginViewModel());

  late User dbUser;
  late String _username, _password;

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> initDb() async {
    dbUser = await User.initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    Size dim = MediaQuery.of(context).size;

    var loginBtn = new RawMaterialButton(
      // fill color with button theme
      fillColor: Theme.of(context).buttonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dim.height * 0.01),
      ),
      splashColor: Colors.blue[900],
      onPressed: () async {
        await _login();
      },
      child: const Text("Login", style: TextStyle(color: Colors.white)),
    );
    var registerBtn = new RawMaterialButton(
      padding: const EdgeInsets.all(10.0),
      fillColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dim.height * 0.01),
      ),
      splashColor: Colors.blue[900],
      onPressed: () {
        _navigateReplace(context, const RegisterScreen());
      },
      child: const Text("Register", style: TextStyle(color: Colors.white)),
    );
    var loginForm = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Text(
          "Wishlistku Login",
          textScaleFactor: 2.0,
        ),
        new Form(
          key: _formKey,
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.all(dim.height * 0.02),
                child: new TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    _username = value;
                    return null;
                  },
                  decoration: const InputDecoration(labelText: "Username"),
                ),
              ),
              new Padding(
                padding: EdgeInsets.all(dim.height * 0.02),
                child: new TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    _password = value;
                    return null;
                  },
                  decoration: const InputDecoration(labelText: "Password"),
                ),
              )
            ],
          ),
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            loginBtn,
            new Padding(
              padding: EdgeInsets.all(dim.height * 0.01),
              child: registerBtn,
            ),
          ],
        ),
      ],
    );

    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Login Page"),
      ),
      key: scaffoldKey,
      body: new SingleChildScrollView(
        child: new Container(
          padding: EdgeInsets.all(dim.height * 0.02),
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Image.asset("assets/images/login.png",
                    height: dim.height * 0.3),
                SizedBox(height: dim.height * 0.02),
                loginForm,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateReplace(BuildContext context, Widget widget) {
    Route route = MaterialPageRoute(builder: (context) => widget);
    Navigator.pushReplacement(context, route);
  }

  Future<void> _login() async {
    _formKey.currentState?.validate();
    UserAttrb? user = await dbUser.login(_username, _password);

    if (user != null) {
      _viewModel.loginUser(user);
      _navigateReplace(context, const ListWhiteList());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validasi Gagal'),
        ),
      );
    }
  }
}
