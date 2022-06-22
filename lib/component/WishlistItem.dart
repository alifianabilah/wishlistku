// ignore_for_file: file_names, unnecessary_null_comparison, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wishlistku/database/kategoriDB.dart';
import 'package:wishlistku/database/wishlistDB.dart';

class WishlistItem extends StatefulWidget {
  final Function() onTap;
  final WishlistAttrb wishlistAttrb;

  const WishlistItem(
      {required Key key, required this.onTap, required this.wishlistAttrb})
      : super(key: key);

  @override
  _WishlistItemState createState() => _WishlistItemState();
}

class _WishlistItemState extends State<WishlistItem> {
  IconData? iconData;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: iconData != null
            ? Icon(
                iconData,
                color: widget.wishlistAttrb.status == 0
                    ? Colors.white
                    : Theme.of(context).colorScheme.secondary,
              )
            : Icon(
                Icons.warning,
                color: Colors.grey[400],
              ),
      ),
      onTap: widget.onTap,
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            "Biaya",
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12.0),
          ),
          Text(
            "Rp" +
                NumberFormat("#,###")
                    .format(double.parse(widget.wishlistAttrb.price))
                    .replaceAll(",", "."),
            style: TextStyle(fontSize: 18.0),
          )
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(widget.wishlistAttrb.title),
          SizedBox(
            width: 3,
          ),
          Text(
            DateFormat(DateFormat.YEAR_MONTH_DAY)
                .format(widget.wishlistAttrb.time),
            style: TextStyle(
                color: widget.wishlistAttrb.status == 1
                    ? Colors.green
                    : !DateTime.now().isAfter(widget.wishlistAttrb.time)
                        ? Colors.grey[600]
                        : Colors.red,
                fontSize: 10.0),
          ),
        ],
      ),
      subtitle: widget.wishlistAttrb.description != null
          ? Text(
              widget.wishlistAttrb.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          : null,
    );
  }

  @override
  void initState() {
    super.initState();
    initIconData();
  }

  void initIconData() async {
    Kategori kategori = await Kategori.initDatabase();
    KategoriAttrb? kategoriAttrb =
        await kategori.getById(widget.wishlistAttrb.idKategori);
    iconData = kategoriAttrb != null ? kategoriAttrb.icon : Icons.warning;
    if (mounted) setState(() {});
  }
}
