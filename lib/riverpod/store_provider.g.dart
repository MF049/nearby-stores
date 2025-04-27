// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storeNotifierHash() => r'ed836d7b2c91f84db099b985489eba695620efde';

/// See also [StoreNotifier].
@ProviderFor(StoreNotifier)
final storeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<StoreNotifier, List<Store>>.internal(
  StoreNotifier.new,
  name: r'storeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StoreNotifier = AutoDisposeAsyncNotifier<List<Store>>;
String _$favoriteStoresNotifierHash() =>
    r'4501977dfcda82acfb058893beb0daa8fa7e2f57';

/// See also [FavoriteStoresNotifier].
@ProviderFor(FavoriteStoresNotifier)
final favoriteStoresNotifierProvider = AutoDisposeAsyncNotifierProvider<
    FavoriteStoresNotifier, List<Store>>.internal(
  FavoriteStoresNotifier.new,
  name: r'favoriteStoresNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoriteStoresNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FavoriteStoresNotifier = AutoDisposeAsyncNotifier<List<Store>>;
String _$locationNotifierHash() => r'a7765ac6dd975587866fb7cb8d76ef8f3c23b349';

/// See also [LocationNotifier].
@ProviderFor(LocationNotifier)
final locationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<LocationNotifier, Position?>.internal(
  LocationNotifier.new,
  name: r'locationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocationNotifier = AutoDisposeAsyncNotifier<Position?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
