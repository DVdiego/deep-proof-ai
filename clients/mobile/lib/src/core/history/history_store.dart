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

  Future<List<Map<String, dynamic>>> readExecuteEntries() => _readJsonLines(executeHistoryFile);
  Future<List<Map<String, dynamic>>> readCompareEntries() => _readJsonLines(compareHistoryFile);

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
