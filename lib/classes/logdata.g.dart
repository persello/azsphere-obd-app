// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logdata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RawLogItemTypeAdapter extends TypeAdapter<RawLogItemType> {
  @override
  RawLogItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RawLogItemType.Initializer;
      case 1:
        return RawLogItemType.TimeUpdateBefore;
      case 2:
        return RawLogItemType.TimeUpdateAfter;
      case 3:
        return RawLogItemType.Latitude;
      case 4:
        return RawLogItemType.Longitude;
      case 5:
        return RawLogItemType.GPSSpeed;
      case 6:
        return RawLogItemType.GPSCourse;
      case 7:
        return RawLogItemType.EcuInitialization;
      case 8:
        return RawLogItemType.BatteryVoltage;
      case 9:
        return RawLogItemType.EngineTemperature;
      case 10:
        return RawLogItemType.EngineRPM;
      case 11:
        return RawLogItemType.Speed;
      case 12:
        return RawLogItemType.Airflow;
      case 13:
        return RawLogItemType.ThrottlePosition;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, RawLogItemType obj) {
    switch (obj) {
      case RawLogItemType.Initializer:
        writer.writeByte(0);
        break;
      case RawLogItemType.TimeUpdateBefore:
        writer.writeByte(1);
        break;
      case RawLogItemType.TimeUpdateAfter:
        writer.writeByte(2);
        break;
      case RawLogItemType.Latitude:
        writer.writeByte(3);
        break;
      case RawLogItemType.Longitude:
        writer.writeByte(4);
        break;
      case RawLogItemType.GPSSpeed:
        writer.writeByte(5);
        break;
      case RawLogItemType.GPSCourse:
        writer.writeByte(6);
        break;
      case RawLogItemType.EcuInitialization:
        writer.writeByte(7);
        break;
      case RawLogItemType.BatteryVoltage:
        writer.writeByte(8);
        break;
      case RawLogItemType.EngineTemperature:
        writer.writeByte(9);
        break;
      case RawLogItemType.EngineRPM:
        writer.writeByte(10);
        break;
      case RawLogItemType.Speed:
        writer.writeByte(11);
        break;
      case RawLogItemType.Airflow:
        writer.writeByte(12);
        break;
      case RawLogItemType.ThrottlePosition:
        writer.writeByte(13);
        break;
    }
  }
}

class LogSessionAdapter extends TypeAdapter<LogSession> {
  @override
  LogSession read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LogSession()
      ..rawTimedData = (fields[0] as List)?.cast<RawTimedItem>()
      ..startGmtDateTime = fields[1] as DateTime
      ..stopGmtDateTime = fields[2] as DateTime
      ..complete = fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, LogSession obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.rawTimedData)
      ..writeByte(1)
      ..write(obj.startGmtDateTime)
      ..writeByte(2)
      ..write(obj.stopGmtDateTime)
      ..writeByte(3)
      ..write(obj.complete);
  }
}

class RawTimedItemAdapter extends TypeAdapter<RawTimedItem> {
  @override
  RawTimedItem read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RawTimedItem()
      ..gmtDateTime = fields[0] as DateTime
      ..type = fields[1] as RawLogItemType
      ..numericContent = fields[2] as double
      ..textContent = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, RawTimedItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.gmtDateTime)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.numericContent)
      ..writeByte(3)
      ..write(obj.textContent);
  }
}
