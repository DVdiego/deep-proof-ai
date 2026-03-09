import 'dart:convert';
import 'dart:io';

import 'history_entry.dart';

class HistoryStore {
  HistoryStore({
    required this.executeHistoryFile,
    required this.compareHistoryFile,
  });

  final File executeHistoryFile;
  final File compareHistoryFile;

  Future<void> appendExecute(ExecuteHistoryEntry entry) async {
    await _appendLine(executeHistoryFile, entry.toJson());
  }

  Future<void> appendCompare(CompareHistoryEntry entry) async {
    await _appendLine(compareHistoryFile, entry.toJson());
  }

  Future<List<ExecuteHistoryEntry>> readExecuteEntries() async {
    final payload = await _readJsonLines(executeHistoryFile);
    return payload.map(ExecuteHistoryEntry.fromJson).toList(growable: false);
  }

  Future<List<CompareHistoryEntry>> readCompareEntries() async {
    final payload = await _readJsonLines(compareHistoryFile);
    return payload.map(CompareHistoryEntry.fromJson).toList(growable: false);
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
