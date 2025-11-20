// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_node.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProblemNodeAdapter extends TypeAdapter<ProblemNode> {
  @override
  final int typeId = 1;

  @override
  ProblemNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProblemNode(
      id: fields[0] as String,
      conceptId: fields[1] as String,
      prompt: fields[2] as String,
      childConceptIds: (fields[3] as List).cast<String>(),
      supportingSteps: (fields[4] as List).cast<String>(),
      difficulty: fields[5] as int,
      subject: fields[6] as String,
      grade: fields[7] as String,
      topic: fields[8] as String,
      correctAnswer: fields[9] as String,
      choices: (fields[10] as List).cast<ProblemChoice>(),
      questionImageUrl: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProblemNode obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.conceptId)
      ..writeByte(2)
      ..write(obj.prompt)
      ..writeByte(3)
      ..write(obj.childConceptIds)
      ..writeByte(4)
      ..write(obj.supportingSteps)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.subject)
      ..writeByte(7)
      ..write(obj.grade)
      ..writeByte(8)
      ..write(obj.topic)
      ..writeByte(9)
      ..write(obj.correctAnswer)
      ..writeByte(10)
      ..write(obj.choices)
      ..writeByte(11)
      ..write(obj.questionImageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
