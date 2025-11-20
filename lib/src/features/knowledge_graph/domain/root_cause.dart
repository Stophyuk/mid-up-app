import 'package:hive/hive.dart';

part 'root_cause.g.dart';

@HiveType(typeId: 4)
class RootCause {
  const RootCause({
    required this.id,
    required this.name,
    required this.description,
    required this.subject,
    required this.category,
    required this.severity,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String subject;

  @HiveField(4)
  final String category;

  /// Severity scale (1~5) from dataset.
  @HiveField(5)
  final int severity;
}
