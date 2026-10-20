/// Live Noorva backend (AWS staging). Override with --dart-define=NOORVA_API_BASE=...
class NoorvaApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'NOORVA_API_BASE',
    defaultValue: 'http://32.196.84.157',
  );

  static String get v1 => '$baseUrl/v1';
}
