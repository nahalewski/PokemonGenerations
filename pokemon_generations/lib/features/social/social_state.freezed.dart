// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SocialState {
  List<SocialUser> get users => throw _privateConstructorUsedError;
  List<SocialUser> get friends => throw _privateConstructorUsedError;
  List<Map<String, String>> get pendingRequests =>
      throw _privateConstructorUsedError;
  List<ChatMessage> get chatMessages => throw _privateConstructorUsedError;
  List<ChatMessage> get unreadMessages => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get incomingChallenges =>
      throw _privateConstructorUsedError;
  Map<String, dynamic>? get globalBroadcast =>
      throw _privateConstructorUsedError;
  List<Gift> get pendingGifts => throw _privateConstructorUsedError;
  List<String> get dismissedGiftIds => throw _privateConstructorUsedError;
  DateTime? get lastReadTime => throw _privateConstructorUsedError;
  String? get dismissedBroadcastAt => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isServerConnected => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of SocialState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SocialStateCopyWith<SocialState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocialStateCopyWith<$Res> {
  factory $SocialStateCopyWith(
    SocialState value,
    $Res Function(SocialState) then,
  ) = _$SocialStateCopyWithImpl<$Res, SocialState>;
  @useResult
  $Res call({
    List<SocialUser> users,
    List<SocialUser> friends,
    List<Map<String, String>> pendingRequests,
    List<ChatMessage> chatMessages,
    List<ChatMessage> unreadMessages,
    List<Map<String, dynamic>> incomingChallenges,
    Map<String, dynamic>? globalBroadcast,
    List<Gift> pendingGifts,
    List<String> dismissedGiftIds,
    DateTime? lastReadTime,
    String? dismissedBroadcastAt,
    bool isLoading,
    bool isServerConnected,
    String? error,
  });
}

/// @nodoc
class _$SocialStateCopyWithImpl<$Res, $Val extends SocialState>
    implements $SocialStateCopyWith<$Res> {
  _$SocialStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocialState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? friends = null,
    Object? pendingRequests = null,
    Object? chatMessages = null,
    Object? unreadMessages = null,
    Object? incomingChallenges = null,
    Object? globalBroadcast = freezed,
    Object? pendingGifts = null,
    Object? dismissedGiftIds = null,
    Object? lastReadTime = freezed,
    Object? dismissedBroadcastAt = freezed,
    Object? isLoading = null,
    Object? isServerConnected = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            users: null == users
                ? _value.users
                : users // ignore: cast_nullable_to_non_nullable
                      as List<SocialUser>,
            friends: null == friends
                ? _value.friends
                : friends // ignore: cast_nullable_to_non_nullable
                      as List<SocialUser>,
            pendingRequests: null == pendingRequests
                ? _value.pendingRequests
                : pendingRequests // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, String>>,
            chatMessages: null == chatMessages
                ? _value.chatMessages
                : chatMessages // ignore: cast_nullable_to_non_nullable
                      as List<ChatMessage>,
            unreadMessages: null == unreadMessages
                ? _value.unreadMessages
                : unreadMessages // ignore: cast_nullable_to_non_nullable
                      as List<ChatMessage>,
            incomingChallenges: null == incomingChallenges
                ? _value.incomingChallenges
                : incomingChallenges // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            globalBroadcast: freezed == globalBroadcast
                ? _value.globalBroadcast
                : globalBroadcast // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            pendingGifts: null == pendingGifts
                ? _value.pendingGifts
                : pendingGifts // ignore: cast_nullable_to_non_nullable
                      as List<Gift>,
            dismissedGiftIds: null == dismissedGiftIds
                ? _value.dismissedGiftIds
                : dismissedGiftIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            lastReadTime: freezed == lastReadTime
                ? _value.lastReadTime
                : lastReadTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dismissedBroadcastAt: freezed == dismissedBroadcastAt
                ? _value.dismissedBroadcastAt
                : dismissedBroadcastAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isServerConnected: null == isServerConnected
                ? _value.isServerConnected
                : isServerConnected // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SocialStateImplCopyWith<$Res>
    implements $SocialStateCopyWith<$Res> {
  factory _$$SocialStateImplCopyWith(
    _$SocialStateImpl value,
    $Res Function(_$SocialStateImpl) then,
  ) = __$$SocialStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<SocialUser> users,
    List<SocialUser> friends,
    List<Map<String, String>> pendingRequests,
    List<ChatMessage> chatMessages,
    List<ChatMessage> unreadMessages,
    List<Map<String, dynamic>> incomingChallenges,
    Map<String, dynamic>? globalBroadcast,
    List<Gift> pendingGifts,
    List<String> dismissedGiftIds,
    DateTime? lastReadTime,
    String? dismissedBroadcastAt,
    bool isLoading,
    bool isServerConnected,
    String? error,
  });
}

