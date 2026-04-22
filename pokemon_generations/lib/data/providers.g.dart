// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'3db8efb59043d58a020432b725dc5c954aca9b63';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = AutoDisposeProvider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = AutoDisposeProviderRef<AppDatabase>;
String _$rosterRepositoryHash() => r'ea5cfeb45360377e56fac3c3ee5b2a540b5c2fe9';

/// See also [rosterRepository].
@ProviderFor(rosterRepository)
final rosterRepositoryProvider = AutoDisposeProvider<RosterRepository>.internal(
  rosterRepository,
  name: r'rosterRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rosterRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RosterRepositoryRef = AutoDisposeProviderRef<RosterRepository>;
String _$historyRepositoryHash() => r'a85708aab2cdf09dd0ca01b2f432cf646c7997e7';

/// See also [historyRepository].
@ProviderFor(historyRepository)
final historyRepositoryProvider =
    AutoDisposeProvider<HistoryRepository>.internal(
      historyRepository,
      name: r'historyRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistoryRepositoryRef = AutoDisposeProviderRef<HistoryRepository>;
String _$pokemonNameHash() => r'373e8b2e35939313db04895ed32a64ab6007695a';

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

/// See also [pokemonName].
@ProviderFor(pokemonName)
const pokemonNameProvider = PokemonNameFamily();

/// See also [pokemonName].
class PokemonNameFamily extends Family<AsyncValue<String>> {
  /// See also [pokemonName].
  const PokemonNameFamily();

  /// See also [pokemonName].
  PokemonNameProvider call(String pokemonId) {
    return PokemonNameProvider(pokemonId);
  }

  @override
  PokemonNameProvider getProviderOverride(
    covariant PokemonNameProvider provider,
  ) {
    return call(provider.pokemonId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pokemonNameProvider';
}

/// See also [pokemonName].
class PokemonNameProvider extends AutoDisposeFutureProvider<String> {
  /// See also [pokemonName].
  PokemonNameProvider(String pokemonId)
    : this._internal(
        (ref) => pokemonName(ref as PokemonNameRef, pokemonId),
        from: pokemonNameProvider,
        name: r'pokemonNameProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pokemonNameHash,
        dependencies: PokemonNameFamily._dependencies,
        allTransitiveDependencies: PokemonNameFamily._allTransitiveDependencies,
        pokemonId: pokemonId,
      );

  PokemonNameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pokemonId,
  }) : super.internal();

  final String pokemonId;

  @override
  Override overrideWith(
    FutureOr<String> Function(PokemonNameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PokemonNameProvider._internal(
        (ref) => create(ref as PokemonNameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pokemonId: pokemonId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _PokemonNameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PokemonNameProvider && other.pokemonId == pokemonId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pokemonId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PokemonNameRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `pokemonId` of this provider.
  String get pokemonId;
}

class _PokemonNameProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with PokemonNameRef {
  _PokemonNameProviderElement(super.provider);

  @override
  String get pokemonId => (origin as PokemonNameProvider).pokemonId;
}

String _$analysisHistoryNotifierHash() =>
    r'f914e65528795840bff996f2f7750b751cda8448';

/// See also [AnalysisHistoryNotifier].
@ProviderFor(AnalysisHistoryNotifier)
final analysisHistoryNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      AnalysisHistoryNotifier,
      List<AnalysisHistory>
    >.internal(
      AnalysisHistoryNotifier.new,
      name: r'analysisHistoryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$analysisHistoryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AnalysisHistoryNotifier =
    AutoDisposeAsyncNotifier<List<AnalysisHistory>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
