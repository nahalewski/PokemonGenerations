// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SocialUser _$SocialUserFromJson(Map<String, dynamic> json) {
  return _SocialUser.fromJson(json);
}

/// @nodoc
mixin _$SocialUser {
  String get username => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get roster => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'online', 'battling', 'offline'
  String? get currentBattleId => throw _privateConstructorUsedError;
  int get wins => throw _privateConstructorUsedError;
  int get losses => throw _privateConstructorUsedError;
  bool get forcePasscodeChange => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  Map<String, dynamic> get cardCustomization =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get recentReplays =>
      throw _privateConstructorUsedError;

  /// Serializes this SocialUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SocialUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SocialUserCopyWith<SocialUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocialUserCopyWith<$Res> {
  factory $SocialUserCopyWith(
    SocialUser value,
    $Res Function(SocialUser) then,
  ) = _$SocialUserCopyWithImpl<$Res, SocialUser>;
  @useResult
  $Res call({
    String username,
    String displayName,
    List<Map<String, dynamic>> roster,
    String status,
    String? currentBattleId,
    int wins,
    int losses,
    bool forcePasscodeChange,
    String? profileImageUrl,
    Map<String, dynamic> cardCustomization,
    List<Map<String, dynamic>> recentReplays,
  });
}

/// @nodoc
class _$SocialUserCopyWithImpl<$Res, $Val extends SocialUser>
    implements $SocialUserCopyWith<$Res> {
  _$SocialUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocialUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? displayName = null,
    Object? roster = null,
    Object? status = null,
    Object? currentBattleId = freezed,
    Object? wins = null,
    Object? losses = null,
    Object? forcePasscodeChange = null,
    Object? profileImageUrl = freezed,
    Object? cardCustomization = null,
    Object? recentReplays = null,
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
            roster: null == roster
                ? _value.roster
                : roster // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            currentBattleId: freezed == currentBattleId
                ? _value.currentBattleId
                : currentBattleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            wins: null == wins
                ? _value.wins
                : wins // ignore: cast_nullable_to_non_nullable
                      as int,
            losses: null == losses
                ? _value.losses
                : losses // ignore: cast_nullable_to_non_nullable
                      as int,
            forcePasscodeChange: null == forcePasscodeChange
                ? _value.forcePasscodeChange
                : forcePasscodeChange // ignore: cast_nullable_to_non_nullable
                      as bool,
            profileImageUrl: freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            cardCustomization: null == cardCustomization
                ? _value.cardCustomization
                : cardCustomization // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            recentReplays: null == recentReplays
                ? _value.recentReplays
                : recentReplays // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SocialUserImplCopyWith<$Res>
    implements $SocialUserCopyWith<$Res> {
  factory _$$SocialUserImplCopyWith(
    _$SocialUserImpl value,
    $Res Function(_$SocialUserImpl) then,
  ) = __$$SocialUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String username,
    String displayName,
    List<Map<String, dynamic>> roster,
    String status,
    String? currentBattleId,
    int wins,
    int losses,
    bool forcePasscodeChange,
    String? profileImageUrl,
    Map<String, dynamic> cardCustomization,
    List<Map<String, dynamic>> recentReplays,
  });
}

