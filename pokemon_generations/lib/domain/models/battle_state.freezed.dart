// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'battle_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BattleLogEntry {
  String get message => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'attack', 'item', 'switch', 'status', 'faint', 'run', 'info'
  bool get isPlayer => throw _privateConstructorUsedError;
  String? get pokemonId => throw _privateConstructorUsedError;
  String? get itemId => throw _privateConstructorUsedError;
  String? get pokemonName => throw _privateConstructorUsedError;
  List<String> get pokemonSprites => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of BattleLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BattleLogEntryCopyWith<BattleLogEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BattleLogEntryCopyWith<$Res> {
  factory $BattleLogEntryCopyWith(
    BattleLogEntry value,
    $Res Function(BattleLogEntry) then,
  ) = _$BattleLogEntryCopyWithImpl<$Res, BattleLogEntry>;
  @useResult
  $Res call({
    String message,
    String type,
    bool isPlayer,
    String? pokemonId,
    String? itemId,
    String? pokemonName,
    List<String> pokemonSprites,
    DateTime? timestamp,
  });
}

/// @nodoc
class _$BattleLogEntryCopyWithImpl<$Res, $Val extends BattleLogEntry>
    implements $BattleLogEntryCopyWith<$Res> {
  _$BattleLogEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BattleLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? type = null,
    Object? isPlayer = null,
    Object? pokemonId = freezed,
    Object? itemId = freezed,
    Object? pokemonName = freezed,
    Object? pokemonSprites = null,
    Object? timestamp = freezed,
  }) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            isPlayer: null == isPlayer
                ? _value.isPlayer
                : isPlayer // ignore: cast_nullable_to_non_nullable
                      as bool,
            pokemonId: freezed == pokemonId
                ? _value.pokemonId
                : pokemonId // ignore: cast_nullable_to_non_nullable
                      as String?,
            itemId: freezed == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            pokemonName: freezed == pokemonName
                ? _value.pokemonName
                : pokemonName // ignore: cast_nullable_to_non_nullable
                      as String?,
            pokemonSprites: null == pokemonSprites
                ? _value.pokemonSprites
                : pokemonSprites // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            timestamp: freezed == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BattleLogEntryImplCopyWith<$Res>
    implements $BattleLogEntryCopyWith<$Res> {
  factory _$$BattleLogEntryImplCopyWith(
    _$BattleLogEntryImpl value,
    $Res Function(_$BattleLogEntryImpl) then,
  ) = __$$BattleLogEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String message,
    String type,
    bool isPlayer,
    String? pokemonId,
    String? itemId,
    String? pokemonName,
    List<String> pokemonSprites,
    DateTime? timestamp,
  });
}

/// @nodoc
class __$$BattleLogEntryImplCopyWithImpl<$Res>
    extends _$BattleLogEntryCopyWithImpl<$Res, _$BattleLogEntryImpl>
    implements _$$BattleLogEntryImplCopyWith<$Res> {
  __$$BattleLogEntryImplCopyWithImpl(
    _$BattleLogEntryImpl _value,
    $Res Function(_$BattleLogEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BattleLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? type = null,
    Object? isPlayer = null,
    Object? pokemonId = freezed,
    Object? itemId = freezed,
    Object? pokemonName = freezed,
    Object? pokemonSprites = null,
    Object? timestamp = freezed,
  }) {
    return _then(
      _$BattleLogEntryImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        isPlayer: null == isPlayer
            ? _value.isPlayer
            : isPlayer // ignore: cast_nullable_to_non_nullable
                  as bool,
        pokemonId: freezed == pokemonId
            ? _value.pokemonId
            : pokemonId // ignore: cast_nullable_to_non_nullable
                  as String?,
        itemId: freezed == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        pokemonName: freezed == pokemonName
            ? _value.pokemonName
            : pokemonName // ignore: cast_nullable_to_non_nullable
                  as String?,
        pokemonSprites: null == pokemonSprites
            ? _value._pokemonSprites
            : pokemonSprites // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        timestamp: freezed == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$BattleLogEntryImpl implements _BattleLogEntry {
  const _$BattleLogEntryImpl({
    required this.message,
    required this.type,
    required this.isPlayer,
    this.pokemonId,
    this.itemId,
    this.pokemonName,
    final List<String> pokemonSprites = const [],
    this.timestamp,
  }) : _pokemonSprites = pokemonSprites;

  @override
  final String message;
  @override
  final String type;
  // 'attack', 'item', 'switch', 'status', 'faint', 'run', 'info'
  @override
  final bool isPlayer;
  @override
  final String? pokemonId;
  @override
  final String? itemId;
  @override
  final String? pokemonName;
  final List<String> _pokemonSprites;
  @override
  @JsonKey()
  List<String> get pokemonSprites {
    if (_pokemonSprites is EqualUnmodifiableListView) return _pokemonSprites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pokemonSprites);
  }

  @override
  final DateTime? timestamp;

  @override
  String toString() {
    return 'BattleLogEntry(message: $message, type: $type, isPlayer: $isPlayer, pokemonId: $pokemonId, itemId: $itemId, pokemonName: $pokemonName, pokemonSprites: $pokemonSprites, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BattleLogEntryImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isPlayer, isPlayer) ||
                other.isPlayer == isPlayer) &&
            (identical(other.pokemonId, pokemonId) ||
                other.pokemonId == pokemonId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.pokemonName, pokemonName) ||
                other.pokemonName == pokemonName) &&
            const DeepCollectionEquality().equals(
              other._pokemonSprites,
              _pokemonSprites,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    type,
    isPlayer,
    pokemonId,
    itemId,
    pokemonName,
    const DeepCollectionEquality().hash(_pokemonSprites),
    timestamp,
  );

  /// Create a copy of BattleLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BattleLogEntryImplCopyWith<_$BattleLogEntryImpl> get copyWith =>
      __$$BattleLogEntryImplCopyWithImpl<_$BattleLogEntryImpl>(
        this,
        _$identity,
      );
}

abstract class _BattleLogEntry implements BattleLogEntry {
  const factory _BattleLogEntry({
    required final String message,
    required final String type,
    required final bool isPlayer,
    final String? pokemonId,
    final String? itemId,
    final String? pokemonName,
    final List<String> pokemonSprites,
    final DateTime? timestamp,
  }) = _$BattleLogEntryImpl;

  @override
  String get message;
  @override
  String get type; // 'attack', 'item', 'switch', 'status', 'faint', 'run', 'info'
  @override
  bool get isPlayer;
  @override
  String? get pokemonId;
  @override
  String? get itemId;
  @override
  String? get pokemonName;
  @override
  List<String> get pokemonSprites;
  @override
  DateTime? get timestamp;

