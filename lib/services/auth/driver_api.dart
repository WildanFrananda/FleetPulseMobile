import 'package:dio/dio.dart';
import 'package:fleet_pulse_mobile/models/login_request.dart';
import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:retrofit/retrofit.dart';

part 'driver_api.g.dart';

@RestApi()
abstract class DriverApi {
  factory DriverApi(Dio dio, {String baseUrl}) = _DriverApi;

  @POST('/driver/session')
  Future<DriverSession> login(@Body() LoginRequest body);
}
