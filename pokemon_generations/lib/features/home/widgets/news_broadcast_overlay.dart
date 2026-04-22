import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class NewsBroadcastOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onClose;

  const NewsBroadcastOverlay({
    super.key,
    required this.message,
    required this.onClose,
  });

  @override
  State<NewsBroadcastOverlay> createState() => _NewsBroadcastOverlayState();
}

class _NewsBroadcastOverlayState extends State<NewsBroadcastOverlay> {
  String _displayedText = '';
  int _charIndex = 0;
  Timer? _typingTimer;
  bool _isFinished = false;
  late AudioPlayer _audioPlayer;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playTheme();
    _startTyping();
  }

  Future<void> _playTheme() async {
    try {
      await _audioPlayer.setSource(AssetSource('audio/news_theme.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/news_theme.mp3'));
    } catch (e) {
      debugPrint('Error playing news theme: $e');
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _scrollController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_charIndex < widget.message.length) {
        if (mounted) {
          setState(() {
            _displayedText += widget.message[_charIndex];
            _charIndex++;
          });
          
          // Auto-scroll to bottom as text types
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        }
      } else {
        timer.cancel();
        if (mounted) setState(() => _isFinished = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling), // Prevent scaling leakage
      child: Material(
        color: Colors.black.withOpacity(0.85),
        child: Stack(
          children: [
            // Background Generated Image
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/news_broadcast_bg.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

            // Typing Text in the Cutout Area
            Align(
              alignment: Alignment.bottomCenter,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive positioning within the broadcast desk cutout
                  final hPadding = constraints.maxWidth * 0.15;
                  final bPadding = constraints.maxHeight * 0.15;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: bPadding, left: hPadding, right: hPadding),
                    child: Container(
                      height: 120, // Tighten height to stay within the box
                      width: 700, 
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        // Optional: helpful to debug boundary
                        // border: Border.all(color: Colors.white10),
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          _displayedText,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 15,
                            height: 1.4,
                            letterSpacing: 0.5,
                            shadows: [
                              const Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),

          // Breaking News Label
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text(
                  'LIVE BROADCAST / URGENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
            ),
          ),

          // Close Button
          if (_isFinished)
            Positioned(
              top: 40,
              right: 40,
              child: IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
              ).animate().fadeIn(),
            ),
        ],
      ),
    ),
  ).animate().fadeIn(duration: 400.ms);
  }
}
