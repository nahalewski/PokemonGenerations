import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/update_download_listener.dart';
import 'core/theme/app_theme.dart';
import 'core/services/presence_service.dart';
import 'core/services/gamepad_service.dart';
import 'features/social/widgets/social_notification_widgets.dart';
import 'core/widgets/immersive_background.dart';
import 'features/home/widgets/initialization_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const ProviderScope(child: PokemonGenerationsApp()));
}

class PokemonGenerationsApp extends ConsumerWidget {
  const PokemonGenerationsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    ref.watch(presenceServiceProvider);
    ref.watch(gamepadWatcherProvider);

    return MaterialApp.router(
      title: 'Pokemon Generations',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Intercept keys that often trigger browser actions on Android (Esc=Back, etc)
        final interceptedChild = Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            final isGamepadConnected = ref.read(gamepadConnectedProvider);
            if (isGamepadConnected) {
              // Block specific keys from bubble-up to browser (Back/Escape triggers history.back on Web)
              if (event.logicalKey == LogicalKeyboardKey.escape ||
                  event.logicalKey == LogicalKeyboardKey.contextMenu ||
                  event.logicalKey == LogicalKeyboardKey.browserBack) {
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: child ?? const SizedBox.shrink(),
        );

        // 1. Global Challenge Listener (Prompt pops up on ANY screen)
        final rootContent = InitializationGate(
          child: GlobalSocialListener(
            child: UpdateDownloadListener(child: interceptedChild),
          ),
        );
        
        // 2. Immersive Pokemon Experience (Signature Poké Ball background & glass frame)
        return ImmersiveWebFrame(child: rootContent);
      },
    );
  }
}
