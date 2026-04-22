import 'package:flutter/material.dart';
import '../utils/emoji_service.dart';

class EmojiRichText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double emojiSize;

  const EmojiRichText({
    super.key,
    required this.text,
    this.style,
    this.emojiSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> spans = [];
    final RegExp emojiRegex = RegExp(r':([a-z0-9]+):');
    
    int lastMatchEnd = 0;
    
    for (final match in emojiRegex.allMatches(text)) {
      // Add text before emoji
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style,
        ));
      }
      
      final emojiName = match.group(1)!;
      final assetPath = EmojiService.getAssetPath(emojiName);
      
      if (assetPath != null) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Image.asset(
              assetPath,
              width: emojiSize,
              height: emojiSize,
              errorBuilder: (context, error, stackTrace) => Text(':$emojiName:', style: style),
            ),
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: ':$emojiName:',
          style: style,
        ));
      }
      
      lastMatchEnd = match.end;
    }
    
    // Add remaining text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
