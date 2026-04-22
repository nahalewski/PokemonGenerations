import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/terminal_scaffold.dart';
import 'data/services/api_client.dart';
import 'features/auth/login_screen.dart';
import 'features/market/market_screen.dart';
import 'features/bank/bank_screen.dart';
import 'features/portfolio/portfolio_screen.dart';
import 'features/career/white_pages_screen.dart';
import 'features/socials/social_screen.dart';
import 'features/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hide status bar + navigation bar — full immersive mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ProviderScope(child: AevoraExchange()));
}

class AevoraExchange extends ConsumerWidget {
  const AevoraExchange({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Aevora Exchange',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const _AuthGate(),
    );
  }
}

/// Watches [sessionProvider]: shows [LoginScreen] when no user is logged in,
/// and [MainNavigationHub] once a username is present.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(sessionProvider);

    if (username == null) {
      return const _SessionLoader();
    }

    return MainNavigationHub(username: username);
  }
}

/// Shows a spinner while the session notifier restores from SharedPreferences.
/// After a short delay, if still null → show LoginScreen.
class _SessionLoader extends ConsumerStatefulWidget {
  const _SessionLoader();

  @override
  ConsumerState<_SessionLoader> createState() => _SessionLoaderState();
}

class _SessionLoaderState extends ConsumerState<_SessionLoader> {
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _timedOut = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final username = ref.watch(sessionProvider);
    if (username != null) return MainNavigationHub(username: username);
    if (!_timedOut) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFF00FF88))),
      );
    }
    return const LoginScreen();
  }
}

class MainNavigationHub extends ConsumerStatefulWidget {
  final String username;
  const MainNavigationHub({super.key, required this.username});

  @override
  ConsumerState<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends ConsumerState<MainNavigationHub> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final username = widget.username;

    // ── Tab screens (index matches bottom nav) ────────────────────────────────
    // 0 MARKET, 1 BANK, 2 PORTFOLIO, 3 CLASSIFIED, 4 MAILBOX, 5 PROFILE
    final screens = [
      MarketScreen(username: username),       // 0 – MARKET
      BankScreen(username: username),          // 1 – BANK
      PortfolioScreen(username: username),     // 2 – PORTFOLIO
      const WhitePagesScreen(),               // 3 – CLASSIFIED
      SocialScreen(username: username),        // 4 – MAILBOX
      ProfileScreen(username: username),       // 5 – PROFILE
    ];

    // ── AppBar titles ────────────────────────────────────────────────────────
    const titles = [
      'Market',
      'Bank',
      'Portfolio',
      'Classified',
      'Mailbox',
      'Profile',
    ];

    return TerminalScaffold(
      selectedIndex: _selectedIndex,
      title: titles[_selectedIndex],
      onTabSelected: (index) => setState(() => _selectedIndex = index),
      body: screens[_selectedIndex],
    );
  }
}
