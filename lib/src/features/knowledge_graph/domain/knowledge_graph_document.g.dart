// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_graph_document.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KnowledgeGraphDocumentAdapter
    extends TypeAdapter<KnowledgeGraphDocument> {
  @override
  final int typeId = 3;

  @override
  KnowledgeGraphDocument read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KnowledgeGraphDocument(
      id: fields[0] as String,
      name: fields[1] as String,
      subject: fields[2] as String,
      grade: fields[3] as String,
      rootNodeIds: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, KnowledgeGraphDocument obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.subject)
      ..writeByte(3)
      ..write(obj.grade)
      ..writeByte(4)
      ..write(obj.rootNodeIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeGraphDocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
