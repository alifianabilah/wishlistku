// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors, unnecessary_null_comparison

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishlistku/component/KategoriItem.dart';
import 'package:wishlistku/database/kategoriDB.dart';
import 'package:wishlistku/screens/kategori/kategoriIconScreen.dart';
import 'package:wishlistku/values/bahasa.dart';
import 'package:wishlistku/function.dart';

class KategoriScreen extends StatefulWidget {
  @override
  _KategoriScreenState createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  List<KategoriAttrb> _listKategori = [];
  late Kategori dbKategori;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(Bahasa.daftarKategori),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () => getKategoriList(),
        child: _listKategori.isEmpty
            ? ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: <Widget>[
                  Image.asset(
                    "assets/images/insert_kategori.webp",
                    height: 200.0,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    Bahasa.pesanKategoriKosong,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Dismissible(
                      onDismissed: (direction) => hapusItem(index),
                      secondaryBackground: MyFunction.bgHapus(),
                      confirmDismiss: (direction) async {
                        return await dialogHapus();
                      },
                      background: Container(),
                      direction: DismissDirection.endToStart,
                      child: KategoriItem(
                        kategoriAttrb: _listKategori[index],
                      ),
                      key: UniqueKey(),
                    );
                  },
                  itemCount: _listKategori.length,
                )),
      ),
      floatingActionButton: Hero(
        tag: Bahasa.tagPrimaryButton,
        child: SizedBox(
          height: 60.0,
          width: 60.0,
          child: RawMaterialButton(
            shape: CircleBorder(),
            elevation: 10.0,
            fillColor: Theme.of(context).colorScheme.secondary,
            child: Center(
                child: Icon(
              Icons.add,
              color: Theme.of(context).textTheme.button?.color,
            )),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return KategoriIconsScreen();
              }));
              getKategoriList();
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Kategori.initDatabase().then((db) {
      dbKategori = db;
    });
    // delay 1 second
    Future.delayed(Duration(microseconds: 100), () {
      getKategoriList();
    });
  }

  Future<bool> dialogHapus() async {
    return await MyFunction.showDialog(context,
        title: Bahasa.konfirmasiHapusTitle,
        msg: Bahasa.konfirmasiHapusDetail,
        actions: [
          CupertinoButton(
            child: Text(
              Bahasa.hapus,
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          CupertinoButton(
            child: Text(Bahasa.batalkan),
            onPressed: () {
              Navigator.pop(context, false);
            },
          )
        ]);
  }

  Future<void> getKategoriList() async {
    // ignore: prefer_conditional_assignment
    if (dbKategori == null) {
      dbKategori = await Kategori.initDatabase();
    }
    _listKategori = await dbKategori.getData();
    setState(() {});
  }

  Future<void> hapusItem(index) async {
    // ignore: prefer_conditional_assignment
    if (dbKategori == null) {
      dbKategori = await Kategori.initDatabase();
    }
    await dbKategori.deleteData(_listKategori[index].id);
    _listKategori.removeAt(index);
    setState(() {});
  }
}
