import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/models.dart';

abstract interface class OrderRepository {
  Stream<Order?> watchActiveOrder();
  Future<Result<Unit>> pickup(OrderId orderId);
  Future<Result<Unit>> delivered(
    OrderId orderId, {
    String? podPhotoUrl,
    String? podSignature,
  });
}
