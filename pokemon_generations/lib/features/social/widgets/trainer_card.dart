import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/models/social.dart';
import '../../../core/theme/app_colors.dart';

class TrainerCard extends StatelessWidget {
  final SocialUser user;
  final bool compact;

  const TrainerCard({super.key, required this.user, this.compact = false});

  @override
  Widget build(BuildContext context) {
    // Extract customization settings with fallbacks
    final custom = user.cardCustomization;
    final themeColor = _getThemeColor(custom['theme'] ?? 'default');
    final pokemonSprite = custom['signature_sprite'] ?? '';
    final signatureName = custom['signature_name'] ?? 'Pikachu';

    return Container(
      width: compact ? 300 : 400,
      height: compact ? 180 : 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColor.withOpacity(0.8),
            themeColor.withOpacity(0.3),
            Colors.black.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Watermark
            Positioned(
              right: -20,
              bottom: -10,
              child: Text(
                'GENERATIONS',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 60,
                  color: Colors.white.withOpacity(0.05),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            // Pattern Overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _CardPatternPainter(color: Colors.white.withOpacity(0.03)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Left: Signature Pokemon
                  Expanded(
                    flex: 12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (pokemonSprite.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: pokemonSprite,
                            height: compact ? 100 : 140,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack)
                        else
                          Icon(Icons.catching_pokemon, size: 80, color: Colors.white10),
                        const SizedBox(height: 8),
                        Text(
                          signatureName.toUpperCase(),
                          style: GoogleFonts.vt323(
                            color: Colors.white54,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Stats & Info
                  Expanded(
                    flex: 13,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.displayName.toUpperCase(),
                          style: GoogleFonts.vt323(
                            color: Colors.white,
                            fontSize: compact ? 24 : 32,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'RANK: ${user.wins > 50 ? "MASTER" : "TRAINER"}',
                            style: GoogleFonts.vt323(
                              color: themeColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow('WINS', user.wins.toString()),
                        _buildStatRow('LOSSES', user.losses.toString()),
                        const Spacer(),
                        // Badges
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            for (var i = 0; i < 3; i++)
                              _buildBadge(i, themeColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Glassmorphism shine
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: GoogleFonts.vt323(color: Colors.white38, fontSize: 12)),
          const SizedBox(width: 8),
          Text(value, style: GoogleFonts.vt323(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBadge(int index, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Center(
        child: Icon(Icons.stars, size: 14, color: color.withOpacity(0.5)),
      ),
    );
  }

  Color _getThemeColor(String theme) {
    switch (theme.toLowerCase()) {
      case 'fire': return Colors.redAccent;
      case 'water': return Colors.blueAccent;
      case 'electric': return Colors.yellowAccent;
      case 'grass': return Colors.greenAccent;
      case 'psychic': return Colors.purpleAccent;
      default: return AppColors.primary;
    }
  }
}

class _CardPatternPainter extends CustomPainter {
  final Color color;
  _CardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