/// @nodoc
class __$$SocialUserImplCopyWithImpl<$Res>
    extends _$SocialUserCopyWithImpl<$Res, _$SocialUserImpl>
    implements _$$SocialUserImplCopyWith<$Res> {
  __$$SocialUserImplCopyWithImpl(
    _$SocialUserImpl _value,
    $Res Function(_$SocialUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SocialUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? displayName = null,
    Object? roster = null,
    Object? status = null,
    Object? currentBattleId = freezed,
    Object? wins = null,
    Object? losses = null,
    Object? forcePasscodeChange = null,
    Object? profileImageUrl = freezed,
    Object? cardCustomization = null,
    Object? recentReplays = null,
  }) {
    return _then(
      _$SocialUserImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        roster: null == roster
            ? _value._roster
            : roster // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        currentBattleId: freezed == currentBattleId
            ? _value.currentBattleId
            : currentBattleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        wins: null == wins
            ? _value.wins
            : wins // ignore: cast_nullable_to_non_nullable
                  as int,
        losses: null == losses
            ? _value.losses
            : losses // ignore: cast_nullable_to_non_nullable
                  as int,
        forcePasscodeChange: null == forcePasscodeChange
            ? _value.forcePasscodeChange
            : forcePasscodeChange // ignore: cast_nullable_to_non_nullable
                  as bool,
        profileImageUrl: freezed == profileImageUrl
            ? _value.profileImageUrl
            : profileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        cardCustomization: null == cardCustomization
            ? _value._cardCustomization
            : cardCustomization // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        recentReplays: null == recentReplays
            ? _value._recentReplays
            : recentReplays // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SocialUserImpl implements _SocialUser {
  const _$SocialUserImpl({
    required this.username,
    required this.displayName,
    final List<Map<String, dynamic>> roster = const [],
    this.status = 'offline',
    this.currentBattleId,
    this.wins = 0,
    this.losses = 0,
    this.forcePasscodeChange = false,
    this.profileImageUrl,
    final Map<String, dynamic> cardCustomization = const {},
    final List<Map<String, dynamic>> recentReplays = const [],
  }) : _roster = roster,
       _cardCustomization = cardCustomization,
       _recentReplays = recentReplays;

  factory _$SocialUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$SocialUserImplFromJson(json);

  @override
  final String username;
  @override
  final String displayName;
  final List<Map<String, dynamic>> _roster;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get roster {
    if (_roster is EqualUnmodifiableListView) return _roster;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roster);
  }

  @override
  @JsonKey()
  final String status;
  // 'online', 'battling', 'offline'
  @override
  final String? currentBattleId;
  @override
  @JsonKey()
  final int wins;
  @override
  @JsonKey()
  final int losses;
  @override
  @JsonKey()
  final bool forcePasscodeChange;
  @override
  final String? profileImageUrl;
  final Map<String, dynamic> _cardCustomization;
  @override
  @JsonKey()
  Map<String, dynamic> get cardCustomization {
    if (_cardCustomization is EqualUnmodifiableMapView)
      return _cardCustomization;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cardCustomization);
  }

  final List<Map<String, dynamic>> _recentReplays;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get recentReplays {
    if (_recentReplays is EqualUnmodifiableListView) return _recentReplays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentReplays);
  }

  @override
  String toString() {
    return 'SocialUser(username: $username, displayName: $displayName, roster: $roster, status: $status, currentBattleId: $currentBattleId, wins: $wins, losses: $losses, forcePasscodeChange: $forcePasscodeChange, profileImageUrl: $profileImageUrl, cardCustomization: $cardCustomization, recentReplays: $recentReplays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialUserImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            const DeepCollectionEquality().equals(other._roster, _roster) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentBattleId, currentBattleId) ||
                other.currentBattleId == currentBattleId) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.losses, losses) || other.losses == losses) &&
            (identical(other.forcePasscodeChange, forcePasscodeChange) ||
                other.forcePasscodeChange == forcePasscodeChange) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            const DeepCollectionEquality().equals(
              other._cardCustomization,
              _cardCustomization,
            ) &&
            const DeepCollectionEquality().equals(
              other._recentReplays,
              _recentReplays,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    username,
    displayName,
    const DeepCollectionEquality().hash(_roster),
    status,
    currentBattleId,
    wins,
    losses,
    forcePasscodeChange,
    profileImageUrl,
    const DeepCollectionEquality().hash(_cardCustomization),
    const DeepCollectionEquality().hash(_recentReplays),
  );

  /// Create a copy of SocialUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialUserImplCopyWith<_$SocialUserImpl> get copyWith =>
      __$$SocialUserImplCopyWithImpl<_$SocialUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SocialUserImplToJson(this);
  }
}

abstract class _SocialUser implements SocialUser {
  const factory _SocialUser({
    required final String username,
    required final String displayName,
    final List<Map<String, dynamic>> roster,
    final String status,
    final String? currentBattleId,
    final int wins,
    final int losses,
    final bool forcePasscodeChange,
    final String? profileImageUrl,
    final Map<String, dynamic> cardCustomization,
    final List<Map<String, dynamic>> recentReplays,
  }) = _$SocialUserImpl;

