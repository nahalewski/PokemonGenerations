// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pokemon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PokemonMove _$PokemonMoveFromJson(Map<String, dynamic> json) {
  return _PokemonMove.fromJson(json);
}

/// @nodoc
mixin _$PokemonMove {
  String get name => throw _privateConstructorUsedError;
  int get learnLevel => throw _privateConstructorUsedError;
  String get learnMethod => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get power => throw _privateConstructorUsedError;
  String get damageClass =>
      throw _privateConstructorUsedError; // physical, special, status
  String get statusEffect =>
      throw _privateConstructorUsedError; // brn, psn, tox, par, slp, frb, none
  int get statusChance => throw _privateConstructorUsedError;

  /// Serializes this PokemonMove to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PokemonMove
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PokemonMoveCopyWith<PokemonMove> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PokemonMoveCopyWith<$Res> {
  factory $PokemonMoveCopyWith(
    PokemonMove value,
    $Res Function(PokemonMove) then,
  ) = _$PokemonMoveCopyWithImpl<$Res, PokemonMove>;
  @useResult
  $Res call({
    String name,
    int learnLevel,
    String learnMethod,
    String type,
    int power,
    String damageClass,
    String statusEffect,
    int statusChance,
  });
}

/// @nodoc
class _$PokemonMoveCopyWithImpl<$Res, $Val extends PokemonMove>
    implements $PokemonMoveCopyWith<$Res> {
  _$PokemonMoveCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PokemonMove
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? learnLevel = null,
    Object? learnMethod = null,
    Object? type = null,
    Object? power = null,
    Object? damageClass = null,
    Object? statusEffect = null,
    Object? statusChance = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            learnLevel: null == learnLevel
                ? _value.learnLevel
                : learnLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            learnMethod: null == learnMethod
                ? _value.learnMethod
                : learnMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            power: null == power
                ? _value.power
                : power // ignore: cast_nullable_to_non_nullable
                      as int,
            damageClass: null == damageClass
                ? _value.damageClass
                : damageClass // ignore: cast_nullable_to_non_nullable
                      as String,
            statusEffect: null == statusEffect
                ? _value.statusEffect
                : statusEffect // ignore: cast_nullable_to_non_nullable
                      as String,
            statusChance: null == statusChance
                ? _value.statusChance
                : statusChance // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PokemonMoveImplCopyWith<$Res>
    implements $PokemonMoveCopyWith<$Res> {
  factory _$$PokemonMoveImplCopyWith(
    _$PokemonMoveImpl value,
    $Res Function(_$PokemonMoveImpl) then,
  ) = __$$PokemonMoveImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    int learnLevel,
    String learnMethod,
    String type,
    int power,
    String damageClass,
    String statusEffect,
    int statusChance,
  });
}

