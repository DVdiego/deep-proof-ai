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
    required this.analysisFingerprint,
    required this.decisionCode,
    required this.decisionLabel,
    required this.aiProbability,
    required this.rawScore,
    required this.explanation,
    required this.modelVersion,
  });

  final String filePath;
  final String analysisFingerprint;
  final String decisionCode;
  final String decisionLabel;
  final double aiProbability;
  final double rawScore;
  final String explanation;
  final String modelVersion;

  factory ExecuteHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ExecuteHistoryEntry(
      entryId: json['entry_id'] as String,
      fileName: json['file_name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      schemaVersion: json['schema_version'] as String,
      filePath: json['file_path'] as String,
      analysisFingerprint: json['analysis_fingerprint'] as String? ?? '',
      decisionCode: json['decision_code'] as String? ?? '',
      decisionLabel: json['decision_label'] as String,
      aiProbability: (json['ai_probability'] as num).toDouble(),
      rawScore: (json['raw_score'] as num?)?.toDouble() ?? 0,
      explanation: json['explanation'] as String? ?? '',
      modelVersion: json['model_version'] as String,
    );
  }

  bool get canReuse => analysisFingerprint.isNotEmpty;

  @override
  Map<String, dynamic> toJson() {
    return {
      'entry_type': 'execute',
      'entry_id': entryId,
      'file_name': fileName,
      'file_path': filePath,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'analysis_fingerprint': analysisFingerprint,
      'decision_code': decisionCode,
      'decision_label': decisionLabel,
      'ai_probability': aiProbability,
      'raw_score': rawScore,
      'explanation': explanation,
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

  factory CompareHistoryEntry.fromJson(Map<String, dynamic> json) {
    return CompareHistoryEntry(
      entryId: json['entry_id'] as String,
      fileName: json['file_name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      schemaVersion: json['schema_version'] as String,
      primaryModelVersion: json['primary_model_version'] as String,
      secondaryModelVersion: json['secondary_model_version'] as String,
      primaryProbability: (json['primary_probability'] as num).toDouble(),
      secondaryProbability: (json['secondary_probability'] as num).toDouble(),
      deltaProbability: (json['delta_probability'] as num).toDouble(),
    );
  }

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
