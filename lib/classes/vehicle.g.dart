// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  Vehicle read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
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
}

class RemoteFileAdapter extends TypeAdapter<RemoteFile> {
  @override
  RemoteFile read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RemoteFile()
      ..name = fields[0] as String
      ..size = fields[1] as int
      ..downloadedBytes = fields[2] as int;
  }

  @override
  void write(BinaryWriter writer, RemoteFile obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.size)
      ..writeByte(2)
      ..write(obj.downloadedBytes);
  }
}
