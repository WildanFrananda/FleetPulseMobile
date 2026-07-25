import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:fleet_pulse_mobile/models/enums.dart';
import 'package:fleet_pulse_mobile/models/lat_lng.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
abstract class Order with _$Order {
  const factory Order({
    required int id,
    required OrderStatus status,
    @JsonKey(name: 'weight_kg') required int weightKg,
    required LatLng pickup,
    required LatLng dropoff,
    @JsonKey(name: 'assigned_at') required DateTime assignedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
