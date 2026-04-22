// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'move_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MoveDetail _$MoveDetailFromJson(Map<String, dynamic> json) {
  return _MoveDetail.fromJson(json);
}

/// @nodoc
mixin _$MoveDetail {
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get damageClass => throw _privateConstructorUsedError;
  int? get power => throw _privateConstructorUsedError;
  int? get accuracy => throw _privateConstructorUsedError;
  int get pp => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this MoveDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MoveDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MoveDetailCopyWith<MoveDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MoveDetailCopyWith<$Res> {
  factory $MoveDetailCopyWith(
    MoveDetail value,
    $Res Function(MoveDetail) then,
  ) = _$MoveDetailCopyWithImpl<$Res, MoveDetail>;
  @useResult
  $Res call({
    String name,
    String type,
    String damageClass,
    int? power,
    int? accuracy,
    int pp,
    String description,
  });
}

/// @nodoc
class _$MoveDetailCopyWithImpl<$Res, $Val extends MoveDetail>
    implements $MoveDetailCopyWith<$Res> {
  _$MoveDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MoveDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? damageClass = null,
    Object? power = freezed,
    Object? accuracy = freezed,
    Object? pp = null,
    Object? description = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            damageClass: null == damageClass
                ? _value.damageClass
                : damageClass // ignore: cast_nullable_to_non_nullable
                      as String,
            power: freezed == power
                ? _value.power
                : power // ignore: cast_nullable_to_non_nullable
                      as int?,
            accuracy: freezed == accuracy
                ? _value.accuracy
                : accuracy // ignore: cast_nullable_to_non_nullable
                      as int?,
            pp: null == pp
                ? _value.pp
                : pp // ignore: cast_nullable_to_non_nullable
                      as int,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MoveDetailImplCopyWith<$Res>
    implements $MoveDetailCopyWith<$Res> {
  factory _$$MoveDetailImplCopyWith(
    _$MoveDetailImpl value,
    $Res Function(_$MoveDetailImpl) then,
  ) = __$$MoveDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String type,
    String damageClass,
    int? power,
    int? accuracy,
    int pp,
    String description,
  });
}

/// @nodoc
class __$$MoveDetailImplCopyWithImpl<$Res>
    extends _$MoveDetailCopyWithImpl<$Res, _$MoveDetailImpl>
    implements _$$MoveDetailImplCopyWith<$Res> {
  __$$MoveDetailImplCopyWithImpl(
    _$MoveDetailImpl _value,
    $Res Function(_$MoveDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MoveDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? damageClass = null,
    Object? power = freezed,
    Object? accuracy = freezed,
    Object? pp = null,
    Object? description = null,
  }) {
    return _then(
      _$MoveDetailImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        damageClass: null == damageClass
            ? _value.damageClass
            : damageClass // ignore: cast_nullable_to_non_nullable
                  as String,
        power: freezed == power
            ? _value.power
            : power // ignore: cast_nullable_to_non_nullable
                  as int?,
        accuracy: freezed == accuracy
            ? _value.accuracy
            : accuracy // ignore: cast_nullable_to_non_nullable
                  as int?,
        pp: null == pp
            ? _value.pp
            : pp // ignore: cast_nullable_to_non_nullable
                  as int,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MoveDetailImpl implements _MoveDetail {
  const _$MoveDetailImpl({
    required this.name,
    required this.type,
    required this.damageClass,
    required this.power,
    required this.accuracy,
    required this.pp,
    required this.description,
  });

  factory _$MoveDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$MoveDetailImplFromJson(json);

  @override
  final String name;
  @override
  final String type;
  @override
  final String damageClass;
  @override
  final int? power;
  @override
  final int? accuracy;
  @override
  final int pp;
  @override
  final String description;

  @override
  String toString() {
    return 'MoveDetail(name: $name, type: $type, damageClass: $damageClass, power: $power, accuracy: $accuracy, pp: $pp, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MoveDetailImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.damageClass, damageClass) ||
                other.damageClass == damageClass) &&
            (identical(other.power, power) || other.power == power) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.pp, pp) || other.pp == pp) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    type,
    damageClass,
    power,
    accuracy,
    pp,
    description,
  );

  /// Create a copy of MoveDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MoveDetailImplCopyWith<_$MoveDetailImpl> get copyWith =>
      __$$MoveDetailImplCopyWithImpl<_$MoveDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MoveDetailImplToJson(this);
  }
}

abstract class _MoveDetail implements MoveDetail {
  const factory _MoveDetail({
    required final String name,
    required final String type,
    required final String damageClass,
    required final int? power,
    required final int? accuracy,
    required final int pp,
    required final String description,
  }) = _$MoveDetailImpl;

  factory _MoveDetail.fromJson(Map<String, dynamic> json) =
      _$MoveDetailImpl.fromJson;

  @override
  String get name;
  @override
  String get type;
  @override
  String get damageClass;
  @override
  int? get power;
  @override
  int? get accuracy;
  @override
  int get pp;
  @override
  String get description;

  /// Create a copy of MoveDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MoveDetailImplCopyWith<_$MoveDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
