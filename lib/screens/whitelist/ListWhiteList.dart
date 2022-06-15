// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:wishlistku/screens/kategori/kategoriScreen.dart';
import 'package:wishlistku/values/bahasa.dart';

import 'package:wishlistku/screens/whitelist/update_whitelist.dart';
import 'package:wishlistku/screens/whitelist/add_whitelist.dart';
import 'package:wishlistku/component/WhitelistItem.dart';
import 'package:wishlistku/database/kategoriDB.dart';
import 'package:wishlistku/database/whitelistDB.dart';
import 'package:wishlistku/function.dart';

class ListWhiteList extends StatefulWidget {
  const ListWhiteList({Key? key}) : super(key: key);

  @override
  _ListWhiteListState createState() => _ListWhiteListState();
}

class _ListWhiteListState extends State<ListWhiteList> {
  List<WhitelistAttrb> _listWhitelist = [];
  late Whitelist dbWhitelist;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    getWhitelist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(Bahasa.wishlistku),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  child: Text(Bahasa.kategori),
                  value: 1,
                )
              ];
            },
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => KategoriScreen()));
              }
            },
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: customFlatActionButton(context),
      body: RefreshIndicator(
        onRefresh: () => getWhitelist(),
        child: _listWhitelist.isEmpty
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
                        Bahasa.pesanWhitelistKosong,
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
                    direction: _listWhitelist[index].status == 0
                        ? DismissDirection.horizontal
                        : DismissDirection.endToStart,
                    child: WhitelistItem(
                      onTap: () => itemClick(_listWhitelist[index], index),
                      whitelistAttrb: _listWhitelist[index],
                      key: UniqueKey(),
                    ),
                    secondaryBackground: MyFunction.bgHapus(),
                    background: MyFunction.bgTargetSelesai(),
                    key: UniqueKey(),
                  );
                },
                itemCount: _listWhitelist.length,
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
    await dbWhitelist.deleteData(_listWhitelist[index].id);
    _listWhitelist.removeAt(index);
    setState(() {});
  }

  void itemClick(WhitelistAttrb whitelistAttrb, index) async {
    Kategori kategori = await Kategori.initDatabase();
    KategoriAttrb? kategoriAttrb =
        await kategori.getById(whitelistAttrb.idKategori);

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
                        color: whitelistAttrb.status == 0
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle),
                    child: Icon(
                      iconData,
                      size: 80.0,
                      color: whitelistAttrb.status == 0
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    )),
                SizedBox(
                  height: 5.0,
                ),
                Text(whitelistAttrb.title,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    )),
                Text(
                    DateFormat(DateFormat.YEAR_MONTH_DAY)
                        .format(whitelistAttrb.time),
                    style: TextStyle(
                        fontSize: 12.0, fontWeight: FontWeight.normal)),
                Divider(),
                Text(whitelistAttrb.description,
                    style: TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.normal)),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                    "Rp" +
                        NumberFormat("#,###")
                            .format(int.tryParse(whitelistAttrb.price) ?? 0)
                            .replaceAll(",", "."),
                    style: TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 25.0))
              ],
            ),
            actions: <Widget>[
              whitelistAttrb.status == 0
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
              whitelistAttrb.status == 0
                  ? CupertinoButton(
                      child: Text(
                        Bahasa.ubah,
                        style: TextStyle(color: Colors.blue),
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                      onPressed: () async {
                        await updateItem(context, _listWhitelist[index]);
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
                  await dbWhitelist
                      .updateData(_listWhitelist[index].id, {"status": "1"});
                  Navigator.pop(context, true);
                  setState(() {});
                  getWhitelist();
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
    WhitelistAttrb newItem =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddWhiteListScreen();
    }));
    _listWhitelist.add(newItem);
    getWhitelist();
  }

  Future<dynamic> updateItem(BuildContext context, WhitelistAttrb item) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return UpdateWhiteListScreen(item: item);
    }));

    Navigator.pop(context);
    getWhitelist();
  }

  Future<void> getWhitelist() async {
    ready = false;
    setState(() {
      _listWhitelist.clear();
    });
    dbWhitelist = await Whitelist.initDatabase();
    _listWhitelist = await dbWhitelist.getData();
    ready = true;
    if (mounted) setState(() {});
  }
}
