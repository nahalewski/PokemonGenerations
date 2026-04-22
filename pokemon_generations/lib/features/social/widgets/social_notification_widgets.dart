import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../social_controller.dart';
import '../social_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/broadcast_service.dart';
import '../../../domain/models/social.dart';
import '../../../domain/models/gift.dart';

class GlobalSocialListener extends ConsumerWidget {
  final Widget child;

  const GlobalSocialListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(socialControllerProvider);
    final broadcastMsg = state.globalBroadcast?['text'] as String?;

    // 1. Detect if we are in a battle screen to suppress notifications
    late String location;
    try {
      location = GoRouterState.of(context).matchedLocation;
    } catch (_) {
      location = '';
    }

    final isBattleScreen = location.contains('/battle');

    return Stack(
      children: [
        child,

        // Only show overlays if NOT in a battle
        if (!isBattleScreen) ...[
          // Challenges
          if (state.incomingChallenges.isNotEmpty)
            ChallengeNotificationOverlay(
              challenge: state.incomingChallenges.first,
              onAccept: (battleId) {
                ref.read(socialControllerProvider.notifier).acceptBattleChallenge(battleId);
                context.push('/battle/online/$battleId');
              },
              onDecline: (battleId) {},
            ),

          // Broadcast message from admin
          if (broadcastMsg != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: _BroadcastBanner(message: broadcastMsg),
            ),

          // Chat Notifications (Top Toast)
          if (state.unreadMessages.isNotEmpty)
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: ChatNotificationOverlay(
                key: ValueKey(state.unreadMessages.first.id),
                message: state.unreadMessages.first,
                onDismiss: () => ref.read(socialControllerProvider.notifier).dismissMessage(state.unreadMessages.first.id),
                onTap: () {
                  ref.read(socialControllerProvider.notifier).markAllRead();
                  context.push('/social');
                },
              ),
            ),

          // Divine Gift Notification (Full Screen Overlay)
          if (state.pendingGifts.any((g) => !state.dismissedGiftIds.contains(g.id)))
            DivineGiftOverlay(
              gift: state.pendingGifts.firstWhere((g) => !state.dismissedGiftIds.contains(g.id)),
              onDismiss: (id) => ref.read(socialControllerProvider.notifier).dismissGiftNotification(id),
            ),
        ],
        
        // Connectivity LED — anchored to absolute top-right corner
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: state.isServerConnected ? Colors.greenAccent.withValues(alpha: 0.4) : Colors.redAccent.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: state.isServerConnected ? Colors.greenAccent : Colors.redAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (state.isServerConnected)
                        BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.8), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  state.isServerConnected ? 'LIVE' : 'DISCONNECTED',
                  style: TextStyle(
                    color: state.isServerConnected ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChallengeNotificationOverlay extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final Function(String) onAccept;
  final Function(String) onDecline;

  const ChallengeNotificationOverlay({
    super.key,
    required this.challenge,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final challenger = challenge['challenger'] as String;
    final battleId = challenge['battleId'] as String;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blurred background
          GestureDetector(
            onTap: () {}, // Prevent taps passing through
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black26),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Moving flash icon
                    _AnimatedFlashIcon(),
                    const SizedBox(height: 16),
                    Text(
                      'BATTLE CHALLENGE!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$challenger wants to battle!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const Text(
                      'The arena is waiting...',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => onDecline(battleId),
                          child: const Text('DECLINE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          onPressed: () => onAccept(battleId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 8,
                          ),
                          child: const Text('ACCEPT', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatNotificationOverlay extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const ChatNotificationOverlay({
    super.key,
    required this.message,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<ChatNotificationOverlay> createState() => _ChatNotificationOverlayState();
}

class _ChatNotificationOverlayState extends State<ChatNotificationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    // Auto-dismiss after 5 seconds
    _dismissTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) _handleDismiss();
    });
  }

  void _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        onPanUpdate: (details) {
          if (details.delta.dy < -10) _handleDismiss();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  widget.message.sender[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.message.sender.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      widget.message.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                onPressed: _handleDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BroadcastBanner extends ConsumerWidget {
  final String message;
  const _BroadcastBanner({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade900.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12)],
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign, color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.white70),
            onPressed: () => ref.read(socialControllerProvider.notifier).dismissBroadcast(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _AnimatedFlashIcon extends StatefulWidget {
  @override
  State<_AnimatedFlashIcon> createState() => _AnimatedFlashIconState();
}

class _AnimatedFlashIconState extends State<_AnimatedFlashIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.2),
          child: Icon(
            Icons.flash_on,
            color: AppColors.primary,
            size: 80,
            shadows: [
              Shadow(
                color: AppColors.primary.withValues(alpha: _controller.value),
                blurRadius: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}

class DivineGiftOverlay extends StatelessWidget {
  final Gift gift;
  final Function(String) onDismiss;

  const DivineGiftOverlay({
    super.key,
    required this.gift,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
          
          // Cosmic Rays
          Center(
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.amber.withValues(alpha: 0.2),
                    Colors.amber.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCirc,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.amber.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 50,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Arceus Header - Enhanced Visibility
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Golden Glow behind Arceus
                        Container(
                          height: 140,
                          width: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.5),
                                blurRadius: 60,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 220, // Increased height for better visibility
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/divine/arceus_reward.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'DIVINE REWARD',
                      style: TextStyle(
                        color: Colors.amber.shade200,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'The God Pokémon Arceus rewards you...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Item Presentation
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/items/${gift.itemId}.png',
                            height: 80,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2, size: 64, color: Colors.amber),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${gift.quantity}x ${gift.itemId.replaceAll('-', ' ').toUpperCase()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Accept Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => onDismiss(gift.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade200,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 10,
                          shadowColor: Colors.amber.withValues(alpha: 0.5),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 20),
                            SizedBox(width: 12),
                            Text(
                              'ACCEPT DIVINE GIFT',
                              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Separate Positioned 'X'
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 280,
            right: MediaQuery.of(context).size.width / 2 - 190,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 28),
              onPressed: () => onDismiss(gift.id),
            ),
          ),
        ],
      ),
    );
  }
}
