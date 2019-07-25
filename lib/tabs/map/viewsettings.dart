import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:azsphere_obd_app/iosstyles.dart';

//import 'package:azsphere_obd_app/iosstyles.dart';

class MapViewSettings extends StatefulWidget {
  MapViewSettings({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MapViewSettingsState createState() => _MapViewSettingsState();
}

class _MapViewSettingsState extends State<MapViewSettings> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomCupertinoColors.systemGray6,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        previousPageTitle: "Map",
      ),
      child: ListView(
        children: <Widget>[
          ListGroupSpacer(
            title: "View",
          ),
          ListSwitch(
            title: "Show my location",
            onChanged: (bool x) {},
          ),
          ListSwitch(
            title: "Satellite view",
            onChanged: (bool x) {},
            initialValue: true,
          ),
          ListSwitch(
            title: "Bap",
            isLast: true,
            onChanged: (bool x) {},
          ),
        ],
      ),
    );
  }
}