/// @nodoc
class __$$SocialStateImplCopyWithImpl<$Res>
    extends _$SocialStateCopyWithImpl<$Res, _$SocialStateImpl>
    implements _$$SocialStateImplCopyWith<$Res> {
  __$$SocialStateImplCopyWithImpl(
    _$SocialStateImpl _value,
    $Res Function(_$SocialStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SocialState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? friends = null,
    Object? pendingRequests = null,
    Object? chatMessages = null,
    Object? unreadMessages = null,
    Object? incomingChallenges = null,
    Object? globalBroadcast = freezed,
    Object? pendingGifts = null,
    Object? dismissedGiftIds = null,
    Object? lastReadTime = freezed,
    Object? dismissedBroadcastAt = freezed,
    Object? isLoading = null,
    Object? isServerConnected = null,
    Object? error = freezed,
  }) {
    return _then(
      _$SocialStateImpl(
        users: null == users
            ? _value._users
            : users // ignore: cast_nullable_to_non_nullable
                  as List<SocialUser>,
        friends: null == friends
            ? _value._friends
            : friends // ignore: cast_nullable_to_non_nullable
                  as List<SocialUser>,
        pendingRequests: null == pendingRequests
            ? _value._pendingRequests
            : pendingRequests // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, String>>,
        chatMessages: null == chatMessages
            ? _value._chatMessages
            : chatMessages // ignore: cast_nullable_to_non_nullable
                  as List<ChatMessage>,
        unreadMessages: null == unreadMessages
            ? _value._unreadMessages
            : unreadMessages // ignore: cast_nullable_to_non_nullable
                  as List<ChatMessage>,
        incomingChallenges: null == incomingChallenges
            ? _value._incomingChallenges
            : incomingChallenges // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        globalBroadcast: freezed == globalBroadcast
            ? _value._globalBroadcast
            : globalBroadcast // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        pendingGifts: null == pendingGifts
            ? _value._pendingGifts
            : pendingGifts // ignore: cast_nullable_to_non_nullable
                  as List<Gift>,
        dismissedGiftIds: null == dismissedGiftIds
            ? _value._dismissedGiftIds
            : dismissedGiftIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        lastReadTime: freezed == lastReadTime
            ? _value.lastReadTime
            : lastReadTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dismissedBroadcastAt: freezed == dismissedBroadcastAt
            ? _value.dismissedBroadcastAt
            : dismissedBroadcastAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isServerConnected: null == isServerConnected
            ? _value.isServerConnected
            : isServerConnected // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SocialStateImpl implements _SocialState {
  const _$SocialStateImpl({
    final List<SocialUser> users = const [],
    final List<SocialUser> friends = const [],
    final List<Map<String, String>> pendingRequests = const [],
    final List<ChatMessage> chatMessages = const [],
    final List<ChatMessage> unreadMessages = const [],
    final List<Map<String, dynamic>> incomingChallenges = const [],
    final Map<String, dynamic>? globalBroadcast,
    final List<Gift> pendingGifts = const [],
    final List<String> dismissedGiftIds = const [],
    this.lastReadTime,
    this.dismissedBroadcastAt,
    this.isLoading = false,
    this.isServerConnected = true,
    this.error,
  }) : _users = users,
       _friends = friends,
       _pendingRequests = pendingRequests,
       _chatMessages = chatMessages,
       _unreadMessages = unreadMessages,
       _incomingChallenges = incomingChallenges,
       _globalBroadcast = globalBroadcast,
       _pendingGifts = pendingGifts,
       _dismissedGiftIds = dismissedGiftIds;

  final List<SocialUser> _users;
  @override
  @JsonKey()
  List<SocialUser> get users {
    if (_users is EqualUnmodifiableListView) return _users;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_users);
  }

  final List<SocialUser> _friends;
  @override
  @JsonKey()
  List<SocialUser> get friends {
    if (_friends is EqualUnmodifiableListView) return _friends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_friends);
  }

  final List<Map<String, String>> _pendingRequests;
  @override
  @JsonKey()
  List<Map<String, String>> get pendingRequests {
    if (_pendingRequests is EqualUnmodifiableListView) return _pendingRequests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingRequests);
  }

  final List<ChatMessage> _chatMessages;
  @override
  @JsonKey()
  List<ChatMessage> get chatMessages {
    if (_chatMessages is EqualUnmodifiableListView) return _chatMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chatMessages);
  }

  final List<ChatMessage> _unreadMessages;
  @override
  @JsonKey()
  List<ChatMessage> get unreadMessages {
    if (_unreadMessages is EqualUnmodifiableListView) return _unreadMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unreadMessages);
  }

  final List<Map<String, dynamic>> _incomingChallenges;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get incomingChallenges {
    if (_incomingChallenges is EqualUnmodifiableListView)
      return _incomingChallenges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_incomingChallenges);
  }

  final Map<String, dynamic>? _globalBroadcast;
  @override
  Map<String, dynamic>? get globalBroadcast {
    final value = _globalBroadcast;
    if (value == null) return null;
    if (_globalBroadcast is EqualUnmodifiableMapView) return _globalBroadcast;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<Gift> _pendingGifts;
  @override
  @JsonKey()
  List<Gift> get pendingGifts {
    if (_pendingGifts is EqualUnmodifiableListView) return _pendingGifts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingGifts);
  }

  final List<String> _dismissedGiftIds;
  @override
  @JsonKey()
  List<String> get dismissedGiftIds {
    if (_dismissedGiftIds is EqualUnmodifiableListView)
      return _dismissedGiftIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dismissedGiftIds);
  }

  @override
  final DateTime? lastReadTime;
  @override
  final String? dismissedBroadcastAt;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isServerConnected;
  @override
  final String? error;

  @override
  String toString() {
    return 'SocialState(users: $users, friends: $friends, pendingRequests: $pendingRequests, chatMessages: $chatMessages, unreadMessages: $unreadMessages, incomingChallenges: $incomingChallenges, globalBroadcast: $globalBroadcast, pendingGifts: $pendingGifts, dismissedGiftIds: $dismissedGiftIds, lastReadTime: $lastReadTime, dismissedBroadcastAt: $dismissedBroadcastAt, isLoading: $isLoading, isServerConnected: $isServerConnected, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialStateImpl &&
            const DeepCollectionEquality().equals(other._users, _users) &&
            const DeepCollectionEquality().equals(other._friends, _friends) &&
            const DeepCollectionEquality().equals(
              other._pendingRequests,
              _pendingRequests,
            ) &&
            const DeepCollectionEquality().equals(
              other._chatMessages,
              _chatMessages,
            ) &&
            const DeepCollectionEquality().equals(
              other._unreadMessages,
              _unreadMessages,
            ) &&
            const DeepCollectionEquality().equals(
              other._incomingChallenges,
              _incomingChallenges,
            ) &&
            const DeepCollectionEquality().equals(
              other._globalBroadcast,
              _globalBroadcast,
            ) &&
            const DeepCollectionEquality().equals(
              other._pendingGifts,
              _pendingGifts,
            ) &&
            const DeepCollectionEquality().equals(
              other._dismissedGiftIds,
              _dismissedGiftIds,
            ) &&
            (identical(other.lastReadTime, lastReadTime) ||
                other.lastReadTime == lastReadTime) &&
            (identical(other.dismissedBroadcastAt, dismissedBroadcastAt) ||
                other.dismissedBroadcastAt == dismissedBroadcastAt) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isServerConnected, isServerConnected) ||
                other.isServerConnected == isServerConnected) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_users),
    const DeepCollectionEquality().hash(_friends),
    const DeepCollectionEquality().hash(_pendingRequests),
    const DeepCollectionEquality().hash(_chatMessages),
    const DeepCollectionEquality().hash(_unreadMessages),
    const DeepCollectionEquality().hash(_incomingChallenges),
    const DeepCollectionEquality().hash(_globalBroadcast),
    const DeepCollectionEquality().hash(_pendingGifts),
    const DeepCollectionEquality().hash(_dismissedGiftIds),
    lastReadTime,
    dismissedBroadcastAt,
    isLoading,
    isServerConnected,
    error,
  );

  /// Create a copy of SocialState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialStateImplCopyWith<_$SocialStateImpl> get copyWith =>
      __$$SocialStateImplCopyWithImpl<_$SocialStateImpl>(this, _$identity);
}

