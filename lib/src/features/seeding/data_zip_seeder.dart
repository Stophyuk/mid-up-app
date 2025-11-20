import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../core/hive/hive_initializer.dart';
import '../knowledge_graph/domain/concept_node.dart';
import '../knowledge_graph/domain/knowledge_graph_document.dart';
import '../knowledge_graph/domain/problem_choice.dart';
import '../knowledge_graph/domain/problem_node.dart';
import '../knowledge_graph/domain/root_cause.dart';

class DataZipSeeder {
  DataZipSeeder({
    required this.assetBundle,
    required this.hive,
    this.assetPath = 'assets/data/data.zip',
    this.seedVersion = 1,
  });

  final AssetBundle assetBundle;
  final HiveInitializer hive;
  final String assetPath;
  final int seedVersion;

  static const _seedKey = 'seed_version';

  Future<bool> seedIfNeeded() async {
    final currentVersion = (hive.metadataBox.get(_seedKey) as int?) ?? 0;
    if (currentVersion >= seedVersion) {
      return false;
    }

    final archive = await _loadArchive();
    final diagnosticProblems = <String, Map<String, dynamic>>{};
    final conceptRecords = <String, ConceptNode>{};
    final problemRecords = <String, ProblemNode>{};
    final knowledgeDocs = <String, KnowledgeGraphDocument>{};
    final knowledgePayloads = <String>[];
    final rootCauseRecords = <String, RootCause>{};

    for (final file in archive.files) {
      if (!file.isFile) continue;
      final fileName = p.basename(file.name);
      if (!fileName.endsWith('.json')) continue;
      final payload = utf8.decode(file.content as List<int>);
      if (fileName == 'root_causes.json') {
        _parseRootCauses(payload, rootCauseRecords);
      } else if (fileName.startsWith('diagnostic_problems')) {
        _parseDiagnosticProblems(payload, diagnosticProblems);
      } else if (fileName.startsWith('knowledge_graph')) {
        knowledgePayloads.add(payload);
      }
    }

    for (final payload in knowledgePayloads) {
      _parseKnowledgeGraph(
        payload: payload,
        conceptRecords: conceptRecords,
        problemRecords: problemRecords,
        diagnosticLookup: diagnosticProblems,
        docSink: knowledgeDocs,
      );
    }

    await Future.wait([
      hive.conceptBox.clear(),
      hive.problemBox.clear(),
      hive.graphBox.clear(),
      hive.rootCauseBox.clear(),
    ]);

    await hive.conceptBox.putAll(
      {for (final entry in conceptRecords.entries) entry.key: entry.value},
    );
    await hive.problemBox.putAll(
      {for (final entry in problemRecords.entries) entry.key: entry.value},
    );
    await hive.graphBox.putAll(
      {for (final entry in knowledgeDocs.entries) entry.key: entry.value},
    );
    if (rootCauseRecords.isNotEmpty) {
      await hive.rootCauseBox.putAll(
        {for (final entry in rootCauseRecords.entries) entry.key: entry.value},
      );
    }

    await hive.metadataBox.put(_seedKey, seedVersion);
    return true;
  }

  Future<Archive> _loadArchive() async {
    final byteData = await assetBundle.load(assetPath);
    final buffer = byteData.buffer.asUint8List();
    return ZipDecoder().decodeBytes(buffer);
  }

  void _parseDiagnosticProblems(
    String payload,
    Map<String, Map<String, dynamic>> sink,
  ) {
    final decoded = jsonDecode(payload);
    if (decoded is List) {
      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) {
          final id = entry['id']?.toString();
          if (id == null) continue;
          sink[id] = entry;
        }
      }
    }
  }

  void _parseKnowledgeGraph({
    required String payload,
    required Map<String, ConceptNode> conceptRecords,
    required Map<String, ProblemNode> problemRecords,
    required Map<String, Map<String, dynamic>> diagnosticLookup,
    required Map<String, KnowledgeGraphDocument> docSink,
  }) {
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) return;

    final doc = KnowledgeGraphDocument(
      id: decoded['id']?.toString() ?? '',
      name: decoded['name']?.toString() ?? 'Unknown',
      subject: decoded['subject']?.toString() ?? 'Math',
      grade: decoded['grade']?.toString() ?? 'unknown',
      rootNodeIds: _stringList(decoded['rootNodeIds']),
    );
    if (doc.id.isNotEmpty) {
      docSink[doc.id] = doc;
    }

    final nodes = decoded['nodes'];
    if (nodes is! Map<String, dynamic>) return;

    for (final entry in nodes.entries) {
      final data = entry.value;
      if (data is! Map<String, dynamic>) continue;
      final concept = ConceptNode(
        id: data['id']?.toString() ?? entry.key,
        title: data['name']?.toString() ?? 'Concept',
        parentId: data['parentId']?.toString(),
        childIds: _stringList(data['childIds']),
        description: data['description']?.toString(),
      );
      conceptRecords[concept.id] = concept;

      final relatedProblems = _stringList(data['relatedProblemIds']);
      for (final problemId in relatedProblems) {
        final raw = diagnosticLookup[problemId];
        if (raw == null) continue;
        problemRecords[problemId] = ProblemNode(
          id: problemId,
          conceptId: concept.id,
          prompt: raw['questionText']?.toString() ?? 'Problem unavailable',
          childConceptIds: concept.childIds,
          supportingSteps: const [],
          difficulty: _intFrom(raw['difficulty']) ?? data['level'] as int? ?? 1,
          subject: raw['subject']?.toString() ?? doc.subject,
          grade: raw['grade']?.toString() ?? doc.grade,
          topic: raw['topic']?.toString() ?? concept.title,
          correctAnswer: raw['correctAnswer']?.toString() ?? '',
          choices: _buildChoices(raw['distractors'], raw['correctAnswer']),
          questionImageUrl: raw['questionImageUrl']?.toString(),
        );
      }
    }
  }

  void _parseRootCauses(
    String payload,
    Map<String, RootCause> sink,
  ) {
    final decoded = jsonDecode(payload);
    if (decoded is! List) return;
    for (final entry in decoded) {
      if (entry is! Map<String, dynamic>) continue;
      final id = entry['id']?.toString();
      if (id == null) continue;
      sink[id] = RootCause(
        id: id,
        name: entry['name']?.toString() ?? 'Unknown',
        description: entry['description']?.toString() ?? '',
        subject: entry['subject']?.toString() ?? 'Math',
        category: entry['category']?.toString() ?? 'general',
        severity: _intFrom(entry['severity']) ?? 1,
      );
    }
  }

  List<String> _stringList(dynamic data) {
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return const [];
  }

  int? _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<ProblemChoice> _buildChoices(dynamic distractors, dynamic correct) {
    final results = <ProblemChoice>[];
    if (correct != null) {
      results.add(ProblemChoice(value: correct.toString()));
    }
    if (distractors is List) {
      for (final entry in distractors) {
        if (entry is Map<String, dynamic>) {
          results.add(
            ProblemChoice(
              value: entry['value']?.toString() ?? '',
              rootCauseId: entry['rootCauseId']?.toString(),
              explanation: entry['explanation']?.toString(),
            ),
          );
        }
      }
    }
    return results;
  }
}
