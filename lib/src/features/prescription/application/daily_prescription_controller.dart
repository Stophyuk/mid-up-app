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
