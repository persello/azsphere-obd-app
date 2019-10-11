import 'package:azsphere_obd_app/classes/logdata.dart';
import 'package:azsphere_obd_app/globals.dart';
import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:azsphere_obd_app/tabs/map/viewsettings.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:math' as Math;

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
  double _currentZoom = 0;

  void getCameraParams(CameraPosition camera) {
    _currentZoom = camera.zoom;
    logger.i('New zoom is $_currentZoom.');
  }

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

    // Get item count and compute divider
    int markersInView = 0;
    for (LogSession session in car.logSessions) {
      for (RawTimedItem item in session.rawTimedData) {
        if (item.type == RawLogItemType.Speed) {
          if (lastLoc != null && mapBounds.contains(lastLoc)) {
            markersInView++;
          }
        } else if (item.type == RawLogItemType.Latitude) {
          lastLat = item.numericContent;
        } else if (item.type == RawLogItemType.Longitude) {
          lastLng = item.numericContent;
          lastLoc = new LatLng(lastLat, lastLng);
        }
      }
    }

    // We want no more than 500 markers per screen
    double divider = 500 / markersInView;
    double currentItemDivider = 0;

    logger.i('There should be $markersInView markers in view, divider is $divider.');

    for (LogSession session in car.logSessions) {
      for (RawTimedItem item in session.rawTimedData) {
        if (item.type == RawLogItemType.Speed) {
          // Add only when in view and up to 500 markers
          if (lastLoc != null && mapBounds.contains(lastLoc) && (currentItemDivider += divider) > cid) {

            // Calculate dot color
            // Speed = 0 km/h -> Green (0), Speed >= 130 km/h -> Red (1)
            double colorFactor = item.numericContent >= 130 ? 1 : item.numericContent / 130;

            // Calculate the radius
            double cRadius = 0.2851041 + (268.3408 - 0.2851041)/(1 + Math.pow((_currentZoom/9.965059),8.10246));

            Circle c = new Circle(
                center: lastLoc,
                radius: cRadius,
                fillColor: Color.alphaBlend(CustomCupertinoColors.systemRed.withOpacity(colorFactor),
                    CustomCupertinoColors.systemGreen),
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
            onCameraMove: getCameraParams,
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
