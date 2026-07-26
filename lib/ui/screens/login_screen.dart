import 'package:fleet_pulse_mobile/viewmodels/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginViewModel vm = context.watch<LoginViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Driver Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('FleetPulse Driver'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: vm.devContinue,
                child: const Text('Continue (dev)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
