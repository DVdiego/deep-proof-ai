import '../entitlement/entitlement_state.dart';
import 'history_entry.dart';
import 'history_store.dart';

class ExecuteHistoryRepository {
  ExecuteHistoryRepository({required this.store});

  final HistoryStore store;

  Future<void> add(ExecuteHistoryEntry entry) => store.appendExecute(entry);

  Future<List<ExecuteHistoryEntry>> listVisibleEntries(EntitlementTier tier) async {
    final entries = await store.readExecuteEntries();
    if (tier == EntitlementTier.free && entries.length > 10) {
      return entries.sublist(entries.length - 10);
    }
    return entries;
  }
}
