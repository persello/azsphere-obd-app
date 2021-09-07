import 'package:azsphere_obd_app/tabs/settings/carproperties.dart';
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
    1: Text('Normal'),
    4: Text('Satellite'),
    3: Text('Terrain')
  };

  final Map<int, Widget> dataTypeChoices = const <int, Widget>{
    0: Text('None'),
    1: Text('Speed'),
    2: Text('RPM'),
    3: Text('Fuel')
  };

  @override
  _MapViewSettingsState createState() => _MapViewSettingsState();
}

class _MapViewSettingsState extends State<MapViewSettings> {
  @override
  Widget build(BuildContext context) {
    // logger.v('Building map view settings page.');
    return CupertinoPageScaffold(
      backgroundColor: CustomCupertinoColors.systemGray6,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        previousPageTitle: 'Map',
      ),
      child: ListView(
        children: <Widget>[
          ListGroupSpacer(title: 'View'),
          ListSwitch(
            title: 'Show my location',
            onChanged: (bool value) {
              logger.d('Show location setting is now $value.');
              widget.data.showMyLocation = value;
              appSettings.saveMapSettings();
            },
            initialValue: widget.data.showMyLocation,
          ),
          GenericListItem(
            child: CupertinoSegmentedControl<int>(
              onValueChanged: (int selectedMapType) {
                logger.d(
                    'Selected map type is now ${MapType.values[selectedMapType]}.');
                setState(() {
                  widget.data.mapType = selectedMapType;
                  appSettings.saveMapSettings();
                });
              },
              children: widget.mapTypeChoices,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              groupValue: widget.data.mapType,
            ),
          ),
          ListGroupSpacer(title: 'Data'),
          GenericListItem(
            child: CupertinoSegmentedControl<int>(
              onValueChanged: (int selectedDataType) {
                logger.d(
                    'Selected data type is now ${widget.dataTypeChoices[selectedDataType]}.');
                if (selectedDataType == 3 && car.fuel.massAirFuelRatio == 0.0) {
                  // Show dialog to user
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) => new CupertinoAlertDialog(
                      title: new Text("Fuel not selected"),
                      content: new Text(
                          "Please select a valid fuel before continuing."),
                      actions: [
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          child: new Text("Select fuel"),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                builder: (context) => SettingsCarProperties(
                                  title: 'Vehicle information',
                                  previousTitle: widget.title,
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  );
                }
                setState(() {
                  widget.data.mapDataType = selectedDataType;
                  appSettings.saveMapSettings();
                });
              },
              children: widget.dataTypeChoices,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              groupValue: widget.data.mapDataType,
            ),
          ),
        ],
      ),
    );
  }
}
