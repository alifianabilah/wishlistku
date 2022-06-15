// ignore_for_file: unnecessary_new, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:wishlistku/database/userDB.dart';
import 'package:wishlistku/screens/auth/login_screen.dart';
import 'package:wishlistku/screens/whitelist/ListWhiteList.dart';
import 'package:wishlistku/values/bahasa.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  // ignore: unused_field
  late String _username, _password;
  late User db;

  @override
  Widget build(BuildContext context) {
    Size dim = MediaQuery.of(context).size;

    var registerBtn = new RawMaterialButton(
      fillColor: Theme.of(context).buttonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dim.height * 0.01),
      ),
      splashColor: Colors.blue[900],
      onPressed: () async {
        await _register();
      },
      child: const Text("Register", style: TextStyle(color: Colors.white)),
    );
    var loginBtn = new RawMaterialButton(
      padding: const EdgeInsets.all(10.0),
      fillColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dim.height * 0.01),
      ),
      splashColor: Colors.blue[900],
      onPressed: () {
        _navigateToLoginScreen(context);
      },
      child: const Text("Login", style: TextStyle(color: Colors.white)),
    );
    var loginForm = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Text(
          "Wishlistku Register",
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
                      return Bahasa.fieldKosong;
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
                      return Bahasa.fieldKosong;
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            registerBtn,
            new Padding(
              padding: EdgeInsets.all(dim.height * 0.01),
              child: loginBtn,
            ),
          ],
        ),
      ],
    );

    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Register Page"),
      ),
      key: scaffoldKey,
      body: new SingleChildScrollView(
        child: new Container(
          padding: EdgeInsets.all(dim.height * 0.02),
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Image.asset("assets/images/register.png",
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

  void _navigateToLoginScreen(BuildContext context) {
    Route route = MaterialPageRoute(builder: (context) => const LoginScreen());
    Navigator.pushReplacement(context, route);
  }

  Future<void> _register() async {
    _formKey.currentState?.validate();
    db = await User.initDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_username)),
    );
    var user = await db.register(username: _username, password: _password);
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register Berhasil')),
      );
      Route route =
          MaterialPageRoute(builder: (context) => const LoginScreen());
      Navigator.pushReplacement(context, route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Validasi Gagal')),
      );
    }
  }
}
