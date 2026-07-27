// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    _RegisterRequest(
      name: json['name'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String,
      vehiclePlate: json['vehicle_plate'] as String,
      capacityKg: (json['capacity_kg'] as num).toInt(),
    );

Map<String, dynamic> _$RegisterRequestToJson(_RegisterRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'password': instance.password,
      'vehicle_plate': instance.vehiclePlate,
      'capacity_kg': instance.capacityKg,
    };
