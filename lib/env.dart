/// Configuration values that must not be committed to the repository.
///
/// Values are provided at build time, e.g.
///   flutter run --dart-define-from-file=env.json
/// See env.example.json for the list of keys.
class Env {
  static const String smtpUsername = String.fromEnvironment('SMTP_USERNAME');
  static const String smtpPassword = String.fromEnvironment('SMTP_PASSWORD');
  static const String adminEmail = String.fromEnvironment('ADMIN_EMAIL');

  static const String instagramUsername = String.fromEnvironment('INSTAGRAM_USERNAME');
  static const String instagramPassword = String.fromEnvironment('INSTAGRAM_PASSWORD');

  static const String sessionServerUrl = String.fromEnvironment('SESSION_SERVER_URL');
  static const String sessionServerTokenA = String.fromEnvironment('SESSION_SERVER_TOKEN_A');
  static const String sessionServerTokenB = String.fromEnvironment('SESSION_SERVER_TOKEN_B');
  static const String sessionServerTokenC = String.fromEnvironment('SESSION_SERVER_TOKEN_C');

  static const String quotesKey = String.fromEnvironment('QUOTES_KEY');
}
