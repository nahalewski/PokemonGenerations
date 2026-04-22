// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnalysisHistory _$AnalysisHistoryFromJson(Map<String, dynamic> json) {
  return _AnalysisHistory.fromJson(json);
}

/// @nodoc
mixin _$AnalysisHistory {
  String get id => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  List<PokemonForm> get opponentTeam => throw _privateConstructorUsedError;
  MatchupAnalysis get result => throw _privateConstructorUsedError;
  String get format => throw _privateConstructorUsedError;

  /// Serializes this AnalysisHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnalysisHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnalysisHistoryCopyWith<AnalysisHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalysisHistoryCopyWith<$Res> {
  factory $AnalysisHistoryCopyWith(
    AnalysisHistory value,
    $Res Function(AnalysisHistory) then,
  ) = _$AnalysisHistoryCopyWithImpl<$Res, AnalysisHistory>;
  @useResult
  $Res call({
    String id,
    DateTime timestamp,
    List<PokemonForm> opponentTeam,
    MatchupAnalysis result,
    String format,
  });

  $MatchupAnalysisCopyWith<$Res> get result;
}

/// @nodoc
class _$AnalysisHistoryCopyWithImpl<$Res, $Val extends AnalysisHistory>
    implements $AnalysisHistoryCopyWith<$Res> {
  _$AnalysisHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnalysisHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? opponentTeam = null,
    Object? result = null,
    Object? format = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            opponentTeam: null == opponentTeam
                ? _value.opponentTeam
                : opponentTeam // ignore: cast_nullable_to_non_nullable
                      as List<PokemonForm>,
            result: null == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as MatchupAnalysis,
            format: null == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of AnalysisHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchupAnalysisCopyWith<$Res> get result {
    return $MatchupAnalysisCopyWith<$Res>(_value.result, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AnalysisHistoryImplCopyWith<$Res>
    implements $AnalysisHistoryCopyWith<$Res> {
  factory _$$AnalysisHistoryImplCopyWith(
    _$AnalysisHistoryImpl value,
    $Res Function(_$AnalysisHistoryImpl) then,
  ) = __$$AnalysisHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime timestamp,
    List<PokemonForm> opponentTeam,
    MatchupAnalysis result,
    String format,
  });

  @override
  $MatchupAnalysisCopyWith<$Res> get result;
}

/// @nodoc
class __$$AnalysisHistoryImplCopyWithImpl<$Res>
    extends _$AnalysisHistoryCopyWithImpl<$Res, _$AnalysisHistoryImpl>
    implements _$$AnalysisHistoryImplCopyWith<$Res> {
  __$$AnalysisHistoryImplCopyWithImpl(
    _$AnalysisHistoryImpl _value,
    $Res Function(_$AnalysisHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnalysisHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? opponentTeam = null,
    Object? result = null,
    Object? format = null,
  }) {
    return _then(
      _$AnalysisHistoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        opponentTeam: null == opponentTeam
            ? _value._opponentTeam
            : opponentTeam // ignore: cast_nullable_to_non_nullable
                  as List<PokemonForm>,
        result: null == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as MatchupAnalysis,
        format: null == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalysisHistoryImpl implements _AnalysisHistory {
  const _$AnalysisHistoryImpl({
    required this.id,
    required this.timestamp,
    required final List<PokemonForm> opponentTeam,
    required this.result,
    required this.format,
  }) : _opponentTeam = opponentTeam;

  factory _$AnalysisHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalysisHistoryImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime timestamp;
  final List<PokemonForm> _opponentTeam;
  @override
  List<PokemonForm> get opponentTeam {
    if (_opponentTeam is EqualUnmodifiableListView) return _opponentTeam;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_opponentTeam);
  }

  @override
  final MatchupAnalysis result;
  @override
  final String format;

  @override
  String toString() {
    return 'AnalysisHistory(id: $id, timestamp: $timestamp, opponentTeam: $opponentTeam, result: $result, format: $format)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalysisHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(
              other._opponentTeam,
              _opponentTeam,
            ) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.format, format) || other.format == format));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    timestamp,
    const DeepCollectionEquality().hash(_opponentTeam),
    result,
    format,
  );

  /// Create a copy of AnalysisHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalysisHistoryImplCopyWith<_$AnalysisHistoryImpl> get copyWith =>
      __$$AnalysisHistoryImplCopyWithImpl<_$AnalysisHistoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalysisHistoryImplToJson(this);
  }
}

abstract class _AnalysisHistory implements AnalysisHistory {
  const factory _AnalysisHistory({
    required final String id,
    required final DateTime timestamp,
    required final List<PokemonForm> opponentTeam,
    required final MatchupAnalysis result,
    required final String format,
  }) = _$AnalysisHistoryImpl;

  factory _AnalysisHistory.fromJson(Map<String, dynamic> json) =
      _$AnalysisHistoryImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get timestamp;
  @override
  List<PokemonForm> get opponentTeam;
  @override
  MatchupAnalysis get result;
  @override
  String get format;

  /// Create a copy of AnalysisHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalysisHistoryImplCopyWith<_$AnalysisHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
