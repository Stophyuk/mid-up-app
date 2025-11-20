import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/core/app_providers.dart';
import 'src/core/hive/hive_initializer.dart';
import 'src/features/knowledge_graph/data/hive_knowledge_graph_repository.dart';
import 'src/features/knowledge_graph/data/root_cause_repository.dart';
import 'src/features/seeding/data_zip_seeder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hive = HiveInitializer();
  await hive.init();
  final seeder = DataZipSeeder(
    assetBundle: rootBundle,
    hive: hive,
  );
  await seeder.seedIfNeeded();
  final repository = HiveKnowledgeGraphRepository(hive);
  final rootCauseRepository = HiveRootCauseRepository(hive);
  runApp(
    ProviderScope(
      overrides: [
        knowledgeGraphRepositoryProvider.overrideWithValue(repository),
        rootCauseRepositoryProvider.overrideWithValue(rootCauseRepository),
      ],
      child: const MidUpApp(),
    ),
  );
}
