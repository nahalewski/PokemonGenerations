// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analysis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MatchupAnalysis _$MatchupAnalysisFromJson(Map<String, dynamic> json) {
  return _MatchupAnalysis.fromJson(json);
}

/// @nodoc
mixin _$MatchupAnalysis {
  String get id => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  List<String> get recommendedPicks => throw _privateConstructorUsedError;
  List<String> get recommendedLeads => throw _privateConstructorUsedError;
  List<ThreatReport> get threats => throw _privateConstructorUsedError;
  List<MoveRecommendation> get moveRecommendations =>
      throw _privateConstructorUsedError;
  List<String> get simulationLog => throw _privateConstructorUsedError;
  double get matchupScore => throw _privateConstructorUsedError;
  String get reasoning => throw _privateConstructorUsedError;
  String get format => throw _privateConstructorUsedError;

  /// Serializes this MatchupAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchupAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchupAnalysisCopyWith<MatchupAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchupAnalysisCopyWith<$Res> {
  factory $MatchupAnalysisCopyWith(
    MatchupAnalysis value,
    $Res Function(MatchupAnalysis) then,
  ) = _$MatchupAnalysisCopyWithImpl<$Res, MatchupAnalysis>;
  @useResult
  $Res call({
    String id,
    DateTime timestamp,
    List<String> recommendedPicks,
    List<String> recommendedLeads,
    List<ThreatReport> threats,
    List<MoveRecommendation> moveRecommendations,
    List<String> simulationLog,
    double matchupScore,
    String reasoning,
    String format,
  });
}

/// @nodoc
class _$MatchupAnalysisCopyWithImpl<$Res, $Val extends MatchupAnalysis>
    implements $MatchupAnalysisCopyWith<$Res> {
  _$MatchupAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchupAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? recommendedPicks = null,
    Object? recommendedLeads = null,
    Object? threats = null,
    Object? moveRecommendations = null,
    Object? simulationLog = null,
    Object? matchupScore = null,
    Object? reasoning = null,
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
            recommendedPicks: null == recommendedPicks
                ? _value.recommendedPicks
                : recommendedPicks // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            recommendedLeads: null == recommendedLeads
                ? _value.recommendedLeads
                : recommendedLeads // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            threats: null == threats
                ? _value.threats
                : threats // ignore: cast_nullable_to_non_nullable
                      as List<ThreatReport>,
            moveRecommendations: null == moveRecommendations
                ? _value.moveRecommendations
                : moveRecommendations // ignore: cast_nullable_to_non_nullable
                      as List<MoveRecommendation>,
            simulationLog: null == simulationLog
                ? _value.simulationLog
                : simulationLog // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            matchupScore: null == matchupScore
                ? _value.matchupScore
                : matchupScore // ignore: cast_nullable_to_non_nullable
                      as double,
            reasoning: null == reasoning
                ? _value.reasoning
                : reasoning // ignore: cast_nullable_to_non_nullable
                      as String,
            format: null == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchupAnalysisImplCopyWith<$Res>
    implements $MatchupAnalysisCopyWith<$Res> {
  factory _$$MatchupAnalysisImplCopyWith(
    _$MatchupAnalysisImpl value,
    $Res Function(_$MatchupAnalysisImpl) then,
  ) = __$$MatchupAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime timestamp,
    List<String> recommendedPicks,
    List<String> recommendedLeads,
    List<ThreatReport> threats,
    List<MoveRecommendation> moveRecommendations,
    List<String> simulationLog,
    double matchupScore,
    String reasoning,
    String format,
  });
}

