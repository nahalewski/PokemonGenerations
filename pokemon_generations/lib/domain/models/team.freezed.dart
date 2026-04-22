// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Team _$TeamFromJson(Map<String, dynamic> json) {
  return _Team.fromJson(json);
}

/// @nodoc
mixin _$Team {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<PokemonForm> get slots => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  int get winCount => throw _privateConstructorUsedError;
  int get lossCount => throw _privateConstructorUsedError;

  /// Serializes this Team to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamCopyWith<Team> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamCopyWith<$Res> {
  factory $TeamCopyWith(Team value, $Res Function(Team) then) =
      _$TeamCopyWithImpl<$Res, Team>;
  @useResult
  $Res call({
    String id,
    String name,
    List<PokemonForm> slots,
    String notes,
    DateTime updatedAt,
    int winCount,
    int lossCount,
  });
}

/// @nodoc
class _$TeamCopyWithImpl<$Res, $Val extends Team>
    implements $TeamCopyWith<$Res> {
  _$TeamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slots = null,
    Object? notes = null,
    Object? updatedAt = null,
    Object? winCount = null,
    Object? lossCount = null,
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
            slots: null == slots
                ? _value.slots
                : slots // ignore: cast_nullable_to_non_nullable
                      as List<PokemonForm>,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            winCount: null == winCount
                ? _value.winCount
                : winCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lossCount: null == lossCount
                ? _value.lossCount
                : lossCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamImplCopyWith<$Res> implements $TeamCopyWith<$Res> {
  factory _$$TeamImplCopyWith(
    _$TeamImpl value,
    $Res Function(_$TeamImpl) then,
  ) = __$$TeamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    List<PokemonForm> slots,
    String notes,
    DateTime updatedAt,
    int winCount,
    int lossCount,
  });
}

/// @nodoc
class __$$TeamImplCopyWithImpl<$Res>
    extends _$TeamCopyWithImpl<$Res, _$TeamImpl>
    implements _$$TeamImplCopyWith<$Res> {
  __$$TeamImplCopyWithImpl(_$TeamImpl _value, $Res Function(_$TeamImpl) _then)
    : super(_value, _then);

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slots = null,
    Object? notes = null,
    Object? updatedAt = null,
    Object? winCount = null,
    Object? lossCount = null,
  }) {
    return _then(
      _$TeamImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        slots: null == slots
            ? _value._slots
            : slots // ignore: cast_nullable_to_non_nullable
                  as List<PokemonForm>,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        winCount: null == winCount
            ? _value.winCount
            : winCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lossCount: null == lossCount
            ? _value.lossCount
            : lossCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamImpl implements _Team {
  const _$TeamImpl({
    required this.id,
    required this.name,
    required final List<PokemonForm> slots,
    this.notes = '',
    required this.updatedAt,
    this.winCount = 0,
    this.lossCount = 0,
  }) : _slots = slots;

  factory _$TeamImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<PokemonForm> _slots;
  @override
  List<PokemonForm> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slots);
  }

  @override
  @JsonKey()
  final String notes;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final int winCount;
  @override
  @JsonKey()
  final int lossCount;

  @override
  String toString() {
    return 'Team(id: $id, name: $name, slots: $slots, notes: $notes, updatedAt: $updatedAt, winCount: $winCount, lossCount: $lossCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._slots, _slots) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.winCount, winCount) ||
                other.winCount == winCount) &&
            (identical(other.lossCount, lossCount) ||
                other.lossCount == lossCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_slots),
    notes,
    updatedAt,
    winCount,
    lossCount,
  );

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamImplCopyWith<_$TeamImpl> get copyWith =>
      __$$TeamImplCopyWithImpl<_$TeamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamImplToJson(this);
  }
}

abstract class _Team implements Team {
  const factory _Team({
    required final String id,
    required final String name,
    required final List<PokemonForm> slots,
    final String notes,
    required final DateTime updatedAt,
    final int winCount,
    final int lossCount,
  }) = _$TeamImpl;

