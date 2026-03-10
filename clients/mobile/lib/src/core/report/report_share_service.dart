import 'dart:ui' show Rect;

import 'package:share_plus/share_plus.dart';

class ReportShareService {
  const ReportShareService();

  Future<void> shareReport({
    required String reportPath,
    required String title,
    required String summary,
    Rect? sharePositionOrigin,
  }) async {
    final params = ShareParams(
      files: <XFile>[XFile(reportPath)],
      text: '$title\n$summary',
      subject: title,
      sharePositionOrigin: sharePositionOrigin,
    );
    await SharePlus.instance.share(params);
  }
}
