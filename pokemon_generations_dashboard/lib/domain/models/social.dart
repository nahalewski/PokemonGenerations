class SocialUser {
  final String username;
  final String displayName;
  final List<PokemonRosterItem> roster;
  final String status;
  final int wins;

  SocialUser({
    required this.username,
    required this.displayName,
    this.roster = const [],
    this.status = 'offline',
    this.wins = 0,
  });

  factory SocialUser.fromJson(Map<String, dynamic> json) {
    return SocialUser(
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      status: json['status'] ?? 'offline',
      wins: json['wins'] ?? 0,
      roster: (json['roster'] as List? ?? [])
          .map((e) => PokemonRosterItem.fromJson(e))
          .toList(),
    );
  }
}

class PokemonRosterItem {
  final String pokemonId;

  PokemonRosterItem({required this.pokemonId});

  factory PokemonRosterItem.fromJson(Map<String, dynamic> json) {
    return PokemonRosterItem(
      pokemonId: json['pokemonId'] ?? '',
    );
  }
}

class ChatMessage {
  final String id;
  final String sender;
  final String text;
  final String timestamp;
  final String? ip;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.ip,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      sender: json['sender'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] ?? '',
      ip: json['ip'],
    );
  }
}

