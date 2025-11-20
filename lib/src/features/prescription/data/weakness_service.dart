import 'dart:math' as math;

import '../../knowledge_graph/domain/knowledge_graph.dart';
import '../../knowledge_graph/domain/knowledge_graph_document.dart';
import '../../knowledge_graph/domain/problem_node.dart';
import '../../knowledge_graph/domain/root_cause.dart';
import '../domain/weakness.dart';

class WeaknessService {
  const WeaknessService();

  List<Weakness> buildDefaultWeaknesses({
    required KnowledgeGraph graph,
    required List<KnowledgeGraphDocument> documents,
    required Map<String, RootCause> rootCauseMap,
    int limit = 3,
  }) {
    final conceptScores = _calculateConceptScores(graph, rootCauseMap);
    if (conceptScores.isEmpty) {
      return _fallbackWeaknesses(graph);
    }

    final docPriority = _buildDocPriority(documents);
    final sorted = conceptScores.entries.toList()
      ..sort((a, b) {
        final compareScore = b.value.compareTo(a.value);
        if (compareScore != 0) return compareScore;
        final priorityA = docPriority[a.key] ?? 1 << 20;
        final priorityB = docPriority[b.key] ?? 1 << 20;
        return priorityA.compareTo(priorityB);
      });

    final weaknesses = <Weakness>[];
    for (final entry in sorted) {
      final concept = graph.conceptById(entry.key);
      if (concept == null) continue;
      weaknesses.add(
        Weakness(
          conceptId: concept.id,
          conceptName: concept.title,
          severity: double.parse(entry.value.clamp(0, 1).toStringAsFixed(2)),
        ),
      );
      if (weaknesses.length >= limit) break;
    }

    return weaknesses.isEmpty ? _fallbackWeaknesses(graph) : weaknesses;
  }

  Map<String, double> _calculateConceptScores(
    KnowledgeGraph graph,
    Map<String, RootCause> rootCauseMap,
  ) {
    if (rootCauseMap.isEmpty) return const {};
    final scores = <String, double>{};
    for (final problem in graph.allProblems) {
      final severity = _problemSeverity(problem, rootCauseMap);
      if (severity <= 0) continue;
      scores.update(
        problem.conceptId,
        (value) => value + severity,
        ifAbsent: () => severity,
      );
    }
    if (scores.isEmpty) {
      return const {};
    }
    final maxScore = scores.values.reduce(math.max);
    if (maxScore <= 0) return const {};
    return scores.map(
      (key, value) => MapEntry(key, value / maxScore),
    );
  }

  double _problemSeverity(
    ProblemNode problem,
    Map<String, RootCause> rootCauseMap,
  ) {
    double score = 0;
    for (final choice in problem.choices) {
      final causeId = choice.rootCauseId;
      if (causeId == null) continue;
      final cause = rootCauseMap[causeId];
      if (cause == null) continue;
      score += cause.severity.clamp(1, 5) / 5;
    }
    return score;
  }

  Map<String, int> _buildDocPriority(
    List<KnowledgeGraphDocument> documents,
  ) {
    final map = <String, int>{};
    var index = 0;
    for (final doc in documents) {
      for (final conceptId in doc.rootNodeIds) {
        map.putIfAbsent(conceptId, () => index++);
      }
    }
    return map;
  }

  List<Weakness> _fallbackWeaknesses(KnowledgeGraph graph) {
    if (graph.allProblems.isEmpty) {
      return const [];
    }
    final conceptId = graph.allProblems.first.conceptId;
    final concept = graph.conceptById(conceptId);
    return [
      Weakness(
        conceptId: conceptId,
        conceptName: concept?.title ?? 'Unassigned',
        severity: 1.0,
      ),
    ];
  }
}