  /// Create a copy of BattleLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BattleLogEntryImplCopyWith<_$BattleLogEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BattleState {
  Pokemon get playerPokemon => throw _privateConstructorUsedError;
  Pokemon get opponentPokemon => throw _privateConstructorUsedError;
  int get playerCurrentHp => throw _privateConstructorUsedError;
  int get opponentCurrentHp => throw _privateConstructorUsedError;
  int get playerMaxHp => throw _privateConstructorUsedError;
  int get opponentMaxHp => throw _privateConstructorUsedError;
  int get playerLevel => throw _privateConstructorUsedError;
  int get opponentLevel => throw _privateConstructorUsedError;
  List<Pokemon> get playerTeam =>
      throw _privateConstructorUsedError; // The full roster for swapping
  List<Pokemon> get opponentTeam =>
      throw _privateConstructorUsedError; // NEW: The CPU's random team
  int get activePlayerIdx => throw _privateConstructorUsedError;
  int get activeOpponentIdx => throw _privateConstructorUsedError;
  Map<String, int> get playerHpMap =>
      throw _privateConstructorUsedError; // id -> current hp
  Map<String, int> get playerMaxHpMap =>
      throw _privateConstructorUsedError; // id -> max hp
  Map<String, int> get opponentHpMap =>
      throw _privateConstructorUsedError; // id -> current hp
  Map<String, int> get opponentMaxHpMap =>
      throw _privateConstructorUsedError; // id -> max hp
  Map<String, int> get inventory =>
      throw _privateConstructorUsedError; // The user's bag
  List<BattleLogEntry> get battleLog => throw _privateConstructorUsedError;
  bool get isPlayerTurn => throw _privateConstructorUsedError;
  bool get isFinished => throw _privateConstructorUsedError;
  String? get winner => throw _privateConstructorUsedError;
  bool get isAnimating => throw _privateConstructorUsedError;
  bool get isWaitingForOpponent => throw _privateConstructorUsedError;
  bool get isWaitingForSwitch =>
      throw _privateConstructorUsedError; // NEW: Mandatory switch state
  bool get isSpectator => throw _privateConstructorUsedError;
  bool get player1Connected => throw _privateConstructorUsedError;
  bool get player2Connected => throw _privateConstructorUsedError;
  String get player1Name => throw _privateConstructorUsedError;
  String get player2Name => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get difficulty =>
      throw _privateConstructorUsedError; // 'normal' or 'hard'
  Map<String, int> get cpuInventory =>
      throw _privateConstructorUsedError; // CPU's bag
  String get weather =>
      throw _privateConstructorUsedError; // 'none', 'rain', 'sun', 'sand', 'snow'
  String get terrain =>
      throw _privateConstructorUsedError; // 'none', 'electric', 'grassy', 'misty', 'psychic'
  String? get lastMoveName =>
      throw _privateConstructorUsedError; // For SFX/VFX triggering
  String? get lastMoveType =>
      throw _privateConstructorUsedError; // For particle selection
  bool get isRecharging =>
      throw _privateConstructorUsedError; // For moves like Hyper Beam
  Map<String, String> get statusMap =>
      throw _privateConstructorUsedError; // id -> 'brn', 'psn', 'tox', 'par', 'slp', 'frz', 'none'
  Map<String, int> get statusTurns =>
      throw _privateConstructorUsedError; // id -> number of turns
  Map<String, List<String>> get volatileStatusMap =>
      throw _privateConstructorUsedError; // id -> ['confused', 'taunted', ...]
  Map<String, Map<String, int>> get volatileStatusTurns =>
      throw _privateConstructorUsedError; // id -> { 'taunt': 3 }
  Map<String, String> get disabledMoveMap =>
      throw _privateConstructorUsedError; // id -> name of disabled move
  Map<String, String> get encoredMoveMap => throw _privateConstructorUsedError;

  /// Create a copy of BattleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BattleStateCopyWith<BattleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BattleStateCopyWith<$Res> {
  factory $BattleStateCopyWith(
    BattleState value,
    $Res Function(BattleState) then,
  ) = _$BattleStateCopyWithImpl<$Res, BattleState>;
  @useResult
  $Res call({
    Pokemon playerPokemon,
    Pokemon opponentPokemon,
    int playerCurrentHp,
    int opponentCurrentHp,
    int playerMaxHp,
    int opponentMaxHp,
    int playerLevel,
    int opponentLevel,
    List<Pokemon> playerTeam,
    List<Pokemon> opponentTeam,
    int activePlayerIdx,
    int activeOpponentIdx,
    Map<String, int> playerHpMap,
    Map<String, int> playerMaxHpMap,
    Map<String, int> opponentHpMap,
    Map<String, int> opponentMaxHpMap,
    Map<String, int> inventory,
    List<BattleLogEntry> battleLog,
    bool isPlayerTurn,
    bool isFinished,
    String? winner,
    bool isAnimating,
    bool isWaitingForOpponent,
    bool isWaitingForSwitch,
    bool isSpectator,
    bool player1Connected,
    bool player2Connected,
    String player1Name,
    String player2Name,
    String message,
    String difficulty,
    Map<String, int> cpuInventory,
    String weather,
    String terrain,
    String? lastMoveName,
    String? lastMoveType,
    bool isRecharging,
    Map<String, String> statusMap,
    Map<String, int> statusTurns,
    Map<String, List<String>> volatileStatusMap,
    Map<String, Map<String, int>> volatileStatusTurns,
    Map<String, String> disabledMoveMap,
    Map<String, String> encoredMoveMap,
  });

  $PokemonCopyWith<$Res> get playerPokemon;
  $PokemonCopyWith<$Res> get opponentPokemon;
}

