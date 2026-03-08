import 'package:flutter/services.dart';

import '../core/analysis/analysis_request.dart';
import '../core/analysis/analysis_result.dart';

class AnalysisBridge {
  const AnalysisBridge({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('ai_authenticity/runtime');

  final MethodChannel _channel;

  Future<AnalysisResult> analyzeImage(AnalysisRequest request) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'analyzeImage',
      request.toJson(),
    );
    return AnalysisResult.fromJson(
      result ??
          const <String, dynamic>{
            'ok': false,
            'errorCode': 'BRIDGE_EMPTY_RESPONSE',
            'errorMessage': 'Native bridge returned no data.',
          },
    );
  }
}
