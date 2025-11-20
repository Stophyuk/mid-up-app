import 'problem_node.dart';

class RemediationStep {
  const RemediationStep({
    required this.depth,
    required this.problem,
    this.parentProblemId,
  });

  final int depth;
  final ProblemNode problem;
  final String? parentProblemId;
}

class RemediationPlan {
  const RemediationPlan({
    required this.rootProblemId,
    required this.steps,
    this.isLoopDetected = false,
    this.focusedIndex = 0,
  });

  final String rootProblemId;
  final List<RemediationStep> steps;
  final bool isLoopDetected;
  final int focusedIndex;

  bool get hasRemediation => steps.length > 1;

  RemediationPlan copyWith({int? focusedIndex}) {
    return RemediationPlan(
      rootProblemId: rootProblemId,
      steps: steps,
      isLoopDetected: isLoopDetected,
      focusedIndex: focusedIndex ?? this.focusedIndex,
    );
  }
}
