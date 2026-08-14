class ReviewBatch {
  const ReviewBatch({
    required this.batchId,
    required this.name,
    required this.createdAt,
    required this.status,
    required this.totalCount,
    required this.completedCount,
    required this.failedCount,
    required this.authenticCount,
    required this.needsReviewCount,
    required this.aiCount,
    required this.priorityCount,
    required this.averageConfidence,
  });

  final String batchId;
  final String name;
  final DateTime createdAt;
  final String status;
  final int totalCount;
  final int completedCount;
  final int failedCount;
  final int authenticCount;
  final int needsReviewCount;
  final int aiCount;
  final int priorityCount;
  final double averageConfidence;

  factory ReviewBatch.fromJson(Map<String, dynamic> json) {
    return ReviewBatch(
      batchId: json['batch_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'completed',
      totalCount: json['total_count'] as int? ?? 0,
      completedCount: json['completed_count'] as int? ?? 0,
      failedCount: json['failed_count'] as int? ?? 0,
      authenticCount: json['authentic_count'] as int? ?? 0,
      needsReviewCount: json['needs_review_count'] as int? ?? 0,
      aiCount: json['ai_count'] as int? ?? 0,
      priorityCount: json['priority_count'] as int? ?? 0,
      averageConfidence: (json['average_confidence'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'name': name,
      'created_at': createdAt.toUtc().toIso8601String(),
      'status': status,
      'total_count': totalCount,
      'completed_count': completedCount,
      'failed_count': failedCount,
      'authentic_count': authenticCount,
      'needs_review_count': needsReviewCount,
      'ai_count': aiCount,
      'priority_count': priorityCount,
      'average_confidence': averageConfidence,
    };
  }
}

class ReviewBatchItem {
  const ReviewBatchItem({
    required this.itemId,
    required this.batchId,
    required this.index,
    required this.fileName,
    required this.filePath,
    required this.analyzedAt,
    required this.ok,
    required this.analysisFingerprint,
    required this.decisionCode,
    required this.decisionLabel,
    required this.aiProbability,
    required this.rawScore,
    required this.explanation,
    required this.modelVersion,
    required this.schemaVersion,
    required this.reusedCachedResult,
    required this.priorityReason,
    required this.errorCode,
    required this.errorMessage,
  });

  final String itemId;
  final String batchId;
  final int index;
  final String fileName;
  final String filePath;
  final DateTime analyzedAt;
  final bool ok;
  final String analysisFingerprint;
  final String decisionCode;
  final String decisionLabel;
  final double aiProbability;
  final double rawScore;
  final String explanation;
  final String modelVersion;
  final String schemaVersion;
  final bool reusedCachedResult;
  final String priorityReason;
  final String errorCode;
  final String errorMessage;

  bool get isPriority => priorityReason.isNotEmpty;

  factory ReviewBatchItem.fromJson(Map<String, dynamic> json) {
    return ReviewBatchItem(
      itemId: json['item_id'] as String,
      batchId: json['batch_id'] as String,
      index: json['index'] as int? ?? 0,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      analyzedAt: DateTime.parse(json['analyzed_at'] as String),
      ok: json['ok'] as bool? ?? false,
      analysisFingerprint: json['analysis_fingerprint'] as String? ?? '',
      decisionCode: json['decision_code'] as String? ?? '',
      decisionLabel: json['decision_label'] as String? ?? '',
      aiProbability: (json['ai_probability'] as num?)?.toDouble() ?? 0,
      rawScore: (json['raw_score'] as num?)?.toDouble() ?? 0,
      explanation: json['explanation'] as String? ?? '',
      modelVersion: json['model_version'] as String? ?? '',
      schemaVersion: json['schema_version'] as String? ?? '',
      reusedCachedResult: json['reused_cached_result'] as bool? ?? false,
      priorityReason: json['priority_reason'] as String? ?? '',
      errorCode: json['error_code'] as String? ?? '',
      errorMessage: json['error_message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'batch_id': batchId,
      'index': index,
      'file_name': fileName,
      'file_path': filePath,
      'analyzed_at': analyzedAt.toUtc().toIso8601String(),
      'ok': ok,
      'analysis_fingerprint': analysisFingerprint,
      'decision_code': decisionCode,
      'decision_label': decisionLabel,
      'ai_probability': aiProbability,
      'raw_score': rawScore,
      'explanation': explanation,
      'model_version': modelVersion,
      'schema_version': schemaVersion,
      'reused_cached_result': reusedCachedResult,
      'priority_reason': priorityReason,
      'error_code': errorCode,
      'error_message': errorMessage,
    };
  }
}
