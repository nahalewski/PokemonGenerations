import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemon_center/models/service_info.dart';
import 'package:pokemon_center/services/service_notifier.dart';
import 'package:pokemon_center/core/theme.dart';

class ServiceCard extends ConsumerWidget {
  final ServiceInfo service;

  const ServiceCard({super.key, required this.service});

  /// Opens the first http/https URL in macOS's default browser.
  void _openUrl() {
    final url = service.supportedUrls.firstWhere(
      (u) => u.startsWith('http://') || u.startsWith('https://'),
      orElse: () => '',
    );
    if (url.isNotEmpty) {
      Process.run('open', [url]);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color statusColor = _getStatusColor(service.status);
    final bool isOnline = service.status == ServiceStatus.online;
    final bool isStarting = service.status == ServiceStatus.starting;
    final bool isBuilding = service.status == ServiceStatus.building;
    final bool isFailed = service.status == ServiceStatus.failed;
    final urlsToShow = service.supportedUrls.take(2).toList();
    final hiddenUrlCount = service.supportedUrls.length - urlsToShow.length;

    final hasOpenableUrl = service.supportedUrls.any(
      (u) => u.startsWith('http://') || u.startsWith('https://'),
    );

    return InkWell(
      // Tapping the card opens the URL in the browser.
      onTap: hasOpenableUrl ? _openUrl : null,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isOnline
                  ? statusColor.withOpacity(0.08)
                  : (isFailed
                      ? statusColor.withOpacity(0.12)
                      : AppColors.surface.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isOnline || isFailed)
                    ? statusColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.08),
                width: (isOnline || isFailed) ? 2 : 1,
              ),
              boxShadow: [
                if (isOnline || isFailed)
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: status dot + name ──────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                        boxShadow: [
                          if (isOnline || isStarting || isBuilding || isFailed)
                            BoxShadow(
                              color: statusColor.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        service.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 14,
                              color: (isOnline || isFailed)
                                  ? Colors.white
                                  : AppColors.textDim,
                            ),
                      ),
                    ),
                    // Open-in-browser hint icon (only if URL available)
                    if (hasOpenableUrl)
                      Icon(
                        Icons.open_in_browser_rounded,
                        size: 14,
                        color: isOnline
                            ? Colors.white54
                            : AppColors.textDim.withOpacity(0.4),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // ── Description ────────────────────────────────────────────
                Text(
                  service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textDim,
                        fontSize: 10,
                      ),
                ),

                const SizedBox(height: 10),

                // ── URLs ───────────────────────────────────────────────────
                if (urlsToShow.isNotEmpty) ...[
                  Text(
                    'SUPPORTED URLS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textDim,
                          fontSize: 9,
                          letterSpacing: 0.8,
                        ),
                  ),
                  const SizedBox(height: 4),
                  for (final url in urlsToShow)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 9,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  if (hiddenUrlCount > 0)
                    Text(
                      '+$hiddenUrlCount more',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textDim,
                      ),
                    ),
                  const Spacer(),
                ] else
                  const Spacer(),

                // ── Footer: port badge + toggle button ─────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Port badge
                    if (service.port != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'P:${service.port}',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            color: AppColors.accent,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    // Toggle button (start / stop)
                    if (isBuilding)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      _ToggleButton(
                        service: service,
                        isOnline: isOnline,
                        isStarting: isStarting,
                        statusColor: statusColor,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ServiceStatus status) {
    return switch (status) {
      ServiceStatus.online => AppColors.success,
      ServiceStatus.starting => AppColors.warning,
      ServiceStatus.building => AppColors.accent,
      ServiceStatus.failed => AppColors.error,
      ServiceStatus.offline => AppColors.textDim,
    };
  }
}

// ── Toggle Button ──────────────────────────────────────────────────────────────
class _ToggleButton extends ConsumerWidget {
  const _ToggleButton({
    required this.service,
    required this.isOnline,
    required this.isStarting,
    required this.statusColor,
  });

  final ServiceInfo service;
  final bool isOnline;
  final bool isStarting;
  final Color statusColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(serviceProvider.notifier);

    return GestureDetector(
      // Stop event propagation so the toggle doesn't also trigger the card tap.
      onTap: () {
        if (isOnline || isStarting) {
          notifier.stopService(service.id);
        } else {
          notifier.startService(service.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: (isOnline || isStarting)
              ? Colors.red.withOpacity(0.15)
              : Colors.green.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (isOnline || isStarting)
                ? Colors.red.withOpacity(0.4)
                : Colors.green.withOpacity(0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              (isOnline || isStarting)
                  ? Icons.stop_rounded
                  : Icons.play_arrow_rounded,
              size: 12,
              color: (isOnline || isStarting) ? Colors.redAccent : Colors.greenAccent,
            ),
            const SizedBox(width: 4),
            Text(
              (isOnline || isStarting) ? 'Stop' : 'Start',
              style: TextStyle(
                fontSize: 10,
                color: (isOnline || isStarting)
                    ? Colors.redAccent
                    : Colors.greenAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
