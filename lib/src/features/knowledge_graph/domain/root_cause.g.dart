// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_cause.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RootCauseAdapter extends TypeAdapter<RootCause> {
  @override
  final int typeId = 4;

  @override
  RootCause read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RootCause(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      subject: fields[3] as String,
      category: fields[4] as String,
      severity: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RootCause obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.subject)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.severity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RootCauseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
