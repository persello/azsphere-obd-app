import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/globals.dart';
import 'package:azsphere_obd_app/classes/device.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddNetworksPage extends StatefulWidget {
  AddNetworksPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddNetworksPageState createState() => _AddNetworksPageState();
}

class _AddNetworksPageState extends State<AddNetworksPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 120),
            child: Center(
              child: Text(
                widget.title,
                style: CustomCupertinoTextStyles.lightBigTitle,
              ),
            ),
          ),
          Container(
            height: 400,
            child: ListView(
              children: <Widget>[
                ListWiFiItem("TEST", 5, true, true, true),
                ListWiFiItem("TEST", 4, false, true, true),
                ListWiFiItem("TEST", 3, false, true, false),
                ListWiFiItem("TEST", 2, true, false, true),
                ListWiFiItem("TEST", 1, false, false, true),
                ListWiFiItem("TEST", 0, false, false, false),
                ListGroupSpacer(height: 60),
                ListWiFiItem("TEST", 6, true, true, false),
                ListWiFiItem("TEST", -1, true, true, true),
                ListWiFiItem("TEST", 3, true, true, true),
                ListWiFiItem("TEST", 4, true, true, true),
                ListWiFiItem("TEST", 5, true, true, true),
                ListWiFiItem("TEST", 2, true, true, true),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CupertinoButton(
                    child: Text("Back"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      globalScanner.closeConnection();
                    }),
                CupertinoButton(
                  child: Text("Save to device"),
                  color: CustomCupertinoColors.systemBlue,
                  onPressed: () {},
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