/// @nodoc
class __$$MatchupAnalysisImplCopyWithImpl<$Res>
    extends _$MatchupAnalysisCopyWithImpl<$Res, _$MatchupAnalysisImpl>
    implements _$$MatchupAnalysisImplCopyWith<$Res> {
  __$$MatchupAnalysisImplCopyWithImpl(
    _$MatchupAnalysisImpl _value,
    $Res Function(_$MatchupAnalysisImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchupAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? recommendedPicks = null,
    Object? recommendedLeads = null,
    Object? threats = null,
    Object? moveRecommendations = null,
    Object? simulationLog = null,
    Object? matchupScore = null,
    Object? reasoning = null,
    Object? format = null,
  }) {
    return _then(
      _$MatchupAnalysisImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        recommendedPicks: null == recommendedPicks
            ? _value._recommendedPicks
            : recommendedPicks // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        recommendedLeads: null == recommendedLeads
            ? _value._recommendedLeads
            : recommendedLeads // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        threats: null == threats
            ? _value._threats
            : threats // ignore: cast_nullable_to_non_nullable
                  as List<ThreatReport>,
        moveRecommendations: null == moveRecommendations
            ? _value._moveRecommendations
            : moveRecommendations // ignore: cast_nullable_to_non_nullable
                  as List<MoveRecommendation>,
        simulationLog: null == simulationLog
            ? _value._simulationLog
            : simulationLog // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        matchupScore: null == matchupScore
            ? _value.matchupScore
            : matchupScore // ignore: cast_nullable_to_non_nullable
                  as double,
        reasoning: null == reasoning
            ? _value.reasoning
            : reasoning // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$MatchupAnalysisImpl implements _MatchupAnalysis {
  const _$MatchupAnalysisImpl({
    required this.id,
    required this.timestamp,
    required final List<String> recommendedPicks,
    required final List<String> recommendedLeads,
    required final List<ThreatReport> threats,
    required final List<MoveRecommendation> moveRecommendations,
    final List<String> simulationLog = const [],
    required this.matchupScore,
    required this.reasoning,
    required this.format,
  }) : _recommendedPicks = recommendedPicks,
       _recommendedLeads = recommendedLeads,
       _threats = threats,
       _moveRecommendations = moveRecommendations,
       _simulationLog = simulationLog;

  factory _$MatchupAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchupAnalysisImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime timestamp;
  final List<String> _recommendedPicks;
  @override
  List<String> get recommendedPicks {
    if (_recommendedPicks is EqualUnmodifiableListView)
      return _recommendedPicks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendedPicks);
  }

  final List<String> _recommendedLeads;
  @override
  List<String> get recommendedLeads {
    if (_recommendedLeads is EqualUnmodifiableListView)
      return _recommendedLeads;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendedLeads);
  }

  final List<ThreatReport> _threats;
  @override
  List<ThreatReport> get threats {
    if (_threats is EqualUnmodifiableListView) return _threats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_threats);
  }

  final List<MoveRecommendation> _moveRecommendations;
  @override
  List<MoveRecommendation> get moveRecommendations {
    if (_moveRecommendations is EqualUnmodifiableListView)
      return _moveRecommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moveRecommendations);
  }

  final List<String> _simulationLog;
  @override
  @JsonKey()
  List<String> get simulationLog {
    if (_simulationLog is EqualUnmodifiableListView) return _simulationLog;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_simulationLog);
  }

  @override
  final double matchupScore;
  @override
  final String reasoning;
  @override
  final String format;

  @override
  String toString() {
    return 'MatchupAnalysis(id: $id, timestamp: $timestamp, recommendedPicks: $recommendedPicks, recommendedLeads: $recommendedLeads, threats: $threats, moveRecommendations: $moveRecommendations, simulationLog: $simulationLog, matchupScore: $matchupScore, reasoning: $reasoning, format: $format)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchupAnalysisImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(
              other._recommendedPicks,
              _recommendedPicks,
            ) &&
            const DeepCollectionEquality().equals(
              other._recommendedLeads,
              _recommendedLeads,
            ) &&
            const DeepCollectionEquality().equals(other._threats, _threats) &&
            const DeepCollectionEquality().equals(
              other._moveRecommendations,
              _moveRecommendations,
            ) &&
            const DeepCollectionEquality().equals(
              other._simulationLog,
              _simulationLog,
            ) &&
            (identical(other.matchupScore, matchupScore) ||
                other.matchupScore == matchupScore) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning) &&
            (identical(other.format, format) || other.format == format));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    timestamp,
    const DeepCollectionEquality().hash(_recommendedPicks),
    const DeepCollectionEquality().hash(_recommendedLeads),
    const DeepCollectionEquality().hash(_threats),
    const DeepCollectionEquality().hash(_moveRecommendations),
    const DeepCollectionEquality().hash(_simulationLog),
    matchupScore,
    reasoning,
    format,
  );

  /// Create a copy of MatchupAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchupAnalysisImplCopyWith<_$MatchupAnalysisImpl> get copyWith =>
      __$$MatchupAnalysisImplCopyWithImpl<_$MatchupAnalysisImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchupAnalysisImplToJson(this);
  }
}

