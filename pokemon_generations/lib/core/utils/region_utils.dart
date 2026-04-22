class RegionUtils {
  static String getRegionName(String idOrUrl) {
    try {
      final idStr = _extractId(idOrUrl);
      final id = int.tryParse(idStr) ?? 0;

      if (id <= 0) return 'Unknown';
      if (id <= 151) return 'Kanto';
      if (id <= 251) return 'Johto';
      if (id <= 386) return 'Hoenn';
      if (id <= 493) return 'Sinnoh';
      if (id <= 649) return 'Unova';
      if (id <= 721) return 'Kalos';
      if (id <= 809) return 'Alola';
      if (id <= 905) return 'Galar';
      return 'Paldea';
    } catch (_) {
      return 'Unknown';
    }
  }

  static String _extractId(String input) {
    if (input.contains('/')) {
      final parts = input.split('/').where((s) => s.isNotEmpty).toList();
      return parts.last;
    }
    return input;
  }

  static const List<String> regionsOrdered = [
    'Kanto',
    'Johto',
    'Hoenn',
    'Sinnoh',
    'Unova',
    'Kalos',
    'Alola',
    'Galar',
    'Paldea',
    'Unknown',
  ];
}
