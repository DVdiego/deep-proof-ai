class AnalysisRequest {
  const AnalysisRequest({
    required this.filePath,
    required this.modelVersion,
    this.mediaType = 'image',
  });

  final String filePath;
  final String modelVersion;
  final String mediaType;

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'modelVersion': modelVersion,
      'mediaType': mediaType,
    };
  }
}
