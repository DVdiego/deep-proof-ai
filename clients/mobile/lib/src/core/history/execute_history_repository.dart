import '../entitlement/entitlement_state.dart';
import 'history_entry.dart';
import 'history_store.dart';

class ExecuteHistoryRepository {
  ExecuteHistoryRepository({required this.store});

  final HistoryStore store;

  Future<void> add(ExecuteHistoryEntry entry) => store.appendExecute(entry);

  Future<ExecuteHistoryEntry?> findLatestReusableByFingerprint(String fingerprint) async {
    final entries = await store.readExecuteEntries();
    for (final entry in entries.reversed) {
      if (entry.analysisFingerprint == fingerprint && entry.canReuse) {
        return entry;
      }
    }
    return null;
  }

  Future<List<ExecuteHistoryEntry>> listVisibleEntries(EntitlementTier tier) async {
    final entries = await store.readExecuteEntries();
    final deduped = _dedupeByFingerprint(entries);
    if (tier == EntitlementTier.free && deduped.length > 10) {
      return deduped.sublist(deduped.length - 10);
    }
    return deduped;
  }

  List<ExecuteHistoryEntry> _dedupeByFingerprint(List<ExecuteHistoryEntry> entries) {
    final seen = <String>{};
    final dedupedReversed = <ExecuteHistoryEntry>[];

    for (final entry in entries.reversed) {
      final key = entry.analysisFingerprint.isNotEmpty
          ? entry.analysisFingerprint
          : '${entry.filePath}::${entry.modelVersion}';
      if (seen.add(key)) {
        dedupedReversed.add(entry);
      }
    }

    return dedupedReversed.reversed.toList(growable: false);
  }
}
