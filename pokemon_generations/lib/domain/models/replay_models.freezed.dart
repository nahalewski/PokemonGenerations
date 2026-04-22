// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'replay_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BattleReplay _$BattleReplayFromJson(Map<String, dynamic> json) {
  return _BattleReplay.fromJson(json);
}

/// @nodoc
mixin _$BattleReplay {
  int get version => throw _privateConstructorUsedError;
  String get battleId => throw _privateConstructorUsedError;
  String get ruleset => throw _privateConstructorUsedError;
  int get startTimestampMs => throw _privateConstructorUsedError;
  int get rngSeed => throw _privateConstructorUsedError;
  ReplayPlayer get p1 => throw _privateConstructorUsedError;
  ReplayPlayer get p2 => throw _privateConstructorUsedError;
  List<ReplayTurn> get turns => throw _privateConstructorUsedError;
  String get winner => throw _privateConstructorUsedError;
  String? get endReason => throw _privateConstructorUsedError;

  /// Serializes this BattleReplay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BattleReplay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BattleReplayCopyWith<BattleReplay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BattleReplayCopyWith<$Res> {
  factory $BattleReplayCopyWith(
    BattleReplay value,
    $Res Function(BattleReplay) then,
  ) = _$BattleReplayCopyWithImpl<$Res, BattleReplay>;
  @useResult
  $Res call({
    int version,
    String battleId,
    String ruleset,
    int startTimestampMs,
    int rngSeed,
    ReplayPlayer p1,
    ReplayPlayer p2,
    List<ReplayTurn> turns,
    String winner,
    String? endReason,
  });

  $ReplayPlayerCopyWith<$Res> get p1;
  $ReplayPlayerCopyWith<$Res> get p2;
}

