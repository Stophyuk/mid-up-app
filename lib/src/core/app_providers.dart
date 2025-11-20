import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/knowledge_graph/data/hive_knowledge_graph_repository.dart';
import '../features/knowledge_graph/data/root_cause_repository.dart';
import '../features/knowledge_graph/domain/knowledge_graph.dart';
import '../features/knowledge_graph/domain/knowledge_graph_document.dart';
import '../features/knowledge_graph/domain/root_cause.dart';

final knowledgeGraphRepositoryProvider = Provider<KnowledgeGraphRepository>(
  (ref) => throw UnimplementedError('KnowledgeGraphRepository has not been provided'),
);

final knowledgeGraphProvider = Provider<KnowledgeGraph>(
  (ref) => ref.watch(knowledgeGraphRepositoryProvider).buildFullGraph(),
);

final knowledgeGraphDocumentsProvider = Provider<List<KnowledgeGraphDocument>>(
  (ref) => ref.watch(knowledgeGraphRepositoryProvider).availableDocuments(),
);

final rootCauseRepositoryProvider = Provider<RootCauseRepository>(
  (ref) => throw UnimplementedError('RootCauseRepository has not been provided'),
);

final rootCauseMapProvider = Provider<Map<String, RootCause>>((ref) {
  final repo = ref.watch(rootCauseRepositoryProvider);
  final map = <String, RootCause>{};
  for (final cause in repo.findAll()) {
    map[cause.id] = cause;
  }
  return map;
});
