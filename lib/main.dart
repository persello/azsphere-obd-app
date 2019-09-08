import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:flutter/cupertino.dart';

import 'package:azsphere_obd_app/tabs/home/home.dart';
import 'package:azsphere_obd_app/tabs/map/map.dart';
import 'package:azsphere_obd_app/tabs/settings/settings.dart';

import 'package:azsphere_obd_app/globals.dart';
import 'package:flutter/services.dart';

void main() {
  // Limit to vertical orientation until layout is responsive.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Color.fromARGB(0, 0, 0, 0),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Application setup
    appSettings = Settings();

    return CupertinoApp(
      title: 'Azure Sphere OBD Driving Stats',
      home: MainPage(title: 'Driving Stats'),
      debugShowCheckedModeBanner: false,
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
    //Bottom tab bar and upper container
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            activeIcon: Icon(CustomCupertinoIcons.home_solid),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomCupertinoIcons.navigation_circled),
            activeIcon: Icon(CustomCupertinoIcons.navigation_circled_solid),
            title: Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomCupertinoIcons.pie_chart),
            activeIcon: Icon(CustomCupertinoIcons.pie_chart_solid),
            title: Text('Data'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomCupertinoIcons.dashboard),
            activeIcon: Icon(CustomCupertinoIcons.dashboard_solid),
            title: Text('Dashboard'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings_solid),
            title: Text('Settings'),
          ),
        ],
      ),

      // Tabs in the container
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return HomeTab(title: "Home");
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