  factory _SocialUser.fromJson(Map<String, dynamic> json) =
      _$SocialUserImpl.fromJson;

  @override
  String get username;
  @override
  String get displayName;
  @override
  List<Map<String, dynamic>> get roster;
  @override
  String get status; // 'online', 'battling', 'offline'
  @override
  String? get currentBattleId;
  @override
  int get wins;
  @override
  int get losses;
  @override
  bool get forcePasscodeChange;
  @override
  String? get profileImageUrl;
  @override
  Map<String, dynamic> get cardCustomization;
  @override
  List<Map<String, dynamic>> get recentReplays;

  /// Create a copy of SocialUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocialUserImplCopyWith<_$SocialUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get sender => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get recipient =>
      throw _privateConstructorUsedError; // For @Admin private messages
  String get type =>
      throw _privateConstructorUsedError; // 'regular', 'admin_reset', 'broadcast'
  String? get profileImageUrl => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String sender,
    String text,
    DateTime timestamp,
    String? recipient,
    String type,
    String? profileImageUrl,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sender = null,
    Object? text = null,
    Object? timestamp = null,
    Object? recipient = freezed,
    Object? type = null,
    Object? profileImageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sender: null == sender
                ? _value.sender
                : sender // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            recipient: freezed == recipient
                ? _value.recipient
                : recipient // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            profileImageUrl: freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sender,
    String text,
    DateTime timestamp,
    String? recipient,
    String type,
    String? profileImageUrl,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sender = null,
    Object? text = null,
    Object? timestamp = null,
    Object? recipient = freezed,
    Object? type = null,
    Object? profileImageUrl = freezed,
  }) {
    return _then(
      _$ChatMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sender: null == sender
            ? _value.sender
            : sender // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        recipient: freezed == recipient
            ? _value.recipient
            : recipient // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        profileImageUrl: freezed == profileImageUrl
            ? _value.profileImageUrl
            : profileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.recipient,
    this.type = 'regular',
    this.profileImageUrl,
  });

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String sender;
  @override
  final String text;
  @override
  final DateTime timestamp;
  @override
  final String? recipient;
  // For @Admin private messages
  @override
  @JsonKey()
  final String type;
  // 'regular', 'admin_reset', 'broadcast'
  @override
  final String? profileImageUrl;

  @override
  String toString() {
    return 'ChatMessage(id: $id, sender: $sender, text: $text, timestamp: $timestamp, recipient: $recipient, type: $type, profileImageUrl: $profileImageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.recipient, recipient) ||
                other.recipient == recipient) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sender,
    text,
    timestamp,
    recipient,
    type,
    profileImageUrl,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String sender,
    required final String text,
    required final DateTime timestamp,
    final String? recipient,
    final String type,
    final String? profileImageUrl,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get sender;
  @override
  String get text;
  @override
  DateTime get timestamp;
  @override
  String? get recipient; // For @Admin private messages
  @override
  String get type; // 'regular', 'admin_reset', 'broadcast'
  @override
  String? get profileImageUrl;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BattleSession _$BattleSessionFromJson(Map<String, dynamic> json) {
  return _BattleSession.fromJson(json);
}

/// @nodoc
mixin _$BattleSession {
  String get id => throw _privateConstructorUsedError;
  String get player1 => throw _privateConstructorUsedError; // Username
  String get player2 => throw _privateConstructorUsedError; // Username
  String get status =>
      throw _privateConstructorUsedError; // 'pending', 'active', 'finished'
  String? get currentTurn =>
      throw _privateConstructorUsedError; // Username of whose turn it is
  int get turnCount => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get history => throw _privateConstructorUsedError;
  Map<String, dynamic>? get lastMove => throw _privateConstructorUsedError;
  Map<String, dynamic> get hpState => throw _privateConstructorUsedError;
  Map<String, List<Map<String, dynamic>>> get rosters =>
      throw _privateConstructorUsedError;
  DateTime? get lastUpdate => throw _privateConstructorUsedError;

  /// Serializes this BattleSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BattleSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BattleSessionCopyWith<BattleSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BattleSessionCopyWith<$Res> {
  factory $BattleSessionCopyWith(
    BattleSession value,
    $Res Function(BattleSession) then,
  ) = _$BattleSessionCopyWithImpl<$Res, BattleSession>;
  @useResult
  $Res call({
    String id,
    String player1,
    String player2,
    String status,
    String? currentTurn,
    int turnCount,
    List<Map<String, dynamic>> history,
    Map<String, dynamic>? lastMove,
    Map<String, dynamic> hpState,
    Map<String, List<Map<String, dynamic>>> rosters,
    DateTime? lastUpdate,
  });
}

