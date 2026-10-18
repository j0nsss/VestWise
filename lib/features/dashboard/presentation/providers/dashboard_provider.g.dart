// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Combines the feature repositories' streams into a single [DashboardState].
///
/// Each `ref.watch` re-runs this function whenever the underlying stream emits,
/// so completing a task or logging a transaction updates the Dashboard with no
/// manual refresh.

@ProviderFor(dashboard)
final dashboardProvider = DashboardProvider._();

/// Combines the feature repositories' streams into a single [DashboardState].
///
/// Each `ref.watch` re-runs this function whenever the underlying stream emits,
/// so completing a task or logging a transaction updates the Dashboard with no
/// manual refresh.

final class DashboardProvider
    extends $FunctionalProvider<DashboardState, DashboardState, DashboardState>
    with $Provider<DashboardState> {
  /// Combines the feature repositories' streams into a single [DashboardState].
  ///
  /// Each `ref.watch` re-runs this function whenever the underlying stream emits,
  /// so completing a task or logging a transaction updates the Dashboard with no
  /// manual refresh.
  DashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardHash();

  @$internal
  @override
  $ProviderElement<DashboardState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DashboardState create(Ref ref) {
    return dashboard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardState>(value),
    );
  }
}

String _$dashboardHash() => r'511b5a5a0dda69c4a594c79998ad7a3541e89c94';
