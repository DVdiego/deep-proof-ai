import '../entitlement/entitlement_state.dart';
import 'history_entry.dart';
import 'history_store.dart';

class CompareHistoryRepository {
  CompareHistoryRepository({required this.store});

  final HistoryStore store;

  Future<void> add(CompareHistoryEntry entry) => store.appendCompare(entry);

  Future<List<CompareHistoryEntry>> listVisibleEntries(EntitlementTier tier) async {
    if (tier == EntitlementTier.free) {
      return const [];
    }
    return store.readCompareEntries();
  }
}
