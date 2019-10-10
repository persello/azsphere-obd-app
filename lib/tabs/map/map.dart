import 'package:azsphere_obd_app/classes/logdata.dart';
import 'package:azsphere_obd_app/globals.dart';
import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:azsphere_obd_app/tabs/map/viewsettings.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapTab extends StatefulWidget {
  MapTab({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  Completer<GoogleMapController> _controllerCompleter = Completer();
  GoogleMapController _controller;
  bool _mapActivityIndicatorVisible = true;
  Set<Circle> _speedMarkers = {};

  void calculateSpeedMarkers() async {
    logger.i('Calculating speed markers.');

    // Reset marker set
    _speedMarkers.clear();

    // Reset temporary variables
    double lastLat = 0;
    double lastLng = 0;
    LatLng lastLoc;
    int cid = 0;

    // Get map bounds
    if (_controller == null) return;

    LatLngBounds mapBounds = await _controller.getVisibleRegion();

    for (LogSession session in car.logSessions) {
      for (RawTimedItem item in session.rawTimedData) {
        if (item.type == RawLogItemType.Speed) {
          if (lastLoc != null && mapBounds.contains(lastLoc)) {
            Circle c = new Circle(
                center: lastLoc,
                radius: 12,
                fillColor: CustomCupertinoColors.systemRed,
                strokeWidth: 0,
                circleId: new CircleId(cid.toString()));
            _speedMarkers.add(c);
            cid++;
          }
        } else if (item.type == RawLogItemType.Latitude) {
          lastLat = item.numericContent;
        } else if (item.type == RawLogItemType.Longitude) {
          lastLng = item.numericContent;
          lastLoc = new LatLng(lastLat, lastLng);
        }
      }
    }

    setState(() {
     _speedMarkers = _speedMarkers; 
    });

    logger.d('$cid markers added.');
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;

    // Do map work
    PermissionHandler().requestPermissions([PermissionGroup.location]);
    logger.i('Permission requested.');
    try {
      _controllerCompleter.complete(controller);
    } catch (e) {}
    logger.v('Controller completed.');
    setState(() {
      _mapActivityIndicatorVisible = false;
    });
  }

  void _editMapView() {
    logger.i('Opening map view editor.');
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => MapViewSettings(
          title: 'Map Settings',
          data: appSettings.mapViewSettingsData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // logger.v('Building map page.');
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.all(10),
          child: Text('Edit'),
          onPressed: _editMapView,
        ),
      ),
      child: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 1),
            onMapCreated: _onMapCreated,
            onCameraIdle: calculateSpeedMarkers,
            circles: _speedMarkers,
            compassEnabled: true,
            myLocationButtonEnabled: true,
            myLocationEnabled: appSettings.mapViewSettingsData.showMyLocation,
            padding: EdgeInsets.fromLTRB(0, 70, 0, 50),
            mapType: MapType.values[appSettings.mapViewSettingsData.mapType],
            tiltGesturesEnabled: false,
          ),
          Center(
            child: Visibility(
              child: CupertinoActivityIndicator(
                animating: true,
              ),
              visible: _mapActivityIndicatorVisible,
            ),
          ),
        ],
      ),
    );
  }
}
