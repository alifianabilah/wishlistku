// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishlistku/values/bahasa.dart';

class MyFunction {
  static void focusSwitcher(
      BuildContext context, FocusNode curFocus, FocusNode nextFocust) {
    curFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocust);
  }

  static Widget bgHapus() {
    return Container(
      alignment: Alignment.centerRight,
      color: Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            Bahasa.hapus,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            width: 10.0,
          ),
          Icon(
            Icons.delete_sweep,
            color: Colors.white,
          ),
          SizedBox(
            width: 10.0,
          ),
        ],
      ),
    );
  }

  static Widget bgTargetSelesai() {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.green,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 10.0,
          ),
          Icon(
            Icons.done,
            color: Colors.white,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            Bahasa.targetTercapaiTitle,
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  static Future showDialog(context,
      {required String title,
      required String msg,
      required List<Widget> actions}) {
    return showCupertinoDialog(
        builder: (context) {
          return CupertinoAlertDialog(
            actions: actions,
            title: Text(title),
            content: Text(msg),
          );
        },
        context: context);
  }
}
