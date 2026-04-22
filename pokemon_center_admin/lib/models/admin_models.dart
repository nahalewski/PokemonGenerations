import 'dart:convert';

enum AdminUserStatus { online, offline, battling }

class AdminUser {
  final String username;
  final String displayName;
  final AdminUserStatus status;
  final int wins;
  final int losses;
  final bool suspended;
  final bool forcePasscodeChange;
  final List<dynamic> roster;

  AdminUser({
    required this.username,
    required this.displayName,
    required this.status,
    this.wins = 0,
    this.losses = 0,
    this.suspended = false,
    this.forcePasscodeChange = false,
    this.roster = const [],
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      status: _parseStatus(json['status']),
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      suspended: json['suspended'] ?? false,
      forcePasscodeChange: json['forcePasscodeChange'] ?? false,
      roster: json['roster'] ?? [],
    );
  }

  static AdminUserStatus _parseStatus(String? status) {
    switch (status) {
      case 'online': return AdminUserStatus.online;
      case 'battling': return AdminUserStatus.battling;
      default: return AdminUserStatus.offline;
    }
  }
}

class AdminChatMessage {
  final String id;
  final String sender;
  final String text;
  final DateTime timestamp;
  final String? ip;
  final String? recipient;
  final String type;

  AdminChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.ip,
    this.recipient,
    this.type = 'regular',
  });

  factory AdminChatMessage.fromJson(Map<String, dynamic> json) {
    return AdminChatMessage(
      id: json['id'] ?? '',
      sender: json['sender'] ?? 'Unknown',
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      ip: json['ip'],
      recipient: json['recipient'],
      type: json['type'] ?? 'regular',
    );
  }
}

class AdminBroadcast {
  final String text;
  final DateTime sentAt;
  final String sentBy;

  AdminBroadcast({
    required this.text,
    required this.sentAt,
    required this.sentBy,
  });

  factory AdminBroadcast.fromJson(Map<String, dynamic> json) {
    return AdminBroadcast(
      text: json['text'] ?? '',
      sentAt: DateTime.parse(json['sentAt'] ?? DateTime.now().toIso8601String()),
      sentBy: json['sentBy'] ?? 'System',
    );
  }
}
class LiveBattle {
  final String id;
  final String player1;
  final String player2;
  final int turnCount;
  final String? lastUpdate;
  final String? active1;
  final String? active2;
  final double? hp1;
  final double? hp2;

  LiveBattle({
    required this.id,
    required this.player1,
    required this.player2,
    required this.turnCount,
    this.lastUpdate,
    this.active1,
    this.active2,
    this.hp1,
    this.hp2,
  });

  factory LiveBattle.fromJson(Map<String, dynamic> json) {
    return LiveBattle(
      id: json['id'] ?? '',
      player1: json['player1'] ?? '',
      player2: json['player2'] ?? '',
      turnCount: json['turnCount'] ?? 0,
      lastUpdate: json['lastUpdate'],
      active1: json['active1'],
      active2: json['active2'],
      hp1: (json['hp1'] as num?)?.toDouble(),
      hp2: (json['hp2'] as num?)?.toDouble(),
    );
  }
}

class TelemetryBattle {
  final String id;
  final Map<String, dynamic> playerInfo;
  final Map<String, dynamic> opponentInfo;
  final List<dynamic> log;
  final String status;
  final String lastUpdate;

  TelemetryBattle({
    required this.id,
    required this.playerInfo,
    required this.opponentInfo,
    required this.log,
    required this.status,
    required this.lastUpdate,
  });

  factory TelemetryBattle.fromJson(Map<String, dynamic> json) {
    return TelemetryBattle(
      id: json['id'] ?? '',
      playerInfo: json['playerInfo'] ?? {},
      opponentInfo: json['opponentInfo'] ?? {},
      log: json['log'] ?? [],
      status: json['status'] ?? 'active',
      lastUpdate: json['lastUpdate'] ?? '',
    );
  }
}
