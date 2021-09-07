// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 2;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      brand: fields[1] as String,
      model: fields[2] as String,
      vin: fields[3] as String,
      fuel: fields[4] as Fuel,
    )
      ..imagePath = fields[0] as String
      ..logSessions = (fields[5] as List)?.cast<LogSession>()
      ..knownFiles = (fields[6] as List)?.cast<RemoteFile>();
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj.brand)
      ..writeByte(2)
      ..write(obj.model)
      ..writeByte(3)
      ..write(obj.vin)
      ..writeByte(4)
      ..write(obj.fuel)
      ..writeByte(5)
      ..write(obj.logSessions)
      ..writeByte(6)
      ..write(obj.knownFiles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RemoteFileAdapter extends TypeAdapter<RemoteFile> {
  @override
  final int typeId = 5;

  @override
  RemoteFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RemoteFile(
      name: fields[0] as String,
      size: fields[1] as int,
    )
      ..downloadedBytes = fields[2] as int
      ..parsed = fields[3] as bool
      ..content = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, RemoteFile obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.size)
      ..writeByte(2)
      ..write(obj.downloadedBytes)
      ..writeByte(3)
      ..write(obj.parsed)
      ..writeByte(4)
      ..write(obj.content);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoteFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
