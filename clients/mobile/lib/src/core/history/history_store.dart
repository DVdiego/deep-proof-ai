import 'dart:convert';
import 'dart:io';

import 'history_entry.dart';

class HistoryStore {
  HistoryStore({
    required this.executeHistoryFile,
    required this.reportHistoryFile,
    required this.reportQueueFile,
  });

  final File executeHistoryFile;
  final File reportHistoryFile;
  final File reportQueueFile;

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

  Future<void> writeQueuedReportEntries(List<ReportQueueEntry> entries) async {
    await reportQueueFile.parent.create(recursive: true);
    final sink = reportQueueFile.openWrite(mode: FileMode.writeOnly);
    for (final entry in entries) {
      sink.writeln(jsonEncode(entry.toJson()));
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