/// @nodoc
class _$BattleStateCopyWithImpl<$Res, $Val extends BattleState>
    implements $BattleStateCopyWith<$Res> {
  _$BattleStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BattleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerPokemon = null,
    Object? opponentPokemon = null,
    Object? playerCurrentHp = null,
    Object? opponentCurrentHp = null,
    Object? playerMaxHp = null,
    Object? opponentMaxHp = null,
    Object? playerLevel = null,
    Object? opponentLevel = null,
    Object? playerTeam = null,
    Object? opponentTeam = null,
    Object? activePlayerIdx = null,
    Object? activeOpponentIdx = null,
    Object? playerHpMap = null,
    Object? playerMaxHpMap = null,
    Object? opponentHpMap = null,
    Object? opponentMaxHpMap = null,
    Object? inventory = null,
    Object? battleLog = null,
    Object? isPlayerTurn = null,
    Object? isFinished = null,
    Object? winner = freezed,
    Object? isAnimating = null,
    Object? isWaitingForOpponent = null,
    Object? isWaitingForSwitch = null,
    Object? isSpectator = null,
    Object? player1Connected = null,
    Object? player2Connected = null,
    Object? player1Name = null,
    Object? player2Name = null,
    Object? message = null,
    Object? difficulty = null,
    Object? cpuInventory = null,
    Object? weather = null,
    Object? terrain = null,
    Object? lastMoveName = freezed,
    Object? lastMoveType = freezed,
    Object? isRecharging = null,
    Object? statusMap = null,
    Object? statusTurns = null,
    Object? volatileStatusMap = null,
    Object? volatileStatusTurns = null,
    Object? disabledMoveMap = null,
    Object? encoredMoveMap = null,
  }) {
    return _then(
      _value.copyWith(
            playerPokemon: null == playerPokemon
                ? _value.playerPokemon
                : playerPokemon // ignore: cast_nullable_to_non_nullable
                      as Pokemon,
            opponentPokemon: null == opponentPokemon
                ? _value.opponentPokemon
                : opponentPokemon // ignore: cast_nullable_to_non_nullable
                      as Pokemon,
            playerCurrentHp: null == playerCurrentHp
                ? _value.playerCurrentHp
                : playerCurrentHp // ignore: cast_nullable_to_non_nullable
                      as int,
            opponentCurrentHp: null == opponentCurrentHp
                ? _value.opponentCurrentHp
                : opponentCurrentHp // ignore: cast_nullable_to_non_nullable
                      as int,
            playerMaxHp: null == playerMaxHp
                ? _value.playerMaxHp
                : playerMaxHp // ignore: cast_nullable_to_non_nullable
                      as int,
            opponentMaxHp: null == opponentMaxHp
                ? _value.opponentMaxHp
                : opponentMaxHp // ignore: cast_nullable_to_non_nullable
                      as int,
            playerLevel: null == playerLevel
                ? _value.playerLevel
                : playerLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            opponentLevel: null == opponentLevel
                ? _value.opponentLevel
                : opponentLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            playerTeam: null == playerTeam
                ? _value.playerTeam
                : playerTeam // ignore: cast_nullable_to_non_nullable
                      as List<Pokemon>,
            opponentTeam: null == opponentTeam
                ? _value.opponentTeam
                : opponentTeam // ignore: cast_nullable_to_non_nullable
                      as List<Pokemon>,
            activePlayerIdx: null == activePlayerIdx
                ? _value.activePlayerIdx
                : activePlayerIdx // ignore: cast_nullable_to_non_nullable
                      as int,
            activeOpponentIdx: null == activeOpponentIdx
                ? _value.activeOpponentIdx
                : activeOpponentIdx // ignore: cast_nullable_to_non_nullable
                      as int,
            playerHpMap: null == playerHpMap
                ? _value.playerHpMap
                : playerHpMap // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            playerMaxHpMap: null == playerMaxHpMap
                ? _value.playerMaxHpMap
                : playerMaxHpMap // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            opponentHpMap: null == opponentHpMap
                ? _value.opponentHpMap
                : opponentHpMap // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            opponentMaxHpMap: null == opponentMaxHpMap
                ? _value.opponentMaxHpMap
                : opponentMaxHpMap // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            inventory: null == inventory
                ? _value.inventory
                : inventory // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            battleLog: null == battleLog
                ? _value.battleLog
                : battleLog // ignore: cast_nullable_to_non_nullable
                      as List<BattleLogEntry>,
            isPlayerTurn: null == isPlayerTurn
                ? _value.isPlayerTurn
                : isPlayerTurn // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFinished: null == isFinished
                ? _value.isFinished
                : isFinished // ignore: cast_nullable_to_non_nullable
                      as bool,
            winner: freezed == winner
                ? _value.winner
                : winner // ignore: cast_nullable_to_non_nullable
                      as String?,
            isAnimating: null == isAnimating
                ? _value.isAnimating
                : isAnimating // ignore: cast_nullable_to_non_nullable
                      as bool,
            isWaitingForOpponent: null == isWaitingForOpponent
                ? _value.isWaitingForOpponent
                : isWaitingForOpponent // ignore: cast_nullable_to_non_nullable
                      as bool,
            isWaitingForSwitch: null == isWaitingForSwitch
                ? _value.isWaitingForSwitch
                : isWaitingForSwitch // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSpectator: null == isSpectator
                ? _value.isSpectator
                : isSpectator // ignore: cast_nullable_to_non_nullable
                      as bool,
            player1Connected: null == player1Connected
                ? _value.player1Connected
                : player1Connected // ignore: cast_nullable_to_non_nullable
                      as bool,
            player2Connected: null == player2Connected
                ? _value.player2Connected
                : player2Connected // ignore: cast_nullable_to_non_nullable
                      as bool,
            player1Name: null == player1Name
                ? _value.player1Name
                : player1Name // ignore: cast_nullable_to_non_nullable
                      as String,
            player2Name: null == player2Name
                ? _value.player2Name
                : player2Name // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String,
            cpuInventory: null == cpuInventory
                ? _value.cpuInventory
                : cpuInventory // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            weather: null == weather
                ? _value.weather
                : weather // ignore: cast_nullable_to_non_nullable
                      as String,
            terrain: null == terrain
                ? _value.terrain
                : terrain // ignore: cast_nullable_to_non_nullable
                      as String,
            lastMoveName: freezed == lastMoveName
                ? _value.lastMoveName
                : lastMoveName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastMoveType: freezed == lastMoveType
                ? _value.lastMoveType
                : lastMoveType // ignore: cast_nullable_to_non_nullable
                      as String?,
            isRecharging: null == isRecharging
                ? _value.isRecharging
                : isRecharging // ignore: cast_nullable_to_non_nullable
                      as bool,
            statusMap: null == statusMap
                ? _value.statusMap
                : statusMap // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            statusTurns: null == statusTurns
                ? _value.statusTurns
                : statusTurns // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            volatileStatusMap: null == volatileStatusMap
                ? _value.volatileStatusMap
                : volatileStatusMap // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<String>>,
            volatileStatusTurns: null == volatileStatusTurns
                ? _value.volatileStatusTurns
                : volatileStatusTurns // ignore: cast_nullable_to_non_nullable
                      as Map<String, Map<String, int>>,
            disabledMoveMap: null == disabledMoveMap
                ? _value.disabledMoveMap
                : disabledMoveMap // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            encoredMoveMap: null == encoredMoveMap
                ? _value.encoredMoveMap
                : encoredMoveMap // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
          )
          as $Val,
    );
  }

  /// Create a copy of BattleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PokemonCopyWith<$Res> get playerPokemon {
    return $PokemonCopyWith<$Res>(_value.playerPokemon, (value) {
      return _then(_value.copyWith(playerPokemon: value) as $Val);
    });
  }

  /// Create a copy of BattleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PokemonCopyWith<$Res> get opponentPokemon {
    return $PokemonCopyWith<$Res>(_value.opponentPokemon, (value) {
      return _then(_value.copyWith(opponentPokemon: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BattleStateImplCopyWith<$Res>
    implements $BattleStateCopyWith<$Res> {
  factory _$$BattleStateImplCopyWith(
    _$BattleStateImpl value,
    $Res Function(_$BattleStateImpl) then,
  ) = __$$BattleStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Pokemon playerPokemon,
    Pokemon opponentPokemon,
    int playerCurrentHp,
    int opponentCurrentHp,
    int playerMaxHp,
    int opponentMaxHp,
    int playerLevel,
    int opponentLevel,
    List<Pokemon> playerTeam,
    List<Pokemon> opponentTeam,
    int activePlayerIdx,
    int activeOpponentIdx,
    Map<String, int> playerHpMap,
    Map<String, int> playerMaxHpMap,
    Map<String, int> opponentHpMap,
    Map<String, int> opponentMaxHpMap,
    Map<String, int> inventory,
    List<BattleLogEntry> battleLog,
    bool isPlayerTurn,
    bool isFinished,
    String? winner,
    bool isAnimating,
    bool isWaitingForOpponent,
    bool isWaitingForSwitch,
    bool isSpectator,
    bool player1Connected,
    bool player2Connected,
    String player1Name,
    String player2Name,
    String message,
    String difficulty,
    Map<String, int> cpuInventory,
    String weather,
    String terrain,
    String? lastMoveName,
    String? lastMoveType,
    bool isRecharging,
    Map<String, String> statusMap,
    Map<String, int> statusTurns,
    Map<String, List<String>> volatileStatusMap,
    Map<String, Map<String, int>> volatileStatusTurns,
    Map<String, String> disabledMoveMap,
    Map<String, String> encoredMoveMap,
  });

  @override
  $PokemonCopyWith<$Res> get playerPokemon;
  @override
  $PokemonCopyWith<$Res> get opponentPokemon;
}

/// @nodoc
class __$$BattleStateImplCopyWithImpl<$Res>
    extends _$BattleStateCopyWithImpl<$Res, _$BattleStateImpl>
    implements _$$BattleStateImplCopyWith<$Res> {
  __$$BattleStateImplCopyWithImpl(
    _$BattleStateImpl _value,
    $Res Function(_$BattleStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BattleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerPokemon = null,
    Object? opponentPokemon = null,
    Object? playerCurrentHp = null,
    Object? opponentCurrentHp = null,
    Object? playerMaxHp = null,
    Object? opponentMaxHp = null,
    Object? playerLevel = null,
    Object? opponentLevel = null,
    Object? playerTeam = null,
    Object? opponentTeam = null,
    Object? activePlayerIdx = null,
    Object? activeOpponentIdx = null,
    Object? playerHpMap = null,
    Object? playerMaxHpMap = null,
    Object? opponentHpMap = null,
    Object? opponentMaxHpMap = null,
    Object? inventory = null,
    Object? battleLog = null,
    Object? isPlayerTurn = null,
    Object? isFinished = null,
    Object? winner = freezed,
    Object? isAnimating = null,
    Object? isWaitingForOpponent = null,
    Object? isWaitingForSwitch = null,
    Object? isSpectator = null,
    Object? player1Connected = null,
    Object? player2Connected = null,
    Object? player1Name = null,
    Object? player2Name = null,
    Object? message = null,
    Object? difficulty = null,
    Object? cpuInventory = null,
    Object? weather = null,
    Object? terrain = null,
    Object? lastMoveName = freezed,
    Object? lastMoveType = freezed,
    Object? isRecharging = null,
    Object? statusMap = null,
    Object? statusTurns = null,
    Object? volatileStatusMap = null,
    Object? volatileStatusTurns = null,
    Object? disabledMoveMap = null,
    Object? encoredMoveMap = null,
  }) {
    return _then(
      _$BattleStateImpl(
        playerPokemon: null == playerPokemon
            ? _value.playerPokemon
            : playerPokemon // ignore: cast_nullable_to_non_nullable
                  as Pokemon,
        opponentPokemon: null == opponentPokemon
            ? _value.opponentPokemon
            : opponentPokemon // ignore: cast_nullable_to_non_nullable
                  as Pokemon,
        playerCurrentHp: null == playerCurrentHp
            ? _value.playerCurrentHp
            : playerCurrentHp // ignore: cast_nullable_to_non_nullable
                  as int,
        opponentCurrentHp: null == opponentCurrentHp
            ? _value.opponentCurrentHp
            : opponentCurrentHp // ignore: cast_nullable_to_non_nullable
                  as int,
        playerMaxHp: null == playerMaxHp
            ? _value.playerMaxHp
            : playerMaxHp // ignore: cast_nullable_to_non_nullable
                  as int,
        opponentMaxHp: null == opponentMaxHp
            ? _value.opponentMaxHp
            : opponentMaxHp // ignore: cast_nullable_to_non_nullable
                  as int,
        playerLevel: null == playerLevel
            ? _value.playerLevel
            : playerLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        opponentLevel: null == opponentLevel
            ? _value.opponentLevel
            : opponentLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        playerTeam: null == playerTeam
            ? _value._playerTeam
            : playerTeam // ignore: cast_nullable_to_non_nullable
                  as List<Pokemon>,
        opponentTeam: null == opponentTeam
            ? _value._opponentTeam
            : opponentTeam // ignore: cast_nullable_to_non_nullable
                  as List<Pokemon>,
        activePlayerIdx: null == activePlayerIdx
            ? _value.activePlayerIdx
            : activePlayerIdx // ignore: cast_nullable_to_non_nullable
                  as int,
        activeOpponentIdx: null == activeOpponentIdx
            ? _value.activeOpponentIdx
            : activeOpponentIdx // ignore: cast_nullable_to_non_nullable
                  as int,
        playerHpMap: null == playerHpMap
            ? _value._playerHpMap
            : playerHpMap // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        playerMaxHpMap: null == playerMaxHpMap
            ? _value._playerMaxHpMap
            : playerMaxHpMap // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        opponentHpMap: null == opponentHpMap
            ? _value._opponentHpMap
            : opponentHpMap // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        opponentMaxHpMap: null == opponentMaxHpMap
            ? _value._opponentMaxHpMap
            : opponentMaxHpMap // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        inventory: null == inventory
            ? _value._inventory
            : inventory // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        battleLog: null == battleLog
            ? _value._battleLog
            : battleLog // ignore: cast_nullable_to_non_nullable
                  as List<BattleLogEntry>,
        isPlayerTurn: null == isPlayerTurn
            ? _value.isPlayerTurn
            : isPlayerTurn // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFinished: null == isFinished
            ? _value.isFinished
            : isFinished // ignore: cast_nullable_to_non_nullable
                  as bool,
        winner: freezed == winner
            ? _value.winner
            : winner // ignore: cast_nullable_to_non_nullable
                  as String?,
        isAnimating: null == isAnimating
            ? _value.isAnimating
            : isAnimating // ignore: cast_nullable_to_non_nullable
                  as bool,
        isWaitingForOpponent: null == isWaitingForOpponent
            ? _value.isWaitingForOpponent
            : isWaitingForOpponent // ignore: cast_nullable_to_non_nullable
                  as bool,
        isWaitingForSwitch: null == isWaitingForSwitch
            ? _value.isWaitingForSwitch
            : isWaitingForSwitch // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSpectator: null == isSpectator
            ? _value.isSpectator
            : isSpectator // ignore: cast_nullable_to_non_nullable
                  as bool,
        player1Connected: null == player1Connected
            ? _value.player1Connected
            : player1Connected // ignore: cast_nullable_to_non_nullable
                  as bool,
        player2Connected: null == player2Connected
            ? _value.player2Connected
            : player2Connected // ignore: cast_nullable_to_non_nullable
                  as bool,
        player1Name: null == player1Name
            ? _value.player1Name
            : player1Name // ignore: cast_nullable_to_non_nullable
                  as String,
        player2Name: null == player2Name
            ? _value.player2Name
            : player2Name // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String,
        cpuInventory: null == cpuInventory
            ? _value._cpuInventory
            : cpuInventory // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        weather: null == weather
            ? _value.weather
            : weather // ignore: cast_nullable_to_non_nullable
                  as String,
        terrain: null == terrain
            ? _value.terrain
            : terrain // ignore: cast_nullable_to_non_nullable
                  as String,
        lastMoveName: freezed == lastMoveName
            ? _value.lastMoveName
            : lastMoveName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastMoveType: freezed == lastMoveType
            ? _value.lastMoveType
            : lastMoveType // ignore: cast_nullable_to_non_nullable
                  as String?,
        isRecharging: null == isRecharging
            ? _value.isRecharging
            : isRecharging // ignore: cast_nullable_to_non_nullable
                  as bool,
        statusMap: null == statusMap
            ? _value._statusMap
            : statusMap // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        statusTurns: null == statusTurns
            ? _value._statusTurns
            : statusTurns // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        volatileStatusMap: null == volatileStatusMap
            ? _value._volatileStatusMap
            : volatileStatusMap // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<String>>,
        volatileStatusTurns: null == volatileStatusTurns
            ? _value._volatileStatusTurns
            : volatileStatusTurns // ignore: cast_nullable_to_non_nullable
                  as Map<String, Map<String, int>>,
        disabledMoveMap: null == disabledMoveMap
            ? _value._disabledMoveMap
            : disabledMoveMap // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        encoredMoveMap: null == encoredMoveMap
            ? _value._encoredMoveMap
            : encoredMoveMap // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc

class _$BattleStateImpl implements _BattleState {
  const _$BattleStateImpl({
    required this.playerPokemon,
    required this.opponentPokemon,
    required this.playerCurrentHp,
    required this.opponentCurrentHp,
    required this.playerMaxHp,
    required this.opponentMaxHp,
    this.playerLevel = 50,
    this.opponentLevel = 50,
    final List<Pokemon> playerTeam = const [],
    final List<Pokemon> opponentTeam = const [],
    this.activePlayerIdx = 0,
    this.activeOpponentIdx = 0,
    final Map<String, int> playerHpMap = const {},
    final Map<String, int> playerMaxHpMap = const {},
    final Map<String, int> opponentHpMap = const {},
    final Map<String, int> opponentMaxHpMap = const {},
    final Map<String, int> inventory = const {},
    final List<BattleLogEntry> battleLog = const [],
    this.isPlayerTurn = true,
    this.isFinished = false,
    this.winner,
    this.isAnimating = false,
    this.isWaitingForOpponent = false,
    this.isWaitingForSwitch = false,
    this.isSpectator = false,
    this.player1Connected = true,
    this.player2Connected = true,
    this.player1Name = '',
    this.player2Name = '',
    this.message = '',
    this.difficulty = 'normal',
    final Map<String, int> cpuInventory = const {'potion': 2},
    this.weather = 'none',
    this.terrain = 'none',
    this.lastMoveName,
    this.lastMoveType,
    this.isRecharging = false,
    final Map<String, String> statusMap = const {},
    final Map<String, int> statusTurns = const {},
    final Map<String, List<String>> volatileStatusMap = const {},
    final Map<String, Map<String, int>> volatileStatusTurns = const {},
    final Map<String, String> disabledMoveMap = const {},
    final Map<String, String> encoredMoveMap = const {},
  }) : _playerTeam = playerTeam,
       _opponentTeam = opponentTeam,
       _playerHpMap = playerHpMap,
       _playerMaxHpMap = playerMaxHpMap,
       _opponentHpMap = opponentHpMap,
       _opponentMaxHpMap = opponentMaxHpMap,
       _inventory = inventory,
       _battleLog = battleLog,
       _cpuInventory = cpuInventory,
       _statusMap = statusMap,
       _statusTurns = statusTurns,
       _volatileStatusMap = volatileStatusMap,
       _volatileStatusTurns = volatileStatusTurns,
       _disabledMoveMap = disabledMoveMap,
       _encoredMoveMap = encoredMoveMap;

  @override
  final Pokemon playerPokemon;
  @override
  final Pokemon opponentPokemon;
  @override
  final int playerCurrentHp;
  @override
  final int opponentCurrentHp;
  @override
  final int playerMaxHp;
  @override
  final int opponentMaxHp;
  @override
  @JsonKey()
  final int playerLevel;
  @override
  @JsonKey()
  final int opponentLevel;
  final List<Pokemon> _playerTeam;
  @override
  @JsonKey()
  List<Pokemon> get playerTeam {
    if (_playerTeam is EqualUnmodifiableListView) return _playerTeam;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playerTeam);
  }

  // The full roster for swapping
  final List<Pokemon> _opponentTeam;
  // The full roster for swapping
  @override
  @JsonKey()
  List<Pokemon> get opponentTeam {
    if (_opponentTeam is EqualUnmodifiableListView) return _opponentTeam;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_opponentTeam);
  }

  // NEW: The CPU's random team
  @override
  @JsonKey()
  final int activePlayerIdx;
  @override
  @JsonKey()
  final int activeOpponentIdx;
  final Map<String, int> _playerHpMap;
  @override
  @JsonKey()
  Map<String, int> get playerHpMap {
    if (_playerHpMap is EqualUnmodifiableMapView) return _playerHpMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_playerHpMap);
  }

  // id -> current hp
  final Map<String, int> _playerMaxHpMap;
  // id -> current hp
  @override
  @JsonKey()
  Map<String, int> get playerMaxHpMap {
    if (_playerMaxHpMap is EqualUnmodifiableMapView) return _playerMaxHpMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_playerMaxHpMap);
  }

  // id -> max hp
  final Map<String, int> _opponentHpMap;
  // id -> max hp
  @override
  @JsonKey()
  Map<String, int> get opponentHpMap {
    if (_opponentHpMap is EqualUnmodifiableMapView) return _opponentHpMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_opponentHpMap);
  }

  // id -> current hp
  final Map<String, int> _opponentMaxHpMap;
  // id -> current hp
  @override
  @JsonKey()
  Map<String, int> get opponentMaxHpMap {
    if (_opponentMaxHpMap is EqualUnmodifiableMapView) return _opponentMaxHpMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_opponentMaxHpMap);
  }

  // id -> max hp
  final Map<String, int> _inventory;
  // id -> max hp
  @override
  @JsonKey()
  Map<String, int> get inventory {
    if (_inventory is EqualUnmodifiableMapView) return _inventory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_inventory);
  }

  // The user's bag
  final List<BattleLogEntry> _battleLog;
  // The user's bag
  @override
  @JsonKey()
  List<BattleLogEntry> get battleLog {
    if (_battleLog is EqualUnmodifiableListView) return _battleLog;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_battleLog);
  }

  @override
  @JsonKey()
  final bool isPlayerTurn;
  @override
  @JsonKey()
  final bool isFinished;
  @override
  final String? winner;
  @override
  @JsonKey()
  final bool isAnimating;
  @override
  @JsonKey()
  final bool isWaitingForOpponent;
  @override
  @JsonKey()
  final bool isWaitingForSwitch;
  // NEW: Mandatory switch state
  @override
  @JsonKey()
  final bool isSpectator;
  @override
  @JsonKey()
  final bool player1Connected;
  @override
  @JsonKey()
  final bool player2Connected;
  @override
  @JsonKey()
  final String player1Name;
  @override
  @JsonKey()
  final String player2Name;
  @override
  @JsonKey()
  final String message;
  @override
  @JsonKey()
  final String difficulty;
  // 'normal' or 'hard'
  final Map<String, int> _cpuInventory;
  // 'normal' or 'hard'
  @override
  @JsonKey()
  Map<String, int> get cpuInventory {
    if (_cpuInventory is EqualUnmodifiableMapView) return _cpuInventory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cpuInventory);
  }

  // CPU's bag
  @override
  @JsonKey()
  final String weather;
  // 'none', 'rain', 'sun', 'sand', 'snow'
  @override
  @JsonKey()
  final String terrain;
  // 'none', 'electric', 'grassy', 'misty', 'psychic'
  @override
  final String? lastMoveName;
  // For SFX/VFX triggering
  @override
  final String? lastMoveType;
  // For particle selection
  @override
  @JsonKey()
  final bool isRecharging;
  // For moves like Hyper Beam
  final Map<String, String> _statusMap;
  // For moves like Hyper Beam
  @override
  @JsonKey()
  Map<String, String> get statusMap {
    if (_statusMap is EqualUnmodifiableMapView) return _statusMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_statusMap);
  }

  // id -> 'brn', 'psn', 'tox', 'par', 'slp', 'frz', 'none'
  final Map<String, int> _statusTurns;
  // id -> 'brn', 'psn', 'tox', 'par', 'slp', 'frz', 'none'
  @override
  @JsonKey()
  Map<String, int> get statusTurns {
    if (_statusTurns is EqualUnmodifiableMapView) return _statusTurns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_statusTurns);
  }

  // id -> number of turns
  final Map<String, List<String>> _volatileStatusMap;
  // id -> number of turns
  @override
  @JsonKey()
  Map<String, List<String>> get volatileStatusMap {
    if (_volatileStatusMap is EqualUnmodifiableMapView)
      return _volatileStatusMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_volatileStatusMap);
  }

  // id -> ['confused', 'taunted', ...]
  final Map<String, Map<String, int>> _volatileStatusTurns;
  // id -> ['confused', 'taunted', ...]
  @override
  @JsonKey()
  Map<String, Map<String, int>> get volatileStatusTurns {
    if (_volatileStatusTurns is EqualUnmodifiableMapView)
      return _volatileStatusTurns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_volatileStatusTurns);
  }

  // id -> { 'taunt': 3 }
  final Map<String, String> _disabledMoveMap;
  // id -> { 'taunt': 3 }
  @override
  @JsonKey()
  Map<String, String> get disabledMoveMap {
    if (_disabledMoveMap is EqualUnmodifiableMapView) return _disabledMoveMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_disabledMoveMap);
  }

  // id -> name of disabled move
  final Map<String, String> _encoredMoveMap;
  // id -> name of disabled move
  @override
  @JsonKey()
  Map<String, String> get encoredMoveMap {
    if (_encoredMoveMap is EqualUnmodifiableMapView) return _encoredMoveMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_encoredMoveMap);
  }

  @override
  String toString() {
    return 'BattleState(playerPokemon: $playerPokemon, opponentPokemon: $opponentPokemon, playerCurrentHp: $playerCurrentHp, opponentCurrentHp: $opponentCurrentHp, playerMaxHp: $playerMaxHp, opponentMaxHp: $opponentMaxHp, playerLevel: $playerLevel, opponentLevel: $opponentLevel, playerTeam: $playerTeam, opponentTeam: $opponentTeam, activePlayerIdx: $activePlayerIdx, activeOpponentIdx: $activeOpponentIdx, playerHpMap: $playerHpMap, playerMaxHpMap: $playerMaxHpMap, opponentHpMap: $opponentHpMap, opponentMaxHpMap: $opponentMaxHpMap, inventory: $inventory, battleLog: $battleLog, isPlayerTurn: $isPlayerTurn, isFinished: $isFinished, winner: $winner, isAnimating: $isAnimating, isWaitingForOpponent: $isWaitingForOpponent, isWaitingForSwitch: $isWaitingForSwitch, isSpectator: $isSpectator, player1Connected: $player1Connected, player2Connected: $player2Connected, player1Name: $player1Name, player2Name: $player2Name, message: $message, difficulty: $difficulty, cpuInventory: $cpuInventory, weather: $weather, terrain: $terrain, lastMoveName: $lastMoveName, lastMoveType: $lastMoveType, isRecharging: $isRecharging, statusMap: $statusMap, statusTurns: $statusTurns, volatileStatusMap: $volatileStatusMap, volatileStatusTurns: $volatileStatusTurns, disabledMoveMap: $disabledMoveMap, encoredMoveMap: $encoredMoveMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BattleStateImpl &&
            (identical(other.playerPokemon, playerPokemon) ||
                other.playerPokemon == playerPokemon) &&
            (identical(other.opponentPokemon, opponentPokemon) ||
                other.opponentPokemon == opponentPokemon) &&
            (identical(other.playerCurrentHp, playerCurrentHp) ||
                other.playerCurrentHp == playerCurrentHp) &&
            (identical(other.opponentCurrentHp, opponentCurrentHp) ||
                other.opponentCurrentHp == opponentCurrentHp) &&
            (identical(other.playerMaxHp, playerMaxHp) ||
                other.playerMaxHp == playerMaxHp) &&
            (identical(other.opponentMaxHp, opponentMaxHp) ||
                other.opponentMaxHp == opponentMaxHp) &&
            (identical(other.playerLevel, playerLevel) ||
                other.playerLevel == playerLevel) &&
            (identical(other.opponentLevel, opponentLevel) ||
                other.opponentLevel == opponentLevel) &&
            const DeepCollectionEquality().equals(
              other._playerTeam,
              _playerTeam,
            ) &&
            const DeepCollectionEquality().equals(
              other._opponentTeam,
              _opponentTeam,
            ) &&
            (identical(other.activePlayerIdx, activePlayerIdx) ||
                other.activePlayerIdx == activePlayerIdx) &&
            (identical(other.activeOpponentIdx, activeOpponentIdx) ||
                other.activeOpponentIdx == activeOpponentIdx) &&
            const DeepCollectionEquality().equals(
              other._playerHpMap,
              _playerHpMap,
            ) &&
            const DeepCollectionEquality().equals(
              other._playerMaxHpMap,
              _playerMaxHpMap,
            ) &&
            const DeepCollectionEquality().equals(
              other._opponentHpMap,
              _opponentHpMap,
            ) &&
            const DeepCollectionEquality().equals(
              other._opponentMaxHpMap,
              _opponentMaxHpMap,
            ) &&
            const DeepCollectionEquality().equals(
              other._inventory,
              _inventory,
            ) &&
            const DeepCollectionEquality().equals(
              other._battleLog,
              _battleLog,
            ) &&
            (identical(other.isPlayerTurn, isPlayerTurn) ||
                other.isPlayerTurn == isPlayerTurn) &&
            (identical(other.isFinished, isFinished) ||
                other.isFinished == isFinished) &&
            (identical(other.winner, winner) || other.winner == winner) &&
            (identical(other.isAnimating, isAnimating) ||
                other.isAnimating == isAnimating) &&
            (identical(other.isWaitingForOpponent, isWaitingForOpponent) ||
                other.isWaitingForOpponent == isWaitingForOpponent) &&
            (identical(other.isWaitingForSwitch, isWaitingForSwitch) ||
                other.isWaitingForSwitch == isWaitingForSwitch) &&
            (identical(other.isSpectator, isSpectator) ||
                other.isSpectator == isSpectator) &&
            (identical(other.player1Connected, player1Connected) ||
                other.player1Connected == player1Connected) &&
            (identical(other.player2Connected, player2Connected) ||
                other.player2Connected == player2Connected) &&
            (identical(other.player1Name, player1Name) ||
                other.player1Name == player1Name) &&
            (identical(other.player2Name, player2Name) ||
                other.player2Name == player2Name) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality().equals(
              other._cpuInventory,
              _cpuInventory,
            ) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.terrain, terrain) || other.terrain == terrain) &&
            (identical(other.lastMoveName, lastMoveName) ||
                other.lastMoveName == lastMoveName) &&
            (identical(other.lastMoveType, lastMoveType) ||
                other.lastMoveType == lastMoveType) &&
            (identical(other.isRecharging, isRecharging) ||
                other.isRecharging == isRecharging) &&
            const DeepCollectionEquality().equals(
              other._statusMap,
              _statusMap,
            ) &&
            const DeepCollectionEquality().equals(
              other._statusTurns,
              _statusTurns,
            ) &&
            const DeepCollectionEquality().equals(
              other._volatileStatusMap,
              _volatileStatusMap,
            ) &&
            const DeepCollectionEquality().equals(
              other._volatileStatusTurns,
              _volatileStatusTurns,
            ) &&
            const DeepCollectionEquality().equals(
              other._disabledMoveMap,
              _disabledMoveMap,
            ) &&
            const DeepCollectionEquality().equals(
              other._encoredMoveMap,
              _encoredMoveMap,
            ));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    playerPokemon,
    opponentPokemon,
    playerCurrentHp,
    opponentCurrentHp,
    playerMaxHp,
    opponentMaxHp,
    playerLevel,
    opponentLevel,
    const DeepCollectionEquality().hash(_playerTeam),
    const DeepCollectionEquality().hash(_opponentTeam),
    activePlayerIdx,
    activeOpponentIdx,
    const DeepCollectionEquality().hash(_playerHpMap),
    const DeepCollectionEquality().hash(_playerMaxHpMap),
    const DeepCollectionEquality().hash(_opponentHpMap),
    const DeepCollectionEquality().hash(_opponentMaxHpMap),
    const DeepCollectionEquality().hash(_inventory),
    const DeepCollectionEquality().hash(_battleLog),
    isPlayerTurn,
    isFinished,
    winner,
    isAnimating,
    isWaitingForOpponent,
    isWaitingForSwitch,
    isSpectator,
    player1Connected,
    player2Connected,
    player1Name,
    player2Name,
    message,
    difficulty,
    const DeepCollectionEquality().hash(_cpuInventory),
    weather,
    terrain,
    lastMoveName,
    lastMoveType,
    isRecharging,
    const DeepCollectionEquality().hash(_statusMap),
    const DeepCollectionEquality().hash(_statusTurns),
    const DeepCollectionEquality().hash(_volatileStatusMap),
    const DeepCollectionEquality().hash(_volatileStatusTurns),
    const DeepCollectionEquality().hash(_disabledMoveMap),
    const DeepCollectionEquality().hash(_encoredMoveMap),
  ]);

  /// Create a copy of BattleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BattleStateImplCopyWith<_$BattleStateImpl> get copyWith =>
      __$$BattleStateImplCopyWithImpl<_$BattleStateImpl>(this, _$identity);
}

