// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'globals.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MapViewSettingsDataAdapter extends TypeAdapter<MapViewSettingsData> {
  @override
  MapViewSettingsData read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MapViewSettingsData(
      showMyLocation: fields[0] as bool,
      mapType: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MapViewSettingsData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.showMyLocation)
      ..writeByte(1)
      ..write(obj.mapType);
  }
}