abstract class _MatchupAnalysis implements MatchupAnalysis {
  const factory _MatchupAnalysis({
    required final String id,
    required final DateTime timestamp,
    required final List<String> recommendedPicks,
    required final List<String> recommendedLeads,
    required final List<ThreatReport> threats,
    required final List<MoveRecommendation> moveRecommendations,
    final List<String> simulationLog,
    required final double matchupScore,
    required final String reasoning,
    required final String format,
  }) = _$MatchupAnalysisImpl;

  factory _MatchupAnalysis.fromJson(Map<String, dynamic> json) =
      _$MatchupAnalysisImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get timestamp;
  @override
  List<String> get recommendedPicks;
  @override
  List<String> get recommendedLeads;
  @override
  List<ThreatReport> get threats;
  @override
  List<MoveRecommendation> get moveRecommendations;
  @override
  List<String> get simulationLog;
  @override
  double get matchupScore;
  @override
  String get reasoning;
  @override
  String get format;

  /// Create a copy of MatchupAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchupAnalysisImplCopyWith<_$MatchupAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ThreatReport _$ThreatReportFromJson(Map<String, dynamic> json) {
  return _ThreatReport.fromJson(json);
}

/// @nodoc
mixin _$ThreatReport {
  String get pokemonName => throw _privateConstructorUsedError;
  double get threatLevel => throw _privateConstructorUsedError; // 0.0 to 1.0
  String get description => throw _privateConstructorUsedError;
  List<String> get countersFromRoster => throw _privateConstructorUsedError;

  /// Serializes this ThreatReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ThreatReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ThreatReportCopyWith<ThreatReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThreatReportCopyWith<$Res> {
  factory $ThreatReportCopyWith(
    ThreatReport value,
    $Res Function(ThreatReport) then,
  ) = _$ThreatReportCopyWithImpl<$Res, ThreatReport>;
  @useResult
  $Res call({
    String pokemonName,
    double threatLevel,
    String description,
    List<String> countersFromRoster,
  });
}