abstract class _BattleState implements BattleState {
  const factory _BattleState({
    required final Pokemon playerPokemon,
    required final Pokemon opponentPokemon,
    required final int playerCurrentHp,
    required final int opponentCurrentHp,
    required final int playerMaxHp,
    required final int opponentMaxHp,
    final int playerLevel,
    final int opponentLevel,
    final List<Pokemon> playerTeam,
    final List<Pokemon> opponentTeam,
    final int activePlayerIdx,
    final int activeOpponentIdx,
    final Map<String, int> playerHpMap,
    final Map<String, int> playerMaxHpMap,
    final Map<String, int> opponentHpMap,
    final Map<String, int> opponentMaxHpMap,
    final Map<String, int> inventory,
    final List<BattleLogEntry> battleLog,
    final bool isPlayerTurn,
    final bool isFinished,
    final String? winner,
    final bool isAnimating,
    final bool isWaitingForOpponent,
    final bool isWaitingForSwitch,
    final bool isSpectator,
    final bool player1Connected,
    final bool player2Connected,
    final String player1Name,
    final String player2Name,
    final String message,
    final String difficulty,
    final Map<String, int> cpuInventory,
    final String weather,
    final String terrain,
    final String? lastMoveName,
    final String? lastMoveType,
    final bool isRecharging,
    final Map<String, String> statusMap,
    final Map<String, int> statusTurns,
    final Map<String, List<String>> volatileStatusMap,
    final Map<String, Map<String, int>> volatileStatusTurns,
    final Map<String, String> disabledMoveMap,
    final Map<String, String> encoredMoveMap,
  }) = _$BattleStateImpl;

