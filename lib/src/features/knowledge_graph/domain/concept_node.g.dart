// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concept_node.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConceptNodeAdapter extends TypeAdapter<ConceptNode> {
  @override
  final int typeId = 0;

  @override
  ConceptNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConceptNode(
      id: fields[0] as String,
      title: fields[1] as String,
      parentId: fields[2] as String?,
      childIds: (fields[3] as List).cast<String>(),
      description: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ConceptNode obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.parentId)
      ..writeByte(3)
      ..write(obj.childIds)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConceptNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
