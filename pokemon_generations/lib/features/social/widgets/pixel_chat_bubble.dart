import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';

class PixelChatBubble extends StatelessWidget {
  final Widget child;
  final bool isMe;
  final Color? borderColor;

  const PixelChatBubble({
    super.key,
    required this.child,
    required this.isMe,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isMe ? AppColors.primary : AppColors.secondary;
    final finalBorderColor = borderColor ?? primaryColor.withOpacity(0.5);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          // Glass background
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: finalBorderColor,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: child,
              ),
            ),
          ),
          
          // Pixel corner accents (Top Left)
          Positioned(
            top: 0,
            left: 0,
            child: _buildPixelCorner(finalBorderColor),
          ),
          
          // Pixel corner accents (Bottom Right)
          Positioned(
            bottom: 0,
            right: 0,
            child: RotatedBox(
              quarterTurns: 2,
              child: _buildPixelCorner(finalBorderColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPixelCorner(Color color) {
    return SizedBox(
      width: 12,
      height: 12,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: _pixel(color, 4)),
          Positioned(top: 0, left: 4, child: _pixel(color, 4)),
          Positioned(top: 4, left: 0, child: _pixel(color, 4)),
        ],
      ),
    );
  }

  Widget _pixel(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }
}
