import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme.dart';
import 'ui/screens/dashboard/dashboard_screen.dart';
import 'ui/windows/spectator_window.dart';
import 'ui/windows/console_window.dart';
import 'ui/windows/pokemon_editor_window.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args[2];
    dynamic decodedArgs;
    try {
      decodedArgs = jsonDecode(argument);
    } catch (e) {
      decodedArgs = {};
    }
    final argsMap = decodedArgs is Map<String, dynamic> ? decodedArgs : <String, dynamic>{};
    final isConsoleWindow = argsMap['args1'] == 'console';
    runApp(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: isConsoleWindow
            ? ConsoleWindow(
                windowController: WindowController.fromWindowId(windowId),
                args: argsMap,
              )
            : argsMap['args1'] == 'pokemon_editor'
              ? PokemonEditorWindow(
                  windowController: WindowController.fromWindowId(windowId),
                  args: argsMap,
                )
              : SpectatorWindow(
                  windowController: WindowController.fromWindowId(windowId),
                  args: argsMap,
                ),
        ),
      ),
    );
    return;
  }

  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    center: true,
    title: 'Pokemon Center Admin',
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    const ProviderScope(
      child: PokemonCenterApp(),
    ),
  );
}

class PokemonCenterApp extends StatelessWidget {
  const PokemonCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Center',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const DashboardScreen(),
    );
  }
}
