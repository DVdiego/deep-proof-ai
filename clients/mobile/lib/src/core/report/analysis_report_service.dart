import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../analysis/analysis_result.dart';
import '../model_package/model_package.dart';

class GeneratedReport {
  const GeneratedReport({
    required this.path,
    required this.fileName,
  });

  final String path;
  final String fileName;
}

class AnalysisReportService {
  const AnalysisReportService();

  Future<GeneratedReport> generate({
    required String sourceImagePath,
    required AnalysisResult result,
    required PublicModelProfile publicProfile,
    required Directory reportsDirectory,
  }) async {
    await reportsDirectory.create(recursive: true);
    final fileName = 'report_${_safeKey(result.analysisFingerprint)}.png';
    final outputFile = File('${reportsDirectory.path}/$fileName');
    if (await outputFile.exists()) {
      return GeneratedReport(path: outputFile.path, fileName: fileName);
    }

    final sourceImage = await _decodeImage(sourceImagePath);
    final recorder = ui.PictureRecorder();
    const width = 1280.0;
    const height = 1680.0;
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));

    _drawBackground(canvas, width, height);
    _drawHeader(canvas, width, publicProfile);
    _drawImagePreview(canvas, sourceImage, width, p.basename(sourceImagePath));
    _drawAssessment(canvas, width, result);
    _drawExplanation(canvas, width, result);
    _drawFooter(canvas, width, publicProfile, result);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await outputFile.writeAsBytes(bytes!.buffer.asUint8List());

    return GeneratedReport(path: outputFile.path, fileName: fileName);
  }

  Future<ui.Image?> _decodeImage(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 900);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  void _drawBackground(Canvas canvas, double width, double height) {
    final background = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFF5F8FA), Color(0xFFEAF2F7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), background);
  }

  void _drawHeader(Canvas canvas, double width, PublicModelProfile publicProfile) {
    _drawRoundedCard(canvas, const Rect.fromLTWH(60, 56, 1160, 210), const Color(0xFF08202B));
    _drawText(
      canvas,
      'AI Authenticity',
      const Offset(100, 96),
      const TextStyle(
        color: Colors.white,
        fontSize: 54,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
    );
    _drawText(
      canvas,
      'On-device image analysis report',
      const Offset(100, 162),
      const TextStyle(
        color: Color(0xFFD2EAF5),
        fontSize: 26,
        fontWeight: FontWeight.w500,
      ),
    );
    _drawPill(
      canvas,
      text: '${publicProfile.name} · ${publicProfile.version}',
      x: 760,
      y: 156,
      width: 380,
    );
  }

  void _drawImagePreview(Canvas canvas, ui.Image? image, double width, String fileName) {
    const previewRect = Rect.fromLTWH(60, 310, 1160, 620);
    _drawRoundedCard(canvas, previewRect, Colors.white);
    final imageRect = Rect.fromLTWH(92, 342, 1096, 556);
    final clipRRect = RRect.fromRectAndRadius(imageRect, const Radius.circular(34));
    canvas.save();
    canvas.clipRRect(clipRRect);
    if (image != null) {
      paintImage(
        canvas: canvas,
        rect: imageRect,
        image: image,
        fit: BoxFit.cover,
      );
    } else {
      final fallbackPaint = Paint()..color = const Color(0xFFE3EDF3);
      canvas.drawRect(imageRect, fallbackPaint);
      _drawText(
        canvas,
        'Preview unavailable',
        const Offset(420, 600),
        const TextStyle(
          color: Color(0xFF516576),
          fontSize: 30,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    canvas.restore();
    _drawText(
      canvas,
      fileName,
      const Offset(98, 904),
      const TextStyle(
        color: Color(0xFF617384),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: 1090,
    );
  }

  void _drawAssessment(Canvas canvas, double width, AnalysisResult result) {
    final accent = _accentFor(result.decisionCode);
    _drawRoundedCard(canvas, const Rect.fromLTWH(60, 970, 1160, 268), Colors.white);
    _drawText(
      canvas,
      'Assessment',
      const Offset(100, 1020),
      const TextStyle(color: Color(0xFF6D7F8F), fontSize: 26, fontWeight: FontWeight.w600),
    );
    _drawText(
      canvas,
      result.decisionLabel,
      const Offset(100, 1066),
      TextStyle(color: accent, fontSize: 54, fontWeight: FontWeight.w800, letterSpacing: -1.1),
      maxWidth: 720,
    );
    _drawText(
      canvas,
      '${result.aiProbability.toStringAsFixed(1)}% confidence',
      const Offset(100, 1138),
      const TextStyle(color: Color(0xFF1E728F), fontSize: 34, fontWeight: FontWeight.w700),
    );
    _drawPill(
      canvas,
      text: 'Analyzed on-device',
      x: 870,
      y: 1020,
      width: 250,
      fill: const Color(0xFFE8F5EE),
      foreground: const Color(0xFF0C8A63),
    );
    _drawText(
      canvas,
      _summaryFor(result.decisionCode),
      const Offset(100, 1188),
      const TextStyle(color: Color(0xFF536677), fontSize: 28, fontWeight: FontWeight.w500, height: 1.35),
      maxWidth: 980,
    );
  }

  void _drawExplanation(Canvas canvas, double width, AnalysisResult result) {
    _drawRoundedCard(canvas, const Rect.fromLTWH(60, 1278, 1160, 252), const Color(0xFFF8FBFD));
    _drawText(
      canvas,
      'Summary',
      const Offset(100, 1324),
      const TextStyle(color: Color(0xFF617384), fontSize: 24, fontWeight: FontWeight.w700),
    );
    _drawText(
      canvas,
      result.explanation,
      const Offset(100, 1368),
      const TextStyle(color: Color(0xFF213140), fontSize: 33, fontWeight: FontWeight.w500, height: 1.38),
      maxWidth: 1030,
    );
  }

  void _drawFooter(Canvas canvas, double width, PublicModelProfile publicProfile, AnalysisResult result) {
    _drawText(
      canvas,
      'AI Authenticity · ${publicProfile.name} ${publicProfile.version} · Mark ${publicProfile.signature}',
      const Offset(80, 1598),
      const TextStyle(color: Color(0xFF738596), fontSize: 22, fontWeight: FontWeight.w600),
      maxWidth: 1100,
    );
    _drawText(
      canvas,
      'Forensic fingerprint ${_publicFingerprint(result, publicProfile)}',
      const Offset(80, 1630),
      const TextStyle(color: Color(0xFF738596), fontSize: 18, fontWeight: FontWeight.w700),
    );
    _drawText(
      canvas,
      'This card summarizes a local device analysis result and is not a certification of origin.',
      const Offset(80, 1658),
      const TextStyle(color: Color(0xFF8393A2), fontSize: 18, fontWeight: FontWeight.w500),
      maxWidth: 1100,
    );
  }

  void _drawRoundedCard(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(36)),
      paint,
    );
  }

  void _drawPill(
    Canvas canvas, {
    required String text,
    required double x,
    required double y,
    required double width,
    Color fill = const Color(0x1FFFFFFF),
    Color foreground = Colors.white,
  }) {
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, width, 56), const Radius.circular(999));
    final paint = Paint()..color = fill;
    canvas.drawRRect(rect, paint);
    _drawText(
      canvas,
      text,
      Offset(x + 22, y + 12),
      TextStyle(color: foreground, fontSize: 22, fontWeight: FontWeight.w700),
      maxWidth: width - 44,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    double? maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      maxLines: maxWidth == null ? 1 : null,
    )..layout(maxWidth: maxWidth ?? double.infinity);
    painter.paint(canvas, offset);
  }

  Color _accentFor(String decisionCode) {
    switch (decisionCode) {
      case 'RealLikely':
        return const Color(0xFF0C8A63);
      case 'AIHigh':
        return const Color(0xFFB04354);
      case 'AILikely':
        return const Color(0xFF9E6B0A);
      default:
        return const Color(0xFF0B698C);
    }
  }

  String _summaryFor(String decisionCode) {
    switch (decisionCode) {
      case 'RealLikely':
        return 'The image aligns with patterns usually found in authentic camera captures.';
      case 'AIHigh':
        return 'The image shows strong patterns commonly associated with AI-generated media.';
      case 'AILikely':
        return 'The image shows notable signs of AI generation and should be treated carefully.';
      default:
        return 'The result remains mixed. Manual review is recommended before relying on it.';
    }
  }

  String _safeKey(String input) {
    final normalized = input.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
    return normalized.isEmpty ? 'analysis' : normalized.substring(0, normalized.length > 40 ? 40 : normalized.length);
  }

  String _publicFingerprint(AnalysisResult result, PublicModelProfile publicProfile) {
    final raw = result.analysisFingerprint;
    if (raw.isEmpty) {
      return '${publicProfile.signature}-PENDING';
    }
    final digest = raw.contains('::') ? raw.split('::').last : raw;
    final suffix = digest.length <= 8 ? digest : digest.substring(digest.length - 8);
    return '${publicProfile.signature}-${suffix.toUpperCase()}';
  }
}
