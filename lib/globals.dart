import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import 'classes/device.dart';
import 'classes/vehicle.dart';

part 'globals.g.dart';

const int HIVE_MAP_VIEW_SETTINGS_ADAPTER_ID = 0;
const int HIVE_VEHICLE_ADAPTER_ID = 1;
const int HIVE_FUEL_ADAPTER_ID = 2;
const int HIVE_RAW_LOG_ITEM_ADAPTER_ID = 3;
const int HIVE_LOG_SESSION_ADAPTER_ID = 4;
const int HIVE_RAW_TIMED_ITEM_ADAPTER_ID = 5;
const int HIVE_REMOTE_FILE_ADAPTER_ID = 6;

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
    _hiveReady = getAppSettingsBox();
  }

  MapViewSettingsData mapViewSettingsData = MapViewSettingsData();
  Box appSettings;

  Future getAppSettingsBox() async {
    appSettings = await Hive.openBox('app-settings');
  }

  void restoreMapSettings() async {
    logger.i('Restoring map settings from storage.');

    await this.hiveReady;

    // Map settings
    this.mapViewSettingsData = appSettings.get('map-view-settings', defaultValue: new MapViewSettingsData(showMyLocation: true, mapType: MapType.normal.index));
  }

  void saveMapSettings() async {
    logger.i('Storing map settings.');

    await this.hiveReady;

    // Map settings
    appSettings.put('map-view-settings', this.mapViewSettingsData);
  }

  Future _hiveReady;

  Future get hiveReady => _hiveReady;

}

/// Map view settings.
@HiveType()
class MapViewSettingsData {
  MapViewSettingsData({this.showMyLocation, this.mapType});

  @HiveField(0)
  bool showMyLocation;

  // Normal, hybrid or terrain
  @HiveField(1)
  int mapType;
}
