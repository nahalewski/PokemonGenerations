import 'package:freezed_annotation/freezed_annotation.dart';

part 'move.freezed.dart';
part 'move.g.dart';

@freezed
class Move with _$Move {
  const factory Move({
    required String id,
    required String name,
    required String type,
    required String category, // Physical, Special, Status
    required int? power,
    required int? accuracy,
    required int pp,
    required int priority,
    required String description,
  }) = _Move;

  factory Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);
}

@freezed
class Ability with _$Ability {
  const factory Ability({
    required String id,
    required String name,
    required String description,
  }) = _Ability;

  factory Ability.fromJson(Map<String, dynamic> json) => _$AbilityFromJson(json);
}

@freezed
class Item with _$Item {
  const factory Item({
    required String id,
    required String name,
    required String description,
    String? spriteUrl,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
