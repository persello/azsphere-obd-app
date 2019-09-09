import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:azsphere_obd_app/tabs/map/viewsettings.dart';

import 'classes/device.dart';
import 'classes/vehicle.dart';

StoredSettings appSettings;
OBDScanner globalScanner;
Vehicle car = new Vehicle();

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
  final MapViewSettingsData mapViewSettingsData = MapViewSettingsData();

  /// Gets the last IP of the scanner from the shared preferences
  static Future<String> restoreIp() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    return sp.getString('scanner_last_ip') ?? '';
  }

  /// Saves [ip] into the shared preferences
  static void saveIp(String ip) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    sp.setString('scanner_last_ip', ip);
  }

  void restoreMapSettings() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    // Map settings
    this.mapViewSettingsData.mapType = MapType.values[
        sp.getInt('mapViewSettingsData_mapType') ?? MapType.normal.index];
    this.mapViewSettingsData.showMyLocation =
        sp.getBool('mapViewSettingsData_showMyLocation') ?? true;
  }

  void saveMapSettings() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    // Map settings
    sp.setInt(
        "mapViewSettingsData_mapType", this.mapViewSettingsData.mapType.index);
    sp.setBool("mapViewSettingsData_showMyLocation",
        this.mapViewSettingsData.showMyLocation);
  }
}

/// Map view settings.
class MapViewSettingsData {
  MapViewSettingsData({this.showMyLocation, this.mapType});
  bool showMyLocation;
  // Normal, hybrid or terrain
  MapType mapType;
}
