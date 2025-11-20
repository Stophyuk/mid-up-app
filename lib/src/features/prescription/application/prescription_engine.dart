import '../../knowledge_graph/application/knowledge_graph_navigator.dart';
import '../../knowledge_graph/domain/knowledge_graph.dart';
import '../../knowledge_graph/domain/remediation_plan.dart';
import '../domain/daily_prescription.dart';
import '../domain/prescription_task.dart';
import '../domain/weakness.dart';

class PrescriptionEngine {
  const PrescriptionEngine();

  DailyPrescription generate({
    required KnowledgeGraph graph,
    required List<Weakness> weaknesses,
    int minTasks = 3,
    int maxTasks = 5,
  }) {
    final navigator = KnowledgeGraphNavigator(graph);
    final sortedWeaknesses = [...weaknesses]
      ..sort((a, b) => b.severity.compareTo(a.severity));
    final tasks = <PrescriptionTask>[];
    final seenProblems = <String>{};

    for (final weakness in sortedWeaknesses) {
      final conceptProblems = graph.problemsForConcept(weakness.conceptId);
      if (conceptProblems.isEmpty) continue;

      final RemediationPlan plan =
          navigator.buildRemediationPlan(conceptProblems.first.id);
      for (final step in plan.steps) {
        if (!seenProblems.add(step.problem.id)) {
          continue;
        }
        tasks.add(
          PrescriptionTask(
            id: '${weakness.conceptId}-${step.problem.id}-${step.depth}',
            problemId: step.problem.id,
            remediationPlan: plan.copyWith(focusedIndex: plan.steps.indexOf(step)),
            conceptId: step.problem.conceptId,
            conceptName: graph.conceptById(step.problem.conceptId)?.title ??
                weakness.conceptName,
            prompt: step.problem.prompt,
            depth: step.depth,
            weaknessConceptId: weakness.conceptId,
          ),
        );
        if (tasks.length >= maxTasks) {
          break;
        }
      }
      if (tasks.length >= maxTasks) break;
    }

    if (tasks.length < minTasks) {
      for (final problem in graph.allProblems) {
        if (seenProblems.contains(problem.id)) continue;
        tasks.add(
          PrescriptionTask(
            id: 'fallback-${problem.id}',
            problemId: problem.id,
            remediationPlan: RemediationPlan(
              rootProblemId: problem.id,
              steps: [
                RemediationStep(
                  depth: 0,
                  problem: problem,
                ),
              ],
              isLoopDetected: false,
              focusedIndex: 0,
            ),
            conceptId: problem.conceptId,
            conceptName: graph.conceptById(problem.conceptId)?.title ??
                problem.conceptId,
            prompt: problem.prompt,
            depth: 0,
            weaknessConceptId: problem.conceptId,
          ),
        );
        if (tasks.length >= minTasks) break;
      }
    }

    return DailyPrescription(
      generatedAt: DateTime.now(),
      tasks: tasks.take(maxTasks).toList(),
      weaknesses: sortedWeaknesses,
    );
  }
}
