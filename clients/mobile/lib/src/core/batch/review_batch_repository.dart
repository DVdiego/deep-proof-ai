import '../entitlement/entitlement_state.dart';
import '../history/history_store.dart';
import 'review_batch.dart';

class ReviewBatchRepository {
  ReviewBatchRepository({required this.store});

  final HistoryStore store;

  Future<void> saveBatch(ReviewBatch batch, List<ReviewBatchItem> items) async {
    final existingBatches = await store.readReviewBatches();
    final filteredBatches =
        existingBatches
            .where((item) => item.batchId != batch.batchId)
            .toList(growable: true)
          ..add(batch);
    filteredBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await store.writeReviewBatches(filteredBatches);

    final existingItems = await store.readReviewBatchItems();
    final filteredItems =
        existingItems
            .where((item) => item.batchId != batch.batchId)
            .toList(growable: true)
          ..addAll(items);
    filteredItems.sort((a, b) {
      final byDate = b.analyzedAt.compareTo(a.analyzedAt);
      if (byDate != 0) {
        return byDate;
      }
      return a.index.compareTo(b.index);
    });
    await store.writeReviewBatchItems(filteredItems);
  }

  Future<List<ReviewBatch>> listVisibleBatches(EntitlementTier tier) async {
    if (tier != EntitlementTier.professional) {
      return const [];
    }
    final batches = await store.readReviewBatches();
    batches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return batches;
  }

  Future<List<ReviewBatchItem>> listItemsForBatch(
    String batchId,
    EntitlementTier tier,
  ) async {
    if (tier != EntitlementTier.professional) {
      return const [];
    }
    final items = await store.readReviewBatchItems();
    final filtered = items
        .where((item) => item.batchId == batchId)
        .toList(growable: false);
    filtered.sort((a, b) => a.index.compareTo(b.index));
    return filtered;
  }

  Future<void> clearAll() async {
    await store.writeReviewBatches(const <ReviewBatch>[]);
    await store.writeReviewBatchItems(const <ReviewBatchItem>[]);
  }
}
