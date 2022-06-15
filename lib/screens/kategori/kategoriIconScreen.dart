// ignore_for_file: deprecated_member_use, file_names, use_key_in_widget_constructors, prefer_final_fields, unnecessary_null_comparison, prefer_const_constructors

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wishlistku/screens/kategori/add_kategori.dart';
import 'package:wishlistku/values/bahasa.dart';
import 'package:wishlistku/values/listIcon.dart';

class KategoriIconsScreen extends StatefulWidget {
  @override
  _KategoriIconsScreenState createState() => _KategoriIconsScreenState();
}

class _KategoriIconsScreenState extends State<KategoriIconsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<IconAttrb> _listIcon = [];
  late StreamSubscription streamSubscription;
  List<RefreshController> _refreshController = [
    RefreshController(),
    RefreshController(),
    RefreshController(),
    RefreshController()
  ];

  int _selectedIconIndex = -1;
  late IconAttrb _selectedIconAttrb;

  int iconLoad = 0, iconMaxLoad = 1;
  bool readyToLoad = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {
        iconLoad = 0;
        initIcon(context, _tabController.index);
      });
    });
    initIcon(context, 0);
    Future.delayed(Duration.zero).then((_) {
      initIcon(context, _tabController.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Bahasa.pilihIkon),
          backgroundColor: Theme.of(context).primaryColor,
          actions: <Widget>[
            Hero(
              tag: Bahasa.tagPrimaryButton,
              child: SizedBox(
                width: 56.0,
                child: FlatButton(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: const Icon(Icons.done, color: Colors.white),
                  onPressed: () async {
                    if (_selectedIconAttrb != null) {
                      var tambah = await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AddKategoriScreen(
                          iconAttrb: _selectedIconAttrb,
                          key: UniqueKey(),
                        );
                      }));

                      if (tambah != null && tambah) {
                        Navigator.pop(context, true);
                      }
                    } else {
                      showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: Text(Bahasa.pilihIconTitle),
                              content: Text(Bahasa.pilihIconDetail),
                              actions: <Widget>[
                                CupertinoButton(
                                  child: Text(Bahasa.mengerti),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
                    }
                  },
                ),
              ),
            )
          ],
          bottom: TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: const <Widget>[
              Tab(
                text: "Material",
              ),
              Tab(
                text: "Ionics",
              ),
              Tab(
                text: "Ant Design",
              ),
              Tab(
                text: "Fontawasome",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: List.generate(4, (index) {
            if (_tabController.index != index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Image.asset(
                  "assets/images/loading.webp",
                  height: 150.0,
                  fit: BoxFit.contain,
                ),
              );
            } else {
              return containerListIcon(context, index);
            }
          }),
        ));
  }

  Widget containerListIcon(BuildContext context, i) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SmartRefresher(
        controller: _refreshController[i],
        onLoading: () {
          // print("loading");
          if (iconLoad < iconMaxLoad) {
            iconLoad++;
            readyToLoad = false;
            initIcon(context, i);
          } else {
            _refreshController[i].loadNoData();
          }
          setState(() {});
          _refreshController[i].refreshCompleted();
        },
        onRefresh: () async {
          // print list icon
          initIcon(context, i);
          // Future.delayed(const Duration(seconds: 3));
          _refreshController[i].loadNoData();
          iconLoad = 0;
          setState(() {});
          _refreshController[i].refreshCompleted();
        },
        enablePullUp: readyToLoad,
        child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Wrap(
              spacing: 5.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.spaceEvenly,
              runAlignment: WrapAlignment.start,
              children: List.generate(_listIcon.length, (index) {
                return SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      CircleAvatar(
                        child: Icon(_listIcon[index].icon,
                            color: _selectedIconIndex > -1 &&
                                    _selectedIconIndex == index - 1
                                ? Theme.of(context).primaryColor
                                : Color.fromARGB(255, 251, 248, 248)),
                        backgroundColor: _selectedIconIndex > -1 &&
                                _selectedIconIndex == index - 1
                            ? Theme.of(context).accentColor
                            : Theme.of(context).primaryColor,
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(100.0),
                          onTap: () {
                            setState(() {
                              _selectedIconIndex = index - 1;
                              _selectedIconAttrb = _listIcon[index];
                            });
                          },
                        ),
                      )
                    ],
                  ),
                );
              }),
            )),
      ),
    );
  }

  void initIcon(context, int? index) async {
    Map<String, int> data;
    if (iconLoad == 0) {
      setState(() {
        _listIcon.clear();
      });
      // _selectedIconAttrb = null;
      _selectedIconIndex = 0;
    }

    // printing index of tab controller
    data = getIconDataByType(index ?? 0);
    // streamSubscription.cancel();
    var sumStream = streamSum(context, data);
    int setStateOn = 0;
    streamSubscription = sumStream.listen((value) {
      if (_listIcon.length == data.length) {
        streamSubscription.cancel();
        return;
      }

      //Add list icon using stream, idk how to implement stream in the right way :'D
      _listIcon
          .add(IconAttrb(index ?? 0, data.keys.toList()[_listIcon.length]));

      //Setstate if setstateon == 6, you can change it or just throw it away
      if (setStateOn == 6) {
        setStateOn = 0;
        if (mounted) setState(() {});
      }
      setStateOn++;
    });
    streamSubscription.onDone(() {
      _refreshController[index ?? 0].refreshCompleted();
      _refreshController[index ?? 0].loadComplete();
      readyToLoad = true;
      if (mounted) setState(() {});
    });
  }

  Map<String, int> getIconDataByType(iconType) {
    switch (iconType) {
      case 0:
        return ListIcons.material;
      case 1:
        return ListIcons.ionicons;
      case 2:
        return ListIcons.antdesign;
      case 3:
        return ListIcons.fontawesome;
      default:
        return ListIcons.material;
    }
  }

  Stream<int> streamSum(context, Map<String, int> data) async* {
    int colCount = (MediaQuery.of(context).size.height / 50)
        .floor(); //Jumlah Column yang terisi jika ukuran 50.0
    int rowCount = (MediaQuery.of(context).size.width / 50)
        .floor(); //Jumlah Row yang terisi jika ukuran 50.0
    int rowSpacing = ((rowCount * 3.14) + rowCount).floor();

    iconMaxLoad = (data.length / ((colCount * rowCount) - rowSpacing)).floor();
    for (int i = 0; i < (colCount * rowCount) - rowSpacing; i++) {
      yield i;
      if (!mounted) break;
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }
}
