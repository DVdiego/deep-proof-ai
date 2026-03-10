class AnalysisResult {
  const AnalysisResult({
    required this.ok,
    required this.rawScore,
    required this.aiProbability,
    required this.analysisFingerprint,
    required this.decisionCode,
    required this.decisionLabel,
    required this.explanation,
    required this.modelVersion,
    required this.schemaVersion,
    required this.errorCode,
    required this.errorMessage,
    required this.features,
  });

  final bool ok;
  final double rawScore;
  final double aiProbability;
  final String analysisFingerprint;
  final String decisionCode;
  final String decisionLabel;
  final String explanation;
  final String modelVersion;
  final String schemaVersion;
  final String errorCode;
  final String errorMessage;
  final List<double> features;

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final rawScore = (json['rawScore'] ?? json['raw_score'] ?? 0) as num;
    final aiProbability = (json['aiProbability'] ?? json['ai_probability'] ?? 0) as num;
    return AnalysisResult(
      ok: json['ok'] as bool? ?? false,
      rawScore: rawScore.toDouble(),
      aiProbability: aiProbability.toDouble(),
      analysisFingerprint:
          json['analysisFingerprint'] as String? ?? json['analysis_fingerprint'] as String? ?? '',
      decisionCode: json['decisionCode'] as String? ?? json['decision_code'] as String? ?? '',
      decisionLabel: json['decisionLabel'] as String? ?? json['decision_label'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      modelVersion: json['modelVersion'] as String? ?? json['model_version'] as String? ?? '',
      schemaVersion: json['schemaVersion'] as String? ?? json['schema_version'] as String? ?? '',
      errorCode: json['errorCode'] as String? ?? json['error_code'] as String? ?? '',
      errorMessage: json['errorMessage'] as String? ?? json['error_message'] as String? ?? '',
      features: ((json['features'] as List<dynamic>?) ?? const <dynamic>[])
          .map((value) => (value as num).toDouble())
          .toList(),
    );
  }
}
