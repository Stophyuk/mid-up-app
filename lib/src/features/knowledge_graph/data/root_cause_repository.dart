import '../../../core/hive/hive_initializer.dart';
import '../domain/root_cause.dart';

abstract class RootCauseRepository {
  List<RootCause> findAll();
}

class HiveRootCauseRepository implements RootCauseRepository {
  HiveRootCauseRepository(this._hive);

  final HiveInitializer _hive;

  @override
  List<RootCause> findAll() => _hive.rootCauseBox.values.toList();
}