  factory _Team.fromJson(Map<String, dynamic> json) = _$TeamImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<PokemonForm> get slots;
  @override
  String get notes;
  @override
  DateTime get updatedAt;
  @override
  int get winCount;
  @override
  int get lossCount;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamImplCopyWith<_$TeamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Roster _$RosterFromJson(Map<String, dynamic> json) {
  return _Roster.fromJson(json);
}

/// @nodoc
mixin _$Roster {
  String get id => throw _privateConstructorUsedError;
  List<PokemonForm> get pokemon => throw _privateConstructorUsedError;
  List<Team> get presets => throw _privateConstructorUsedError;

  /// Serializes this Roster to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Roster
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RosterCopyWith<Roster> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RosterCopyWith<$Res> {
  factory $RosterCopyWith(Roster value, $Res Function(Roster) then) =
      _$RosterCopyWithImpl<$Res, Roster>;
  @useResult
  $Res call({String id, List<PokemonForm> pokemon, List<Team> presets});
}

/// @nodoc
class _$RosterCopyWithImpl<$Res, $Val extends Roster>
    implements $RosterCopyWith<$Res> {
  _$RosterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Roster
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pokemon = null,
    Object? presets = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            pokemon: null == pokemon
                ? _value.pokemon
                : pokemon // ignore: cast_nullable_to_non_nullable
                      as List<PokemonForm>,
            presets: null == presets
                ? _value.presets
                : presets // ignore: cast_nullable_to_non_nullable
                      as List<Team>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RosterImplCopyWith<$Res> implements $RosterCopyWith<$Res> {
  factory _$$RosterImplCopyWith(
    _$RosterImpl value,
    $Res Function(_$RosterImpl) then,
  ) = __$$RosterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, List<PokemonForm> pokemon, List<Team> presets});
}

/// @nodoc
class __$$RosterImplCopyWithImpl<$Res>
    extends _$RosterCopyWithImpl<$Res, _$RosterImpl>
    implements _$$RosterImplCopyWith<$Res> {
  __$$RosterImplCopyWithImpl(
    _$RosterImpl _value,
    $Res Function(_$RosterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Roster
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pokemon = null,
    Object? presets = null,
  }) {
    return _then(
      _$RosterImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        pokemon: null == pokemon
            ? _value._pokemon
            : pokemon // ignore: cast_nullable_to_non_nullable
                  as List<PokemonForm>,
        presets: null == presets
            ? _value._presets
            : presets // ignore: cast_nullable_to_non_nullable
                  as List<Team>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RosterImpl implements _Roster {
  const _$RosterImpl({
    required this.id,
    final List<PokemonForm> pokemon = const [],
    final List<Team> presets = const [],
  }) : _pokemon = pokemon,
       _presets = presets;

  factory _$RosterImpl.fromJson(Map<String, dynamic> json) =>
      _$$RosterImplFromJson(json);

  @override
  final String id;
  final List<PokemonForm> _pokemon;
  @override
  @JsonKey()
  List<PokemonForm> get pokemon {
    if (_pokemon is EqualUnmodifiableListView) return _pokemon;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pokemon);
  }

  final List<Team> _presets;
  @override
  @JsonKey()
  List<Team> get presets {
    if (_presets is EqualUnmodifiableListView) return _presets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_presets);
  }

  @override
  String toString() {
    return 'Roster(id: $id, pokemon: $pokemon, presets: $presets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RosterImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._pokemon, _pokemon) &&
            const DeepCollectionEquality().equals(other._presets, _presets));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_pokemon),
    const DeepCollectionEquality().hash(_presets),
  );

  /// Create a copy of Roster
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RosterImplCopyWith<_$RosterImpl> get copyWith =>
      __$$RosterImplCopyWithImpl<_$RosterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RosterImplToJson(this);
  }
}

abstract class _Roster implements Roster {
  const factory _Roster({
    required final String id,
    final List<PokemonForm> pokemon,
    final List<Team> presets,
  }) = _$RosterImpl;

  factory _Roster.fromJson(Map<String, dynamic> json) = _$RosterImpl.fromJson;

  @override
  String get id;
  @override
  List<PokemonForm> get pokemon;
  @override
  List<Team> get presets;

  /// Create a copy of Roster
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RosterImplCopyWith<_$RosterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
