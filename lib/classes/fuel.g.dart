// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FuelAdapter extends TypeAdapter<Fuel> {
  @override
  final int typeId = 0;

  @override
  Fuel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Fuel(
      name: fields[0] as String,
      massAirFuelRatio: fields[1] as double,
      density: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Fuel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.massAirFuelRatio)
      ..writeByte(2)
      ..write(obj.density);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FuelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
