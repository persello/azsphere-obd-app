import 'dart:math';

import 'package:azsphere_obd_app/classes/fuel.dart';
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
  String _unitLabel = '';
  bool _mapActivityIndicatorVisible = true;
  Set<Circle> _dataMarkers = {};
  double _currentZoom = 0;
  Timer _mapTimer;
  double _maxValue = 0;
  double _minValue = 0;

  void getCameraParams(CameraPosition camera) {
    _currentZoom = camera.zoom;
    logger.i('New zoom is $_currentZoom.');
  }

  /// Calculates fuel economy in L/100km and averages it with the last two items.
  ///
  /// [airflow] is in g/s, and [speed] in km/h
  double lastSpeed = 0;
  double lastLHKM1;
  double lastLHKM2;
  double calculateLKM(double airflow, Fuel fuel, double speed) {
    // Filter slow and accelerations
    if (speed < 10 || (speed - lastSpeed) > 10) return 0;

    double gramsOfFuelPerSecond = airflow * fuel.massAirFuelRatio;
    double millilitersOfFuelPerSecond = gramsOfFuelPerSecond / fuel.density;
    double metersPerSecond = speed * (10 / 36);
    double kilometersPerLitre = metersPerSecond / millilitersOfFuelPerSecond;
    double litersHundredKm = 100 / kilometersPerLitre;

    // First time set to the same
    if (lastLHKM1 == null) lastLHKM1 = litersHundredKm;
    if (lastLHKM2 == null) lastLHKM2 = litersHundredKm;

    // Calculate average
    double average = (litersHundredKm + lastLHKM1 + lastLHKM2) / 3;

    // Shift
    lastLHKM2 = lastLHKM1;
    lastLHKM1 = litersHundredKm;

    // Save speed and return
    lastSpeed = speed;
    return average;
  }

  void calculateDataMarkers() async {
    logger.i('Calculating speed markers.');

    // Reset marker set
    _dataMarkers.clear();

    // Reset temporary variables
    double lastLat = 0;
    double lastLng = 0;
    LatLng lastLoc;
    double lastSpeed = 0;

    RawLogItemType interestingDataType;

    setState(() {
      switch (appSettings.mapViewSettingsData.mapDataType) {
        case 0:
          // None
          interestingDataType = RawLogItemType.None;
          _maxValue = 0;
          _minValue = 0;
          break;
        case 1:
          interestingDataType = RawLogItemType.GPSSpeed;
          _maxValue = 90;
          _minValue = double.infinity;
          _unitLabel = 'kph';
          break;
        case 2:
          interestingDataType = RawLogItemType.EngineRPM;
          _maxValue = 1500;
          _minValue = double.infinity;
          _unitLabel = 'RPM';
          break;
        case 3:
          interestingDataType = RawLogItemType.Airflow;
          // Litres for 100km
          _maxValue = 10;
          _minValue = double.infinity;
          _unitLabel = 'l/100';
          break;
      }
    });

    // Get map bounds
    if (_controller == null) return;

    LatLngBounds mapBounds = await _controller.getVisibleRegion();

    // Get item count and compute divider
    int markersInView = 0;
    for (LogSession session in car.logSessions) {
      for (RawTimedItem item in session.rawTimedData) {
        if (item.type == interestingDataType) {
          if (lastLoc != null && mapBounds.contains(lastLoc)) {

            // Value calculation
            double value = appSettings.mapViewSettingsData.mapDataType == 3
                ? calculateLKM(item.numericContent, car.fuel, lastSpeed)
                : item.numericContent;
            _maxValue = value > _maxValue ? value : _maxValue;

            // When in RPM mode, filter everything under 600
            if (appSettings.mapViewSettingsData.mapDataType == 2 && item.numericContent > 600) {
              _minValue = value < _minValue ? value : _minValue;
            } else if (appSettings.mapViewSettingsData.mapDataType != 2) {
              _minValue = value < _minValue ? value : _minValue;
            }

            markersInView++;

            // No more markers here, please
            lastLoc = null;
          }
        } else if (item.type == RawLogItemType.Latitude) {
          lastLat = item.numericContent;
        } else if (item.type == RawLogItemType.Longitude) {
          lastLng = item.numericContent;
          lastLoc = new LatLng(lastLat, lastLng);
          // Use tacho speed for fuel calculation
        } else if (item.type == RawLogItemType.Speed) {
          lastSpeed = item.numericContent;
        }
      }
    }

    // We want no more than 500 markers per screen
    double divider = 500 / markersInView;
    double currentItemDivider = 0;
    int addedMarkers = 0;
    int lastStateSet = 0;

    logger.i('There should be $markersInView markers in view, divider is $divider.');

    for (LogSession session in car.logSessions) {
      for (RawTimedItem item in session.rawTimedData) {
        if (item.type == interestingDataType) {
          // Add only when in view
          if (lastLoc != null && mapBounds.contains(lastLoc)) {
            // Up to about 500 markers
            if ((currentItemDivider += divider) > addedMarkers && item.numericContent > 3) {
              // Calculate value for fuel consumption
              double value = appSettings.mapViewSettingsData.mapDataType == 3
                  ? calculateLKM(item.numericContent, car.fuel, lastSpeed)
                  : item.numericContent;

              // Calculate dot color
              // 0 -> Green (0), maxValue -> Red (1)
              double colorFactor = (value - _minValue) / (_maxValue - _minValue);
              if (colorFactor > 1) colorFactor = 1;
              if (colorFactor.isNaN || colorFactor < 0) colorFactor = 0;

              // Calculate the radius
              double cRadius =
                  0.2851041 + (268.3408 - 0.2851041) / (1 + Math.pow((_currentZoom / 9.965059), 8.10246));

              Circle c = new Circle(
                  center: lastLoc,
                  radius: cRadius,
                  fillColor: Color.alphaBlend(CustomCupertinoColors.systemRed.withOpacity(colorFactor),
                          CustomCupertinoColors.systemGreen)
                      .withOpacity(0.2 + _currentZoom / 30),
                  strokeWidth: 0,
                  circleId: new CircleId(addedMarkers.toString()));
              _dataMarkers.add(c);

              // Add markers in blocks of 100
              if (lastStateSet < (addedMarkers - 100)) {
                logger.i('Partial markers: $addedMarkers, previous was $lastStateSet');
                lastStateSet = addedMarkers;

                setState(() {
                  _dataMarkers = _dataMarkers;
                });
              }
              lastLoc = null;
              addedMarkers++;
            }
          }
        } else if (item.type == RawLogItemType.Latitude) {
          lastLat = item.numericContent;
        } else if (item.type == RawLogItemType.Longitude) {
          lastLng = item.numericContent;
          lastLoc = new LatLng(lastLat, lastLng);
          // Use tacho speed for fuel calculations
        } else if (item.type == RawLogItemType.Speed) {
          lastSpeed = item.numericContent;
        }
      }
    }

    setState(() {
      _dataMarkers = _dataMarkers;
    });

    logger.d('$addedMarkers markers added.');
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _controller.setMapStyle('''[
    {
        "featureType": "landscape.natural",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "visibility": "on"
            },
            {
                "color": "#e0efef"
            }
        ]
    },
    {
        "featureType": "poi",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "visibility": "on"
            },
            {
                "hue": "#1900ff"
            },
            {
                "color": "#c0e8e8"
            }
        ]
    },
    {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
            {
                "lightness": 100
            },
            {
                "visibility": "simplified"
            }
        ]
    },
    {
        "featureType": "road",
        "elementType": "labels",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "transit.line",
        "elementType": "geometry",
        "stylers": [
            {
                "visibility": "on"
            },
            {
                "lightness": 700
            }
        ]
    },
    {
        "featureType": "water",
        "elementType": "all",
        "stylers": [
            {
                "color": "#7dcdcd"
            }
        ]
    }
    ]''');

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
    calculateDataMarkers();
  }

  void _editMapView() async {
    logger.i('Opening map view editor.');
    var t = await Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => MapViewSettings(
          title: 'Map Settings',
          data: appSettings.mapViewSettingsData,
        ),
      ),
    );

    // Recalculate when returning back
    calculateDataMarkers();
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
            onCameraIdle: () {
              _mapTimer = new Timer(Duration(milliseconds: 500), calculateDataMarkers);
            },
            onCameraMove: (CameraPosition c) {
              _mapTimer.cancel();
              getCameraParams(c);
            },
            circles: _dataMarkers,
            compassEnabled: true,
            myLocationButtonEnabled: true,
            myLocationEnabled: appSettings.mapViewSettingsData.showMyLocation,
            padding: EdgeInsets.fromLTRB(0, 70, 0, 50),
            mapType: MapType.values[appSettings.mapViewSettingsData.mapType],
            tiltGesturesEnabled: false,
          ),
          Visibility(
            visible: (appSettings.mapViewSettingsData.mapDataType != 0),
            child: Container(
              margin: EdgeInsets.only(left: 8, top: 160),
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    width: 40,
                    height: 360,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: CustomCupertinoColors.black.withOpacity(.4),
                          blurRadius: 12,
                        ),
                      ],
                      color: CustomCupertinoColors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text('${_maxValue.toInt()}'),
                        Expanded(
                          child: Container(
                            width: 6,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [CustomCupertinoColors.systemRed, CustomCupertinoColors.systemGreen],
                              ),
                            ),
                          ),
                        ),
                        Text('${(_minValue.isFinite) ? _minValue.toInt() : 0}'),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 10),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: CustomCupertinoColors.black.withOpacity(.4),
                          blurRadius: 12,
                        ),
                      ],
                      color: CustomCupertinoColors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(_unitLabel),
                  ),
                ],
              ),
            ),
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
