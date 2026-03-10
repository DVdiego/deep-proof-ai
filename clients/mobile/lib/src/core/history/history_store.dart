import 'dart:convert';
import 'dart:io';

import '../batch/review_batch.dart';
import 'history_entry.dart';

class HistoryStore {
  HistoryStore({
    required this.executeHistoryFile,
    required this.reportHistoryFile,
    required this.reportQueueFile,
    required this.reviewBatchFile,
    required this.reviewBatchItemFile,
  });

  final File executeHistoryFile;
  final File reportHistoryFile;
  final File reportQueueFile;
  final File reviewBatchFile;
  final File reviewBatchItemFile;

  Future<void> appendExecute(ExecuteHistoryEntry entry) async {
    await _appendLine(executeHistoryFile, entry.toJson());
  }

  Future<void> appendReport(ReportHistoryEntry entry) async {
    await _appendLine(reportHistoryFile, entry.toJson());
  }

  Future<void> appendQueuedReport(ReportQueueEntry entry) async {
    await _appendLine(reportQueueFile, entry.toJson());
  }

  Future<List<ExecuteHistoryEntry>> readExecuteEntries() async {
    final payload = await _readJsonLines(executeHistoryFile);
    return payload.map(ExecuteHistoryEntry.fromJson).toList(growable: false);
  }

  Future<List<ReportHistoryEntry>> readReportEntries() async {
    final payload = await _readJsonLines(reportHistoryFile);
    return payload.map(ReportHistoryEntry.fromJson).toList(growable: false);
  }

  Future<List<ReportQueueEntry>> readQueuedReportEntries() async {
    final payload = await _readJsonLines(reportQueueFile);
    return payload.map(ReportQueueEntry.fromJson).toList(growable: false);
  }

  Future<List<ReviewBatch>> readReviewBatches() async {
    final payload = await _readJsonLines(reviewBatchFile);
    return payload.map(ReviewBatch.fromJson).toList(growable: false);
  }

  Future<List<ReviewBatchItem>> readReviewBatchItems() async {
    final payload = await _readJsonLines(reviewBatchItemFile);
    return payload.map(ReviewBatchItem.fromJson).toList(growable: false);
  }

  Future<void> writeQueuedReportEntries(List<ReportQueueEntry> entries) async {
    await _writeEntries(
      reportQueueFile,
      entries.map((entry) => entry.toJson()).toList(growable: false),
    );
  }

  Future<void> writeExecuteEntries(List<ExecuteHistoryEntry> entries) async {
    await _writeEntries(
      executeHistoryFile,
      entries.map((entry) => entry.toJson()).toList(growable: false),
    );
  }

  Future<void> writeReportEntries(List<ReportHistoryEntry> entries) async {
    await _writeEntries(
      reportHistoryFile,
      entries.map((entry) => entry.toJson()).toList(growable: false),
    );
  }

  Future<void> writeReviewBatches(List<ReviewBatch> entries) async {
    await _writeEntries(
      reviewBatchFile,
      entries.map((entry) => entry.toJson()).toList(growable: false),
    );
  }

  Future<void> writeReviewBatchItems(List<ReviewBatchItem> entries) async {
    await _writeEntries(
      reviewBatchItemFile,
      entries.map((entry) => entry.toJson()).toList(growable: false),
    );
  }

  Future<void> _writeEntries(
    File file,
    List<Map<String, dynamic>> payloads,
  ) async {
    await file.parent.create(recursive: true);
    final sink = file.openWrite(mode: FileMode.writeOnly);
    for (final payload in payloads) {
      sink.writeln(jsonEncode(payload));
    }
    await sink.flush();
    await sink.close();
  }

  Future<void> _appendLine(File file, Map<String, dynamic> payload) async {
    await file.parent.create(recursive: true);
    await file.writeAsString('${jsonEncode(payload)}\n', mode: FileMode.append);
  }

  Future<List<Map<String, dynamic>>> _readJsonLines(File file) async {
    if (!await file.exists()) {
      return const [];
    }
    final lines = await file.readAsLines();
    return lines
        .where((line) => line.trim().isNotEmpty)
        .map((line) => jsonDecode(line) as Map<String, dynamic>)
        .toList(growable: false);
  }
}
