import 'package:test/test.dart';
import 'package:mid_up_app/src/features/knowledge_graph/application/knowledge_graph_navigator.dart';
import 'package:mid_up_app/src/features/knowledge_graph/domain/concept_node.dart';
import 'package:mid_up_app/src/features/knowledge_graph/domain/knowledge_graph.dart';
import 'package:mid_up_app/src/features/knowledge_graph/domain/problem_node.dart';
import 'package:mid_up_app/src/sample_data/sample_graph.dart';

void main() {
  group('KnowledgeGraphNavigator', () {
    test('builds remediation path using DFS order', () {
      final navigator = KnowledgeGraphNavigator(buildSampleKnowledgeGraph());

      final plan = navigator.buildRemediationPlan('PROB-QUAD-01');

      expect(plan.steps, hasLength(4));
      expect(plan.steps.first.problem.id, 'PROB-QUAD-01');
      expect(plan.steps[1].problem.id, 'PROB-CF-01');
      expect(plan.steps[2].problem.id, 'PROB-MUL-01');
      expect(plan.steps[3].problem.id, 'PROB-SIGN-01');
      expect(plan.isLoopDetected, isFalse);
    });

    test('detects loops in the graph', () {
      final graph = KnowledgeGraph(
        concepts: const [
          ConceptNode(id: 'A', title: 'A', childIds: ['B']),
          ConceptNode(id: 'B', title: 'B', childIds: ['A']),
        ],
        problems: const [
          ProblemNode(
            id: 'P1',
            conceptId: 'A',
            prompt: 'A',
            childConceptIds: ['B'],
            subject: '수학',
            grade: '중3',
            topic: '테스트',
            correctAnswer: '1',
            choices: [],
          ),
          ProblemNode(
            id: 'P2',
            conceptId: 'B',
            prompt: 'B',
            childConceptIds: ['A'],
            subject: '수학',
            grade: '중3',
            topic: '테스트',
            correctAnswer: '1',
            choices: [],
          ),
        ],
      );

      final navigator = KnowledgeGraphNavigator(graph);
      final plan = navigator.buildRemediationPlan('P1');

      expect(plan.isLoopDetected, isTrue);
    });
  });
}
