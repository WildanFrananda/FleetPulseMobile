abstract final class AppConfig {
  static const String wsBase = String.fromEnvironment(
    'WS_BASE',
    defaultValue: 'ws://10.0.2.2:4000',
  );

  static const String httpBase = String.fromEnvironment(
    'HTTP_BASE',
    defaultValue: 'http://10.0.2.2:4000',
  );
}