/// @nodoc
class _$BattleReplayCopyWithImpl<$Res, $Val extends BattleReplay>
    implements $BattleReplayCopyWith<$Res> {
  _$BattleReplayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BattleReplay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? battleId = null,
    Object? ruleset = null,
    Object? startTimestampMs = null,
    Object? rngSeed = null,
    Object? p1 = null,
    Object? p2 = null,
    Object? turns = null,
    Object? winner = null,
    Object? endReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as int,
            battleId: null == battleId
                ? _value.battleId
                : battleId // ignore: cast_nullable_to_non_nullable
                      as String,
            ruleset: null == ruleset
                ? _value.ruleset
                : ruleset // ignore: cast_nullable_to_non_nullable
                      as String,
            startTimestampMs: null == startTimestampMs
                ? _value.startTimestampMs
                : startTimestampMs // ignore: cast_nullable_to_non_nullable
                      as int,
            rngSeed: null == rngSeed
                ? _value.rngSeed
                : rngSeed // ignore: cast_nullable_to_non_nullable
                      as int,
            p1: null == p1
                ? _value.p1
                : p1 // ignore: cast_nullable_to_non_nullable
                      as ReplayPlayer,
            p2: null == p2
                ? _value.p2
                : p2 // ignore: cast_nullable_to_non_nullable
                      as ReplayPlayer,
            turns: null == turns
                ? _value.turns
                : turns // ignore: cast_nullable_to_non_nullable
                      as List<ReplayTurn>,
            winner: null == winner
                ? _value.winner
                : winner // ignore: cast_nullable_to_non_nullable
                      as String,
            endReason: freezed == endReason
                ? _value.endReason
                : endReason // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of BattleReplay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReplayPlayerCopyWith<$Res> get p1 {
    return $ReplayPlayerCopyWith<$Res>(_value.p1, (value) {
      return _then(_value.copyWith(p1: value) as $Val);
    });
  }

  /// Create a copy of BattleReplay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReplayPlayerCopyWith<$Res> get p2 {
    return $ReplayPlayerCopyWith<$Res>(_value.p2, (value) {
      return _then(_value.copyWith(p2: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BattleReplayImplCopyWith<$Res>
    implements $BattleReplayCopyWith<$Res> {
  factory _$$BattleReplayImplCopyWith(
    _$BattleReplayImpl value,
    $Res Function(_$BattleReplayImpl) then,
  ) = __$$BattleReplayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int version,
    String battleId,
    String ruleset,
    int startTimestampMs,
    int rngSeed,
    ReplayPlayer p1,
    ReplayPlayer p2,
    List<ReplayTurn> turns,
    String winner,
    String? endReason,
  });

  @override
  $ReplayPlayerCopyWith<$Res> get p1;
  @override
  $ReplayPlayerCopyWith<$Res> get p2;
}

/// @nodoc
class __$$BattleReplayImplCopyWithImpl<$Res>
    extends _$BattleReplayCopyWithImpl<$Res, _$BattleReplayImpl>
    implements _$$BattleReplayImplCopyWith<$Res> {
  __$$BattleReplayImplCopyWithImpl(
    _$BattleReplayImpl _value,
    $Res Function(_$BattleReplayImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BattleReplay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? battleId = null,
    Object? ruleset = null,
    Object? startTimestampMs = null,
    Object? rngSeed = null,
    Object? p1 = null,
    Object? p2 = null,
    Object? turns = null,
    Object? winner = null,
    Object? endReason = freezed,
  }) {
    return _then(
      _$BattleReplayImpl(
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as int,
        battleId: null == battleId
            ? _value.battleId
            : battleId // ignore: cast_nullable_to_non_nullable
                  as String,
        ruleset: null == ruleset
            ? _value.ruleset
            : ruleset // ignore: cast_nullable_to_non_nullable
                  as String,
        startTimestampMs: null == startTimestampMs
            ? _value.startTimestampMs
            : startTimestampMs // ignore: cast_nullable_to_non_nullable
                  as int,
        rngSeed: null == rngSeed
            ? _value.rngSeed
            : rngSeed // ignore: cast_nullable_to_non_nullable
                  as int,
        p1: null == p1
            ? _value.p1
            : p1 // ignore: cast_nullable_to_non_nullable
                  as ReplayPlayer,
        p2: null == p2
            ? _value.p2
            : p2 // ignore: cast_nullable_to_non_nullable
                  as ReplayPlayer,
        turns: null == turns
            ? _value._turns
            : turns // ignore: cast_nullable_to_non_nullable
                  as List<ReplayTurn>,
        winner: null == winner
            ? _value.winner
            : winner // ignore: cast_nullable_to_non_nullable
                  as String,
        endReason: freezed == endReason
            ? _value.endReason
            : endReason // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BattleReplayImpl implements _BattleReplay {
  const _$BattleReplayImpl({
    required this.version,
    required this.battleId,
    required this.ruleset,
    required this.startTimestampMs,
    required this.rngSeed,
    required this.p1,
    required this.p2,
    required final List<ReplayTurn> turns,
    required this.winner,
    this.endReason,
  }) : _turns = turns;

  factory _$BattleReplayImpl.fromJson(Map<String, dynamic> json) =>
      _$$BattleReplayImplFromJson(json);

  @override
  final int version;
  @override
  final String battleId;
  @override
  final String ruleset;
  @override
  final int startTimestampMs;
  @override
  final int rngSeed;
  @override
  final ReplayPlayer p1;
  @override
  final ReplayPlayer p2;
  final List<ReplayTurn> _turns;
  @override
  List<ReplayTurn> get turns {
    if (_turns is EqualUnmodifiableListView) return _turns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_turns);
  }

  @override
  final String winner;
  @override
  final String? endReason;

  @override
  String toString() {
    return 'BattleReplay(version: $version, battleId: $battleId, ruleset: $ruleset, startTimestampMs: $startTimestampMs, rngSeed: $rngSeed, p1: $p1, p2: $p2, turns: $turns, winner: $winner, endReason: $endReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BattleReplayImpl &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.battleId, battleId) ||
                other.battleId == battleId) &&
            (identical(other.ruleset, ruleset) || other.ruleset == ruleset) &&
            (identical(other.startTimestampMs, startTimestampMs) ||
                other.startTimestampMs == startTimestampMs) &&
            (identical(other.rngSeed, rngSeed) || other.rngSeed == rngSeed) &&
            (identical(other.p1, p1) || other.p1 == p1) &&
            (identical(other.p2, p2) || other.p2 == p2) &&
            const DeepCollectionEquality().equals(other._turns, _turns) &&
            (identical(other.winner, winner) || other.winner == winner) &&
            (identical(other.endReason, endReason) ||
                other.endReason == endReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    version,
    battleId,
    ruleset,
    startTimestampMs,
    rngSeed,
    p1,
    p2,
    const DeepCollectionEquality().hash(_turns),
    winner,
    endReason,
  );

  /// Create a copy of BattleReplay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BattleReplayImplCopyWith<_$BattleReplayImpl> get copyWith =>
      __$$BattleReplayImplCopyWithImpl<_$BattleReplayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BattleReplayImplToJson(this);
  }
}

abstract class _BattleReplay implements BattleReplay {
  const factory _BattleReplay({
    required final int version,
    required final String battleId,
    required final String ruleset,
    required final int startTimestampMs,
    required final int rngSeed,
    required final ReplayPlayer p1,
    required final ReplayPlayer p2,
    required final List<ReplayTurn> turns,
    required final String winner,
    final String? endReason,
  }) = _$BattleReplayImpl;

  factory _BattleReplay.fromJson(Map<String, dynamic> json) =
      _$BattleReplayImpl.fromJson;

  @override
  int get version;
  @override
  String get battleId;
  @override
  String get ruleset;
  @override
  int get startTimestampMs;
  @override
  int get rngSeed;
  @override
  ReplayPlayer get p1;
  @override
  ReplayPlayer get p2;
  @override
  List<ReplayTurn> get turns;
  @override
  String get winner;
  @override
  String? get endReason;

  /// Create a copy of BattleReplay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BattleReplayImplCopyWith<_$BattleReplayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReplayPlayer _$ReplayPlayerFromJson(Map<String, dynamic> json) {
  return _ReplayPlayer.fromJson(json);
}

/// @nodoc
mixin _$ReplayPlayer {
  String get username => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  List<ReplayPokemonState> get team => throw _privateConstructorUsedError;

  /// Serializes this ReplayPlayer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReplayPlayer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReplayPlayerCopyWith<ReplayPlayer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReplayPlayerCopyWith<$Res> {
  factory $ReplayPlayerCopyWith(
    ReplayPlayer value,
    $Res Function(ReplayPlayer) then,
  ) = _$ReplayPlayerCopyWithImpl<$Res, ReplayPlayer>;
  @useResult
  $Res call({
    String username,
    String displayName,
    List<ReplayPokemonState> team,
  });
}

/// @nodoc
class _$ReplayPlayerCopyWithImpl<$Res, $Val extends ReplayPlayer>
    implements $ReplayPlayerCopyWith<$Res> {
  _$ReplayPlayerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReplayPlayer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? displayName = null,
    Object? team = null,
  }) {
    return _then(
      _value.copyWith(
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            team: null == team
                ? _value.team
                : team // ignore: cast_nullable_to_non_nullable
                      as List<ReplayPokemonState>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReplayPlayerImplCopyWith<$Res>
    implements $ReplayPlayerCopyWith<$Res> {
  factory _$$ReplayPlayerImplCopyWith(
    _$ReplayPlayerImpl value,
    $Res Function(_$ReplayPlayerImpl) then,
  ) = __$$ReplayPlayerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String username,
    String displayName,
    List<ReplayPokemonState> team,
  });
}

/// @nodoc
class __$$ReplayPlayerImplCopyWithImpl<$Res>
    extends _$ReplayPlayerCopyWithImpl<$Res, _$ReplayPlayerImpl>
    implements _$$ReplayPlayerImplCopyWith<$Res> {
  __$$ReplayPlayerImplCopyWithImpl(
    _$ReplayPlayerImpl _value,
    $Res Function(_$ReplayPlayerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReplayPlayer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? displayName = null,
    Object? team = null,
  }) {
    return _then(
      _$ReplayPlayerImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        team: null == team
            ? _value._team
            : team // ignore: cast_nullable_to_non_nullable
                  as List<ReplayPokemonState>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplayPlayerImpl implements _ReplayPlayer {
  const _$ReplayPlayerImpl({
    required this.username,
    required this.displayName,
    required final List<ReplayPokemonState> team,
  }) : _team = team;

  factory _$ReplayPlayerImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReplayPlayerImplFromJson(json);

  @override
  final String username;
  @override
  final String displayName;
  final List<ReplayPokemonState> _team;
  @override
  List<ReplayPokemonState> get team {
    if (_team is EqualUnmodifiableListView) return _team;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_team);
  }

  @override
  String toString() {
    return 'ReplayPlayer(username: $username, displayName: $displayName, team: $team)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplayPlayerImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            const DeepCollectionEquality().equals(other._team, _team));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    username,
    displayName,
    const DeepCollectionEquality().hash(_team),
  );

  /// Create a copy of ReplayPlayer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplayPlayerImplCopyWith<_$ReplayPlayerImpl> get copyWith =>
      __$$ReplayPlayerImplCopyWithImpl<_$ReplayPlayerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplayPlayerImplToJson(this);
  }
}

abstract class _ReplayPlayer implements ReplayPlayer {
  const factory _ReplayPlayer({
    required final String username,
    required final String displayName,
    required final List<ReplayPokemonState> team,
  }) = _$ReplayPlayerImpl;

  factory _ReplayPlayer.fromJson(Map<String, dynamic> json) =
      _$ReplayPlayerImpl.fromJson;

  @override
  String get username;
  @override
  String get displayName;
  @override
  List<ReplayPokemonState> get team;

  /// Create a copy of ReplayPlayer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplayPlayerImplCopyWith<_$ReplayPlayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReplayPokemonState _$ReplayPokemonStateFromJson(Map<String, dynamic> json) {
  return _ReplayPokemonState.fromJson(json);
}

/// @nodoc
mixin _$ReplayPokemonState {
  String get pokemonId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get maxHp => throw _privateConstructorUsedError;
  int get currentHp => throw _privateConstructorUsedError;
  List<String> get moveIds => throw _privateConstructorUsedError;
  String? get abilityId => throw _privateConstructorUsedError;
  String? get itemId => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  bool get isShiny => throw _privateConstructorUsedError;

  /// Serializes this ReplayPokemonState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReplayPokemonState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReplayPokemonStateCopyWith<ReplayPokemonState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReplayPokemonStateCopyWith<$Res> {
  factory $ReplayPokemonStateCopyWith(
    ReplayPokemonState value,
    $Res Function(ReplayPokemonState) then,
  ) = _$ReplayPokemonStateCopyWithImpl<$Res, ReplayPokemonState>;
  @useResult
  $Res call({
    String pokemonId,
    String nickname,
    int level,
    int maxHp,
    int currentHp,
    List<String> moveIds,
    String? abilityId,
    String? itemId,
    String? gender,
    bool isShiny,
  });
}

/// @nodoc
class _$ReplayPokemonStateCopyWithImpl<$Res, $Val extends ReplayPokemonState>
    implements $ReplayPokemonStateCopyWith<$Res> {
  _$ReplayPokemonStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReplayPokemonState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pokemonId = null,
    Object? nickname = null,
    Object? level = null,
    Object? maxHp = null,
    Object? currentHp = null,
    Object? moveIds = null,
    Object? abilityId = freezed,
    Object? itemId = freezed,
    Object? gender = freezed,
    Object? isShiny = null,
  }) {
    return _then(
      _value.copyWith(
            pokemonId: null == pokemonId
                ? _value.pokemonId
                : pokemonId // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            maxHp: null == maxHp
                ? _value.maxHp
                : maxHp // ignore: cast_nullable_to_non_nullable
                      as int,
            currentHp: null == currentHp
                ? _value.currentHp
                : currentHp // ignore: cast_nullable_to_non_nullable
                      as int,
            moveIds: null == moveIds
                ? _value.moveIds
                : moveIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            abilityId: freezed == abilityId
                ? _value.abilityId
                : abilityId // ignore: cast_nullable_to_non_nullable
                      as String?,
            itemId: freezed == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            isShiny: null == isShiny
                ? _value.isShiny
                : isShiny // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReplayPokemonStateImplCopyWith<$Res>
    implements $ReplayPokemonStateCopyWith<$Res> {
  factory _$$ReplayPokemonStateImplCopyWith(
    _$ReplayPokemonStateImpl value,
    $Res Function(_$ReplayPokemonStateImpl) then,
  ) = __$$ReplayPokemonStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String pokemonId,
    String nickname,
    int level,
    int maxHp,
    int currentHp,
    List<String> moveIds,
    String? abilityId,
    String? itemId,
    String? gender,
    bool isShiny,
  });
}

/// @nodoc
class __$$ReplayPokemonStateImplCopyWithImpl<$Res>
    extends _$ReplayPokemonStateCopyWithImpl<$Res, _$ReplayPokemonStateImpl>
    implements _$$ReplayPokemonStateImplCopyWith<$Res> {
  __$$ReplayPokemonStateImplCopyWithImpl(
    _$ReplayPokemonStateImpl _value,
    $Res Function(_$ReplayPokemonStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReplayPokemonState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pokemonId = null,
    Object? nickname = null,
    Object? level = null,
    Object? maxHp = null,
    Object? currentHp = null,
    Object? moveIds = null,
    Object? abilityId = freezed,
    Object? itemId = freezed,
    Object? gender = freezed,
    Object? isShiny = null,
  }) {
    return _then(
      _$ReplayPokemonStateImpl(
        pokemonId: null == pokemonId
            ? _value.pokemonId
            : pokemonId // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        maxHp: null == maxHp
            ? _value.maxHp
            : maxHp // ignore: cast_nullable_to_non_nullable
                  as int,
        currentHp: null == currentHp
            ? _value.currentHp
            : currentHp // ignore: cast_nullable_to_non_nullable
                  as int,
        moveIds: null == moveIds
            ? _value._moveIds
            : moveIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        abilityId: freezed == abilityId
            ? _value.abilityId
            : abilityId // ignore: cast_nullable_to_non_nullable
                  as String?,
        itemId: freezed == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        isShiny: null == isShiny
            ? _value.isShiny
            : isShiny // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplayPokemonStateImpl implements _ReplayPokemonState {
  const _$ReplayPokemonStateImpl({
    required this.pokemonId,
    required this.nickname,
    required this.level,
    required this.maxHp,
    required this.currentHp,
    required final List<String> moveIds,
    this.abilityId,
    this.itemId,
    this.gender,
    this.isShiny = false,
  }) : _moveIds = moveIds;

  factory _$ReplayPokemonStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReplayPokemonStateImplFromJson(json);

  @override
  final String pokemonId;
  @override
  final String nickname;
  @override
  final int level;
  @override
  final int maxHp;
  @override
  final int currentHp;
  final List<String> _moveIds;
  @override
  List<String> get moveIds {
    if (_moveIds is EqualUnmodifiableListView) return _moveIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moveIds);
  }

  @override
  final String? abilityId;
  @override
  final String? itemId;
  @override
  final String? gender;
  @override
  @JsonKey()
  final bool isShiny;

  @override
  String toString() {
    return 'ReplayPokemonState(pokemonId: $pokemonId, nickname: $nickname, level: $level, maxHp: $maxHp, currentHp: $currentHp, moveIds: $moveIds, abilityId: $abilityId, itemId: $itemId, gender: $gender, isShiny: $isShiny)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplayPokemonStateImpl &&
            (identical(other.pokemonId, pokemonId) ||
                other.pokemonId == pokemonId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.maxHp, maxHp) || other.maxHp == maxHp) &&
            (identical(other.currentHp, currentHp) ||
                other.currentHp == currentHp) &&
            const DeepCollectionEquality().equals(other._moveIds, _moveIds) &&
            (identical(other.abilityId, abilityId) ||
                other.abilityId == abilityId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.isShiny, isShiny) || other.isShiny == isShiny));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    pokemonId,
    nickname,
    level,
    maxHp,
    currentHp,
    const DeepCollectionEquality().hash(_moveIds),
    abilityId,
    itemId,
    gender,
    isShiny,
  );

  /// Create a copy of ReplayPokemonState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplayPokemonStateImplCopyWith<_$ReplayPokemonStateImpl> get copyWith =>
      __$$ReplayPokemonStateImplCopyWithImpl<_$ReplayPokemonStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplayPokemonStateImplToJson(this);
  }
}

abstract class _ReplayPokemonState implements ReplayPokemonState {
  const factory _ReplayPokemonState({
    required final String pokemonId,
    required final String nickname,
    required final int level,
    required final int maxHp,
    required final int currentHp,
    required final List<String> moveIds,
    final String? abilityId,
    final String? itemId,
    final String? gender,
    final bool isShiny,
  }) = _$ReplayPokemonStateImpl;

  factory _ReplayPokemonState.fromJson(Map<String, dynamic> json) =
      _$ReplayPokemonStateImpl.fromJson;

  @override
  String get pokemonId;
  @override
  String get nickname;
  @override
  int get level;
  @override
  int get maxHp;
  @override
  int get currentHp;
  @override
  List<String> get moveIds;
  @override
  String? get abilityId;
  @override
  String? get itemId;
  @override
  String? get gender;
  @override
  bool get isShiny;

  /// Create a copy of ReplayPokemonState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplayPokemonStateImplCopyWith<_$ReplayPokemonStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReplayTurn _$ReplayTurnFromJson(Map<String, dynamic> json) {
  return _ReplayTurn.fromJson(json);
}

/// @nodoc
mixin _$ReplayTurn {
  int get turnIndex => throw _privateConstructorUsedError;
  List<ReplayEvent> get events => throw _privateConstructorUsedError;

  /// Serializes this ReplayTurn to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReplayTurn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReplayTurnCopyWith<ReplayTurn> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReplayTurnCopyWith<$Res> {
  factory $ReplayTurnCopyWith(
    ReplayTurn value,
    $Res Function(ReplayTurn) then,
  ) = _$ReplayTurnCopyWithImpl<$Res, ReplayTurn>;
  @useResult
  $Res call({int turnIndex, List<ReplayEvent> events});
}

/// @nodoc
class _$ReplayTurnCopyWithImpl<$Res, $Val extends ReplayTurn>
    implements $ReplayTurnCopyWith<$Res> {
  _$ReplayTurnCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReplayTurn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? turnIndex = null, Object? events = null}) {
    return _then(
      _value.copyWith(
            turnIndex: null == turnIndex
                ? _value.turnIndex
                : turnIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            events: null == events
                ? _value.events
                : events // ignore: cast_nullable_to_non_nullable
                      as List<ReplayEvent>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReplayTurnImplCopyWith<$Res>
    implements $ReplayTurnCopyWith<$Res> {
  factory _$$ReplayTurnImplCopyWith(
    _$ReplayTurnImpl value,
    $Res Function(_$ReplayTurnImpl) then,
  ) = __$$ReplayTurnImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int turnIndex, List<ReplayEvent> events});
}

/// @nodoc
class __$$ReplayTurnImplCopyWithImpl<$Res>
    extends _$ReplayTurnCopyWithImpl<$Res, _$ReplayTurnImpl>
    implements _$$ReplayTurnImplCopyWith<$Res> {
  __$$ReplayTurnImplCopyWithImpl(
    _$ReplayTurnImpl _value,
    $Res Function(_$ReplayTurnImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReplayTurn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? turnIndex = null, Object? events = null}) {
    return _then(
      _$ReplayTurnImpl(
        turnIndex: null == turnIndex
            ? _value.turnIndex
            : turnIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        events: null == events
            ? _value._events
            : events // ignore: cast_nullable_to_non_nullable
                  as List<ReplayEvent>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplayTurnImpl implements _ReplayTurn {
  const _$ReplayTurnImpl({
    required this.turnIndex,
    required final List<ReplayEvent> events,
  }) : _events = events;

  factory _$ReplayTurnImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReplayTurnImplFromJson(json);

  @override
  final int turnIndex;
  final List<ReplayEvent> _events;
  @override
  List<ReplayEvent> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  @override
  String toString() {
    return 'ReplayTurn(turnIndex: $turnIndex, events: $events)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplayTurnImpl &&
            (identical(other.turnIndex, turnIndex) ||
                other.turnIndex == turnIndex) &&
            const DeepCollectionEquality().equals(other._events, _events));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    turnIndex,
    const DeepCollectionEquality().hash(_events),
  );

  /// Create a copy of ReplayTurn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplayTurnImplCopyWith<_$ReplayTurnImpl> get copyWith =>
      __$$ReplayTurnImplCopyWithImpl<_$ReplayTurnImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplayTurnImplToJson(this);
  }
}

abstract class _ReplayTurn implements ReplayTurn {
  const factory _ReplayTurn({
    required final int turnIndex,
    required final List<ReplayEvent> events,
  }) = _$ReplayTurnImpl;

  factory _ReplayTurn.fromJson(Map<String, dynamic> json) =
      _$ReplayTurnImpl.fromJson;

  @override
  int get turnIndex;
  @override
  List<ReplayEvent> get events;

  /// Create a copy of ReplayTurn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplayTurnImplCopyWith<_$ReplayTurnImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReplayEvent _$ReplayEventFromJson(Map<String, dynamic> json) {
  return _ReplayEvent.fromJson(json);
}

/// @nodoc
mixin _$ReplayEvent {
  int get timestampMs => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'move', 'damage', 'heal', 'switch', 'status', 'faint', 'item', 'weather', 'terrain', 'info'
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;

  /// Serializes this ReplayEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReplayEventCopyWith<ReplayEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReplayEventCopyWith<$Res> {
  factory $ReplayEventCopyWith(
    ReplayEvent value,
    $Res Function(ReplayEvent) then,
  ) = _$ReplayEventCopyWithImpl<$Res, ReplayEvent>;
  @useResult
  $Res call({int timestampMs, String type, Map<String, dynamic>? data});
}

/// @nodoc
class _$ReplayEventCopyWithImpl<$Res, $Val extends ReplayEvent>
    implements $ReplayEventCopyWith<$Res> {
  _$ReplayEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestampMs = null,
    Object? type = null,
    Object? data = freezed,
  }) {
    return _then(
      _value.copyWith(
            timestampMs: null == timestampMs
                ? _value.timestampMs
                : timestampMs // ignore: cast_nullable_to_non_nullable
                      as int,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReplayEventImplCopyWith<$Res>
    implements $ReplayEventCopyWith<$Res> {
  factory _$$ReplayEventImplCopyWith(
    _$ReplayEventImpl value,
    $Res Function(_$ReplayEventImpl) then,
  ) = __$$ReplayEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int timestampMs, String type, Map<String, dynamic>? data});
}

/// @nodoc
class __$$ReplayEventImplCopyWithImpl<$Res>
    extends _$ReplayEventCopyWithImpl<$Res, _$ReplayEventImpl>
    implements _$$ReplayEventImplCopyWith<$Res> {
  __$$ReplayEventImplCopyWithImpl(
    _$ReplayEventImpl _value,
    $Res Function(_$ReplayEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestampMs = null,
    Object? type = null,
    Object? data = freezed,
  }) {
    return _then(
      _$ReplayEventImpl(
        timestampMs: null == timestampMs
            ? _value.timestampMs
            : timestampMs // ignore: cast_nullable_to_non_nullable
                  as int,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        data: freezed == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplayEventImpl implements _ReplayEvent {
  const _$ReplayEventImpl({
    required this.timestampMs,
    required this.type,
    final Map<String, dynamic>? data,
  }) : _data = data;

  factory _$ReplayEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReplayEventImplFromJson(json);

  @override
  final int timestampMs;
  @override
  final String type;
  // 'move', 'damage', 'heal', 'switch', 'status', 'faint', 'item', 'weather', 'terrain', 'info'
  final Map<String, dynamic>? _data;
  // 'move', 'damage', 'heal', 'switch', 'status', 'faint', 'item', 'weather', 'terrain', 'info'
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ReplayEvent(timestampMs: $timestampMs, type: $type, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplayEventImpl &&
            (identical(other.timestampMs, timestampMs) ||
                other.timestampMs == timestampMs) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    timestampMs,
    type,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of ReplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplayEventImplCopyWith<_$ReplayEventImpl> get copyWith =>
      __$$ReplayEventImplCopyWithImpl<_$ReplayEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplayEventImplToJson(this);
  }
}

abstract class _ReplayEvent implements ReplayEvent {
  const factory _ReplayEvent({
    required final int timestampMs,
    required final String type,
    final Map<String, dynamic>? data,
  }) = _$ReplayEventImpl;

  factory _ReplayEvent.fromJson(Map<String, dynamic> json) =
      _$ReplayEventImpl.fromJson;

  @override
  int get timestampMs;
  @override
  String get type; // 'move', 'damage', 'heal', 'switch', 'status', 'faint', 'item', 'weather', 'terrain', 'info'
  @override
  Map<String, dynamic>? get data;

  /// Create a copy of ReplayEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplayEventImplCopyWith<_$ReplayEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
