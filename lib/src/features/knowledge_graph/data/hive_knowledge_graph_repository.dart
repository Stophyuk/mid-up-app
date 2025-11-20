import '../../../core/hive/hive_initializer.dart';
import '../domain/knowledge_graph.dart';
import '../domain/knowledge_graph_document.dart';

abstract class KnowledgeGraphRepository {
  KnowledgeGraph buildFullGraph();
  List<KnowledgeGraphDocument> availableDocuments();
}

class HiveKnowledgeGraphRepository implements KnowledgeGraphRepository {
  HiveKnowledgeGraphRepository(this._hive);

  final HiveInitializer _hive;

  @override
  KnowledgeGraph buildFullGraph() {
    return KnowledgeGraph(
      concepts: _hive.conceptBox.values.toList(),
      problems: _hive.problemBox.values.toList(),
    );
  }

  @override
  List<KnowledgeGraphDocument> availableDocuments() {
    return _hive.graphBox.values.toList();
  }
}