  @override
  Pokemon get playerPokemon;
  @override
  Pokemon get opponentPokemon;
  @override
  int get playerCurrentHp;
  @override
  int get opponentCurrentHp;
  @override
  int get playerMaxHp;
  @override
  int get opponentMaxHp;
  @override
  int get playerLevel;
  @override
  int get opponentLevel;
  @override
  List<Pokemon> get playerTeam; // The full roster for swapping
  @override
  List<Pokemon> get opponentTeam; // NEW: The CPU's random team
  @override
  int get activePlayerIdx;
  @override
  int get activeOpponentIdx;
  @override
  Map<String, int> get playerHpMap; // id -> current hp
  @override
  Map<String, int> get playerMaxHpMap; // id -> max hp
  @override
  Map<String, int> get opponentHpMap; // id -> current hp
  @override
  Map<String, int> get opponentMaxHpMap; // id -> max hp
  @override
  Map<String, int> get inventory; // The user's bag
  @override
  List<BattleLogEntry> get battleLog;
  @override
  bool get isPlayerTurn;
  @override
  bool get isFinished;
  @override
  String? get winner;
  @override
  bool get isAnimating;
  @override
  bool get isWaitingForOpponent;
  @override
  bool get isWaitingForSwitch; // NEW: Mandatory switch state
  @override
  bool get isSpectator;
  @override
  bool get player1Connected;
  @override
  bool get player2Connected;
  @override
  String get player1Name;
  @override
  String get player2Name;
  @override
  String get message;
  @override
  String get difficulty; // 'normal' or 'hard'
  @override
  Map<String, int> get cpuInventory; // CPU's bag
  @override
  String get weather; // 'none', 'rain', 'sun', 'sand', 'snow'
  @override
  String get terrain; // 'none', 'electric', 'grassy', 'misty', 'psychic'
  @override
  String? get lastMoveName; // For SFX/VFX triggering
  @override
  String? get lastMoveType; // For particle selection
  @override
  bool get isRecharging; // For moves like Hyper Beam
  @override
  Map<String, String> get statusMap; // id -> 'brn', 'psn', 'tox', 'par', 'slp', 'frz', 'none'
  @override
  Map<String, int> get statusTurns; // id -> number of turns
  @override
  Map<String, List<String>> get volatileStatusMap; // id -> ['confused', 'taunted', ...]
  @override
  Map<String, Map<String, int>> get volatileStatusTurns; // id -> { 'taunt': 3 }
  @override
  Map<String, String> get disabledMoveMap; // id -> name of disabled move
  @override
  Map<String, String> get encoredMoveMap;

