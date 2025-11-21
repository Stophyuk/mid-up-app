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

    expect(find.text('오늘의 처방'), findsOneWidget);
    // 핵심 UI 요소가 보이는지만 확인 (문구 변경 시에도 유지되는 최소 체크)
    expect(find.text('코칭'), findsOneWidget);
    expect(find.text('노트'), findsOneWidget);
    expect(find.textContaining('문제 업로드'), findsOneWidget);
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
