import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../knowledge_graph/application/knowledge_graph_navigator.dart';
import '../../knowledge_graph/domain/remediation_plan.dart';
import '../../../core/app_providers.dart';

final prescriptionDetailControllerProvider = NotifierProvider<
    PrescriptionDetailController, RemediationPlan>(
  PrescriptionDetailController.new,
);

class PrescriptionDetailController extends Notifier<RemediationPlan> {
  @override
  RemediationPlan build() {
    throw UnimplementedError('PrescriptionDetailController must be overridden with a plan');
  }

  void focusStep(int index) {
    if (index < 0 || index >= state.steps.length) return;
    state = state.copyWith(focusedIndex: index);
  }

  void goBackToParent() {
    final currentStep = state.steps[state.focusedIndex];
    final parentId = currentStep.parentProblemId;
    if (parentId == null) return;
    final parentIndex = state.steps.indexWhere(
      (step) => step.problem.id == parentId,
    );
    if (parentIndex == -1) return;
    state = state.copyWith(focusedIndex: parentIndex);
  }

  void regeneratePlan(String problemId) {
    final graph = ref.read(knowledgeGraphProvider);
    final navigator = KnowledgeGraphNavigator(graph);
    state = navigator.buildRemediationPlan(problemId);
  }
}
