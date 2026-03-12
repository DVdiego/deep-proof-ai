import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../batch/review_batch.dart';
import '../model_package/model_package.dart';
import 'analysis_report_service.dart';

class BatchReportService {
  const BatchReportService();

  static const double _width = 1280.0;
  static const double _cardWidth = 1160.0;

  Future<GeneratedReport> generate({
    required ReviewBatch batch,
    required List<ReviewBatchItem> items,
    required PublicModelProfile publicProfile,
    required Directory reportsDirectory,
  }) async {
    await reportsDirectory.create(recursive: true);
    final fileName = 'batch_report_v1_${batch.batchId}.png';
    final outputFile = File('${reportsDirectory.path}/$fileName');

    final summaryText =
        'This case groups ${batch.completedCount} completed analyses out of ${batch.totalCount} selected images. '
        '${batch.authenticCount} look likely authentic, ${batch.needsReviewCount} need closer review and ${batch.aiCount} show stronger AI indicators.';
    final priorityItems = items
        .where((item) => item.isPriority)
        .take(8)
        .toList(growable: false);
    final summaryPainter = _painter(
      summaryText,
      const TextStyle(
        color: Color(0xFF213140),
        fontSize: 32,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      maxWidth: 1040,
    );
    final priorityPainters = priorityItems
        .map(
          (item) => _painter(
            '• ${item.fileName} — ${item.decisionLabel}${item.priorityReason.isNotEmpty ? ' · ${item.priorityReason}' : ''}',
            const TextStyle(
              color: Color(0xFF385062),
              fontSize: 24,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
            maxWidth: 1020,
          ),
        )
        .toList(growable: false);
    final priorityHeight = priorityPainters.fold<double>(
      0,
      (total, painter) => total + painter.height + 12,
    );
    final listTitleHeight = priorityItems.isEmpty ? 0.0 : 42.0;
    final priorityCardHeight =
        48 +
        listTitleHeight +
        priorityHeight +
        (priorityItems.isEmpty ? 40 : 22);
    final footerTop = 1044 + priorityCardHeight + 54;
    final footerPainter = _painter(
      'AI Authenticity · ${publicProfile.name} ${publicProfile.version} · Batch summary',
      const TextStyle(
        color: Color(0xFF738596),
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      maxWidth: 1100,
    );
    final height = footerTop + footerPainter.height + 84;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, _width, height));

    _drawBackground(canvas, height);
    _drawHeader(canvas, publicProfile);
    _drawMetrics(canvas, batch);
    _drawSummary(canvas, summaryPainter);
    _drawPriorityList(
      canvas,
      priorityItems,
      priorityPainters,
      priorityCardHeight,
    );
    footerPainter.paint(canvas, Offset(80, footerTop));
    _drawText(
      canvas,
      'Review first: ${batch.priorityCount} item${batch.priorityCount == 1 ? '' : 's'} need follow-up. Open the case in-app to inspect every image.',
      Offset(80, footerTop + footerPainter.height + 12),
      const TextStyle(
        color: Color(0xFF8393A2),
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      maxWidth: 1100,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(_width.toInt(), height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await outputFile.writeAsBytes(bytes!.buffer.asUint8List());
    return GeneratedReport(path: outputFile.path, fileName: fileName);
  }

  void _drawBackground(Canvas canvas, double height) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFF5F8FA), Color(0xFFEAF2F7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, _width, height));
    canvas.drawRect(Rect.fromLTWH(0, 0, _width, height), paint);
  }

  void _drawHeader(Canvas canvas, PublicModelProfile publicProfile) {
    _card(
      canvas,
      const Rect.fromLTWH(60, 56, 1160, 220),
      const Color(0xFF08202B),
    );
    _drawText(
      canvas,
      'AI Authenticity',
      const Offset(100, 100),
      const TextStyle(
        color: Colors.white,
        fontSize: 54,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
    );
    _drawText(
      canvas,
      'Professional case summary',
      const Offset(100, 166),
      const TextStyle(
        color: Color(0xFFD2EAF5),
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
    );
    _pill(
      canvas,
      text: '${publicProfile.name} · ${publicProfile.version}',
      x: 764,
      y: 156,
      width: 360,
    );
  }

  void _drawMetrics(Canvas canvas, ReviewBatch batch) {
    _card(canvas, const Rect.fromLTWH(60, 320, 1160, 248), Colors.white);
    _drawText(
      canvas,
      batch.name,
      const Offset(100, 364),
      const TextStyle(
        color: Color(0xFF152634),
        fontSize: 42,
        fontWeight: FontWeight.w800,
      ),
      maxWidth: 780,
    );
    _drawText(
      canvas,
      '${batch.completedCount}/${batch.totalCount} analyzed · ${batch.failedCount} blocked/failed · ${batch.averageConfidence.toStringAsFixed(1)}% average confidence',
      const Offset(100, 426),
      const TextStyle(
        color: Color(0xFF5B6D7D),
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      maxWidth: 900,
    );
    final chips = [
      '${batch.authenticCount} authentic',
      '${batch.needsReviewCount} need review',
      '${batch.aiCount} AI',
      '${batch.priorityCount} priority',
    ];
    var x = 100.0;
    for (final chip in chips) {
      final width =
          (_painter(
                    chip,
                    const TextStyle(
                      color: Color(0xFF315063),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ).width +
                  40)
              .clamp(180.0, 280.0);
      _pill(
        canvas,
        text: chip,
        x: x,
        y: 480,
        width: width,
        fill: const Color(0xFFEAF1F6),
        foreground: const Color(0xFF315063),
      );
      x += width + 14;
    }
  }

  void _drawSummary(Canvas canvas, TextPainter summaryPainter) {
    final height = summaryPainter.height + 92;
    _card(
      canvas,
      Rect.fromLTWH(60, 612, _cardWidth, height),
      const Color(0xFFF8FBFD),
    );
    _drawText(
      canvas,
      'Case summary',
      const Offset(100, 654),
      const TextStyle(
        color: Color(0xFF617384),
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    );
    summaryPainter.paint(canvas, const Offset(100, 698));
  }

  void _drawPriorityList(
    Canvas canvas,
    List<ReviewBatchItem> items,
    List<TextPainter> painters,
    double cardHeight,
  ) {
    _card(
      canvas,
      Rect.fromLTWH(60, 1044, _cardWidth, cardHeight),
      Colors.white,
    );
    _drawText(
      canvas,
      'Review first',
      const Offset(100, 1088),
      const TextStyle(
        color: Color(0xFF152634),
        fontSize: 32,
        fontWeight: FontWeight.w800,
      ),
    );
    if (items.isEmpty) {
      _drawText(
        canvas,
        'This case has no priority items right now.',
        const Offset(100, 1140),
        const TextStyle(
          color: Color(0xFF5B6D7D),
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      );
      return;
    }
    var y = 1140.0;
    for (final painter in painters) {
      painter.paint(canvas, Offset(100, y));
      y += painter.height + 12;
    }
  }

  TextPainter _painter(String text, TextStyle style, {double? maxWidth}) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: maxWidth ?? double.infinity);
  }

  void _card(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(36)),
      paint,
    );
  }

  void _pill(
    Canvas canvas, {
    required String text,
    required double x,
    required double y,
    required double width,
    Color fill = const Color(0x1FFFFFFF),
    Color foreground = Colors.white,
  }) {
    final paint = Paint()..color = fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, width, 56),
        const Radius.circular(999),
      ),
      paint,
    );
    _drawText(
      canvas,
      text,
      Offset(x + 20, y + 12),
      TextStyle(color: foreground, fontSize: 22, fontWeight: FontWeight.w700),
      maxWidth: width - 40,
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
    )..layout(maxWidth: maxWidth ?? double.infinity);
    painter.paint(canvas, offset);
  }
}