/// @nodoc
class __$$PokemonMoveImplCopyWithImpl<$Res>
    extends _$PokemonMoveCopyWithImpl<$Res, _$PokemonMoveImpl>
    implements _$$PokemonMoveImplCopyWith<$Res> {
  __$$PokemonMoveImplCopyWithImpl(
    _$PokemonMoveImpl _value,
    $Res Function(_$PokemonMoveImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PokemonMove
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? learnLevel = null,
    Object? learnMethod = null,
    Object? type = null,
    Object? power = null,
    Object? damageClass = null,
    Object? statusEffect = null,
    Object? statusChance = null,
  }) {
    return _then(
      _$PokemonMoveImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        learnLevel: null == learnLevel
            ? _value.learnLevel
            : learnLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        learnMethod: null == learnMethod
            ? _value.learnMethod
            : learnMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        power: null == power
            ? _value.power
            : power // ignore: cast_nullable_to_non_nullable
                  as int,
        damageClass: null == damageClass
            ? _value.damageClass
            : damageClass // ignore: cast_nullable_to_non_nullable
                  as String,
        statusEffect: null == statusEffect
            ? _value.statusEffect
            : statusEffect // ignore: cast_nullable_to_non_nullable
                  as String,
        statusChance: null == statusChance
            ? _value.statusChance
            : statusChance // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PokemonMoveImpl implements _PokemonMove {
  const _$PokemonMoveImpl({
    required this.name,
    required this.learnLevel,
    required this.learnMethod,
    this.type = 'normal',
    this.power = 60,
    this.damageClass = 'physical',
    this.statusEffect = 'none',
    this.statusChance = 0,
  });

  factory _$PokemonMoveImpl.fromJson(Map<String, dynamic> json) =>
      _$$PokemonMoveImplFromJson(json);

  @override
  final String name;
  @override
  final int learnLevel;
  @override
  final String learnMethod;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final int power;
  @override
  @JsonKey()
  final String damageClass;
  // physical, special, status
  @override
  @JsonKey()
  final String statusEffect;
  // brn, psn, tox, par, slp, frb, none
  @override
  @JsonKey()
  final int statusChance;

  @override
  String toString() {
    return 'PokemonMove(name: $name, learnLevel: $learnLevel, learnMethod: $learnMethod, type: $type, power: $power, damageClass: $damageClass, statusEffect: $statusEffect, statusChance: $statusChance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PokemonMoveImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.learnLevel, learnLevel) ||
                other.learnLevel == learnLevel) &&
            (identical(other.learnMethod, learnMethod) ||
                other.learnMethod == learnMethod) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.power, power) || other.power == power) &&
            (identical(other.damageClass, damageClass) ||
                other.damageClass == damageClass) &&
            (identical(other.statusEffect, statusEffect) ||
                other.statusEffect == statusEffect) &&
            (identical(other.statusChance, statusChance) ||
                other.statusChance == statusChance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    learnLevel,
    learnMethod,
    type,
    power,
    damageClass,
    statusEffect,
    statusChance,
  );

  /// Create a copy of PokemonMove
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PokemonMoveImplCopyWith<_$PokemonMoveImpl> get copyWith =>
      __$$PokemonMoveImplCopyWithImpl<_$PokemonMoveImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PokemonMoveImplToJson(this);
  }
}

abstract class _PokemonMove implements PokemonMove {
  const factory _PokemonMove({
    required final String name,
    required final int learnLevel,
    required final String learnMethod,
    final String type,
    final int power,
    final String damageClass,
    final String statusEffect,
    final int statusChance,
  }) = _$PokemonMoveImpl;

  factory _PokemonMove.fromJson(Map<String, dynamic> json) =
      _$PokemonMoveImpl.fromJson;

  @override
  String get name;
  @override
  int get learnLevel;
  @override
  String get learnMethod;
  @override
  String get type;
  @override
  int get power;
  @override
  String get damageClass; // physical, special, status
  @override
  String get statusEffect; // brn, psn, tox, par, slp, frb, none
  @override
  int get statusChance;

