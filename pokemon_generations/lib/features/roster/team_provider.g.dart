// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teamByIdHash() => r'ffd0c5630d17251126c4e228a2a596e348a8677e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [teamById].
@ProviderFor(teamById)
const teamByIdProvider = TeamByIdFamily();

/// See also [teamById].
class TeamByIdFamily extends Family<AsyncValue<Team?>> {
  /// See also [teamById].
  const TeamByIdFamily();

  /// See also [teamById].
  TeamByIdProvider call(String id) {
    return TeamByIdProvider(id);
  }

  @override
  TeamByIdProvider getProviderOverride(covariant TeamByIdProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'teamByIdProvider';
}

/// See also [teamById].
class TeamByIdProvider extends AutoDisposeFutureProvider<Team?> {
  /// See also [teamById].
  TeamByIdProvider(String id)
    : this._internal(
        (ref) => teamById(ref as TeamByIdRef, id),
        from: teamByIdProvider,
        name: r'teamByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$teamByIdHash,
        dependencies: TeamByIdFamily._dependencies,
        allTransitiveDependencies: TeamByIdFamily._allTransitiveDependencies,
        id: id,
      );

  TeamByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(FutureOr<Team?> Function(TeamByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: TeamByIdProvider._internal(
        (ref) => create(ref as TeamByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Team?> createElement() {
    return _TeamByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TeamByIdRef on AutoDisposeFutureProviderRef<Team?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TeamByIdProviderElement extends AutoDisposeFutureProviderElement<Team?>
    with TeamByIdRef {
  _TeamByIdProviderElement(super.provider);

  @override
  String get id => (origin as TeamByIdProvider).id;
}

String _$teamListHash() => r'a526c36f2d3931a882a8366657205f2c54f3fbbe';

/// See also [TeamList].
@ProviderFor(TeamList)
final teamListProvider =
    AutoDisposeAsyncNotifierProvider<TeamList, List<Team>>.internal(
      TeamList.new,
      name: r'teamListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teamListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TeamList = AutoDisposeAsyncNotifier<List<Team>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
