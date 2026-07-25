import 'package:fleet_pulse_mobile/di/injection.dart';
import 'package:fleet_pulse_mobile/routes/app_route_mapper.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FleetPulseApp extends StatelessWidget {
  const FleetPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<AppRouterState>(),
      child: MaterialApp(
        title: 'FleetPulse Driver',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const _RouterHost(),
      ),
    );
  }
}

class _RouterHost extends StatelessWidget {
  const _RouterHost();

  @override
  Widget build(BuildContext context) {
    final AppRouterState router = context.watch<AppRouterState>();
    const AppRouteMapper mapper = AppRouteMapper();

    return Navigator(
      pages: <Page<dynamic>>[
        for (final route in router.stack) mapper.toPage(route),
      ],
      onDidRemovePage: (Page<dynamic> page) => router.pop(),
    );
  }
}
