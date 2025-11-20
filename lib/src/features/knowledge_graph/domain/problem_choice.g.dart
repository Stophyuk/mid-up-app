// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_choice.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProblemChoiceAdapter extends TypeAdapter<ProblemChoice> {
  @override
  final int typeId = 2;

  @override
  ProblemChoice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProblemChoice(
      value: fields[0] as String,
      rootCauseId: fields[1] as String?,
      explanation: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProblemChoice obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.rootCauseId)
      ..writeByte(2)
      ..write(obj.explanation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemChoiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