  /// Create a copy of BattleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BattleStateImplCopyWith<_$BattleStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BattleAction {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PokemonMove move) attack,
    required TResult Function(String itemId, String? targetId) item,
    required TResult Function(Pokemon pokemon) pokemon,
    required TResult Function() run,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PokemonMove move)? attack,
    TResult? Function(String itemId, String? targetId)? item,
    TResult? Function(Pokemon pokemon)? pokemon,
    TResult? Function()? run,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PokemonMove move)? attack,
    TResult Function(String itemId, String? targetId)? item,
    TResult Function(Pokemon pokemon)? pokemon,
    TResult Function()? run,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AttackAction value) attack,
    required TResult Function(ItemAction value) item,
    required TResult Function(PokemonAction value) pokemon,
    required TResult Function(RunAction value) run,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AttackAction value)? attack,
    TResult? Function(ItemAction value)? item,
    TResult? Function(PokemonAction value)? pokemon,
    TResult? Function(RunAction value)? run,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AttackAction value)? attack,
    TResult Function(ItemAction value)? item,
    TResult Function(PokemonAction value)? pokemon,
    TResult Function(RunAction value)? run,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BattleActionCopyWith<$Res> {
  factory $BattleActionCopyWith(
    BattleAction value,
    $Res Function(BattleAction) then,
  ) = _$BattleActionCopyWithImpl<$Res, BattleAction>;
}

