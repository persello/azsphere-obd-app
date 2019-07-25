import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Azure Sphere OBD Driving Stats',
      home: MainPage(title: 'Driving Stats'),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Completer<GoogleMapController> _controller = Completer();
  bool _mapActivityIndicatorVisible = true;
  void _onMapCreated(GoogleMapController controller) {
    askLocationPermission();
    _controller.complete(controller);
    setState(() {
      _mapActivityIndicatorVisible = false;
    });
  }

  askLocationPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.location]);
  }

  void _editMapView() {}

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.navigation_circled),
            title: Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.pie_chart),
            title: Text('Data'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.download),
            title: Text('Download'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            title: Text('Settings'),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: Text("Home"),
                ),
                child: Center(
                  child: Text("1"),
                ),
              );
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: Text("Map"),
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
                      myLocationEnabled: true,
                      padding: EdgeInsets.fromLTRB(0, 70, 0, 50),
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
            });
          case 2:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Center(
                  child: Text("3"),
                ),
              );
            });
          case 3:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Center(
                  child: Text("4"),
                ),
              );
            });
          case 4:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Center(
                  child: Text("5"),
                ),
              );
            });
        }
      },
    );
  }
}