/// @nodoc
class _$BattleSessionCopyWithImpl<$Res, $Val extends BattleSession>
    implements $BattleSessionCopyWith<$Res> {
  _$BattleSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BattleSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? player1 = null,
    Object? player2 = null,
    Object? status = null,
    Object? currentTurn = freezed,
    Object? turnCount = null,
    Object? history = null,
    Object? lastMove = freezed,
    Object? hpState = null,
    Object? rosters = null,
    Object? lastUpdate = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            player1: null == player1
                ? _value.player1
                : player1 // ignore: cast_nullable_to_non_nullable
                      as String,
            player2: null == player2
                ? _value.player2
                : player2 // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            currentTurn: freezed == currentTurn
                ? _value.currentTurn
                : currentTurn // ignore: cast_nullable_to_non_nullable
                      as String?,
            turnCount: null == turnCount
                ? _value.turnCount
                : turnCount // ignore: cast_nullable_to_non_nullable
                      as int,
            history: null == history
                ? _value.history
                : history // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            lastMove: freezed == lastMove
                ? _value.lastMove
                : lastMove // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            hpState: null == hpState
                ? _value.hpState
                : hpState // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            rosters: null == rosters
                ? _value.rosters
                : rosters // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<Map<String, dynamic>>>,
            lastUpdate: freezed == lastUpdate
                ? _value.lastUpdate
                : lastUpdate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BattleSessionImplCopyWith<$Res>
    implements $BattleSessionCopyWith<$Res> {
  factory _$$BattleSessionImplCopyWith(
    _$BattleSessionImpl value,
    $Res Function(_$BattleSessionImpl) then,
  ) = __$$BattleSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String player1,
    String player2,
    String status,
    String? currentTurn,
    int turnCount,
    List<Map<String, dynamic>> history,
    Map<String, dynamic>? lastMove,
    Map<String, dynamic> hpState,
    Map<String, List<Map<String, dynamic>>> rosters,
    DateTime? lastUpdate,
  });
}

