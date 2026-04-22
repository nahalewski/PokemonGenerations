import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import '../../core/theme.dart';
import 'package:pokemon_center/ui/screens/dashboard/widgets/console_view.dart';

class ConsoleWindow extends StatelessWidget {
  final Map<String, dynamic> args;

  const ConsoleWindow({
    super.key,
    required WindowController windowController,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            // Custom Title Bar for the pop-out
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.surface,
              child: Row(
                children: [
                  const Icon(Icons.terminal_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Text(
                    'SYSTEM CONSOLE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const Expanded(
              child: ConsoleView(isPopOut: true),
            ),
          ],
        ),
      ),
    );
  }
}
