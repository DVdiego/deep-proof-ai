import 'package:flutter/services.dart';

import '../core/analysis/analysis_request.dart';
import '../core/analysis/analysis_result.dart';

abstract class ImageAnalyzer {
  Future<AnalysisResult> analyzeImage(AnalysisRequest request);
}

class AnalysisBridge implements ImageAnalyzer {
  const AnalysisBridge({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('ai_authenticity/runtime');

  final MethodChannel _channel;

  @override
  Future<AnalysisResult> analyzeImage(AnalysisRequest request) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'analyzeImage',
      request.toJson(),
    );
    return AnalysisResult.fromJson(
      result ??
          const <String, dynamic>{
            'ok': false,
            'rawScore': 0.0,
            'aiProbability': 0.0,
            'decisionCode': '',
            'decisionLabel': '',
            'explanation': '',
            'modelVersion': '',
            'schemaVersion': '',
            'errorCode': 'BRIDGE_EMPTY_RESPONSE',
            'errorMessage': 'Native bridge returned no data.',
          },
    );
  }
}