/// @nodoc
class _$BattleActionCopyWithImpl<$Res, $Val extends BattleAction>
    implements $BattleActionCopyWith<$Res> {
  _$BattleActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AttackActionImplCopyWith<$Res> {
  factory _$$AttackActionImplCopyWith(
    _$AttackActionImpl value,
    $Res Function(_$AttackActionImpl) then,
  ) = __$$AttackActionImplCopyWithImpl<$Res>;
  @useResult
  $Res call({PokemonMove move});

  $PokemonMoveCopyWith<$Res> get move;
}

/// @nodoc
class __$$AttackActionImplCopyWithImpl<$Res>
    extends _$BattleActionCopyWithImpl<$Res, _$AttackActionImpl>
    implements _$$AttackActionImplCopyWith<$Res> {
  __$$AttackActionImplCopyWithImpl(
    _$AttackActionImpl _value,
    $Res Function(_$AttackActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? move = null}) {
    return _then(
      _$AttackActionImpl(
        null == move
            ? _value.move
            : move // ignore: cast_nullable_to_non_nullable
                  as PokemonMove,
      ),
    );
  }

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PokemonMoveCopyWith<$Res> get move {
    return $PokemonMoveCopyWith<$Res>(_value.move, (value) {
      return _then(_value.copyWith(move: value));
    });
  }
}

/// @nodoc

class _$AttackActionImpl implements AttackAction {
  const _$AttackActionImpl(this.move);

  @override
  final PokemonMove move;

  @override
  String toString() {
    return 'BattleAction.attack(move: $move)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttackActionImpl &&
            (identical(other.move, move) || other.move == move));
  }

  @override
  int get hashCode => Object.hash(runtimeType, move);

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttackActionImplCopyWith<_$AttackActionImpl> get copyWith =>
      __$$AttackActionImplCopyWithImpl<_$AttackActionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PokemonMove move) attack,
    required TResult Function(String itemId, String? targetId) item,
    required TResult Function(Pokemon pokemon) pokemon,
    required TResult Function() run,
  }) {
    return attack(move);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PokemonMove move)? attack,
    TResult? Function(String itemId, String? targetId)? item,
    TResult? Function(Pokemon pokemon)? pokemon,
    TResult? Function()? run,
  }) {
    return attack?.call(move);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PokemonMove move)? attack,
    TResult Function(String itemId, String? targetId)? item,
    TResult Function(Pokemon pokemon)? pokemon,
    TResult Function()? run,
    required TResult orElse(),
  }) {
    if (attack != null) {
      return attack(move);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AttackAction value) attack,
    required TResult Function(ItemAction value) item,
    required TResult Function(PokemonAction value) pokemon,
    required TResult Function(RunAction value) run,
  }) {
    return attack(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AttackAction value)? attack,
    TResult? Function(ItemAction value)? item,
    TResult? Function(PokemonAction value)? pokemon,
    TResult? Function(RunAction value)? run,
  }) {
    return attack?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AttackAction value)? attack,
    TResult Function(ItemAction value)? item,
    TResult Function(PokemonAction value)? pokemon,
    TResult Function(RunAction value)? run,
    required TResult orElse(),
  }) {
    if (attack != null) {
      return attack(this);
    }
    return orElse();
  }
}

abstract class AttackAction implements BattleAction {
  const factory AttackAction(final PokemonMove move) = _$AttackActionImpl;

  PokemonMove get move;

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttackActionImplCopyWith<_$AttackActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ItemActionImplCopyWith<$Res> {
  factory _$$ItemActionImplCopyWith(
    _$ItemActionImpl value,
    $Res Function(_$ItemActionImpl) then,
  ) = __$$ItemActionImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String itemId, String? targetId});
}

