import 'package:hive_flutter/hive_flutter.dart';

import '../../features/knowledge_graph/domain/concept_node.dart';
import '../../features/knowledge_graph/domain/knowledge_graph_document.dart';
import '../../features/knowledge_graph/domain/problem_choice.dart';
import '../../features/knowledge_graph/domain/problem_node.dart';
import '../../features/knowledge_graph/domain/root_cause.dart';
import 'hive_boxes.dart';

class HiveInitializer {
  Box<ConceptNode>? _conceptBox;
  Box<ProblemNode>? _problemBox;
  Box<KnowledgeGraphDocument>? _graphBox;
  Box<dynamic>? _metadataBox;
  Box<RootCause>? _rootCauseBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive
      ..registerAdapter(ConceptNodeAdapter())
      ..registerAdapter(ProblemNodeAdapter())
      ..registerAdapter(ProblemChoiceAdapter())
      ..registerAdapter(KnowledgeGraphDocumentAdapter())
      ..registerAdapter(RootCauseAdapter());

    _conceptBox = await Hive.openBox<ConceptNode>(HiveBoxes.concepts);
    _problemBox = await Hive.openBox<ProblemNode>(HiveBoxes.problems);
    _graphBox = await Hive.openBox<KnowledgeGraphDocument>(
      HiveBoxes.knowledgeGraphs,
    );
    _metadataBox = await Hive.openBox<dynamic>(HiveBoxes.metadata);
    _rootCauseBox = await Hive.openBox<RootCause>(HiveBoxes.rootCauses);
  }

  Box<ConceptNode> get conceptBox => _conceptBox!;
  Box<ProblemNode> get problemBox => _problemBox!;
  Box<KnowledgeGraphDocument> get graphBox => _graphBox!;
  Box<dynamic> get metadataBox => _metadataBox!;
  Box<RootCause> get rootCauseBox => _rootCauseBox!;

  Future<void> dispose() async {
    await Hive.close();
  }
}
