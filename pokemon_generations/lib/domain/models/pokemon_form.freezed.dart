// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pokemon_form.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PokemonForm _$PokemonFormFromJson(Map<String, dynamic> json) {
  return _PokemonForm.fromJson(json);
}

/// @nodoc
mixin _$PokemonForm {
  String get id => throw _privateConstructorUsedError;
  String get pokemonId => throw _privateConstructorUsedError;
  String? get pokemonName => throw _privateConstructorUsedError;
  String get ability => throw _privateConstructorUsedError;
  String get item => throw _privateConstructorUsedError;
  String get nature => throw _privateConstructorUsedError;
  Map<String, int> get evs => throw _privateConstructorUsedError;
  Map<String, int> get ivs => throw _privateConstructorUsedError;
  List<String> get moves => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  String get teraType => throw _privateConstructorUsedError;
  int get wins => throw _privateConstructorUsedError;
  int get losses => throw _privateConstructorUsedError;
  int get boxIndex => throw _privateConstructorUsedError;
  int get slotIndex => throw _privateConstructorUsedError;

  /// Serializes this PokemonForm to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PokemonForm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PokemonFormCopyWith<PokemonForm> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PokemonFormCopyWith<$Res> {
  factory $PokemonFormCopyWith(
    PokemonForm value,
    $Res Function(PokemonForm) then,
  ) = _$PokemonFormCopyWithImpl<$Res, PokemonForm>;
  @useResult
  $Res call({
    String id,
    String pokemonId,
    String? pokemonName,
    String ability,
    String item,
    String nature,
    Map<String, int> evs,
    Map<String, int> ivs,
    List<String> moves,
    int level,
    String teraType,
    int wins,
    int losses,
    int boxIndex,
    int slotIndex,
  });
}

/// @nodoc
class _$PokemonFormCopyWithImpl<$Res, $Val extends PokemonForm>
    implements $PokemonFormCopyWith<$Res> {
  _$PokemonFormCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PokemonForm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pokemonId = null,
    Object? pokemonName = freezed,
    Object? ability = null,
    Object? item = null,
    Object? nature = null,
    Object? evs = null,
    Object? ivs = null,
    Object? moves = null,
    Object? level = null,
    Object? teraType = null,
    Object? wins = null,
    Object? losses = null,
    Object? boxIndex = null,
    Object? slotIndex = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            pokemonId: null == pokemonId
                ? _value.pokemonId
                : pokemonId // ignore: cast_nullable_to_non_nullable
                      as String,
            pokemonName: freezed == pokemonName
                ? _value.pokemonName
                : pokemonName // ignore: cast_nullable_to_non_nullable
                      as String?,
            ability: null == ability
                ? _value.ability
                : ability // ignore: cast_nullable_to_non_nullable
                      as String,
            item: null == item
                ? _value.item
                : item // ignore: cast_nullable_to_non_nullable
                      as String,
            nature: null == nature
                ? _value.nature
                : nature // ignore: cast_nullable_to_non_nullable
                      as String,
            evs: null == evs
                ? _value.evs
                : evs // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            ivs: null == ivs
                ? _value.ivs
                : ivs // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            moves: null == moves
                ? _value.moves
                : moves // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            teraType: null == teraType
                ? _value.teraType
                : teraType // ignore: cast_nullable_to_non_nullable
                      as String,
            wins: null == wins
                ? _value.wins
                : wins // ignore: cast_nullable_to_non_nullable
                      as int,
            losses: null == losses
                ? _value.losses
                : losses // ignore: cast_nullable_to_non_nullable
                      as int,
            boxIndex: null == boxIndex
                ? _value.boxIndex
                : boxIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            slotIndex: null == slotIndex
                ? _value.slotIndex
                : slotIndex // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PokemonFormImplCopyWith<$Res>
    implements $PokemonFormCopyWith<$Res> {
  factory _$$PokemonFormImplCopyWith(
    _$PokemonFormImpl value,
    $Res Function(_$PokemonFormImpl) then,
  ) = __$$PokemonFormImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String pokemonId,
    String? pokemonName,
    String ability,
    String item,
    String nature,
    Map<String, int> evs,
    Map<String, int> ivs,
    List<String> moves,
    int level,
    String teraType,
    int wins,
    int losses,
    int boxIndex,
    int slotIndex,
  });
}