/// @nodoc
class __$$ItemActionImplCopyWithImpl<$Res>
    extends _$BattleActionCopyWithImpl<$Res, _$ItemActionImpl>
    implements _$$ItemActionImplCopyWith<$Res> {
  __$$ItemActionImplCopyWithImpl(
    _$ItemActionImpl _value,
    $Res Function(_$ItemActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? itemId = null, Object? targetId = freezed}) {
    return _then(
      _$ItemActionImpl(
        null == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String,
        targetId: freezed == targetId
            ? _value.targetId
            : targetId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ItemActionImpl implements ItemAction {
  const _$ItemActionImpl(this.itemId, {this.targetId});

  @override
  final String itemId;
  @override
  final String? targetId;

  @override
  String toString() {
    return 'BattleAction.item(itemId: $itemId, targetId: $targetId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemActionImpl &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, itemId, targetId);

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemActionImplCopyWith<_$ItemActionImpl> get copyWith =>
      __$$ItemActionImplCopyWithImpl<_$ItemActionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PokemonMove move) attack,
    required TResult Function(String itemId, String? targetId) item,
    required TResult Function(Pokemon pokemon) pokemon,
    required TResult Function() run,
  }) {
    return item(itemId, targetId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PokemonMove move)? attack,
    TResult? Function(String itemId, String? targetId)? item,
    TResult? Function(Pokemon pokemon)? pokemon,
    TResult? Function()? run,
  }) {
    return item?.call(itemId, targetId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PokemonMove move)? attack,
    TResult Function(String itemId, String? targetId)? item,
    TResult Function(Pokemon pokemon)? pokemon,
    TResult Function()? run,
    required TResult orElse(),
  }) {
    if (item != null) {
      return item(itemId, targetId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AttackAction value) attack,
    required TResult Function(ItemAction value) item,
    required TResult Function(PokemonAction value) pokemon,
    required TResult Function(RunAction value) run,
  }) {
    return item(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AttackAction value)? attack,
    TResult? Function(ItemAction value)? item,
    TResult? Function(PokemonAction value)? pokemon,
    TResult? Function(RunAction value)? run,
  }) {
    return item?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AttackAction value)? attack,
    TResult Function(ItemAction value)? item,
    TResult Function(PokemonAction value)? pokemon,
    TResult Function(RunAction value)? run,
    required TResult orElse(),
  }) {
    if (item != null) {
      return item(this);
    }
    return orElse();
  }
}

abstract class ItemAction implements BattleAction {
  const factory ItemAction(final String itemId, {final String? targetId}) =
      _$ItemActionImpl;

  String get itemId;
  String? get targetId;

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemActionImplCopyWith<_$ItemActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PokemonActionImplCopyWith<$Res> {
  factory _$$PokemonActionImplCopyWith(
    _$PokemonActionImpl value,
    $Res Function(_$PokemonActionImpl) then,
  ) = __$$PokemonActionImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Pokemon pokemon});

  $PokemonCopyWith<$Res> get pokemon;
}

/// @nodoc
class __$$PokemonActionImplCopyWithImpl<$Res>
    extends _$BattleActionCopyWithImpl<$Res, _$PokemonActionImpl>
    implements _$$PokemonActionImplCopyWith<$Res> {
  __$$PokemonActionImplCopyWithImpl(
    _$PokemonActionImpl _value,
    $Res Function(_$PokemonActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? pokemon = null}) {
    return _then(
      _$PokemonActionImpl(
        null == pokemon
            ? _value.pokemon
            : pokemon // ignore: cast_nullable_to_non_nullable
                  as Pokemon,
      ),
    );
  }

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PokemonCopyWith<$Res> get pokemon {
    return $PokemonCopyWith<$Res>(_value.pokemon, (value) {
      return _then(_value.copyWith(pokemon: value));
    });
  }
}

/// @nodoc

class _$PokemonActionImpl implements PokemonAction {
  const _$PokemonActionImpl(this.pokemon);

  @override
  final Pokemon pokemon;

  @override
  String toString() {
    return 'BattleAction.pokemon(pokemon: $pokemon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PokemonActionImpl &&
            (identical(other.pokemon, pokemon) || other.pokemon == pokemon));
  }

  @override
  int get hashCode => Object.hash(runtimeType, pokemon);

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PokemonActionImplCopyWith<_$PokemonActionImpl> get copyWith =>
      __$$PokemonActionImplCopyWithImpl<_$PokemonActionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PokemonMove move) attack,
    required TResult Function(String itemId, String? targetId) item,
    required TResult Function(Pokemon pokemon) pokemon,
    required TResult Function() run,
  }) {
    return pokemon(this.pokemon);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PokemonMove move)? attack,
    TResult? Function(String itemId, String? targetId)? item,
    TResult? Function(Pokemon pokemon)? pokemon,
    TResult? Function()? run,
  }) {
    return pokemon?.call(this.pokemon);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PokemonMove move)? attack,
    TResult Function(String itemId, String? targetId)? item,
    TResult Function(Pokemon pokemon)? pokemon,
    TResult Function()? run,
    required TResult orElse(),
  }) {
    if (pokemon != null) {
      return pokemon(this.pokemon);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AttackAction value) attack,
    required TResult Function(ItemAction value) item,
    required TResult Function(PokemonAction value) pokemon,
    required TResult Function(RunAction value) run,
  }) {
    return pokemon(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AttackAction value)? attack,
    TResult? Function(ItemAction value)? item,
    TResult? Function(PokemonAction value)? pokemon,
    TResult? Function(RunAction value)? run,
  }) {
    return pokemon?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AttackAction value)? attack,
    TResult Function(ItemAction value)? item,
    TResult Function(PokemonAction value)? pokemon,
    TResult Function(RunAction value)? run,
    required TResult orElse(),
  }) {
    if (pokemon != null) {
      return pokemon(this);
    }
    return orElse();
  }
}

abstract class PokemonAction implements BattleAction {
  const factory PokemonAction(final Pokemon pokemon) = _$PokemonActionImpl;

  Pokemon get pokemon;

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PokemonActionImplCopyWith<_$PokemonActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RunActionImplCopyWith<$Res> {
  factory _$$RunActionImplCopyWith(
    _$RunActionImpl value,
    $Res Function(_$RunActionImpl) then,
  ) = __$$RunActionImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RunActionImplCopyWithImpl<$Res>
    extends _$BattleActionCopyWithImpl<$Res, _$RunActionImpl>
    implements _$$RunActionImplCopyWith<$Res> {
  __$$RunActionImplCopyWithImpl(
    _$RunActionImpl _value,
    $Res Function(_$RunActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BattleAction
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RunActionImpl implements RunAction {
  const _$RunActionImpl();

  @override
  String toString() {
    return 'BattleAction.run()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RunActionImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PokemonMove move) attack,
    required TResult Function(String itemId, String? targetId) item,
    required TResult Function(Pokemon pokemon) pokemon,
    required TResult Function() run,
  }) {
    return run();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PokemonMove move)? attack,
    TResult? Function(String itemId, String? targetId)? item,
    TResult? Function(Pokemon pokemon)? pokemon,
    TResult? Function()? run,
  }) {
    return run?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PokemonMove move)? attack,
    TResult Function(String itemId, String? targetId)? item,
    TResult Function(Pokemon pokemon)? pokemon,
    TResult Function()? run,
    required TResult orElse(),
  }) {
    if (run != null) {
      return run();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AttackAction value) attack,
    required TResult Function(ItemAction value) item,
    required TResult Function(PokemonAction value) pokemon,
    required TResult Function(RunAction value) run,
  }) {
    return run(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AttackAction value)? attack,
    TResult? Function(ItemAction value)? item,
    TResult? Function(PokemonAction value)? pokemon,
    TResult? Function(RunAction value)? run,
  }) {
    return run?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AttackAction value)? attack,
    TResult Function(ItemAction value)? item,
    TResult Function(PokemonAction value)? pokemon,
    TResult Function(RunAction value)? run,
    required TResult orElse(),
  }) {
    if (run != null) {
      return run(this);
    }
    return orElse();
  }
}

abstract class RunAction implements BattleAction {
  const factory RunAction() = _$RunActionImpl;
}
