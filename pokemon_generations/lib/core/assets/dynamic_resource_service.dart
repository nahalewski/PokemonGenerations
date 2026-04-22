import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:crypto/crypto.dart';

class DynamicResourceService {
  static const String _baseUrl = 'https://assets.pokemongenerations.app'; // Placeholder
  final Dio _dio = Dio();
  
  /// Checks for asset updates against the server-side manifest.
  Future<Map<String, dynamic>?> checkUpdates() async {
    if (kIsWeb) return null; // Web assets are served statically, no patching manifest needed
    try {
      final response = await _dio.get('$_baseUrl/asset_manifest.json');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print('[DYNAMIC ASSETS] Check failed: $e');
    }
    return null;
  }

  /// Downloads missing or updated assets listed in the manifest.
  Stream<double> downloadPatches(Map<String, dynamic> manifest) async* {
    if (kIsWeb) return; 
    final assets = manifest['assets'] as List<dynamic>;
    final dir = await getApplicationDocumentsDirectory();
    final localAssetsDir = Directory('${dir.path}/patches');
    if (!localAssetsDir.existsSync()) {
      localAssetsDir.createSync(recursive: true);
    }

    int completed = 0;
    for (final asset in assets) {
      final path = asset['file_path'] as String;
      final expectedHash = asset['md5_hash'] as String;
      final url = asset['download_url'] as String? ?? '$_baseUrl/$path';
      final localFile = File('${localAssetsDir.path}/$path');
      
      await localFile.parent.create(recursive: true);

      // Download
      await _dio.download(url, localFile.path);
      
      // Verify MD5
      final bytes = await localFile.readAsBytes();
      final actualHash = md5.convert(bytes).toString();
      
      if (actualHash != expectedHash) {
        print('[DYNAMIC ASSETS] Hash mismatch for $path. Expected: $expectedHash, Got: $actualHash');
        // In a real app, we might retry or delete the faulty file
      }
      
      completed++;
      yield completed / assets.length;
    }
  }

  /// Resolves a resource path to either a local patch or a bundled asset.
  Future<ImageProvider> resolveImage(String assetPath) async {
    if (kIsWeb) return AssetImage(assetPath);
    
    final dir = await getApplicationDocumentsDirectory();
    final patchFile = File('${dir.path}/patches/$assetPath');
    
    if (await patchFile.exists()) {
      return FileImage(patchFile);
    }
    
    // Fallback to bundled asset
    return AssetImage(assetPath);
  }

  /// Checks if any critical patches are missing on first launch.
  Future<bool> needsInitialSync() async {
    if (kIsWeb) return false;
    
    final dir = await getApplicationDocumentsDirectory();
    final patchDir = Directory('${dir.path}/patches');
    // If the folder is empty or non-existent, we need an initial sync
    if (!patchDir.existsSync()) return true;
    final entries = await patchDir.list().length;
    return entries < 10; // Arbitrary threshold for "minimum required assets"
  }
}