  /// Create a copy of PokemonMove
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PokemonMoveImplCopyWith<_$PokemonMoveImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Pokemon _$PokemonFromJson(Map<String, dynamic> json) {
  return _Pokemon.fromJson(json);
}

/// @nodoc
mixin _$Pokemon {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String> get types => throw _privateConstructorUsedError;
  Map<String, int> get baseStats => throw _privateConstructorUsedError;
  List<String> get abilities => throw _privateConstructorUsedError;
  List<PokemonMove> get availableMoves => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get spriteUrl => throw _privateConstructorUsedError;
  bool get isCustom => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get latestCryUrl => throw _privateConstructorUsedError;
  String? get legacyCryUrl => throw _privateConstructorUsedError;

  /// Serializes this Pokemon to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Pokemon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PokemonCopyWith<Pokemon> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PokemonCopyWith<$Res> {
  factory $PokemonCopyWith(Pokemon value, $Res Function(Pokemon) then) =
      _$PokemonCopyWithImpl<$Res, Pokemon>;
  @useResult
  $Res call({
    String id,
    String name,
    List<String> types,
    Map<String, int> baseStats,
    List<String> abilities,
    List<PokemonMove> availableMoves,
    @JsonKey(includeFromJson: false, includeToJson: false) String? spriteUrl,
    bool isCustom,
    String? description,
    String? latestCryUrl,
    String? legacyCryUrl,
  });
}

/// @nodoc
class _$PokemonCopyWithImpl<$Res, $Val extends Pokemon>
    implements $PokemonCopyWith<$Res> {
  _$PokemonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Pokemon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? types = null,
    Object? baseStats = null,
    Object? abilities = null,
    Object? availableMoves = null,
    Object? spriteUrl = freezed,
    Object? isCustom = null,
    Object? description = freezed,
    Object? latestCryUrl = freezed,
    Object? legacyCryUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            types: null == types
                ? _value.types
                : types // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            baseStats: null == baseStats
                ? _value.baseStats
                : baseStats // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            abilities: null == abilities
                ? _value.abilities
                : abilities // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            availableMoves: null == availableMoves
                ? _value.availableMoves
                : availableMoves // ignore: cast_nullable_to_non_nullable
                      as List<PokemonMove>,
            spriteUrl: freezed == spriteUrl
                ? _value.spriteUrl
                : spriteUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isCustom: null == isCustom
                ? _value.isCustom
                : isCustom // ignore: cast_nullable_to_non_nullable
                      as bool,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            latestCryUrl: freezed == latestCryUrl
                ? _value.latestCryUrl
                : latestCryUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            legacyCryUrl: freezed == legacyCryUrl
                ? _value.legacyCryUrl
                : legacyCryUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PokemonImplCopyWith<$Res> implements $PokemonCopyWith<$Res> {
  factory _$$PokemonImplCopyWith(
    _$PokemonImpl value,
    $Res Function(_$PokemonImpl) then,
  ) = __$$PokemonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    List<String> types,
    Map<String, int> baseStats,
    List<String> abilities,
    List<PokemonMove> availableMoves,
    @JsonKey(includeFromJson: false, includeToJson: false) String? spriteUrl,
    bool isCustom,
    String? description,
    String? latestCryUrl,
    String? legacyCryUrl,
  });
}

