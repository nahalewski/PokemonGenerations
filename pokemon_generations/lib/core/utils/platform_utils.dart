import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

class PlatformUtils {
  static bool get isWeb => kIsWeb;
  
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  static bool get isNative => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  
  static bool get isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
