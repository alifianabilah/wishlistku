// ignore_for_file: prefer_const_constructors_in_immutables, file_names

import 'package:flutter/material.dart';
import 'package:wishlistku/database/kategoriDB.dart';

class KategoriItem extends StatefulWidget {
  final KategoriAttrb kategoriAttrb;

  KategoriItem({Key? key, required this.kategoriAttrb}) : super(key: key);

  @override
  _KategoriItemState createState() => _KategoriItemState();
}

class _KategoriItemState extends State<KategoriItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.kategoriAttrb.title),
      subtitle: Text(widget.kategoriAttrb.description),
      leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Center(
              child: Icon(
            widget.kategoriAttrb.icon,
            color: const Color.fromARGB(255, 247, 247, 247),
          ))),
      onTap: () {},
    );
  }
}
