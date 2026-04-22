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
