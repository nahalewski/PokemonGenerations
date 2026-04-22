import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<String> getStorageUsage() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final appDir = await getApplicationSupportDirectory();
      
      int totalSize = 0;
      totalSize += await _getDirSize(tempDir);
      totalSize += await _getDirSize(appDir);
      
      return "${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB";
    } catch (_) {
      return "0.0 MB";
    }
  }

  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {
      // Best effort
    }
  }

  Future<int> _getDirSize(Directory dir) async {
    int totalSize = 0;
    try {
      if (dir.existsSync()) {
        await for (final file in dir.list(recursive: true, followLinks: false)) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
    } catch (_) {}
    return totalSize;
  }
}