/// @nodoc
class _$ThreatReportCopyWithImpl<$Res, $Val extends ThreatReport>
    implements $ThreatReportCopyWith<$Res> {
  _$ThreatReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ThreatReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pokemonName = null,
    Object? threatLevel = null,
    Object? description = null,
    Object? countersFromRoster = null,
  }) {
    return _then(
      _value.copyWith(
            pokemonName: null == pokemonName
                ? _value.pokemonName
                : pokemonName // ignore: cast_nullable_to_non_nullable
                      as String,
            threatLevel: null == threatLevel
                ? _value.threatLevel
                : threatLevel // ignore: cast_nullable_to_non_nullable
                      as double,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            countersFromRoster: null == countersFromRoster
                ? _value.countersFromRoster
                : countersFromRoster // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ThreatReportImplCopyWith<$Res>
    implements $ThreatReportCopyWith<$Res> {
  factory _$$ThreatReportImplCopyWith(
    _$ThreatReportImpl value,
    $Res Function(_$ThreatReportImpl) then,
  ) = __$$ThreatReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String pokemonName,
    double threatLevel,
    String description,
    List<String> countersFromRoster,
  });
}

/// @nodoc
class __$$ThreatReportImplCopyWithImpl<$Res>
    extends _$ThreatReportCopyWithImpl<$Res, _$ThreatReportImpl>
    implements _$$ThreatReportImplCopyWith<$Res> {
  __$$ThreatReportImplCopyWithImpl(
    _$ThreatReportImpl _value,
    $Res Function(_$ThreatReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ThreatReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pokemonName = null,
    Object? threatLevel = null,
    Object? description = null,
    Object? countersFromRoster = null,
  }) {
    return _then(
      _$ThreatReportImpl(
        pokemonName: null == pokemonName
            ? _value.pokemonName
            : pokemonName // ignore: cast_nullable_to_non_nullable
                  as String,
        threatLevel: null == threatLevel
            ? _value.threatLevel
            : threatLevel // ignore: cast_nullable_to_non_nullable
                  as double,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        countersFromRoster: null == countersFromRoster
            ? _value._countersFromRoster
            : countersFromRoster // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ThreatReportImpl implements _ThreatReport {
  const _$ThreatReportImpl({
    required this.pokemonName,
    required this.threatLevel,
    required this.description,
    required final List<String> countersFromRoster,
  }) : _countersFromRoster = countersFromRoster;

  factory _$ThreatReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThreatReportImplFromJson(json);

  @override
  final String pokemonName;
  @override
  final double threatLevel;
  // 0.0 to 1.0
  @override
  final String description;
  final List<String> _countersFromRoster;
  @override
  List<String> get countersFromRoster {
    if (_countersFromRoster is EqualUnmodifiableListView)
      return _countersFromRoster;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_countersFromRoster);
  }

  @override
  String toString() {
    return 'ThreatReport(pokemonName: $pokemonName, threatLevel: $threatLevel, description: $description, countersFromRoster: $countersFromRoster)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThreatReportImpl &&
            (identical(other.pokemonName, pokemonName) ||
                other.pokemonName == pokemonName) &&
            (identical(other.threatLevel, threatLevel) ||
                other.threatLevel == threatLevel) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._countersFromRoster,
              _countersFromRoster,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    pokemonName,
    threatLevel,
    description,
    const DeepCollectionEquality().hash(_countersFromRoster),
  );

  /// Create a copy of ThreatReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThreatReportImplCopyWith<_$ThreatReportImpl> get copyWith =>
      __$$ThreatReportImplCopyWithImpl<_$ThreatReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ThreatReportImplToJson(this);
  }
}

abstract class _ThreatReport implements ThreatReport {
  const factory _ThreatReport({
    required final String pokemonName,
    required final double threatLevel,
    required final String description,
    required final List<String> countersFromRoster,
  }) = _$ThreatReportImpl;

  factory _ThreatReport.fromJson(Map<String, dynamic> json) =
      _$ThreatReportImpl.fromJson;

  @override
  String get pokemonName;
  @override
  double get threatLevel; // 0.0 to 1.0
  @override
  String get description;
  @override
  List<String> get countersFromRoster;

  /// Create a copy of ThreatReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThreatReportImplCopyWith<_$ThreatReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MoveRecommendation _$MoveRecommendationFromJson(Map<String, dynamic> json) {
  return _MoveRecommendation.fromJson(json);
}

/// @nodoc
mixin _$MoveRecommendation {
  String get sourcePokemonName => throw _privateConstructorUsedError;
  String get targetPokemonName => throw _privateConstructorUsedError;
  String get moveName => throw _privateConstructorUsedError;
  String get damageRange => throw _privateConstructorUsedError;
  String get reasoning => throw _privateConstructorUsedError;
  bool get isKoChance => throw _privateConstructorUsedError;

  /// Serializes this MoveRecommendation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MoveRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MoveRecommendationCopyWith<MoveRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MoveRecommendationCopyWith<$Res> {
  factory $MoveRecommendationCopyWith(
    MoveRecommendation value,
    $Res Function(MoveRecommendation) then,
  ) = _$MoveRecommendationCopyWithImpl<$Res, MoveRecommendation>;
  @useResult
  $Res call({
    String sourcePokemonName,
    String targetPokemonName,
    String moveName,
    String damageRange,
    String reasoning,
    bool isKoChance,
  });
}

/// @nodoc
class _$MoveRecommendationCopyWithImpl<$Res, $Val extends MoveRecommendation>
    implements $MoveRecommendationCopyWith<$Res> {
  _$MoveRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MoveRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourcePokemonName = null,
    Object? targetPokemonName = null,
    Object? moveName = null,
    Object? damageRange = null,
    Object? reasoning = null,
    Object? isKoChance = null,
  }) {
    return _then(
      _value.copyWith(
            sourcePokemonName: null == sourcePokemonName
                ? _value.sourcePokemonName
                : sourcePokemonName // ignore: cast_nullable_to_non_nullable
                      as String,
            targetPokemonName: null == targetPokemonName
                ? _value.targetPokemonName
                : targetPokemonName // ignore: cast_nullable_to_non_nullable
                      as String,
            moveName: null == moveName
                ? _value.moveName
                : moveName // ignore: cast_nullable_to_non_nullable
                      as String,
            damageRange: null == damageRange
                ? _value.damageRange
                : damageRange // ignore: cast_nullable_to_non_nullable
                      as String,
            reasoning: null == reasoning
                ? _value.reasoning
                : reasoning // ignore: cast_nullable_to_non_nullable
                      as String,
            isKoChance: null == isKoChance
                ? _value.isKoChance
                : isKoChance // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MoveRecommendationImplCopyWith<$Res>
    implements $MoveRecommendationCopyWith<$Res> {
  factory _$$MoveRecommendationImplCopyWith(
    _$MoveRecommendationImpl value,
    $Res Function(_$MoveRecommendationImpl) then,
  ) = __$$MoveRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sourcePokemonName,
    String targetPokemonName,
    String moveName,
    String damageRange,
    String reasoning,
    bool isKoChance,
  });
}

/// @nodoc
class __$$MoveRecommendationImplCopyWithImpl<$Res>
    extends _$MoveRecommendationCopyWithImpl<$Res, _$MoveRecommendationImpl>
    implements _$$MoveRecommendationImplCopyWith<$Res> {
  __$$MoveRecommendationImplCopyWithImpl(
    _$MoveRecommendationImpl _value,
    $Res Function(_$MoveRecommendationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MoveRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourcePokemonName = null,
    Object? targetPokemonName = null,
    Object? moveName = null,
    Object? damageRange = null,
    Object? reasoning = null,
    Object? isKoChance = null,
  }) {
    return _then(
      _$MoveRecommendationImpl(
        sourcePokemonName: null == sourcePokemonName
            ? _value.sourcePokemonName
            : sourcePokemonName // ignore: cast_nullable_to_non_nullable
                  as String,
        targetPokemonName: null == targetPokemonName
            ? _value.targetPokemonName
            : targetPokemonName // ignore: cast_nullable_to_non_nullable
                  as String,
        moveName: null == moveName
            ? _value.moveName
            : moveName // ignore: cast_nullable_to_non_nullable
                  as String,
        damageRange: null == damageRange
            ? _value.damageRange
            : damageRange // ignore: cast_nullable_to_non_nullable
                  as String,
        reasoning: null == reasoning
            ? _value.reasoning
            : reasoning // ignore: cast_nullable_to_non_nullable
                  as String,
        isKoChance: null == isKoChance
            ? _value.isKoChance
            : isKoChance // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MoveRecommendationImpl implements _MoveRecommendation {
  const _$MoveRecommendationImpl({
    required this.sourcePokemonName,
    required this.targetPokemonName,
    required this.moveName,
    required this.damageRange,
    required this.reasoning,
    this.isKoChance = false,
  });

  factory _$MoveRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MoveRecommendationImplFromJson(json);

  @override
  final String sourcePokemonName;
  @override
  final String targetPokemonName;
  @override
  final String moveName;
  @override
  final String damageRange;
  @override
  final String reasoning;
  @override
  @JsonKey()
  final bool isKoChance;

  @override
  String toString() {
    return 'MoveRecommendation(sourcePokemonName: $sourcePokemonName, targetPokemonName: $targetPokemonName, moveName: $moveName, damageRange: $damageRange, reasoning: $reasoning, isKoChance: $isKoChance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MoveRecommendationImpl &&
            (identical(other.sourcePokemonName, sourcePokemonName) ||
                other.sourcePokemonName == sourcePokemonName) &&
            (identical(other.targetPokemonName, targetPokemonName) ||
                other.targetPokemonName == targetPokemonName) &&
            (identical(other.moveName, moveName) ||
                other.moveName == moveName) &&
            (identical(other.damageRange, damageRange) ||
                other.damageRange == damageRange) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning) &&
            (identical(other.isKoChance, isKoChance) ||
                other.isKoChance == isKoChance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sourcePokemonName,
    targetPokemonName,
    moveName,
    damageRange,
    reasoning,
    isKoChance,
  );

  /// Create a copy of MoveRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MoveRecommendationImplCopyWith<_$MoveRecommendationImpl> get copyWith =>
      __$$MoveRecommendationImplCopyWithImpl<_$MoveRecommendationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MoveRecommendationImplToJson(this);
  }
}

abstract class _MoveRecommendation implements MoveRecommendation {
  const factory _MoveRecommendation({
    required final String sourcePokemonName,
    required final String targetPokemonName,
    required final String moveName,
    required final String damageRange,
    required final String reasoning,
    final bool isKoChance,
  }) = _$MoveRecommendationImpl;

  factory _MoveRecommendation.fromJson(Map<String, dynamic> json) =
      _$MoveRecommendationImpl.fromJson;

  @override
  String get sourcePokemonName;
  @override
  String get targetPokemonName;
  @override
  String get moveName;
  @override
  String get damageRange;
  @override
  String get reasoning;
  @override
  bool get isKoChance;

  /// Create a copy of MoveRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MoveRecommendationImplCopyWith<_$MoveRecommendationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DamageResult _$DamageResultFromJson(Map<String, dynamic> json) {
  return _DamageResult.fromJson(json);
}

/// @nodoc
mixin _$DamageResult {
  String get attackerName => throw _privateConstructorUsedError;
  String get defenderName => throw _privateConstructorUsedError;
  String get moveName => throw _privateConstructorUsedError;
  List<int> get damageRolls => throw _privateConstructorUsedError;
  String get percentageRange => throw _privateConstructorUsedError;
  int get minDamage => throw _privateConstructorUsedError;
  int get maxDamage => throw _privateConstructorUsedError;

  /// Serializes this DamageResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DamageResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DamageResultCopyWith<DamageResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DamageResultCopyWith<$Res> {
  factory $DamageResultCopyWith(
    DamageResult value,
    $Res Function(DamageResult) then,
  ) = _$DamageResultCopyWithImpl<$Res, DamageResult>;
  @useResult
  $Res call({
    String attackerName,
    String defenderName,
    String moveName,
    List<int> damageRolls,
    String percentageRange,
    int minDamage,
    int maxDamage,
  });
}

/// @nodoc
class _$DamageResultCopyWithImpl<$Res, $Val extends DamageResult>
    implements $DamageResultCopyWith<$Res> {
  _$DamageResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DamageResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attackerName = null,
    Object? defenderName = null,
    Object? moveName = null,
    Object? damageRolls = null,
    Object? percentageRange = null,
    Object? minDamage = null,
    Object? maxDamage = null,
  }) {
    return _then(
      _value.copyWith(
            attackerName: null == attackerName
                ? _value.attackerName
                : attackerName // ignore: cast_nullable_to_non_nullable
                      as String,
            defenderName: null == defenderName
                ? _value.defenderName
                : defenderName // ignore: cast_nullable_to_non_nullable
                      as String,
            moveName: null == moveName
                ? _value.moveName
                : moveName // ignore: cast_nullable_to_non_nullable
                      as String,
            damageRolls: null == damageRolls
                ? _value.damageRolls
                : damageRolls // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            percentageRange: null == percentageRange
                ? _value.percentageRange
                : percentageRange // ignore: cast_nullable_to_non_nullable
                      as String,
            minDamage: null == minDamage
                ? _value.minDamage
                : minDamage // ignore: cast_nullable_to_non_nullable
                      as int,
            maxDamage: null == maxDamage
                ? _value.maxDamage
                : maxDamage // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DamageResultImplCopyWith<$Res>
    implements $DamageResultCopyWith<$Res> {
  factory _$$DamageResultImplCopyWith(
    _$DamageResultImpl value,
    $Res Function(_$DamageResultImpl) then,
  ) = __$$DamageResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String attackerName,
    String defenderName,
    String moveName,
    List<int> damageRolls,
    String percentageRange,
    int minDamage,
    int maxDamage,
  });
}

/// @nodoc
class __$$DamageResultImplCopyWithImpl<$Res>
    extends _$DamageResultCopyWithImpl<$Res, _$DamageResultImpl>
    implements _$$DamageResultImplCopyWith<$Res> {
  __$$DamageResultImplCopyWithImpl(
    _$DamageResultImpl _value,
    $Res Function(_$DamageResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DamageResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attackerName = null,
    Object? defenderName = null,
    Object? moveName = null,
    Object? damageRolls = null,
    Object? percentageRange = null,
    Object? minDamage = null,
    Object? maxDamage = null,
  }) {
    return _then(
      _$DamageResultImpl(
        attackerName: null == attackerName
            ? _value.attackerName
            : attackerName // ignore: cast_nullable_to_non_nullable
                  as String,
        defenderName: null == defenderName
            ? _value.defenderName
            : defenderName // ignore: cast_nullable_to_non_nullable
                  as String,
        moveName: null == moveName
            ? _value.moveName
            : moveName // ignore: cast_nullable_to_non_nullable
                  as String,
        damageRolls: null == damageRolls
            ? _value._damageRolls
            : damageRolls // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        percentageRange: null == percentageRange
            ? _value.percentageRange
            : percentageRange // ignore: cast_nullable_to_non_nullable
                  as String,
        minDamage: null == minDamage
            ? _value.minDamage
            : minDamage // ignore: cast_nullable_to_non_nullable
                  as int,
        maxDamage: null == maxDamage
            ? _value.maxDamage
            : maxDamage // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DamageResultImpl implements _DamageResult {
  const _$DamageResultImpl({
    required this.attackerName,
    required this.defenderName,
    required this.moveName,
    required final List<int> damageRolls,
    required this.percentageRange,
    required this.minDamage,
    required this.maxDamage,
  }) : _damageRolls = damageRolls;

  factory _$DamageResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$DamageResultImplFromJson(json);

  @override
  final String attackerName;
  @override
  final String defenderName;
  @override
  final String moveName;
  final List<int> _damageRolls;
  @override
  List<int> get damageRolls {
    if (_damageRolls is EqualUnmodifiableListView) return _damageRolls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_damageRolls);
  }

  @override
  final String percentageRange;
  @override
  final int minDamage;
  @override
  final int maxDamage;

  @override
  String toString() {
    return 'DamageResult(attackerName: $attackerName, defenderName: $defenderName, moveName: $moveName, damageRolls: $damageRolls, percentageRange: $percentageRange, minDamage: $minDamage, maxDamage: $maxDamage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DamageResultImpl &&
            (identical(other.attackerName, attackerName) ||
                other.attackerName == attackerName) &&
            (identical(other.defenderName, defenderName) ||
                other.defenderName == defenderName) &&
            (identical(other.moveName, moveName) ||
                other.moveName == moveName) &&
            const DeepCollectionEquality().equals(
              other._damageRolls,
              _damageRolls,
            ) &&
            (identical(other.percentageRange, percentageRange) ||
                other.percentageRange == percentageRange) &&
            (identical(other.minDamage, minDamage) ||
                other.minDamage == minDamage) &&
            (identical(other.maxDamage, maxDamage) ||
                other.maxDamage == maxDamage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    attackerName,
    defenderName,
    moveName,
    const DeepCollectionEquality().hash(_damageRolls),
    percentageRange,
    minDamage,
    maxDamage,
  );

  /// Create a copy of DamageResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DamageResultImplCopyWith<_$DamageResultImpl> get copyWith =>
      __$$DamageResultImplCopyWithImpl<_$DamageResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DamageResultImplToJson(this);
  }
}

abstract class _DamageResult implements DamageResult {
  const factory _DamageResult({
    required final String attackerName,
    required final String defenderName,
    required final String moveName,
    required final List<int> damageRolls,
    required final String percentageRange,
    required final int minDamage,
    required final int maxDamage,
  }) = _$DamageResultImpl;

  factory _DamageResult.fromJson(Map<String, dynamic> json) =
      _$DamageResultImpl.fromJson;

  @override
  String get attackerName;
  @override
  String get defenderName;
  @override
  String get moveName;
  @override
  List<int> get damageRolls;
  @override
  String get percentageRange;
  @override
  int get minDamage;
  @override
  int get maxDamage;

  /// Create a copy of DamageResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DamageResultImplCopyWith<_$DamageResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
