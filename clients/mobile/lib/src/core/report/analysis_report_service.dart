import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../analysis/analysis_result.dart';
import '../analysis/visible_classification.dart';
import '../model_package/model_package.dart';

class GeneratedReport {
  const GeneratedReport({required this.path, required this.fileName});

  final String path;
  final String fileName;
}

class AnalysisReportService {
  const AnalysisReportService();

  static const double _reportWidth = 1280.0;
  static const double _reportSidePadding = 60.0;
  static const double _reportCardWidth = 1160.0;
  static const double _footerBottomPadding = 54.0;

  Future<GeneratedReport> generate({
    required String sourceImagePath,
    required AnalysisResult result,
    required PublicModelProfile publicProfile,
    required Directory reportsDirectory,
    String? displayFileName,
  }) async {
    await reportsDirectory.create(recursive: true);
    final fileName = 'report_v3_${_safeKey(result.analysisFingerprint)}.png';
    final outputFile = File('${reportsDirectory.path}/$fileName');
    if (await outputFile.exists()) {
      return GeneratedReport(path: outputFile.path, fileName: fileName);
    }

    final sourceImage = await _decodeImage(sourceImagePath);
    final recorder = ui.PictureRecorder();
    const width = _reportWidth;
    final assessmentLayout = _buildAssessmentLayout(result);
    final explanationLayout = _buildExplanationLayout(
      result.explanation,
      startY: assessmentLayout.bottom + 38,
    );
    final footerLayout = _buildFooterLayout(
      publicProfile,
      result,
      startY: explanationLayout.bottom + 52,
    );
    final height = footerLayout.bottom + _footerBottomPadding;
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    _drawBackground(canvas, width, height);
    _drawHeader(canvas, width, publicProfile);
    _drawImagePreview(
      canvas,
      sourceImage,
      width,
      (displayFileName?.trim().isNotEmpty ?? false)
          ? displayFileName!.trim()
          : p.basename(sourceImagePath),
    );
    _drawAssessment(canvas, assessmentLayout, result);
    _drawExplanation(canvas, explanationLayout);
    _drawFooter(canvas, footerLayout);

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

  void _drawHeader(
    Canvas canvas,
    double width,
    PublicModelProfile publicProfile,
  ) {
    _drawRoundedCard(
      canvas,
      const Rect.fromLTWH(60, 56, 1160, 210),
      const Color(0xFF08202B),
    );
    _drawText(
      canvas,
      'DeepProof AI',
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
    _drawAdaptivePill(
      canvas,
      text: '${publicProfile.name} · ${publicProfile.version}',
      right: width - 80,
      y: 150,
      maxWidth: 480,
    );
  }

  void _drawImagePreview(
    Canvas canvas,
    ui.Image? image,
    double width,
    String fileName,
  ) {
    const previewRect = Rect.fromLTWH(60, 310, 1160, 648);
    _drawRoundedCard(canvas, previewRect, Colors.white);
    final imageRect = Rect.fromLTWH(92, 342, 1096, 560);
    final clipRRect = RRect.fromRectAndRadius(
      imageRect,
      const Radius.circular(34),
    );
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
      const Offset(98, 920),
      const TextStyle(
        color: Color(0xFF617384),
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: 1090,
      maxLines: 1,
      ellipsis: '...',
    );
  }

  _AssessmentLayout _buildAssessmentLayout(AnalysisResult result) {
    final classification = VisibleAnalysisClassification.fromProbability(
      result.aiProbability,
    );
    const top = 986.0;
    const titleOffset = Offset(100, 1034);
    const decisionOffset = Offset(100, 1080);
    const confidenceGap = 16.0;
    const summaryGap = 18.0;
    final decisionPainter = _buildTextPainter(
      classification.label,
      TextStyle(
        color: classification.accent,
        fontSize: 54,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
      ),
      maxWidth: 700,
    );
    final confidencePainter = _buildTextPainter(
      '${result.aiProbability.toStringAsFixed(1)}% confidence',
      const TextStyle(
        color: Color(0xFF1E728F),
        fontSize: 34,
        fontWeight: FontWeight.w700,
      ),
    );
    final summaryPainter = _buildTextPainter(
      classification.reportSummary,
      const TextStyle(
        color: Color(0xFF536677),
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
      maxWidth: 940,
    );
    final confidenceY =
        decisionOffset.dy + decisionPainter.height + confidenceGap;
    final summaryY = confidenceY + confidencePainter.height + summaryGap;
    final contentBottom = summaryY + summaryPainter.height;
    final height = (contentBottom - top) + 44;
    return _AssessmentLayout(
      top: top,
      height: height,
      decisionPainter: decisionPainter,
      confidencePainter: confidencePainter,
      summaryPainter: summaryPainter,
      titleOffset: titleOffset,
      decisionOffset: decisionOffset,
      confidenceOffset: Offset(100, confidenceY),
      summaryOffset: Offset(100, summaryY),
      pillRect: const Rect.fromLTWH(846, 1028, 274, 56),
    );
  }

  void _drawAssessment(
    Canvas canvas,
    _AssessmentLayout layout,
    AnalysisResult result,
  ) {
    _drawRoundedCard(
      canvas,
      Rect.fromLTWH(
        _reportSidePadding,
        layout.top,
        _reportCardWidth,
        layout.height,
      ),
      Colors.white,
    );
    _drawText(
      canvas,
      'Assessment',
      layout.titleOffset,
      const TextStyle(
        color: Color(0xFF6D7F8F),
        fontSize: 26,
        fontWeight: FontWeight.w600,
      ),
    );
    layout.decisionPainter.paint(canvas, layout.decisionOffset);
    layout.confidencePainter.paint(canvas, layout.confidenceOffset);
    _drawPill(
      canvas,
      text: 'Analyzed on-device',
      x: layout.pillRect.left,
      y: layout.pillRect.top,
      width: layout.pillRect.width,
      fill: const Color(0xFFE8F5EE),
      foreground: const Color(0xFF0C8A63),
    );
    layout.summaryPainter.paint(canvas, layout.summaryOffset);
  }

  _ExplanationLayout _buildExplanationLayout(
    String explanation, {
    required double startY,
  }) {
    final titleOffset = Offset(100, startY + 44);
    final bodyOffset = Offset(100, startY + 88);
    final bodyPainter = _buildTextPainter(
      explanation,
      const TextStyle(
        color: Color(0xFF213140),
        fontSize: 33,
        fontWeight: FontWeight.w500,
        height: 1.38,
      ),
      maxWidth: 1030,
    );
    final height = (bodyOffset.dy + bodyPainter.height - startY) + 42;
    return _ExplanationLayout(
      top: startY,
      height: height,
      titleOffset: titleOffset,
      bodyOffset: bodyOffset,
      bodyPainter: bodyPainter,
    );
  }

  void _drawExplanation(Canvas canvas, _ExplanationLayout layout) {
    _drawRoundedCard(
      canvas,
      Rect.fromLTWH(
        _reportSidePadding,
        layout.top,
        _reportCardWidth,
        layout.height,
      ),
      const Color(0xFFF8FBFD),
    );
    _drawText(
      canvas,
      'Summary',
      layout.titleOffset,
      const TextStyle(
        color: Color(0xFF617384),
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    );
    layout.bodyPainter.paint(canvas, layout.bodyOffset);
  }

  _FooterLayout _buildFooterLayout(
    PublicModelProfile publicProfile,
    AnalysisResult result, {
    required double startY,
  }) {
    final headlinePainter = _buildTextPainter(
      'DeepProof AI · ${publicProfile.name} ${publicProfile.version} · Mark ${publicProfile.signature}',
      const TextStyle(
        color: Color(0xFF738596),
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      maxWidth: 1100,
    );
    final fingerprintPainter = _buildTextPainter(
      'Forensic fingerprint ${_publicFingerprint(result, publicProfile)}',
      const TextStyle(
        color: Color(0xFF738596),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: 1100,
    );
    final disclaimerPainter = _buildTextPainter(
      'This card summarizes a local device analysis result and is not a certification of origin.',
      const TextStyle(
        color: Color(0xFF8393A2),
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      maxWidth: 1100,
    );
    final headlineOffset = Offset(80, startY);
    final fingerprintOffset = Offset(80, startY + headlinePainter.height + 10);
    final disclaimerOffset = Offset(
      80,
      fingerprintOffset.dy + fingerprintPainter.height + 10,
    );
    final bottom = disclaimerOffset.dy + disclaimerPainter.height;
    return _FooterLayout(
      headlinePainter: headlinePainter,
      headlineOffset: headlineOffset,
      fingerprintPainter: fingerprintPainter,
      fingerprintOffset: fingerprintOffset,
      disclaimerPainter: disclaimerPainter,
      disclaimerOffset: disclaimerOffset,
      bottom: bottom,
    );
  }

  void _drawFooter(Canvas canvas, _FooterLayout layout) {
    layout.headlinePainter.paint(canvas, layout.headlineOffset);
    layout.fingerprintPainter.paint(canvas, layout.fingerprintOffset);
    layout.disclaimerPainter.paint(canvas, layout.disclaimerOffset);
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
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, width, 56),
      const Radius.circular(999),
    );
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

  void _drawAdaptivePill(
    Canvas canvas, {
    required String text,
    required double right,
    required double y,
    required double maxWidth,
    Color fill = const Color(0x1FFFFFFF),
    Color foreground = Colors.white,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: foreground,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: maxWidth - 44);
    final width = (painter.width + 44).clamp(180.0, maxWidth);
    _drawPill(
      canvas,
      text: text,
      x: right - width,
      y: y,
      width: width,
      fill: fill,
      foreground: foreground,
    );
  }

  TextPainter _buildTextPainter(
    String text,
    TextStyle style, {
    double? maxWidth,
  }) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: maxWidth ?? double.infinity);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    double? maxWidth,
    int? maxLines,
    String? ellipsis,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      maxLines: maxLines ?? (maxWidth == null ? 1 : null),
      ellipsis: ellipsis,
    )..layout(maxWidth: maxWidth ?? double.infinity);
    painter.paint(canvas, offset);
  }

  String _safeKey(String input) {
    final normalized = input.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
    if (normalized.isEmpty) return 'analysis';
    // Use up to 200 chars — enough to include both model hash and image hash
    // from a fingerprint of the form "<model_sha256>__<image_sha256>" (129 chars).
    // Truncating to 40 was causing all images to share the same filename prefix
    // (identical model hash), which collapsed all reports into one.
    return normalized.length > 200
        ? normalized.substring(0, 200)
        : normalized;
  }

  String _publicFingerprint(
    AnalysisResult result,
    PublicModelProfile publicProfile,
  ) {
    final raw = result.analysisFingerprint;
    if (raw.isEmpty) {
      return '${publicProfile.signature}-PENDING';
    }
    final digest = raw.contains('::') ? raw.split('::').last : raw;
    final suffix = digest.length <= 8
        ? digest
        : digest.substring(digest.length - 8);
    return '${publicProfile.signature}-${suffix.toUpperCase()}';
  }
}

class _AssessmentLayout {
  const _AssessmentLayout({
    required this.top,
    required this.height,
    required this.decisionPainter,
    required this.confidencePainter,
    required this.summaryPainter,
    required this.titleOffset,
    required this.decisionOffset,
    required this.confidenceOffset,
    required this.summaryOffset,
    required this.pillRect,
  });

  final double top;
  final double height;
  final TextPainter decisionPainter;
  final TextPainter confidencePainter;
  final TextPainter summaryPainter;
  final Offset titleOffset;
  final Offset decisionOffset;
  final Offset confidenceOffset;
  final Offset summaryOffset;
  final Rect pillRect;

  double get bottom => top + height;
}

class _ExplanationLayout {
  const _ExplanationLayout({
    required this.top,
    required this.height,
    required this.titleOffset,
    required this.bodyOffset,
    required this.bodyPainter,
  });

  final double top;
  final double height;
  final Offset titleOffset;
  final Offset bodyOffset;
  final TextPainter bodyPainter;

  double get bottom => top + height;
}

class _FooterLayout {
  const _FooterLayout({
    required this.headlinePainter,
    required this.headlineOffset,
    required this.fingerprintPainter,
    required this.fingerprintOffset,
    required this.disclaimerPainter,
    required this.disclaimerOffset,
    required this.bottom,
  });

  final TextPainter headlinePainter;
  final Offset headlineOffset;
  final TextPainter fingerprintPainter;
  final Offset fingerprintOffset;
  final TextPainter disclaimerPainter;
  final Offset disclaimerOffset;
  final double bottom;
}
