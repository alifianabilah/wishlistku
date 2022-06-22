// ignore_for_file: deprecated_member_use, prefer_const_constructors, duplicate_ignore, must_be_immutable, prefer_const_constructors_in_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:get/instance_manager.dart';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:wishlistku/database/kategoriDB.dart';
import 'package:wishlistku/database/wishlistDB.dart';
import 'package:wishlistku/function.dart';
import 'package:wishlistku/screens/auth/login_view_model.dart';
import 'package:wishlistku/screens/kategori/KategoriIconScreen.dart';
import 'package:wishlistku/values/bahasa.dart';
import 'package:wishlistku/component/Widget.dart';

class UpdateWishListScreen extends StatefulWidget {
  final WishlistAttrb item;

  const UpdateWishListScreen({Key? key, required this.item}) : super(key: key);

  @override
  _UpdateWishListScreenState createState() => _UpdateWishListScreenState();
}

class _UpdateWishListScreenState extends State<UpdateWishListScreen> {
  final FocusNode _focusName = FocusNode();
  final FocusNode _focusDesc = FocusNode();
  final FocusNode _focusPrice = FocusNode();
  CameraPosition _kInitialPosition =
      CameraPosition(target: LatLng(-7.96598, 112.63418), zoom: 15);
  TextEditingController _etNamaItem = TextEditingController();
  TextEditingController _etDeskripsi = TextEditingController();
  TextEditingController _etPrice = TextEditingController();

  bool _autovalidateNama = false;
  bool _autovalidatePrice = false;

  final _formKey = GlobalKey<FormState>();

  final List<DropdownMenuItem> _listKategori = [];
  final LoginViewModel _viewModel = Get.put(LoginViewModel());
  late int _valueKategori;
  late double _latitude;
  late double _longitude;
  String _location = "";

  GoogleMapController? mapController;
  LatLng? _lastTap;
  final List<Marker> _markers = [];
  GeoCode geoCode = GeoCode(apiKey: "AIzaSyCOOOdZc3yZ7RzV8AAhTT3zciChxcXhbZI");

  @override
  void initState() {
    getKategori();
    setCurrentLocation();
    super.initState();
    setState(() {
      _etNamaItem = TextEditingController(text: widget.item.title);
      _etDeskripsi = TextEditingController(text: widget.item.description);
      _etPrice = TextEditingController(text: widget.item.price);
      _latitude = widget.item.lat;
      _longitude = widget.item.lng;
      _lastTap = LatLng(_latitude, _longitude);
      _markers.add(Marker(
          markerId: MarkerId('SomeId'),
          position: LatLng(widget.item.lat, widget.item.lng)));
    });
  }

  DateTime _chooseDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    Size dim = MediaQuery.of(context).size;

    GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
      initialCameraPosition: _kInitialPosition,
      markers: Set<Marker>.of(_markers),
      onTap: (LatLng pos) {
        _lastTap = pos;
        if (_lastTap != null &&
            _lastTap!.latitude != null &&
            _lastTap!.longitude != null) {
          setState(() {
            _latitude = _lastTap?.latitude ?? 12.3;
            _longitude = _lastTap?.longitude ?? 104.3;
          });

          LatLng latLng = LatLng(_lastTap!.latitude, _lastTap!.longitude);
          setState(() {
            _markers.clear();
            _markers
                .add(Marker(markerId: MarkerId('SomeId'), position: latLng));
          });
        }
        setState(() {});
      },
    );

    final List<Widget> columnChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.only(
            left: 10.0, top: 0, right: 10.0, bottom: 10.0),
        child: Center(
          child: SizedBox(
            width: dim.width - 20,
            height: dim.width - 20,
            child: googleMap,
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text(Bahasa.updateWishlist),
      ),
      floatingActionButton: customFlatActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              physics: const BouncingScrollPhysics(),
              children: <Widget>[
                Image.asset(
                  "assets/images/insert_wishlist.webp",
                  width: MediaQuery.of(context).size.width - 200,
                  height: 200.0,
                  fit: BoxFit.fitHeight,
                ),
                SizedBox(
                  width: 20.0,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomTextField(
                        controller: _etNamaItem,
                        focusNode: _focusName,
                        textInputAction: TextInputAction.none,
                        autovalidate: _autovalidateNama,
                        label: Bahasa.namaItem,
                        validator: (val) {
                          if (val.trim().isEmpty) {
                            _autovalidateNama = true;
                            return Bahasa.masihKosong;
                          }
                          _autovalidateNama = false;
                          return null;
                        },
                        onSubmitted: (val) {
                          MyFunction.focusSwitcher(
                              context, _focusName, _focusDesc);
                        },
                        maxLines: 1,
                        key: UniqueKey(),
                        // icon: Icons.text_fields,
                        textInputType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          color: Colors.grey[200],
                          child: Text(DateFormat(DateFormat.YEAR_MONTH_DAY)
                              .format(_chooseDate)
                              .toString()),
                          onPressed: () async {
                            _chooseDate = await showDatePicker(
                                    context: context,
                                    initialDate: _chooseDate,
                                    lastDate: DateTime(2050),
                                    firstDate: DateTime(DateTime.now().year)) ??
                                _chooseDate;
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                CustomTextField(
                  controller: _etDeskripsi,
                  focusNode: _focusDesc,
                  textInputAction: TextInputAction.newline,
                  label: Bahasa.deskripsi,
                  maxLines: 5,
                  textInputType: TextInputType.multiline,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                CustomTextField(
                  controller: _etPrice,
                  focusNode: _focusPrice,
                  autovalidate: _autovalidatePrice,
                  label: Bahasa.harga,
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    if (val?.length < 1) {
                      _autovalidatePrice = true;
                      return Bahasa.masihKosong;
                    }
                    if (int.tryParse(val!) == null) {
                      _autovalidatePrice = true;
                      return Bahasa.hargaTidakValid;
                    }

                    _autovalidatePrice = false;
                    return null;
                  },
                  textInputType: TextInputType.number,
                  maxLines: 1,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        Bahasa.kategori,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      if (_listKategori.isNotEmpty)
                        DropdownButton(
                          isExpanded: true,
                          hint: Text(Bahasa.kategori),
                          iconEnabledColor: Colors.white,
                          items: _listKategori,
                          value: _valueKategori,
                          underline: Container(),
                          icon: Container(),
                          onChanged: (dynamic val) {
                            _valueKategori = val;
                            setState(() {});
                          },
                        )
                      else
                        Container(),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: columnChildren,
                ),
                const SizedBox(
                  height: 120.0,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget customFlatActionButton(BuildContext context) {
    return Hero(
      tag: Bahasa.tagPrimaryButton,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        child: RawMaterialButton(
          elevation: 5.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            Bahasa.simpan,
            style: TextStyle(
                color: Theme.of(context).textTheme.button?.color,
                fontSize: 18.0),
          ),
          fillColor: Theme.of(context).accentColor,
          onPressed: () async {
            Wishlist dbWishlist = await Wishlist.initDatabase();
            int? validPrice = int.tryParse(_etPrice.text);
            _formKey.currentState?.validate();
            if (validPrice == null) {
              return;
            }
            try {
              dynamic user = _viewModel.getData();
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Anda belum login"),
                  duration: Duration(seconds: 2),
                ));
                return;
              }
              await reverseGeocodingSearch(
                  LatLon(_lastTap!.latitude, _lastTap!.longitude));
              if (_lastTap!.latitude != null &&
                  _lastTap!.longitude != null &&
                  _location != "") {
                WishlistAttrb resp = await dbWishlist.updateDataByValue(
                    widget.item.id,
                    userId: user['id'].toString(),
                    title: _etNamaItem.text.trim(),
                    time: DateFormat(DateFormat.YEAR_MONTH_DAY)
                        .format(_chooseDate)
                        .toString(),
                    description: _etDeskripsi.text.trim(),
                    price: validPrice.toString(),
                    lat: _latitude,
                    lng: _longitude,
                    location: _location,
                    idKategori: _valueKategori);
                // WishlistAttrb resp = await dbWishlist.insertDataByValue(
                //     title: _etNamaItem.text.trim(),
                //     time: DateFormat(DateFormat.YEAR_MONTH_DAY)
                //         .format(_chooseDate)
                //         .toString(),
                //     description: _etDeskripsi.text.trim(),
                //     price: validPrice.toString(),
                //     idKategori: _valueKategori);
                Navigator.pop(context, resp);
              } else {
                // scafold popup
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text("Tolong pilih lokasi terlebih dahulu :" + _location),
                  duration: Duration(seconds: 2),
                ));
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Error : " + e.toString()),
                duration: Duration(seconds: 2),
              ));
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _focusDesc.dispose();
    _focusName.dispose();
    _focusPrice.dispose();
  }

  void getKategori() async {
    Kategori dbKategori = await Kategori.initDatabase();
    List<KategoriAttrb> tempKategori = await dbKategori.getData();
    for (KategoriAttrb item in tempKategori) {
      _listKategori.add(DropdownMenuItem(
        child: SizedBox(
          height: 200.0,
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(item.icon, color: Colors.white),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text(item.title)
            ],
          ),
        ),
        value: item.id,
      ));
    }
    if (_listKategori.isEmpty) {
      await MyFunction.showDialog(context,
          title: Bahasa.ops,
          msg: Bahasa.kategoriKosongMsgDetail,
          actions: [
            CupertinoButton(
              child: const Text("Mengerti"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return KategoriIconsScreen();
                }));
              },
            )
          ]);
      return;
    }
    _valueKategori = _listKategori.first.value;
    setState(() {});
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    setState(() {
      mapController = controller;
    });
  }

  Future<LocationManager.LocationData?> _currentLocation() async {
    bool serviceEnabled;
    LocationManager.PermissionStatus permissionGranted;

    LocationManager.Location location = new LocationManager.Location();

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = (await location.hasPermission());
    if (permissionGranted == LocationManager.PermissionStatus.denied) {
      permissionGranted = (await location.requestPermission());
      if (permissionGranted != LocationManager.PermissionStatus.granted) {
        return null;
      }
    }
    return await location.getLocation();
  }

  Future<void> setCurrentLocation() async {
    dynamic location = await _currentLocation();
    _kInitialPosition = CameraPosition(
        target: LatLng(location.latitude, location.longitude), zoom: 11.0);
    setState(() {});
  }

  Future<void> reverseGeocodingSearch(LatLon latlng) async {
    var googleGeocoding =
        GoogleGeocoding("AIzaSyCOOOdZc3yZ7RzV8AAhTT3zciChxcXhbZI");
    var response = await googleGeocoding.geocoding.getReverse(latlng);
    print(response);
    if (response != null && response.results != null) {
      dynamic res = response.results;
      if (res.length < 1) {
        setState(() {
          _location = "Tidak ditemukan";
        });
      } else if (mounted) {
        setState(() {
          _location = response.results!.first != null
              ? (response.results!.first.formattedAddress ?? "Tidak ditemukan")
              : "Tidak ditemukan";
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _location = "Tidak ditemukan";
        });
      }
    }
  }
}
