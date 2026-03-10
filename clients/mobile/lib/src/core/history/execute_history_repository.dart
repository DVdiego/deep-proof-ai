import '../entitlement/entitlement_state.dart';
import 'history_entry.dart';
import 'history_store.dart';

class ExecuteHistoryRepository {
  ExecuteHistoryRepository({required this.store});

  final HistoryStore store;

  Future<void> add(ExecuteHistoryEntry entry) async {
    if (entry.canReuse) {
      final existing = await findLatestReusableByFingerprint(entry.analysisFingerprint);
      if (existing != null) {
        return;
      }
    }
    await store.appendExecute(entry);
  }

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

  Future<void> remove(ExecuteHistoryEntry entry) async {
    final entries = await store.readExecuteEntries();
    final filtered = entries.where((item) => item.entryId != entry.entryId).toList(growable: false);
    await store.writeExecuteEntries(filtered);
  }

  Future<void> clearAll() async {
    await store.writeExecuteEntries(const <ExecuteHistoryEntry>[]);
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