/// @nodoc
class __$$PokemonImplCopyWithImpl<$Res>
    extends _$PokemonCopyWithImpl<$Res, _$PokemonImpl>
    implements _$$PokemonImplCopyWith<$Res> {
  __$$PokemonImplCopyWithImpl(
    _$PokemonImpl _value,
    $Res Function(_$PokemonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Pokemon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? types = null,
    Object? baseStats = null,
    Object? abilities = null,
    Object? availableMoves = null,
    Object? spriteUrl = freezed,
    Object? isCustom = null,
    Object? description = freezed,
    Object? latestCryUrl = freezed,
    Object? legacyCryUrl = freezed,
  }) {
    return _then(
      _$PokemonImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        types: null == types
            ? _value._types
            : types // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        baseStats: null == baseStats
            ? _value._baseStats
            : baseStats // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        abilities: null == abilities
            ? _value._abilities
            : abilities // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        availableMoves: null == availableMoves
            ? _value._availableMoves
            : availableMoves // ignore: cast_nullable_to_non_nullable
                  as List<PokemonMove>,
        spriteUrl: freezed == spriteUrl
            ? _value.spriteUrl
            : spriteUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isCustom: null == isCustom
            ? _value.isCustom
            : isCustom // ignore: cast_nullable_to_non_nullable
                  as bool,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        latestCryUrl: freezed == latestCryUrl
            ? _value.latestCryUrl
            : latestCryUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        legacyCryUrl: freezed == legacyCryUrl
            ? _value.legacyCryUrl
            : legacyCryUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PokemonImpl extends _Pokemon {
  const _$PokemonImpl({
    required this.id,
    required this.name,
    required final List<String> types,
    required final Map<String, int> baseStats,
    required final List<String> abilities,
    final List<PokemonMove> availableMoves = const [],
    @JsonKey(includeFromJson: false, includeToJson: false) this.spriteUrl,
    this.isCustom = false,
    this.description,
    this.latestCryUrl,
    this.legacyCryUrl,
  }) : _types = types,
       _baseStats = baseStats,
       _abilities = abilities,
       _availableMoves = availableMoves,
       super._();

  factory _$PokemonImpl.fromJson(Map<String, dynamic> json) =>
      _$$PokemonImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<String> _types;
  @override
  List<String> get types {
    if (_types is EqualUnmodifiableListView) return _types;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_types);
  }

  final Map<String, int> _baseStats;
  @override
  Map<String, int> get baseStats {
    if (_baseStats is EqualUnmodifiableMapView) return _baseStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_baseStats);
  }

  final List<String> _abilities;
  @override
  List<String> get abilities {
    if (_abilities is EqualUnmodifiableListView) return _abilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_abilities);
  }

  final List<PokemonMove> _availableMoves;
  @override
  @JsonKey()
  List<PokemonMove> get availableMoves {
    if (_availableMoves is EqualUnmodifiableListView) return _availableMoves;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableMoves);
  }

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? spriteUrl;
  @override
  @JsonKey()
  final bool isCustom;
  @override
  final String? description;
  @override
  final String? latestCryUrl;
  @override
  final String? legacyCryUrl;

  @override
  String toString() {
    return 'Pokemon(id: $id, name: $name, types: $types, baseStats: $baseStats, abilities: $abilities, availableMoves: $availableMoves, spriteUrl: $spriteUrl, isCustom: $isCustom, description: $description, latestCryUrl: $latestCryUrl, legacyCryUrl: $legacyCryUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PokemonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._types, _types) &&
            const DeepCollectionEquality().equals(
              other._baseStats,
              _baseStats,
            ) &&
            const DeepCollectionEquality().equals(
              other._abilities,
              _abilities,
            ) &&
            const DeepCollectionEquality().equals(
              other._availableMoves,
              _availableMoves,
            ) &&
            (identical(other.spriteUrl, spriteUrl) ||
                other.spriteUrl == spriteUrl) &&
            (identical(other.isCustom, isCustom) ||
                other.isCustom == isCustom) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.latestCryUrl, latestCryUrl) ||
                other.latestCryUrl == latestCryUrl) &&
            (identical(other.legacyCryUrl, legacyCryUrl) ||
                other.legacyCryUrl == legacyCryUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_types),
    const DeepCollectionEquality().hash(_baseStats),
    const DeepCollectionEquality().hash(_abilities),
    const DeepCollectionEquality().hash(_availableMoves),
    spriteUrl,
    isCustom,
    description,
    latestCryUrl,
    legacyCryUrl,
  );

  /// Create a copy of Pokemon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PokemonImplCopyWith<_$PokemonImpl> get copyWith =>
      __$$PokemonImplCopyWithImpl<_$PokemonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PokemonImplToJson(this);
  }
}

abstract class _Pokemon extends Pokemon {
  const factory _Pokemon({
    required final String id,
    required final String name,
    required final List<String> types,
    required final Map<String, int> baseStats,
    required final List<String> abilities,
    final List<PokemonMove> availableMoves,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final String? spriteUrl,
    final bool isCustom,
    final String? description,
    final String? latestCryUrl,
    final String? legacyCryUrl,
  }) = _$PokemonImpl;
  const _Pokemon._() : super._();

  factory _Pokemon.fromJson(Map<String, dynamic> json) = _$PokemonImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<String> get types;
  @override
  Map<String, int> get baseStats;
  @override
  List<String> get abilities;
  @override
  List<PokemonMove> get availableMoves;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get spriteUrl;
  @override
  bool get isCustom;
  @override
  String? get description;
  @override
  String? get latestCryUrl;
  @override
  String? get legacyCryUrl;

  /// Create a copy of Pokemon
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PokemonImplCopyWith<_$PokemonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
