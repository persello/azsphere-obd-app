import 'package:flutter/cupertino.dart';

import 'package:azsphere_obd_app/tabs/map/map.dart';
import 'package:azsphere_obd_app/tabs/settings/settings.dart';
import 'package:azsphere_obd_app/globals.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Application setup
    appSettings = Settings();

    return CupertinoApp(
      title: 'Azure Sphere OBD Driving Stats',
      home: MainPage(title: 'Driving Stats'),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            activeIcon: Icon(CupertinoIcons.home_solid),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.navigation_circled),
            activeIcon: Icon(CupertinoIcons.navigation_circled_solid),
            title: Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.pie_chart),
            activeIcon: Icon(CupertinoIcons.pie_chart_solid),
            title: Text('Data'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.download),
            activeIcon: Icon(CupertinoIcons.download_solid),
            title: Text('Download'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings_solid),
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
              return MapTab(title: "Map");
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
          default:
            return CupertinoTabView(builder: (context) {
              return SettingsTab(title: "Settings");
            });
        }
      },
    );
  }
}
