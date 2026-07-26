// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:fleet_pulse_mobile/repositories/connection_repository.dart'
    as _i891;
import 'package:fleet_pulse_mobile/repositories/connection_repository_impl.dart'
    as _i458;
import 'package:fleet_pulse_mobile/repositories/order_repository.dart' as _i933;
import 'package:fleet_pulse_mobile/repositories/order_repository_impl.dart'
    as _i549;
import 'package:fleet_pulse_mobile/routes/app_router_state.dart' as _i34;
import 'package:fleet_pulse_mobile/services/channel/channel_client.dart'
    as _i700;
import 'package:fleet_pulse_mobile/viewmodels/login_view_model.dart' as _i598;
import 'package:fleet_pulse_mobile/viewmodels/order_view_model.dart' as _i962;
import 'package:fleet_pulse_mobile/viewmodels/splash_view_model.dart' as _i580;
import 'package:fleet_pulse_mobile/viewmodels/tracking_view_model.dart'
    as _i812;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i34.AppRouterState>(() => _i34.AppRouterState());
    gh.lazySingleton<_i700.ChannelClient>(
      () => _i700.ChannelClient(),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i598.LoginViewModel>(
      () => _i598.LoginViewModel(gh<_i34.AppRouterState>()),
    );
    gh.factory<_i580.SplashViewModel>(
      () => _i580.SplashViewModel(gh<_i34.AppRouterState>()),
    );
    gh.lazySingleton<_i891.ConnectionRepository>(
      () => _i458.ConnectionRepositoryImpl(gh<_i700.ChannelClient>()),
    );
    gh.lazySingleton<_i933.OrderRepository>(
      () => _i549.OrderRepositoryImpl(gh<_i700.ChannelClient>()),
    );
    gh.factory<_i962.OrderViewModel>(
      () => _i962.OrderViewModel(
        gh<_i34.AppRouterState>(),
        gh<_i933.OrderRepository>(),
      ),
    );
    gh.factory<_i812.TrackingViewModel>(
      () => _i812.TrackingViewModel(
        gh<_i34.AppRouterState>(),
        gh<_i891.ConnectionRepository>(),
        gh<_i933.OrderRepository>(),
      ),
    );
    return this;
  }
}
