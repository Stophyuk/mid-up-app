// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mid_up_app/src/app.dart';
import 'package:mid_up_app/src/core/app_providers.dart';
import 'package:mid_up_app/src/features/knowledge_graph/data/hive_knowledge_graph_repository.dart';
import 'package:mid_up_app/src/features/knowledge_graph/domain/knowledge_graph.dart';
import 'package:mid_up_app/src/features/knowledge_graph/domain/knowledge_graph_document.dart';
import 'package:mid_up_app/src/sample_data/sample_graph.dart';

void main() {
  testWidgets('renders remediation debugger', (tester) async {
    final repo = _FakeGraphRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          knowledgeGraphRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MidUpApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('오늘의 처방'), findsOneWidget);
    expect(find.textContaining('인수분해'), findsWidgets);
  });
}

class _FakeGraphRepository implements KnowledgeGraphRepository {
  _FakeGraphRepository() : _graph = buildSampleKnowledgeGraph();

  final _graphDoc = const KnowledgeGraphDocument(
    id: 'sample',
    name: '샘플',
    subject: '수학',
    grade: '중3',
    rootNodeIds: ['MATH_HIGH1_QUADRATIC_FACTORING'],
  );

  final KnowledgeGraph _graph;

  @override
  KnowledgeGraph buildFullGraph() => _graph;

  @override
  List<KnowledgeGraphDocument> availableDocuments() => [_graphDoc];
}
