import '../../knowledge_graph/domain/remediation_plan.dart';

enum PrescriptionTaskStatus { pending, completed, skipped }

class PrescriptionTask {
  const PrescriptionTask({
    required this.id,
    required this.problemId,
    required this.remediationPlan,
    required this.conceptId,
    required this.conceptName,
    required this.prompt,
    required this.depth,
    required this.weaknessConceptId,
    this.status = PrescriptionTaskStatus.pending,
  });

  final String id;
  final String problemId;
  final RemediationPlan remediationPlan;
  final String conceptId;
  final String conceptName;
  final String prompt;
  final int depth;
  final String weaknessConceptId;
  final PrescriptionTaskStatus status;

  PrescriptionTask copyWith({PrescriptionTaskStatus? status}) {
    return PrescriptionTask(
      id: id,
      problemId: problemId,
      conceptId: conceptId,
      remediationPlan: remediationPlan,
      conceptName: conceptName,
      prompt: prompt,
      depth: depth,
      weaknessConceptId: weaknessConceptId,
      status: status ?? this.status,
    );
  }
}
