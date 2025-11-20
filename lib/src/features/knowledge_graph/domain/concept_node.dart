import 'package:hive/hive.dart';

part 'concept_node.g.dart';

@HiveType(typeId: 0)
class ConceptNode {
  const ConceptNode({
    required this.id,
    required this.title,
    this.parentId,
    this.childIds = const [],
    this.description,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? parentId;
  @HiveField(3)
  final List<String> childIds;
  @HiveField(4)
  final String? description;

  ConceptNode copyWith({
    String? id,
    String? title,
    String? parentId,
    List<String>? childIds,
    String? description,
  }) {
    return ConceptNode(
      id: id ?? this.id,
      title: title ?? this.title,
      parentId: parentId ?? this.parentId,
      childIds: childIds ?? this.childIds,
      description: description ?? this.description,
    );
  }
}
