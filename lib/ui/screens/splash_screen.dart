import 'package:fleet_pulse_mobile/viewmodels/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<SplashViewModel>();
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
