import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import 'classes/device.dart';
import 'classes/vehicle.dart';

part 'globals.g.dart';

StoredSettings appSettings;
OBDScanner globalScanner;
Vehicle car = new Vehicle();
Logger logger = new Logger(printer: PrettyPrinter(methodCount: 0));

/// A container class for a Wi-Fi network.
///
/// [isConnected], [isProtected], [isCurrentlyAvailable] and [isSaved]
/// are set to false by default.
class WiFiNetwork {
  /// Matches a signal level to a number (0 - 5)
  static int rssiToDots(int rssi) {
    if (rssi < -90) return 0;
    if (rssi < -80) return 1;
    if (rssi < -70) return 2;
    if (rssi < -67) return 3;
    if (rssi < -45) return 4;
    return 5;
  }

  String ssid;
  String password;
  bool isConnected = false;
  bool isCurrentlyAvailable = false;
  bool isSaved = false;
  bool isProtected = false;
  int rssi = -100;
}

/// The global app settings.
class StoredSettings {
  StoredSettings() {
    logger.v(
        'StoredSettings constructor called, opening "app-settings" Hive box.');

    // Opens the app settings box
    getAppSettingsBox();
  }

  MapViewSettingsData mapViewSettingsData = MapViewSettingsData();
  Box appSettings;

  void getAppSettingsBox() async {
    appSettings = await Hive.openBox('app-settings');
    appSettings.registerAdapter(MapViewSettingsDataAdapter(), 0);
  }

  /// Gets the last IP of the scanner from the shared preferences
  Future<String> restoreIp() async {
    return appSettings.get('scanner-last-ip') ?? '';
  }

  /// Saves [ip] into the shared preferences
  void saveIp(String ip) async {
    appSettings.put('scanner-last-ip', ip);
  }

  void restoreMapSettings() async {
    logger.i('Restoring map settings from storage.');

    // Map settings
    this.mapViewSettingsData = appSettings.get('map-view-settings');
  }

  void saveMapSettings() async {
    logger.i('Storing map settings.');

    // Map settings
    appSettings.put('map-view-settings', this.mapViewSettingsData);
  }
}

/// Map view settings.
@HiveType()
class MapViewSettingsData {
  MapViewSettingsData({this.showMyLocation, this.mapType});

  @HiveField(0)
  bool showMyLocation;

  // Normal, hybrid or terrain
  @HiveField(1)
  MapType mapType;
}
