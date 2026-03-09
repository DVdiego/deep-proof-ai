import 'dart:io';

import 'package:ai_authenticity_mobile/src/core/entitlement/entitlement_state.dart';
import 'package:ai_authenticity_mobile/src/core/history/execute_history_repository.dart';
import 'package:ai_authenticity_mobile/src/core/history/history_entry.dart';
import 'package:ai_authenticity_mobile/src/core/history/history_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late HistoryStore store;
  late ExecuteHistoryRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('execute_history_repo_test');
    store = HistoryStore(
      executeHistoryFile: File('${tempDir.path}/execute.jsonl'),
      compareHistoryFile: File('${tempDir.path}/compare.jsonl'),
    );
    repository = ExecuteHistoryRepository(store: store);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  ExecuteHistoryEntry buildEntry({
    required String id,
    required String fingerprint,
    required DateTime timestamp,
    required double probability,
  }) {
    return ExecuteHistoryEntry(
      entryId: id,
      fileName: '2.png',
      timestamp: timestamp,
      schemaVersion: 'image_features_v2',
      filePath: '/tmp/2.png',
      analysisFingerprint: fingerprint,
      decisionCode: 'AILikely',
      decisionLabel: 'Likely AI-generated',
      aiProbability: probability,
      rawScore: probability / 100,
      explanation: 'cached',
      modelVersion: 'image_featurenet_v1',
    );
  }

  test('listVisibleEntries keeps the latest entry for the same fingerprint', () async {
    await repository.add(buildEntry(
      id: 'one',
      fingerprint: 'same-fingerprint',
      timestamp: DateTime.utc(2026, 3, 9, 9, 0),
      probability: 91,
    ));
    await repository.add(buildEntry(
      id: 'two',
      fingerprint: 'same-fingerprint',
      timestamp: DateTime.utc(2026, 3, 9, 10, 0),
      probability: 93,
    ));

    final visible = await repository.listVisibleEntries(EntitlementTier.professional);

    expect(visible, hasLength(1));
    expect(visible.single.entryId, 'two');
    expect(visible.single.aiProbability, 93);
  });

  test('findLatestReusableByFingerprint returns the latest cached entry', () async {
    await repository.add(buildEntry(
      id: 'one',
      fingerprint: 'fingerprint-a',
      timestamp: DateTime.utc(2026, 3, 9, 9, 0),
      probability: 81.2,
    ));
    await repository.add(buildEntry(
      id: 'two',
      fingerprint: 'fingerprint-b',
      timestamp: DateTime.utc(2026, 3, 9, 9, 30),
      probability: 52,
    ));
    await repository.add(buildEntry(
      id: 'three',
      fingerprint: 'fingerprint-a',
      timestamp: DateTime.utc(2026, 3, 9, 10, 0),
      probability: 88,
    ));

    final cached = await repository.findLatestReusableByFingerprint('fingerprint-a');

    expect(cached, isNotNull);
    expect(cached!.entryId, 'three');
    expect(cached.aiProbability, 88);
  });
}
