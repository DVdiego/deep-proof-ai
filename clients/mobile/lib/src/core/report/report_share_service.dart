import 'package:share_plus/share_plus.dart';

class ReportShareService {
  const ReportShareService();

  Future<void> shareReport({
    required String reportPath,
    required String title,
    required String summary,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(reportPath)],
        text: '$title\n$summary',
        subject: title,
      ),
    );
  }
}
