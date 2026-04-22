import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

final updateStatusProvider = StreamProvider<UpdateStatus>((ref) async* {
  // We assume the script is in the /devops/ directory
  final statusFile = File(p.join(Directory.current.path, 'devops', 'update_status.json'));
  
  while (true) {
    if (await statusFile.exists()) {
      try {
        final content = await statusFile.readAsString();
        yield UpdateStatus.fromJson(jsonDecode(content));
      } catch (e) {
        print('[UPDATE MONITOR] Error reading status: $e');
      }
    }
    await Future.delayed(const Duration(minutes: 5));
  }
});

class UpdateStatus {
  final String lastCheck;
  final int totalUpdates;
  final int reposChecked;
  final List<dynamic> updates;

  UpdateStatus({
    required this.lastCheck,
    required this.totalUpdates,
    required this.reposChecked,
    required this.updates,
  });

  factory UpdateStatus.fromJson(Map<String, dynamic> json) {
    return UpdateStatus(
      lastCheck: json['last_check'] ?? 'Unknown',
      totalUpdates: json['total_updates'] ?? 0,
      reposChecked: json['repos_checked'] ?? 0,
      updates: json['updates'] ?? [],
    );
  }
}
