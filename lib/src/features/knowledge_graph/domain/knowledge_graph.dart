import 'concept_node.dart';
import 'problem_node.dart';

class KnowledgeGraph {
  KnowledgeGraph({
    required List<ConceptNode> concepts,
    required List<ProblemNode> problems,
  })  : _conceptIndex = {for (final c in concepts) c.id: c},
        _problemIndex = {for (final p in problems) p.id: p},
        _problemsByConcept = _groupProblems(problems);

  final Map<String, ConceptNode> _conceptIndex;
  final Map<String, ProblemNode> _problemIndex;
  final Map<String, List<ProblemNode>> _problemsByConcept;

  ConceptNode? conceptById(String id) => _conceptIndex[id];

  ProblemNode? problemById(String id) => _problemIndex[id];

  List<ProblemNode> problemsForConcept(String conceptId) =>
      _problemsByConcept[conceptId] ?? const [];

  Iterable<ProblemNode> get allProblems => _problemIndex.values;

  static Map<String, List<ProblemNode>> _groupProblems(
    List<ProblemNode> problems,
  ) {
    final grouped = <String, List<ProblemNode>>{};
    for (final problem in problems) {
      grouped.putIfAbsent(problem.conceptId, () => []).add(problem);
    }
    for (final entry in grouped.entries) {
      entry.value.sort(
        (a, b) => a.difficulty.compareTo(b.difficulty),
      );
    }
    return grouped;
  }
}
