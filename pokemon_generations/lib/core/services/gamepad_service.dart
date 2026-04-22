import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamepads/gamepads.dart';

enum GamepadAction {
  confirm,       // A (Xbox/Kishi) · Cross (PS5) · B (Switch) · button 0
  cancel,        // B (Xbox/Kishi) · Circle (PS5) · A (Switch) · button 1
  bagAction,     // X (Xbox/Kishi) · Square (PS5) · Y (Switch) · button 2
  pokemonAction, // Y (Xbox/Kishi) · Triangle (PS5) · X (Switch) · button 3
  start,         // Start/Options/Plus · button 9
  up,
  down,
  left,
  right,
}

// Standard Gamepad API button indices — works for:
//   Xbox / Razer Kishi : exact match
//   PS5 DualSense      : same indices, different face labels
//   Switch Pro         : Chrome remaps to standard layout (A=0, B=1)
//   Joy-Con            : each Joy-Con appears as its own gamepad
const _buttonMap = <String, GamepadAction>{
  '0':  GamepadAction.confirm,
  '1':  GamepadAction.cancel,
  '2':  GamepadAction.bagAction,
  '3':  GamepadAction.pokemonAction,
  '9':  GamepadAction.start,
  '12': GamepadAction.up,
  '13': GamepadAction.down,
  '14': GamepadAction.left,
  '15': GamepadAction.right,
  // Some browsers report D-pad on buttons 16-19 instead of 12-15
  '16': GamepadAction.up,
  '17': GamepadAction.down,
  '18': GamepadAction.left,
  '19': GamepadAction.right,
};

final gamepadActionStreamProvider = StreamProvider<GamepadAction>((ref) {
  final controller = StreamController<GamepadAction>.broadcast();

  // Per-axis cooldown: true = currently held past threshold, awaiting reset
  final axisCooldown = <String, bool>{};

  final sub = Gamepads.events.listen((event) {
    // --- Digital buttons ---
    if (event.type == KeyType.button && event.value > 0.5) {
      final action = _buttonMap[event.key];
      if (action != null) controller.add(action);
      return;
    }

    // --- Analog sticks (left stick: axis 0 = X, axis 1 = Y) ---
    if (event.type == KeyType.analog) {
      final axisId = event.key; // "0", "1", "2", "3" …
      final value = event.value;

      if (value.abs() > 0.55 && axisCooldown[axisId] != true) {
        axisCooldown[axisId] = true;
        GamepadAction? action;

        if (axisId == '0') {
          // Left stick horizontal
          action = value > 0 ? GamepadAction.right : GamepadAction.left;
        } else if (axisId == '1') {
          // Left stick vertical (positive = down on most browsers)
          action = value > 0 ? GamepadAction.down : GamepadAction.up;
        }
        // Axes 2 & 3 are the right stick — ignore for navigation

        if (action != null) controller.add(action);
      } else if (value.abs() < 0.25) {
        // Stick returned to neutral — allow next fire
        axisCooldown[axisId] = false;
      }
    }
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});

final gamepadConnectedProvider = StateProvider<bool>((ref) => false);

final gamepadWatcherProvider = Provider<void>((ref) {
  Gamepads.events.listen((event) {
    ref.read(gamepadConnectedProvider.notifier).state = true;
  });
});
