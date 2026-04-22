class PokemonCenterConstants {
  static const String rootDir = '/Users/bennahalewski/Documents/PokeRoster';
  static const String appDir = '$rootDir/pokemon_generations';
  static const String mainSiteDir = '$rootDir/pokemon_generations';
  static const String adminWebDir = '$rootDir/pokemon_generations_dashboard';
  static const String exchangeDir = '$rootDir/aevora_exchange';
  static const String backendDir = '$rootDir/pokemon_generations_backend';
  static const String logDir = '$rootDir/.logs';

  static const String flutterPath =
      '/Users/bennahalewski/development/flutter/bin/flutter';
  static const String nodePath =
      '/Users/bennahalewski/.nvm/versions/node/v22.22.1/bin/node';
  static const String cloudflaredPath = '$rootDir/cloudflared';
  static const String ollamaCliPath = '/usr/local/bin/ollama';
  static const String ollamaAltCliPath = '/opt/homebrew/bin/ollama';
  static const String ollamaBaseUrl = 'http://127.0.0.1:11434';

  static const int backendPort = 8194;
  static const int mainSitePort = 8191;
  static const int adminWebPort = 8080;
  static const int exchangePort = 8192;
  static const int assetServerPort = 8197;
  static const int ollamaPort = 11434;

  // Cloudflare API Configuration
  static const String cloudflareZoneId = String.fromEnvironment(
    'CLOUDFLARE_ZONE_ID',
    defaultValue: '',
  );
  static const String cloudflareApiToken = String.fromEnvironment(
    'CLOUDFLARE_API_TOKEN',
    defaultValue: '',
  );
  static const String cloudflareAccountId = String.fromEnvironment(
    'CLOUDFLARE_ACCOUNT_ID',
    defaultValue: '',
  );
}
