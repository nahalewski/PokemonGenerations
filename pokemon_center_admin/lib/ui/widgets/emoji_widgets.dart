import 'package:flutter/material.dart';

class EmojiService {
  static const String emojiAssetPath = 'assets/emojis/';

  static final List<String> availableEmojis = [
    'abra', 'aerodactyl', 'aipom', 'alakazam', 'ampharos', 'arbok', 'arcanine', 'ariados', 
    'articuno', 'azumarill', 'bayleef', 'beedrill', 'bellossom', 'bellsprout', 'blastoise', 
    'blissey', 'bulbasaur', 'butterfree', 'caterpie', 'celebi', 'chansey', 'charizard', 
    'charmander', 'charmeleon', 'chikorita', 'chinchou', 'clefable', 'clefairy', 'cleffa', 
    'cloyster', 'corsola', 'crobat', 'croconaw', 'cubone', 'cyndaquil', 'delibird', 
    'dewgong', 'diglett', 'ditto', 'dodrio', 'doduo', 'donphan', 'dragonair', 'dragonite', 
    'dratini', 'drowzee', 'dugtrio', 'dunsparce', 'eevee', 'ekans', 'electabuzz', 'electrode', 
    'elekid', 'entei', 'espeon', 'exeggcute', 'exeggutor', 'farfetchd', 'fearow', 'feraligatr', 
    'flaaffy', 'flareon', 'forretress', 'furret', 'gastly', 'gengar', 'geodude', 'girafarig', 
    'gligar', 'gloom', 'golbat', 'goldeen', 'golduck', 'golem', 'granbull', 'graveler', 
    'grimer', 'growlithe', 'gyarados', 'haunter', 'heracross', 'hitmonchan', 'hitmonlee', 
    'hitmontop', 'ho-oh', 'hoothoot', 'hoppip', 'horsea', 'houndoom', 'houndour', 'hypno', 
    'igglybuff', 'ivysaur', 'jigglypuff', 'jolteon', 'jumpluff', 'jynx', 'kabuto', 'kabutops', 
    'kadabra', 'kakuna', 'kangaskhan', 'kingdra', 'kingler', 'koffing', 'krabby', 'lanturn', 
    'lapras', 'larvitar', 'ledian', 'ledyba', 'lickitung', 'lugia', 'machamp', 'machoke', 
    'machop', 'magby', 'magcargo', 'magikarp', 'magmar', 'magnemite', 'magneton', 'mankey', 
    'mantine', 'mareep', 'marill', 'marowak', 'meganium', 'meowth', 'metapod', 'mew', 
    'mewtwo', 'miltank', 'misdreavus', 'moltres', 'mrmime', 'muk', 'murkrow', 'natu', 
    'nidoking', 'nidoqueen', 'nidoranf', 'nidoranm', 'nidorina', 'nidorino', 'ninetales', 
    'noctowl', 'octillery', 'oddish', 'omanyte', 'omastar', 'onix', 'paras', 'parasect', 
    'persian', 'phanpy', 'pichu', 'pidgeot', 'pidgeotto', 'pidgey', 'pikachu', 'piloswine', 
    'pineco', 'pinsir', 'politoed', 'poliwag', 'poliwhirl', 'poliwrath', 'ponyta', 'porygon', 
    'porygon2', 'primeape', 'psyduck', 'pupitar', 'quagsire', 'quilava', 'qwilfish', 
    'raichu', 'raikou', 'rapidash', 'raticate', 'rattata', 'remoraid', 'rhydon', 'rhyhorn', 
    'riolu', 'sandshrew', 'sandslash', 'scizor', 'scyther', 'seadra', 'seaking', 'seel', 
    'sentret', 'shellder', 'shuckle', 'skarmory', 'skiploom', 'slowbro', 'slowking', 
    'slowpoke', 'slugma', 'smeargle', 'smoochum', 'sneasel', 'snorlax', 'snubbull', 
    'spearow', 'spinarak', 'squirtle', 'stantler', 'starmie', 'staryu', 'steelix', 
    'sudowoodo', 'suicune', 'sunflora', 'sunkern', 'swinub', 'tangela', 'tauros', 
    'teddiursa', 'tentacool', 'tentacruel', 'togepi', 'togetic', 'totodile', 'typhlosion', 
    'tyranitar', 'tyrogue', 'umbreon', 'unown', 'ursaring', 'vaporeon', 'venomoth', 
    'venonat', 'venusaur', 'victreebel', 'vileplume', 'voltorb', 'vulpix', 'wartortle', 
    'weedle', 'weepinbell', 'weezing', 'wigglytuff', 'wobbuffet', 'wooper', 'xatu', 
    'yanma', 'zapdos', 'zubat'
  ];

  static String? getAssetPath(String name) {
    final cleanName = name.toLowerCase().replaceAll(':', '').trim();
    if (availableEmojis.contains(cleanName)) {
      return '$emojiAssetPath$cleanName.png';
    }
    return null;
  }

  static List<String> searchEmojis(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return availableEmojis.where((e) => e.contains(lowerQuery)).toList();
  }
}

class EmojiRichText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double emojiSize;

  const EmojiRichText({
    super.key,
    required this.text,
    this.style,
    this.emojiSize = 20.0,
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
