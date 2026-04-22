import 'dart:convert';
import 'pokemon_form.dart';

class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.passcodeHash,
    this.inventory = const {'potion': 5, 'revive': 3},
    this.roster = const [],
    this.pcStorage = const [],
    this.wins = 0,
    this.losses = 0,
    this.isSuspended = false,
    this.forcePasscodeChange = false,
    this.profileImageUrl,
    this.pokedollars = 0,
    this.createdAt,
    this.achievements = const [],
    this.bank = const {},
    this.forSaleItems = const [],
    this.agreedToBankTerms = false,
    this.job,
    this.id = '',
  });

  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String passcodeHash;
  final Map<String, int> inventory;
  final List<PokemonForm> roster;
  final List<PokemonForm> pcStorage;
  final int wins;
  final int losses;
  final bool isSuspended;
  final bool forcePasscodeChange;
  final String? profileImageUrl;
  final int pokedollars;
  final DateTime? createdAt;
  final List<String> achievements;
  final Map<String, dynamic> bank;
  final List<dynamic> forSaleItems;
  final bool agreedToBankTerms;
  final UserJob? job;

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? username,
    String? passcodeHash,
    Map<String, int>? inventory,
    List<PokemonForm>? roster,
    List<PokemonForm>? pcStorage,
    int? wins,
    int? losses,
    bool? isSuspended,
    bool? forcePasscodeChange,
    String? profileImageUrl,
    int? pokedollars,
    DateTime? createdAt,
    List<String>? achievements,
    Map<String, dynamic>? bank,
    List<dynamic>? forSaleItems,
    bool? agreedToBankTerms,
    UserJob? job,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      passcodeHash: passcodeHash ?? this.passcodeHash,
      inventory: inventory ?? this.inventory,
      roster: roster ?? this.roster,
      pcStorage: pcStorage ?? this.pcStorage,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      isSuspended: isSuspended ?? this.isSuspended,
      forcePasscodeChange: forcePasscodeChange ?? this.forcePasscodeChange,
      pokedollars: pokedollars ?? this.pokedollars,
      createdAt: createdAt ?? this.createdAt,
      achievements: achievements ?? this.achievements,
      bank: bank ?? this.bank,
      forSaleItems: forSaleItems ?? this.forSaleItems,
      agreedToBankTerms: agreedToBankTerms ?? this.agreedToBankTerms,
      job: job ?? this.job,
    );
  }

  String get displayName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'passcodeHash': passcodeHash,
      'inventory': inventory,
      'roster': roster.map((e) => e.toJson()).toList(),
      'pcStorage': pcStorage.map((e) => e.toJson()).toList(),
      'wins': wins,
      'losses': losses,
      'isSuspended': isSuspended,
      'forcePasscodeChange': forcePasscodeChange,
      'profileImageUrl': profileImageUrl,
      'pokedollars': pokedollars,
      'createdAt': createdAt?.toIso8601String(),
      'achievements': achievements,
      'bank': bank,
      'forSaleItems': forSaleItems,
      'agreedToBankTerms': agreedToBankTerms,
      'job': job?.toJson(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      passcodeHash: (json['passcodeHash'] ?? '').toString(),
      inventory: Map<String, int>.from(json['inventory'] ?? {'potion': 5, 'revive': 3}),
      roster: (json['roster'] as List? ?? []).map((e) => PokemonForm.fromJson(e)).toList(),
      pcStorage: (json['pcStorage'] as List? ?? []).map((e) => PokemonForm.fromJson(e)).toList(),
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      isSuspended: json['isSuspended'] ?? false,
      forcePasscodeChange: json['forcePasscodeChange'] ?? false,
      profileImageUrl: json['profileImageUrl']?.toString(),
      pokedollars: json['pokedollars'] ?? 10000,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      achievements: List<String>.from(json['achievements'] ?? []),
      bank: Map<String, dynamic>.from(json['bank'] ?? {}),
      forSaleItems: List<dynamic>.from(json['forSaleItems'] ?? []),
    );
  }

  String encode() => jsonEncode(toJson());

  factory UserProfile.decode(String source) {
    return UserProfile.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}

class UserJob {
  final String title;
  final int salary;

  const UserJob({required this.title, required this.salary});

  Map<String, dynamic> toJson() => {'title': title, 'salary': salary};
  factory UserJob.fromJson(Map<String, dynamic> json) => UserJob(
    title: json['title'] ?? 'Trainer',
    salary: json['salary'] ?? 0,
  );
}
