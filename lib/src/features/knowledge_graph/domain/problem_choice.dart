import 'package:hive/hive.dart';

part 'problem_choice.g.dart';

@HiveType(typeId: 2)
class ProblemChoice {
  const ProblemChoice({
    required this.value,
    this.rootCauseId,
    this.explanation,
  });

  @HiveField(0)
  final String value;
  @HiveField(1)
  final String? rootCauseId;
  @HiveField(2)
  final String? explanation;
}
