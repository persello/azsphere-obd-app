import 'package:flutter/cupertino.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:azsphere_obd_app/globals.dart';

/// Map View Settings page
/// 
/// In this page you can change settings related to the [GoogleMap]
/// control in the [MapTab] page.
class MapViewSettings extends StatefulWidget {
  MapViewSettings({Key key, this.title, @required this.data}) : super(key: key);

  final String title;
  final MapViewSettingsData data;

  final Map<int, Widget> mapTypeChoices = const <int, Widget>{
    // 1, 4, 3 in order to match GoogleMap's MapType enum
    1: Text("Normal"),
    4: Text("Satellite"),
    3: Text("Terrain")
  };

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
            onChanged: (bool value) {
              widget.data.showMyLocation = value;
              appSettings.saveMapSettings();
            },
            initialValue: widget.data.showMyLocation,
          ),
          GenericListItem(
            child: CupertinoSegmentedControl<int>(
              onValueChanged: (int selectedMapType) {
                setState(() {
                  widget.data.mapType = MapType.values[selectedMapType];
                  appSettings.saveMapSettings();
                });
              },
              children: widget.mapTypeChoices,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              groupValue: widget.data.mapType.index,
            ),
          ),
        ],
      ),
    );
  }
}