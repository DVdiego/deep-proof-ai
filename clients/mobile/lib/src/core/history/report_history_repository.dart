import '../entitlement/entitlement_state.dart';
import 'history_entry.dart';
import 'history_store.dart';

class ReportHistoryRepository {
  ReportHistoryRepository({required this.store});

  final HistoryStore store;

  Future<void> add(ReportHistoryEntry entry) async {
    final existing = await store.readReportEntries();
    final alreadyStored = existing.any(
      (item) =>
          item.entryId == entry.entryId ||
          item.reportImagePath == entry.reportImagePath ||
          (item.analysisFingerprint.isNotEmpty && item.analysisFingerprint == entry.analysisFingerprint),
    );
    if (alreadyStored) {
      return;
    }
    await store.appendReport(entry);
  }

  Future<ReportHistoryEntry?> findLatestByFingerprint(String fingerprint) async {
    final entries = await store.readReportEntries();
    final matches = entries.where((entry) => entry.analysisFingerprint == fingerprint).toList(growable: false);
    if (matches.isEmpty) {
      return null;
    }
    matches.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return matches.first;
  }

  Future<List<ReportHistoryEntry>> listVisibleEntries(EntitlementTier tier) async {
    if (tier == EntitlementTier.free) {
      return const [];
    }
    final entries = await store.readReportEntries();
    final deduped = <String, ReportHistoryEntry>{};
    for (final entry in entries) {
      final key = entry.analysisFingerprint.isNotEmpty ? entry.analysisFingerprint : entry.entryId;
      final existing = deduped[key];
      if (existing == null || entry.timestamp.isAfter(existing.timestamp)) {
        deduped[key] = entry;
      }
    }
    final sorted = deduped.values.toList(growable: false)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (tier == EntitlementTier.proUnlock && sorted.length > 10) {
      return sorted.take(10).toList(growable: false);
    }
    return sorted;
  }
}
