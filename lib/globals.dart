import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:azsphere_obd_app/tabs/map/viewsettings.dart';

import 'classes/device.dart';

Settings appSettings;
OBDScanner globalScanner;

/// The global app settings.
class Settings {

  // On creation we load everything into the object.
  Settings() {
    restore();
  }

  final MapViewSettingsData mapViewSettingsData = MapViewSettingsData();

  restore() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    // Map settings
    this.mapViewSettingsData.mapType = MapType.values[
        sp.getInt("mapViewSettingsData_mapType") ?? MapType.normal.index];
    this.mapViewSettingsData.showMyLocation =
        sp.getBool("mapViewSettingsData_showMyLocation") ?? true;


  }

  void save() async {
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
