import 'package:hive/hive.dart';

part 'knowledge_graph_document.g.dart';

@HiveType(typeId: 3)
class KnowledgeGraphDocument {
  const KnowledgeGraphDocument({
    required this.id,
    required this.name,
    required this.subject,
    required this.grade,
    required this.rootNodeIds,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String subject;
  @HiveField(3)
  final String grade;
  @HiveField(4)
  final List<String> rootNodeIds;
}
