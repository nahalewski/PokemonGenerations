class AppUpdateInfo {
  const AppUpdateInfo({
    required this.updateAvailable,
    required this.version,
    required this.buildNumber,
    required this.downloadUrl,
    required this.fileName,
    required this.fileSizeBytes,
    this.sha1,
    this.publishedAt,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      updateAvailable: json['updateAvailable'] == true,
      version: (json['version'] ?? '0.0.0').toString(),
      buildNumber: (json['buildNumber'] ?? '0').toString(),
      downloadUrl: (json['downloadUrl'] ?? '').toString(),
      fileName: (json['fileName'] ?? '').toString(),
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      sha1: json['sha1']?.toString(),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.tryParse(json['publishedAt'].toString()),
    );
  }

  final bool updateAvailable;
  final String version;
  final String buildNumber;
  final String downloadUrl;
  final String fileName;
  final int fileSizeBytes;
  final String? sha1;
  final DateTime? publishedAt;

  String get displayVersion => '$version+$buildNumber';
  double get fileSizeMb => fileSizeBytes / (1024 * 1024);
}
