import 'package:azsphere_obd_app/globals.dart' as globals;
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

  Completer<GoogleMapController> _controller = Completer();
  bool _mapActivityIndicatorVisible = true;

  void _onMapCreated(GoogleMapController controller) {
    PermissionHandler().requestPermissions([PermissionGroup.location]);
    _controller.complete(controller);
    setState(() {
      _mapActivityIndicatorVisible = false;
    });
  }

  void _editMapView() {
    Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(fullscreenDialog: true, builder: (context) => MapViewSettings(title: "Map Settings", data: globals.appSettings.mapViewSettingsData,)));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.all(10),
          child: Text("View"),
          onPressed: _editMapView,
        ),
      ),
      child: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(0, 0), zoom: 1),
            onMapCreated: _onMapCreated,
            compassEnabled: true,
            myLocationButtonEnabled: true,
            myLocationEnabled: globals.appSettings.mapViewSettingsData.showMyLocation,
            padding: EdgeInsets.fromLTRB(0, 70, 0, 50),
            mapType: globals.appSettings.mapViewSettingsData.mapType,
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
