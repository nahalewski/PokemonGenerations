import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoggingService {
  Future<void> writeBugToLog(String message, String version, String? userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reports.txt');
      final timestamp = DateTime.now().toIso8601String();
      
      final logEntry = '''
--- BUG REPORT [$timestamp] ---
Version: $version
User ID: ${userId ?? 'Guest'}
Message: $message
-------------------------------
''';
      
      await file.writeAsString(logEntry, mode: FileMode.append);
    } catch (_) {
      // Best effort logging
    }
  }
}
