import 'dart:io';

import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:azsphere_obd_app/tabs/home/home.dart';
import 'package:azsphere_obd_app/tabs/map/map.dart';
import 'package:azsphere_obd_app/tabs/settings/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'classes/fuel.dart';
import 'classes/vehicle.dart';
import 'globals.dart';

void main() async {
  logger.i('Welcome to Azure Sphere OBD Driving Stats!');

  logger.i('Setting up Hive path and adapters.');

  // App folder
  Directory directory;
  directory = await getApplicationDocumentsDirectory();

  // Database location
  Hive.init('${directory.path}/hive');

  // Adapters (one-time registration)
  Hive.registerAdapter(VehicleAdapter(), HIVE_VEHICLE_ADAPTER_ID);
  Hive.registerAdapter(FuelAdapter(), HIVE_FUEL_ADAPTER_ID);
  Hive.registerAdapter(
      MapViewSettingsDataAdapter(), HIVE_MAP_VIEW_SETTINGS_ADAPTER_ID);

  if (Foundation.kDebugMode) {
    logger.w('App is running in debug mode.');
  } else {
    logger.i('App is running in release mode.');
    Logger.level = Level.nothing;
  }

  // Limit to vertical orientation until layout is responsive.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });

  logger.v('Preferred orientation is now portrait only.');

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Color.fromARGB(0, 0, 0, 0),
  ));

  logger.v('Status bar is set to transparent.');
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    logger.i('MyApp started.');

    // Application setup, restore saved data
    logger.v('Getting settings from storage.');
    appSettings = new StoredSettings();
    appSettings.restoreMapSettings();

    logger.i('Map settings restored.');

    return CupertinoApp(
      title: 'OBD Driving Stats',
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
    // logger.v('Building main page.');
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
              return HomeTab(title: 'Home');
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return MapTab(title: 'Map');
            });
          case 2:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Center(
                  child: Text('3'),
                ),
              );
            });
          case 3:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Center(
                  child: Text('4'),
                ),
              );
            });
          case 4:
          default:
            return CupertinoTabView(builder: (context) {
              return SettingsTab(title: 'Settings');
            });
        }
      },
    );
  }
}