abstract class _SocialState implements SocialState {
  const factory _SocialState({
    final List<SocialUser> users,
    final List<SocialUser> friends,
    final List<Map<String, String>> pendingRequests,
    final List<ChatMessage> chatMessages,
    final List<ChatMessage> unreadMessages,
    final List<Map<String, dynamic>> incomingChallenges,
    final Map<String, dynamic>? globalBroadcast,
    final List<Gift> pendingGifts,
    final List<String> dismissedGiftIds,
    final DateTime? lastReadTime,
    final String? dismissedBroadcastAt,
    final bool isLoading,
    final bool isServerConnected,
    final String? error,
  }) = _$SocialStateImpl;

  @override
  List<SocialUser> get users;
  @override
  List<SocialUser> get friends;
  @override
  List<Map<String, String>> get pendingRequests;
  @override
  List<ChatMessage> get chatMessages;
  @override
  List<ChatMessage> get unreadMessages;
  @override
  List<Map<String, dynamic>> get incomingChallenges;
  @override
  Map<String, dynamic>? get globalBroadcast;
  @override
  List<Gift> get pendingGifts;
  @override
  List<String> get dismissedGiftIds;
  @override
  DateTime? get lastReadTime;
  @override
  String? get dismissedBroadcastAt;
  @override
  bool get isLoading;
  @override
  bool get isServerConnected;
  @override
  String? get error;

  /// Create a copy of SocialState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocialStateImplCopyWith<_$SocialStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
