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

class ReportHistoryEntry extends HistoryEntry {
  const ReportHistoryEntry({
    required super.entryId,
    required super.fileName,
    required super.timestamp,
    required super.schemaVersion,
    required this.filePath,
    required this.analysisFingerprint,
    required this.reportImagePath,
    required this.decisionLabel,
    required this.aiProbability,
    required this.engineName,
    required this.engineVersion,
    required this.engineSignature,
  });

  final String filePath;
  final String analysisFingerprint;
  final String reportImagePath;
  final String decisionLabel;
  final double aiProbability;
  final String engineName;
  final String engineVersion;
  final String engineSignature;

  factory ReportHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ReportHistoryEntry(
      entryId: json['entry_id'] as String,
      fileName: json['file_name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      schemaVersion: json['schema_version'] as String,
      filePath: json['file_path'] as String,
      analysisFingerprint: json['analysis_fingerprint'] as String? ?? '',
      reportImagePath: json['report_image_path'] as String,
      decisionLabel: json['decision_label'] as String,
      aiProbability: (json['ai_probability'] as num).toDouble(),
      engineName: json['engine_name'] as String,
      engineVersion: json['engine_version'] as String,
      engineSignature: json['engine_signature'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'entry_type': 'report',
      'entry_id': entryId,
      'file_name': fileName,
      'file_path': filePath,
      'analysis_fingerprint': analysisFingerprint,
      'report_image_path': reportImagePath,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'decision_label': decisionLabel,
      'ai_probability': aiProbability,
      'engine_name': engineName,
      'engine_version': engineVersion,
      'engine_signature': engineSignature,
      'schema_version': schemaVersion,
    };
  }
}

class ReportQueueEntry extends HistoryEntry {
  const ReportQueueEntry({
    required super.entryId,
    required super.fileName,
    required super.timestamp,
    required super.schemaVersion,
    required this.filePath,
    required this.analysisFingerprint,
    required this.reportImagePath,
    required this.decisionLabel,
    required this.aiProbability,
    required this.engineName,
    required this.engineVersion,
    required this.engineSignature,
  });

  final String filePath;
  final String analysisFingerprint;
  final String reportImagePath;
  final String decisionLabel;
  final double aiProbability;
  final String engineName;
  final String engineVersion;
  final String engineSignature;

  factory ReportQueueEntry.fromJson(Map<String, dynamic> json) {
    return ReportQueueEntry(
      entryId: json['entry_id'] as String,
      fileName: json['file_name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      schemaVersion: json['schema_version'] as String,
      filePath: json['file_path'] as String,
      analysisFingerprint: json['analysis_fingerprint'] as String? ?? '',
      reportImagePath: json['report_image_path'] as String,
      decisionLabel: json['decision_label'] as String,
      aiProbability: (json['ai_probability'] as num).toDouble(),
      engineName: json['engine_name'] as String,
      engineVersion: json['engine_version'] as String,
      engineSignature: json['engine_signature'] as String,
    );
  }

  factory ReportQueueEntry.fromReport(ReportHistoryEntry report) {
    return ReportQueueEntry(
      entryId: report.entryId,
      fileName: report.fileName,
      timestamp: DateTime.now().toUtc(),
      schemaVersion: report.schemaVersion,
      filePath: report.filePath,
      analysisFingerprint: report.analysisFingerprint,
      reportImagePath: report.reportImagePath,
      decisionLabel: report.decisionLabel,
      aiProbability: report.aiProbability,
      engineName: report.engineName,
      engineVersion: report.engineVersion,
      engineSignature: report.engineSignature,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'entry_type': 'report_queue',
      'entry_id': entryId,
      'file_name': fileName,
      'file_path': filePath,
      'analysis_fingerprint': analysisFingerprint,
      'report_image_path': reportImagePath,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'decision_label': decisionLabel,
      'ai_probability': aiProbability,
      'engine_name': engineName,
      'engine_version': engineVersion,
      'engine_signature': engineSignature,
      'schema_version': schemaVersion,
    };
  }
}
