class ApiConstants {
  /// Primary: Cloudflare tunnel — works from any network, no VPN needed.
  /// poke.machomes.cc will activate once machomes.cc NS are pointed to Cloudflare.
  /// poke.orosapp.us is the live working tunnel right now.
  static const String baseUrl = 'https://poke.orosapp.us';

  /// Fallback: local LAN (used if tunnel is unreachable).
  static const String localHostUrl = 'http://192.168.0.148:8191';
}
