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
    )..imagePath = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj.brand)
      ..writeByte(2)
      ..write(obj.model)
      ..writeByte(3)
      ..write(obj.vin)
      ..writeByte(4)
      ..write(obj.fuel);
  }
}
