import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_providers.dart';
import '../data/weakness_service.dart';
import '../domain/daily_prescription.dart';
import '../domain/prescription_task.dart';
import 'prescription_engine.dart';

final weaknessServiceProvider = Provider((ref) => const WeaknessService());
final prescriptionEngineProvider =
    Provider((ref) => const PrescriptionEngine());

final dailyPrescriptionControllerProvider =
    AsyncNotifierProvider<DailyPrescriptionController, DailyPrescription>(
  DailyPrescriptionController.new,
);

class DailyPrescriptionController
    extends AsyncNotifier<DailyPrescription> {
  @override
  Future<DailyPrescription> build() async {
    return _generatePlan();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _generatePlan());
  }

  void toggleTaskStatus(String taskId) {
    final current = state.valueOrNull;
    if (current == null) return;
    final updatedTasks = current.tasks.map((task) {
      if (task.id != taskId) return task;
      final newStatus =
          task.status == PrescriptionTaskStatus.completed
              ? PrescriptionTaskStatus.pending
              : PrescriptionTaskStatus.completed;
      return task.copyWith(status: newStatus);
    }).toList();
    state = AsyncData(current.copyWith(tasks: updatedTasks));
  }

  bool gradeTask(String taskId, String answer) {
    final current = state.valueOrNull;
    if (current == null) return false;
    final graph = ref.read(knowledgeGraphProvider);
    final tasks = current.tasks;
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return false;
    final task = tasks[idx];
    final problem = graph.problemById(task.problemId);
    if (problem == null) return false;
    final correct = problem.correctAnswer.trim().toLowerCase();
    final user = answer.trim().toLowerCase();
    final isCorrect = user == correct || user == problem.prompt.trim().toLowerCase();
    final updated = [
      for (final t in tasks)
        if (t.id == taskId)
          t.copyWith(
            status: isCorrect
                ? PrescriptionTaskStatus.completed
                : PrescriptionTaskStatus.pending,
          )
        else
          t,
    ];
    state = AsyncData(current.copyWith(tasks: updated));
    return isCorrect;
  }

  Future<DailyPrescription> _generatePlan() async {
    final graph = ref.read(knowledgeGraphProvider);
    final docs = ref.read(knowledgeGraphDocumentsProvider);
    final rootCauses = ref.read(rootCauseMapProvider);
    final weaknesses = ref
        .read(weaknessServiceProvider)
        .buildDefaultWeaknesses(
          graph: graph,
          documents: docs,
          rootCauseMap: rootCauses,
        );
    final engine = ref.read(prescriptionEngineProvider);
    return engine.generate(
      graph: graph,
      weaknesses: weaknesses,
    );
  }
}
