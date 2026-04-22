class StorageService {
  Future<String> getStorageUsage() async {
    return "0 MB (Web)";
  }

  Future<void> clearCache() async {
    // No-op for web
  }
}
