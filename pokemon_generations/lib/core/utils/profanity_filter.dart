class ProfanityFilter {
  static final List<String> _blockedWords = [
    'fuck', 'shit', 'piss', 'cunt', 'bitch', 'asshole', 'dick', 'pussy', 'bastard'
  ];

  static String filter(String text) {
    String filtered = text;
    for (final word in _blockedWords) {
      final pattern = RegExp(word, caseSensitive: false);
      filtered = filtered.replaceAllMapped(pattern, (match) {
        final original = match.group(0)!;
        if (original.length <= 2) return '*' * original.length;
        return '${original[0]}${'*' * (original.length - 2)}${original[original.length - 1]}';
      });
    }
    return filtered;
  }
}
