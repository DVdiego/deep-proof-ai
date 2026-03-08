import 'package:flutter/services.dart';

class AnalysisBridge {
  const AnalysisBridge({MethodChannel? channel}) : _channel = channel ?? const MethodChannel('ai_authenticity/runtime');

  final MethodChannel _channel;

  Future<Map<String, dynamic>> analyzeImage({
    required String filePath,
    required String modelVersion,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>('analyzeImage', {
      'filePath': filePath,
      'modelVersion': modelVersion,
    });
    return result ?? const <String, dynamic>{
      'ok': false,
      'error_code': 'BRIDGE_EMPTY_RESPONSE',
      'error_message': 'Native bridge returned no data.',
    };
  }
}