/// @nodoc
class __$$BattleSessionImplCopyWithImpl<$Res>
    extends _$BattleSessionCopyWithImpl<$Res, _$BattleSessionImpl>
    implements _$$BattleSessionImplCopyWith<$Res> {
  __$$BattleSessionImplCopyWithImpl(
    _$BattleSessionImpl _value,
    $Res Function(_$BattleSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BattleSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? player1 = null,
    Object? player2 = null,
    Object? status = null,
    Object? currentTurn = freezed,
    Object? turnCount = null,
    Object? history = null,
    Object? lastMove = freezed,
    Object? hpState = null,
    Object? rosters = null,
    Object? lastUpdate = freezed,
  }) {
    return _then(
      _$BattleSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        player1: null == player1
            ? _value.player1
            : player1 // ignore: cast_nullable_to_non_nullable
                  as String,
        player2: null == player2
            ? _value.player2
            : player2 // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        currentTurn: freezed == currentTurn
            ? _value.currentTurn
            : currentTurn // ignore: cast_nullable_to_non_nullable
                  as String?,
        turnCount: null == turnCount
            ? _value.turnCount
            : turnCount // ignore: cast_nullable_to_non_nullable
                  as int,
        history: null == history
            ? _value._history
            : history // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        lastMove: freezed == lastMove
            ? _value._lastMove
            : lastMove // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        hpState: null == hpState
            ? _value._hpState
            : hpState // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        rosters: null == rosters
            ? _value._rosters
            : rosters // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<Map<String, dynamic>>>,
        lastUpdate: freezed == lastUpdate
            ? _value.lastUpdate
            : lastUpdate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BattleSessionImpl implements _BattleSession {
  const _$BattleSessionImpl({
    required this.id,
    required this.player1,
    required this.player2,
    required this.status,
    this.currentTurn,
    this.turnCount = 0,
    final List<Map<String, dynamic>> history = const [],
    final Map<String, dynamic>? lastMove,
    final Map<String, dynamic> hpState = const {},
    final Map<String, List<Map<String, dynamic>>> rosters = const {},
    this.lastUpdate,
  }) : _history = history,
       _lastMove = lastMove,
       _hpState = hpState,
       _rosters = rosters;

  factory _$BattleSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BattleSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String player1;
  // Username
  @override
  final String player2;
  // Username
  @override
  final String status;
  // 'pending', 'active', 'finished'
  @override
  final String? currentTurn;
  // Username of whose turn it is
  @override
  @JsonKey()
  final int turnCount;
  final List<Map<String, dynamic>> _history;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  final Map<String, dynamic>? _lastMove;
  @override
  Map<String, dynamic>? get lastMove {
    final value = _lastMove;
    if (value == null) return null;
    if (_lastMove is EqualUnmodifiableMapView) return _lastMove;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic> _hpState;
  @override
  @JsonKey()
  Map<String, dynamic> get hpState {
    if (_hpState is EqualUnmodifiableMapView) return _hpState;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_hpState);
  }

  final Map<String, List<Map<String, dynamic>>> _rosters;
  @override
  @JsonKey()
  Map<String, List<Map<String, dynamic>>> get rosters {
    if (_rosters is EqualUnmodifiableMapView) return _rosters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rosters);
  }

  @override
  final DateTime? lastUpdate;

  @override
  String toString() {
    return 'BattleSession(id: $id, player1: $player1, player2: $player2, status: $status, currentTurn: $currentTurn, turnCount: $turnCount, history: $history, lastMove: $lastMove, hpState: $hpState, rosters: $rosters, lastUpdate: $lastUpdate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BattleSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.player1, player1) || other.player1 == player1) &&
            (identical(other.player2, player2) || other.player2 == player2) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentTurn, currentTurn) ||
                other.currentTurn == currentTurn) &&
            (identical(other.turnCount, turnCount) ||
                other.turnCount == turnCount) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            const DeepCollectionEquality().equals(other._lastMove, _lastMove) &&
            const DeepCollectionEquality().equals(other._hpState, _hpState) &&
            const DeepCollectionEquality().equals(other._rosters, _rosters) &&
            (identical(other.lastUpdate, lastUpdate) ||
                other.lastUpdate == lastUpdate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    player1,
    player2,
    status,
    currentTurn,
    turnCount,
    const DeepCollectionEquality().hash(_history),
    const DeepCollectionEquality().hash(_lastMove),
    const DeepCollectionEquality().hash(_hpState),
    const DeepCollectionEquality().hash(_rosters),
    lastUpdate,
  );

  /// Create a copy of BattleSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BattleSessionImplCopyWith<_$BattleSessionImpl> get copyWith =>
      __$$BattleSessionImplCopyWithImpl<_$BattleSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BattleSessionImplToJson(this);
  }
}

abstract class _BattleSession implements BattleSession {
  const factory _BattleSession({
    required final String id,
    required final String player1,
    required final String player2,
    required final String status,
    final String? currentTurn,
    final int turnCount,
    final List<Map<String, dynamic>> history,
    final Map<String, dynamic>? lastMove,
    final Map<String, dynamic> hpState,
    final Map<String, List<Map<String, dynamic>>> rosters,
    final DateTime? lastUpdate,
  }) = _$BattleSessionImpl;

  factory _BattleSession.fromJson(Map<String, dynamic> json) =
      _$BattleSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get player1; // Username
  @override
  String get player2; // Username
  @override
  String get status; // 'pending', 'active', 'finished'
  @override
  String? get currentTurn; // Username of whose turn it is
  @override
  int get turnCount;
  @override
  List<Map<String, dynamic>> get history;
  @override
  Map<String, dynamic>? get lastMove;
  @override
  Map<String, dynamic> get hpState;
  @override
  Map<String, List<Map<String, dynamic>>> get rosters;
  @override
  DateTime? get lastUpdate;

  /// Create a copy of BattleSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BattleSessionImplCopyWith<_$BattleSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
