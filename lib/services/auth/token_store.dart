import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class TokenStore {
  TokenStore(this._storage);

  final FlutterSecureStorage _storage;

  static const String _kToken = 'driver_token';
  static const String _kDriverId = 'driver_id';

  Future<void> save(DriverSession session) async {
    await _storage.write(key: _kToken, value: session.token);
    await _storage.write(
      key: _kDriverId,
      value: session.driverId.value.toString(),
    );
  }

  Future<DriverSession?> read() async {
    final String? token = await _storage.read(key: _kToken);
    final String? id = await _storage.read(key: _kDriverId);

    if (token == null || id == null) {
      return null;
    }

    final int? parsed = int.tryParse(id);

    if (parsed == null) {
      return null;
    }

    return DriverSession(driverId: DriverId(parsed), token: token);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kDriverId);
  }
}