/// @nodoc
class __$$PokemonFormImplCopyWithImpl<$Res>
    extends _$PokemonFormCopyWithImpl<$Res, _$PokemonFormImpl>
    implements _$$PokemonFormImplCopyWith<$Res> {
  __$$PokemonFormImplCopyWithImpl(
    _$PokemonFormImpl _value,
    $Res Function(_$PokemonFormImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PokemonForm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pokemonId = null,
    Object? pokemonName = freezed,
    Object? ability = null,
    Object? item = null,
    Object? nature = null,
    Object? evs = null,
    Object? ivs = null,
    Object? moves = null,
    Object? level = null,
    Object? teraType = null,
    Object? wins = null,
    Object? losses = null,
    Object? boxIndex = null,
    Object? slotIndex = null,
  }) {
    return _then(
      _$PokemonFormImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        pokemonId: null == pokemonId
            ? _value.pokemonId
            : pokemonId // ignore: cast_nullable_to_non_nullable
                  as String,
        pokemonName: freezed == pokemonName
            ? _value.pokemonName
            : pokemonName // ignore: cast_nullable_to_non_nullable
                  as String?,
        ability: null == ability
            ? _value.ability
            : ability // ignore: cast_nullable_to_non_nullable
                  as String,
        item: null == item
            ? _value.item
            : item // ignore: cast_nullable_to_non_nullable
                  as String,
        nature: null == nature
            ? _value.nature
            : nature // ignore: cast_nullable_to_non_nullable
                  as String,
        evs: null == evs
            ? _value._evs
            : evs // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        ivs: null == ivs
            ? _value._ivs
            : ivs // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        moves: null == moves
            ? _value._moves
            : moves // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        teraType: null == teraType
            ? _value.teraType
            : teraType // ignore: cast_nullable_to_non_nullable
                  as String,
        wins: null == wins
            ? _value.wins
            : wins // ignore: cast_nullable_to_non_nullable
                  as int,
        losses: null == losses
            ? _value.losses
            : losses // ignore: cast_nullable_to_non_nullable
                  as int,
        boxIndex: null == boxIndex
            ? _value.boxIndex
            : boxIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        slotIndex: null == slotIndex
            ? _value.slotIndex
            : slotIndex // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PokemonFormImpl implements _PokemonForm {
  const _$PokemonFormImpl({
    this.id = '',
    this.pokemonId = '',
    this.pokemonName,
    this.ability = 'Unknown',
    this.item = 'None',
    this.nature = 'Neutral',
    final Map<String, int> evs = const {
      'hp': 0,
      'atk': 0,
      'def': 0,
      'spa': 0,
      'spd': 0,
      'spe': 0,
    },
    final Map<String, int> ivs = const {
      'hp': 31,
      'atk': 31,
      'def': 31,
      'spa': 31,
      'spd': 31,
      'spe': 31,
    },
    final List<String> moves = const [],
    this.level = 50,
    this.teraType = 'Normal',
    this.wins = 0,
    this.losses = 0,
    this.boxIndex = 0,
    this.slotIndex = -1,
  }) : _evs = evs,
       _ivs = ivs,
       _moves = moves;

  factory _$PokemonFormImpl.fromJson(Map<String, dynamic> json) =>
      _$$PokemonFormImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String pokemonId;
  @override
  final String? pokemonName;
  @override
  @JsonKey()
  final String ability;
  @override
  @JsonKey()
  final String item;
  @override
  @JsonKey()
  final String nature;
  final Map<String, int> _evs;
  @override
  @JsonKey()
  Map<String, int> get evs {
    if (_evs is EqualUnmodifiableMapView) return _evs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_evs);
  }

  final Map<String, int> _ivs;
  @override
  @JsonKey()
  Map<String, int> get ivs {
    if (_ivs is EqualUnmodifiableMapView) return _ivs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_ivs);
  }

  final List<String> _moves;
  @override
  @JsonKey()
  List<String> get moves {
    if (_moves is EqualUnmodifiableListView) return _moves;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moves);
  }

  @override
  @JsonKey()
  final int level;
  @override
  @JsonKey()
  final String teraType;
  @override
  @JsonKey()
  final int wins;
  @override
  @JsonKey()
  final int losses;
  @override
  @JsonKey()
  final int boxIndex;
  @override
  @JsonKey()
  final int slotIndex;

  @override
  String toString() {
    return 'PokemonForm(id: $id, pokemonId: $pokemonId, pokemonName: $pokemonName, ability: $ability, item: $item, nature: $nature, evs: $evs, ivs: $ivs, moves: $moves, level: $level, teraType: $teraType, wins: $wins, losses: $losses, boxIndex: $boxIndex, slotIndex: $slotIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PokemonFormImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pokemonId, pokemonId) ||
                other.pokemonId == pokemonId) &&
            (identical(other.pokemonName, pokemonName) ||
                other.pokemonName == pokemonName) &&
            (identical(other.ability, ability) || other.ability == ability) &&
            (identical(other.item, item) || other.item == item) &&
            (identical(other.nature, nature) || other.nature == nature) &&
            const DeepCollectionEquality().equals(other._evs, _evs) &&
            const DeepCollectionEquality().equals(other._ivs, _ivs) &&
            const DeepCollectionEquality().equals(other._moves, _moves) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.teraType, teraType) ||
                other.teraType == teraType) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.losses, losses) || other.losses == losses) &&
            (identical(other.boxIndex, boxIndex) ||
                other.boxIndex == boxIndex) &&
            (identical(other.slotIndex, slotIndex) ||
                other.slotIndex == slotIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    pokemonId,
    pokemonName,
    ability,
    item,
    nature,
    const DeepCollectionEquality().hash(_evs),
    const DeepCollectionEquality().hash(_ivs),
    const DeepCollectionEquality().hash(_moves),
    level,
    teraType,
    wins,
    losses,
    boxIndex,
    slotIndex,
  );

  /// Create a copy of PokemonForm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PokemonFormImplCopyWith<_$PokemonFormImpl> get copyWith =>
      __$$PokemonFormImplCopyWithImpl<_$PokemonFormImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PokemonFormImplToJson(this);
  }
}

abstract class _PokemonForm implements PokemonForm {
  const factory _PokemonForm({
    final String id,
    final String pokemonId,
    final String? pokemonName,
    final String ability,
    final String item,
    final String nature,
    final Map<String, int> evs,
    final Map<String, int> ivs,
    final List<String> moves,
    final int level,
    final String teraType,
    final int wins,
    final int losses,
    final int boxIndex,
    final int slotIndex,
  }) = _$PokemonFormImpl;

  factory _PokemonForm.fromJson(Map<String, dynamic> json) =
      _$PokemonFormImpl.fromJson;

  @override
  String get id;
  @override
  String get pokemonId;
  @override
  String? get pokemonName;
  @override
  String get ability;
  @override
  String get item;
  @override
  String get nature;
  @override
  Map<String, int> get evs;
  @override
  Map<String, int> get ivs;
  @override
  List<String> get moves;
  @override
  int get level;
  @override
  String get teraType;
  @override
  int get wins;
  @override
  int get losses;
  @override
  int get boxIndex;
  @override
  int get slotIndex;

  /// Create a copy of PokemonForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PokemonFormImplCopyWith<_$PokemonFormImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
