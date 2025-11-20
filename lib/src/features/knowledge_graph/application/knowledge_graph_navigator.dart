import '../domain/knowledge_graph.dart';
import '../domain/remediation_plan.dart';

class KnowledgeGraphNavigator {
  KnowledgeGraphNavigator(this._graph);

  final KnowledgeGraph _graph;

  RemediationPlan buildRemediationPlan(String problemId) {
    final visitedConcepts = <String>{};
    final visitedProblems = <String>{};
    final steps = <RemediationStep>[];
    bool isLoopDetected = false;

    final rootProblem = _graph.problemById(problemId);
    if (rootProblem == null) {
      return RemediationPlan(rootProblemId: problemId, steps: const []);
    }

    void dfs(
      String currentProblemId,
      int depth, {
      String? parentProblemId,
    }) {
      final problem = _graph.problemById(currentProblemId);
      if (problem == null) {
        return;
      }
      if (!visitedProblems.add(problem.id)) {
        isLoopDetected = true;
        return;
      }
      steps.add(
        RemediationStep(
          depth: depth,
          problem: problem,
          parentProblemId: parentProblemId,
        ),
      );

      for (final conceptId in problem.childConceptIds) {
        if (!visitedConcepts.add(conceptId)) {
          isLoopDetected = true;
          continue;
        }
        final remedialProblem = _graph.problemsForConcept(conceptId).firstOrNull;
        if (remedialProblem == null) {
          continue;
        }
        dfs(
          remedialProblem.id,
          depth + 1,
          parentProblemId: problem.id,
        );
      }
    }

    dfs(rootProblem.id, 0);

    return RemediationPlan(
      rootProblemId: problemId,
      steps: steps,
      isLoopDetected: isLoopDetected,
      focusedIndex: 0,
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
