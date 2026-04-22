import 'package:flutter_riverpod/flutter_riverpod.dart';
export 'storage_service_stub.dart'
    if (dart.library.io) 'storage_service_native.dart';

import 'storage_service_stub.dart'
    if (dart.library.io) 'storage_service_native.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
