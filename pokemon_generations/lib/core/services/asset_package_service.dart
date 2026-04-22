import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';

import '../../domain/models/asset_package.dart';

final assetPackageServiceProvider = Provider<AssetPackageService>(
  (ref) => AssetPackageService(),
);

/// Resolves first-launch status once and caches it in Riverpod.
/// The router watches this so it only triggers one SharedPreferences read.
final isFirstAssetLaunchProvider = FutureProvider<bool>((ref) {
  return ref.read(assetPackageServiceProvider).isFirstLaunch();
});

class AssetDownloadProgress {
  const AssetDownloadProgress({
    required this.packageId,
    required this.received,
    required this.total,
    this.done = false,
    this.error,
  });

  final String packageId;
  final int received;
  final int total;
  final bool done;
  final String? error;

  double get fraction => total > 0 ? (received / total).clamp(0.0, 1.0) : 0.0;
  double get receivedMb => received / (1024 * 1024);
  double get totalMb => total / (1024 * 1024);
}

class AssetPackageService {
  final Dio _dio = Dio();

  static const _prefPrefix = 'asset_pkg_v_';
  static const _initKey = 'asset_packages_initialized';

  // ── Manifest ────────────────────────────────────────────────────────────────

  Future<AssetManifestResponse?> fetchManifest(String baseUrl) async {
    try {
      final url = '${baseUrl.trimRight()}/api/asset-manifest';
      final resp = await _dio.get<Map<String, dynamic>>(url);
      if (resp.data == null) return null;
      return AssetManifestResponse.fromJson(resp.data!);
    } catch (_) {
      return null;
    }
  }

  // ── Installation state ───────────────────────────────────────────────────────

  Future<bool> isFirstLaunch() async {
    if (kIsWeb) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_initKey) != true;
  }

  Future<void> markInitialized() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_initKey, true);
  }

  Future<String?> getInstalledVersion(String packageId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefPrefix$packageId');
  }

  Future<bool> isPackageUpToDate(AssetPackageInfo pkg) async {
    final installed = await getInstalledVersion(pkg.id);
    return installed == pkg.version;
  }

  Future<void> _markPackageInstalled(String id, String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefPrefix$id', version);
  }

  // ── Download ─────────────────────────────────────────────────────────────────

  Stream<AssetDownloadProgress> downloadPackage(
    AssetPackageInfo pkg,
    String baseUrl,
  ) async* {
    if (kIsWeb) {
      yield AssetDownloadProgress(
        packageId: pkg.id,
        received: 1,
        total: 1,
        done: true,
      );
      return;
    }

    final url = pkg.downloadUrl.startsWith('http')
        ? pkg.downloadUrl
        : '${baseUrl.trimRight()}${pkg.downloadUrl}';

    final destDir = await _packageDirectory(pkg.id);
    final zipPath = p.join(destDir.path, '${pkg.id}.zip');

    final controller = StreamController<AssetDownloadProgress>();

    _dio
        .download(
          url,
          zipPath,
          deleteOnError: true,
          onReceiveProgress: (received, total) {
            controller.add(AssetDownloadProgress(
              packageId: pkg.id,
              received: received,
              total: total > 0 ? total : pkg.sizeBytes,
            ));
          },
        )
        .then((_) async {
          await _extractZip(zipPath, destDir.path);
          await _markPackageInstalled(pkg.id, pkg.version);
          controller.add(AssetDownloadProgress(
            packageId: pkg.id,
            received: pkg.sizeBytes,
            total: pkg.sizeBytes,
            done: true,
          ));
          await controller.close();
        })
        .catchError((Object e) {
          controller.add(AssetDownloadProgress(
            packageId: pkg.id,
            received: 0,
            total: 0,
            error: e.toString(),
          ));
          controller.close();
        });

    yield* controller.stream;
  }

  /// Returns the local file path for an asset within a package, or null.
  Future<String?> resolveLocalPath(String packageId, String relativePath) async {
    if (kIsWeb) return null;
    final dir = await _packageDirectory(packageId);
    final file = File(p.join(dir.path, relativePath));
    if (await file.exists()) return file.path;
    return null;
  }

  Future<Directory> _packageDirectory(String packageId) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'asset_packages', packageId));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _extractZip(String zipPath, String destDir) async {
    final zipFile = File(zipPath);
    if (!await zipFile.exists()) return;

    final bytes = await zipFile.readAsBytes();
    final archive = _decodeZip(bytes);

    for (final file in archive) {
      final outPath = p.join(destDir, file.name);
      if (file.isFile) {
        final outFile = File(outPath);
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      }
    }

    await zipFile.delete();
  }

  List<_ZipEntry> _decodeZip(Uint8List bytes) {
    final entries = <_ZipEntry>[];
    int offset = 0;

    while (offset < bytes.length - 4) {
      if (bytes[offset] != 0x50 ||
          bytes[offset + 1] != 0x4B ||
          bytes[offset + 2] != 0x03 ||
          bytes[offset + 3] != 0x04) {
        break;
      }

      final compression = bytes[offset + 8] | (bytes[offset + 9] << 8);
      final compressedSize = bytes[offset + 18] |
          (bytes[offset + 19] << 8) |
          (bytes[offset + 20] << 16) |
          (bytes[offset + 21] << 24);
      final fileNameLen = bytes[offset + 26] | (bytes[offset + 27] << 8);
      final extraLen = bytes[offset + 28] | (bytes[offset + 29] << 8);

      final nameBytes = bytes.sublist(offset + 30, offset + 30 + fileNameLen);
      final name = utf8.decode(nameBytes, allowMalformed: true);
      final dataStart = offset + 30 + fileNameLen + extraLen;
      final compressedData =
          bytes.sublist(dataStart, dataStart + compressedSize);

      final List<int> content;
      if (compression == 0) {
        content = compressedData;
      } else if (compression == 8) {
        content = zlib.decode(compressedData);
      } else {
        content = compressedData;
      }

      entries.add(_ZipEntry(
        name: name,
        content: content,
        isFile: !name.endsWith('/'),
        uncompressedSize: compressedSize,
      ));

      offset = dataStart + compressedSize;
    }

    return entries;
  }
}

class _ZipEntry {
  const _ZipEntry({
    required this.name,
    required this.content,
    required this.isFile,
    required this.uncompressedSize,
  });

  final String name;
  final List<int> content;
  final bool isFile;
  final int uncompressedSize;
}
