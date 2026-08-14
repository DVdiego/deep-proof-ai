import '../entitlement/entitlement_state.dart';
import 'history_entry.dart';
import 'history_store.dart';

class ReviewQueueRepository {
  ReviewQueueRepository({required this.store});

  final HistoryStore store;

  Future<void> addFromReport(ReportHistoryEntry report) async {
    final existing = await store.readQueuedReportEntries();
    final key = report.analysisFingerprint.isNotEmpty ? report.analysisFingerprint : report.entryId;
    final alreadyQueued = existing.any(
      (item) =>
          (item.analysisFingerprint.isNotEmpty ? item.analysisFingerprint : item.entryId) == key,
    );
    if (alreadyQueued) {
      return;
    }
    await store.appendQueuedReport(ReportQueueEntry.fromReport(report));
  }

  Future<void> remove(ReportQueueEntry entry) async {
    final existing = await store.readQueuedReportEntries();
    final filtered = existing.where((item) {
      if (entry.analysisFingerprint.isNotEmpty && item.analysisFingerprint.isNotEmpty) {
        return item.analysisFingerprint != entry.analysisFingerprint;
      }
      return item.entryId != entry.entryId;
    }).toList(growable: false);
    await store.writeQueuedReportEntries(filtered);
  }

  Future<bool> containsReport(ReportHistoryEntry report) async {
    final existing = await store.readQueuedReportEntries();
    final key = report.analysisFingerprint.isNotEmpty ? report.analysisFingerprint : report.entryId;
    return existing.any(
      (item) => (item.analysisFingerprint.isNotEmpty ? item.analysisFingerprint : item.entryId) == key,
    );
  }

  Future<List<ReportQueueEntry>> listVisibleEntries(EntitlementTier tier) async {
    if (tier != EntitlementTier.professional) {
      return const [];
    }
    final entries = await store.readQueuedReportEntries();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  Future<void> clearAll() async {
    await store.writeQueuedReportEntries(const <ReportQueueEntry>[]);
  }
}
