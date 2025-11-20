import 'prescription_task.dart';
import 'weakness.dart';

class DailyPrescription {
  const DailyPrescription({
    required this.generatedAt,
    required this.tasks,
    required this.weaknesses,
  });

  final DateTime generatedAt;
  final List<PrescriptionTask> tasks;
  final List<Weakness> weaknesses;

  double get completionRatio {
    if (tasks.isEmpty) return 0;
    final completed = tasks.where(
      (task) => task.status == PrescriptionTaskStatus.completed,
    );
    return completed.length / tasks.length;
  }

  DailyPrescription copyWith({
    List<PrescriptionTask>? tasks,
  }) {
    return DailyPrescription(
      generatedAt: generatedAt,
      tasks: tasks ?? this.tasks,
      weaknesses: weaknesses,
    );
  }
}
