// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'globals.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MapViewSettingsDataAdapter extends TypeAdapter<MapViewSettingsData> {
  @override
  final int typeId = 6;

  @override
  MapViewSettingsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MapViewSettingsData(
      showMyLocation: fields[0] as bool,
      mapType: fields[1] as int,
      mapDataType: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MapViewSettingsData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.showMyLocation)
      ..writeByte(1)
      ..write(obj.mapType)
      ..writeByte(2)
      ..write(obj.mapDataType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapViewSettingsDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
