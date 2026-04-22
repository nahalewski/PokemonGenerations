// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roster_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rosterHash() => r'034feaaf9adf08ff842a4a197ef4e4ed6ad180e5';

/// See also [Roster].
@ProviderFor(Roster)
final rosterProvider =
    AutoDisposeAsyncNotifierProvider<Roster, List<PokemonForm>>.internal(
      Roster.new,
      name: r'rosterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rosterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Roster = AutoDisposeAsyncNotifier<List<PokemonForm>>;
String _$pCStorageHash() => r'552935484fd6ff00d8f03212e0033809f526808d';

/// See also [PCStorage].
@ProviderFor(PCStorage)
final pCStorageProvider =
    AutoDisposeAsyncNotifierProvider<PCStorage, List<PokemonForm>>.internal(
      PCStorage.new,
      name: r'pCStorageProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pCStorageHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PCStorage = AutoDisposeAsyncNotifier<List<PokemonForm>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
