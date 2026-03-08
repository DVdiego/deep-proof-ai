abstract class HistoryEntry {
  const HistoryEntry({
    required this.entryId,
    required this.fileName,
    required this.timestamp,
    required this.schemaVersion,
  });

  final String entryId;
  final String fileName;
  final DateTime timestamp;
  final String schemaVersion;

  Map<String, dynamic> toJson();
}

class ExecuteHistoryEntry extends HistoryEntry {
  const ExecuteHistoryEntry({
    required super.entryId,
    required super.fileName,
    required super.timestamp,
    required super.schemaVersion,
    required this.filePath,
    required this.decisionLabel,
    required this.aiProbability,
    required this.modelVersion,
  });

  final String filePath;
  final String decisionLabel;
  final double aiProbability;
  final String modelVersion;

  @override
  Map<String, dynamic> toJson() {
    return {
      'entry_type': 'execute',
      'entry_id': entryId,
      'file_name': fileName,
      'file_path': filePath,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'decision_label': decisionLabel,
      'ai_probability': aiProbability,
      'model_version': modelVersion,
      'schema_version': schemaVersion,
    };
  }
}

class CompareHistoryEntry extends HistoryEntry {
  const CompareHistoryEntry({
    required super.entryId,
    required super.fileName,
    required super.timestamp,
    required super.schemaVersion,
    required this.primaryModelVersion,
    required this.secondaryModelVersion,
    required this.primaryProbability,
    required this.secondaryProbability,
    required this.deltaProbability,
  });

  final String primaryModelVersion;
  final String secondaryModelVersion;
  final double primaryProbability;
  final double secondaryProbability;
  final double deltaProbability;

  @override
  Map<String, dynamic> toJson() {
    return {
      'entry_type': 'compare',
      'entry_id': entryId,
      'file_name': fileName,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'primary_model_version': primaryModelVersion,
      'secondary_model_version': secondaryModelVersion,
      'primary_probability': primaryProbability,
      'secondary_probability': secondaryProbability,
      'delta_probability': deltaProbability,
      'schema_version': schemaVersion,
    };
  }
}
