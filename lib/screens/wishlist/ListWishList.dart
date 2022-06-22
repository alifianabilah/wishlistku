// ignore_for_file: file_names, prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wishlistku/screens/auth/login_view_model.dart';
import 'package:wishlistku/screens/kategori/kategoriScreen.dart';
import 'package:wishlistku/screens/welcome/welcome_screen.dart';
import 'package:wishlistku/values/bahasa.dart';

import 'package:wishlistku/screens/wishlist/update_wishlist.dart';
import 'package:wishlistku/screens/wishlist/add_wishlist.dart';
import 'package:wishlistku/component/WishlistItem.dart';
import 'package:wishlistku/database/kategoriDB.dart';
import 'package:wishlistku/database/wishlistDB.dart';
import 'package:wishlistku/function.dart';

class ListWishList extends StatefulWidget {
  const ListWishList({Key? key}) : super(key: key);

  @override
  _ListWishListState createState() => _ListWishListState();
}

class _ListWishListState extends State<ListWishList> {
  List<WishlistAttrb> _listWishlist = [];
  late Wishlist dbWishlist;
  bool ready = false;
  final LoginViewModel _viewModel = Get.put(LoginViewModel());

  @override
  void initState() {
    super.initState();
    getWishlist();
  }

  @override
  Widget build(BuildContext context) {
    String title = Bahasa.wishlistku;
    dynamic user = _viewModel.getData();
    if (user != null) {
      title = title + ", Selamat datang " + _viewModel.getData()['username'];
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(title),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  child: Text(Bahasa.kategori),
                  value: 1,
                ),
                const PopupMenuItem(
                  child: Text(Bahasa.backupDb),
                  value: 2,
                ),
                const PopupMenuItem(
                  child: Text(Bahasa.logout),
                  value: 3,
                ),
              ];
            },
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => KategoriScreen()));
              } else if (value == 2) {
                backupDb(context);
              } else if (value == 3) {
                _viewModel.logOut();
                _navigateReplace(context, const WelcomeScreen());
              }
            },
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: customFlatActionButton(context),
      body: RefreshIndicator(
        onRefresh: () => getWishlist(),
        child: _listWishlist.isEmpty
            ? !ready
                ? Container()
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    children: <Widget>[
                      Image.asset(
                        "assets/images/dreamer.webp",
                        width: 200.0,
                      ),
                      Text(
                        Bahasa.pesanWishlistKosong,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  )
            : ListView.builder(
                itemBuilder: (context, index) {
                  return Dismissible(
                    onDismissed: (direction) => hapusItem(index),
                    confirmDismiss: (direction) =>
                        dismissAction(direction, index),
                    direction: _listWishlist[index].status == 0
                        ? DismissDirection.horizontal
                        : DismissDirection.endToStart,
                    child: WishlistItem(
                      onTap: () => itemClick(_listWishlist[index], index),
                      wishlistAttrb: _listWishlist[index],
                      key: UniqueKey(),
                    ),
                    secondaryBackground: MyFunction.bgHapus(),
                    background: MyFunction.bgTargetSelesai(),
                    key: UniqueKey(),
                  );
                },
                itemCount: _listWishlist.length,
              ),
      ),
    );
  }

  Widget customFlatActionButton(BuildContext context) {
    return Hero(
      tag: Bahasa.tagPrimaryButton,
      child: SizedBox(
        height: 60.0,
        width: 60.0,
        child: RawMaterialButton(
          shape: const CircleBorder(),
          elevation: 10.0,
          fillColor: Theme.of(context).colorScheme.secondary,
          child: Center(
              child: Icon(
            Icons.add,
            color: Theme.of(context).textTheme.button?.color,
          )),
          onPressed: () async {
            addItem(context);
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> hapusItem(index) async {
    await dbWishlist.deleteData(_listWishlist[index].id);
    _listWishlist.removeAt(index);
    setState(() {});
  }

  void itemClick(WishlistAttrb wishlistAttrb, index) async {
    Kategori kategori = await Kategori.initDatabase();
    KategoriAttrb? kategoriAttrb =
        await kategori.getById(wishlistAttrb.idKategori);

    IconData iconData =
        kategoriAttrb != null ? kategoriAttrb.icon : Icons.warning;
    if (mounted) setState(() {});
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            message: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        color: wishlistAttrb.status == 0
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle),
                    child: Icon(
                      iconData,
                      size: 80.0,
                      color: wishlistAttrb.status == 0
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    )),
                SizedBox(
                  height: 5.0,
                ),
                Text(wishlistAttrb.title,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    )),
                Text(
                    DateFormat(DateFormat.YEAR_MONTH_DAY)
                        .format(wishlistAttrb.time),
                    style: TextStyle(
                        fontSize: 12.0, fontWeight: FontWeight.normal)),
                Divider(),
                Text(wishlistAttrb.description,
                    style: TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.normal)),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                    "Rp" +
                        NumberFormat("#,###")
                            .format(int.tryParse(wishlistAttrb.price) ?? 0)
                            .replaceAll(",", "."),
                    style: TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 25.0))
              ],
            ),
            actions: <Widget>[
              wishlistAttrb.status == 0
                  ? CupertinoButton(
                      child: Text(
                        Bahasa.tercapai,
                        style: TextStyle(color: Colors.green),
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                      onPressed: () async {
                        var selesai = await dialogSelesai(index);
                        if (selesai) {
                          Navigator.pop(context);
                        }
                      },
                    )
                  : Container(),
              wishlistAttrb.status == 0
                  ? CupertinoButton(
                      child: Text(
                        Bahasa.ubah,
                        style: TextStyle(color: Colors.blue),
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                      onPressed: () async {
                        await updateItem(context, _listWishlist[index]);
                        setState(() {});
                      },
                    )
                  : Container(),
              CupertinoButton(
                child: Text(
                  Bahasa.hapus,
                  style: TextStyle(color: Colors.red),
                ),
                borderRadius: BorderRadius.circular(10.0),
                onPressed: () async {
                  var selesai = await dialogHapus();
                  if (selesai) {
                    await hapusItem(index);
                    if (mounted) setState(() {});
                    Navigator.pop(context);
                  }
                },
              ),
              CupertinoButton(
                child: Text(
                  Bahasa.tutup,
                ),
                borderRadius: BorderRadius.circular(10.0),
                onPressed: () async {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Future<bool> dismissAction(var direction, index) async {
    if (direction == DismissDirection.endToStart) {
      return await dialogHapus();
    } else {
      await dialogSelesai(index);
      return false;
    }
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

  Future<bool> dialogSelesai(index) async {
    return await showCupertinoDialog(
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(Bahasa.targetTercapaiTitle),
            content: Text(Bahasa.targetTercapaiDetail),
            actions: <Widget>[
              CupertinoButton(
                child: Text(
                  Bahasa.lanjutkan,
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () async {
                  await dbWishlist
                      .updateData(_listWishlist[index].id, {"status": "1"});
                  Navigator.pop(context, true);
                  setState(() {});
                  getWishlist();
                },
              ),
              CupertinoButton(
                child: Text(Bahasa.batalkan),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              )
            ],
          );
        },
        context: context);
  }

  Future<dynamic> addItem(BuildContext context) async {
    WishlistAttrb newItem =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddWishListScreen();
    }));
    _listWishlist.add(newItem);
    getWishlist();
  }

  Future<dynamic> updateItem(BuildContext context, WishlistAttrb item) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return UpdateWishListScreen(item: item);
    }));

    Navigator.pop(context);
    getWishlist();
  }

  Future<void> getWishlist() async {
    ready = false;
    setState(() {
      _listWishlist.clear();
    });
    dbWishlist = await Wishlist.initDatabase();

    dynamic user = _viewModel.getData();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Anda belum login"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    _listWishlist = await dbWishlist.getByUserID(user['id'].toString());
    ready = true;
    if (mounted) setState(() {});
  }

  _write(BuildContext context, String text) async {
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) {
      // widget pop up dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengekspor data")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              "Berhasil mengekspor data, file di ${directory.path}/wishlist_database.sqlite")),
    );

    final File file = File('${directory.path}/wishlist_database.sqlite');
    await file.writeAsString(text);
  }

  Future<void> backupDb(BuildContext context) async {
    dbWishlist = await Wishlist.initDatabase();
    String backup = await dbWishlist.generateBackup();
    await _write(context, backup);
  }

  void _navigateReplace(BuildContext context, Widget widget) {
    Route route = MaterialPageRoute(builder: (context) => widget);
    Navigator.pushReplacement(context, route);
  }
}
