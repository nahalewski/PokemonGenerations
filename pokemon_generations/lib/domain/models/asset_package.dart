class AssetPackageInfo {
  const AssetPackageInfo({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.sizeBytes,
    required this.downloadUrl,
    required this.required,
    this.checksum,
  });

  factory AssetPackageInfo.fromJson(Map<String, dynamic> json) {
    return AssetPackageInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      version: (json['version'] ?? '1.0.0').toString(),
      description: (json['description'] ?? '').toString(),
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      downloadUrl: (json['downloadUrl'] ?? '').toString(),
      required: json['required'] == true,
      checksum: json['checksum']?.toString(),
    );
  }

  final String id;
  final String name;
  final String version;
  final String description;
  final int sizeBytes;
  final String downloadUrl;
  final bool required;
  final String? checksum;

  double get sizeMb => sizeBytes / (1024 * 1024);
}

class AssetManifestResponse {
  const AssetManifestResponse({
    required this.manifestVersion,
    required this.packages,
  });

  factory AssetManifestResponse.fromJson(Map<String, dynamic> json) {
    final rawPackages = json['packages'] as List<dynamic>? ?? [];
    return AssetManifestResponse(
      manifestVersion: (json['manifestVersion'] ?? '1').toString(),
      packages: rawPackages
          .map((p) => AssetPackageInfo.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  final String manifestVersion;
  final List<AssetPackageInfo> packages;
}
