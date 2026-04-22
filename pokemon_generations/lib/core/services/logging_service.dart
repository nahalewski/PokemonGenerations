import 'package:flutter_riverpod/flutter_riverpod.dart';
export 'logging_service_stub.dart'
    if (dart.library.io) 'logging_service_native.dart';

import 'logging_service_stub.dart'
    if (dart.library.io) 'logging_service_native.dart';

final loggingServiceProvider = Provider<LoggingService>((ref) => LoggingService());
