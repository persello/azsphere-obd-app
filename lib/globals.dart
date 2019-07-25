import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:azsphere_obd_app/tabs/map/viewsettings.dart';

Settings appSettings;

class Settings {
  Settings() {
    restore();
  }

  final MapViewSettingsData mapViewSettingsData = MapViewSettingsData();

  restore() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    this.mapViewSettingsData.mapType = MapType.values[
        sp.getInt("mapViewSettingsData_mapType") ?? MapType.normal.index];
    this.mapViewSettingsData.showMyLocation =
        sp.getBool("mapViewSettingsData_showMyLocation") ?? true;
  }

  void save() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setInt(
        "mapViewSettingsData_mapType", this.mapViewSettingsData.mapType.index);
    sp.setBool("mapViewSettingsData_showMyLocation",
        this.mapViewSettingsData.showMyLocation);
  }
}

class MapViewSettingsData {
  MapViewSettingsData({this.showMyLocation, this.mapType});
  bool showMyLocation;
  // Normal, hybrid or terrain
  MapType mapType;
}
