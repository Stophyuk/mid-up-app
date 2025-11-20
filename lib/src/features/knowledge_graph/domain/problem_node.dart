import 'package:hive/hive.dart';

import 'problem_choice.dart';

part 'problem_node.g.dart';

@HiveType(typeId: 1)
class ProblemNode {
  const ProblemNode({
    required this.id,
    required this.conceptId,
    required this.prompt,
    this.childConceptIds = const [],
    this.supportingSteps = const [],
    this.difficulty = 1,
    required this.subject,
    required this.grade,
    required this.topic,
    required this.correctAnswer,
    this.choices = const [],
    this.questionImageUrl,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String conceptId;
  @HiveField(2)
  final String prompt;
  @HiveField(3)
  final List<String> childConceptIds;
  @HiveField(4)
  final List<String> supportingSteps;
  @HiveField(5)
  final int difficulty;
  @HiveField(6)
  final String subject;
  @HiveField(7)
  final String grade;
  @HiveField(8)
  final String topic;
  @HiveField(9)
  final String correctAnswer;
  @HiveField(10)
  final List<ProblemChoice> choices;
  @HiveField(11)
  final String? questionImageUrl;
}
