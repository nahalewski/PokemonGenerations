import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pokemon_center/services/service_notifier.dart';
import 'package:pokemon_center/models/service_info.dart';
import 'package:pokemon_center/core/theme.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'widgets/service_card.dart';
import 'widgets/gift_center_tab.dart';
import 'widgets/battle_monitor_tab.dart';
import 'widgets/collection_inspector_tab.dart';
import 'widgets/news_management_tab.dart';
import 'widgets/music_s_tab.dart';
import 'widgets/update_management_tab.dart';
import 'widgets/mail_management_tab.dart';
import 'widgets/ai_functions_tab.dart';
import '../../../services/admin_tab_logger.dart';
import '../../../services/update_monitor_service.dart';
import '../admin/admin_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  static const _tabNames = <int, String>{
    0: 'stack_management',
    1: 'social_dashboard',
    2: 'gift_center',
    3: 'collection_inspector',
    4: 'battle_monitor',
    5: 'update_management',
    6: 'news_management',
    7: 'music_telemetry',
    8: 'mail_management',
    9: 'ai_operations',
  };

  @override
  void initState() {
    super.initState();
    DesktopMultiWindow.setMethodHandler(_handleWindowMethodCall);
    AdminTabLogger.log(
      'stack_management',
      'tab_opened',
      details: {'source': 'dashboard_init'},
    );
    // Automatic start on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceProvider.notifier).startAll();
    });
  }

  @override
  void dispose() {
    DesktopMultiWindow.setMethodHandler(null);
    super.dispose();
  }

  Future<dynamic> _handleWindowMethodCall(
    MethodCall call,
    int fromWindowId,
  ) async {
    if (call.method == 'console_request_snapshot') {
      return ref.read(serviceProvider.notifier).exportConsoleSnapshot();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(serviceProvider);
    final notifier = ref.read(serviceProvider.notifier);
    final bool isAllOnline = notifier.isStackOnline;
    final bool isAnyStarting = notifier.isStackBusy;

    return Scaffold(
      floatingActionButton: _buildUpdateAlert(ref),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          image: const DecorationImage(
            image: AssetImage('assets/pokemon_center_bg.png'),
            fit: BoxFit.cover,
            opacity: 0.18, // Slightly more visible for the transparent cards
          ),
        ),
        child: Row(
          children: [
            // Sidebar
            Container(
              width: 80,
              color: AppColors.surface.withOpacity(0.8),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Decorative Profile Avatar (Nurse Joy)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: const DecorationImage(
                        image: AssetImage('assets/nurse_joy.png'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildSidebarItem(
                    Icons.dashboard_rounded,
                    _selectedIndex == 0,
                    onTap: () => _selectTab(0),
                  ),
                  _buildSidebarItem(
                    Icons.admin_panel_settings_rounded,
                    _selectedIndex == 1,
                    onTap: () => _selectTab(1),
                  ),
                  _buildSidebarItem(
                    Icons.card_giftcard_rounded,
                    _selectedIndex == 2,
                    onTap: () => _selectTab(2),
                  ),
                  _buildSidebarItem(
                    Icons.person_search_rounded,
                    _selectedIndex == 3,
                    onTap: () => _selectTab(3),
                  ),
                  _buildSidebarItem(
                    Icons.security_rounded,
                    _selectedIndex == 4,
                    onTap: () => _selectTab(4),
                  ),
                  _buildSidebarItem(
                    Icons.system_update_alt,
                    _selectedIndex == 5,
                    onTap: () => _selectTab(5),
                  ),
                  _buildSidebarItem(
                    Icons.newspaper_rounded,
                    _selectedIndex == 6,
                    onTap: () => _selectTab(6),
                  ),
                  _buildSidebarItem(
                    Icons.music_note_rounded,
                    _selectedIndex == 7,
                    onTap: () => _selectTab(7),
                  ),
                  _buildSidebarItem(
                    Icons.mail_rounded,
                    _selectedIndex == 8,
                    onTap: () => _selectTab(8),
                  ),
                  _buildSidebarItem(
                    Icons.smart_toy_rounded,
                    _selectedIndex == 9,
                    onTap: () => _selectTab(9),
                  ),
                  const Spacer(),
                  _buildSidebarItem(
                    Icons.power_settings_new_rounded,
                    false,
                    color: Colors.redAccent,
                    onTap: () {
                      AdminTabLogger.log(
                        'stack_management',
                        'kill_all_requested',
                      );
                      ref.read(serviceProvider.notifier).killAll();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildServiceDashboard(
                    context,
                    services,
                    isAllOnline,
                    isAnyStarting,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: SocialAdminScreen(),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: GiftCenterTab(),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: CollectionInspectorTab(),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: BattleMonitorTab(),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: UpdateManagementTab(),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: NewsManagementTab(),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: MusicSTab(),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: MailManagementTab(),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: AiFunctionsTab(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
    AdminTabLogger.log(
      _tabNames[index] ?? 'unknown_tab',
      'tab_opened',
      details: {'index': index},
    );
  }

  Widget _buildServiceDashboard(
    BuildContext context,
    List<ServiceInfo> services,
    bool isAllOnline,
    bool isAnyStarting,
  ) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POKEMON CENTER',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stack Management & Service Monitoring',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.textDim),
                  ),
                ],
              ),
              const Spacer(),

              // Global Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Text(
                      isAllOnline
                          ? 'STACK ONLINE'
                          : (isAnyStarting ? 'STARTING...' : 'STACK OFFLINE'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isAllOnline
                            ? AppColors.success
                            : (isAnyStarting
                                  ? AppColors.warning
                                  : AppColors.textDim),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Switch(
                      value: isAllOnline || isAnyStarting,
                      onChanged: isAnyStarting
                          ? null
                          : (val) {
                              if (val) {
                                ref.read(serviceProvider.notifier).startAll();
                              } else {
                                ref.read(serviceProvider.notifier).killAll();
                              }
                            },
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    // Pop-out Terminal Trigger
                    IconButton(
                      onPressed: () async {
                        final window = await DesktopMultiWindow.createWindow(
                          jsonEncode({'args1': 'console'}),
                        );
                        window
                          ..setFrame(
                            const Offset(80, 80) & const Size(1100, 720),
                          )
                          ..center()
                          ..setTitle('SYSTEM CONSOLE')
                          ..show();
                      },
                      icon: const Icon(Icons.terminal_rounded),
                      tooltip: 'Launch Pop-out Console',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Service Grid (5x3)
          Expanded(
            child: GridView.count(
              crossAxisCount: 5,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.9,
              children: services.map((s) => ServiceCard(service: s)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildUpdateAlert(WidgetRef ref) {
    final statusAsync = ref.watch(updateStatusProvider);

    return statusAsync.maybeWhen(
      data: (status) {
        if (status.totalUpdates == 0) return null;

        return FloatingActionButton.extended(
          onPressed: () =>
              setState(() => _selectedIndex = 5), // Switch to Update tab
          backgroundColor: AppColors.primary,
          elevation: 8,
          icon: const Icon(Icons.system_update_alt, color: Colors.white),
          label: Text(
            '${status.totalUpdates} UPDATES PENDING',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds);
      },
      orElse: () => null,
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    bool active, {
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: active ? AppColors.primary : (color ?? AppColors.textDim),
          size: 24,
        ),
      ),
    );
  }
}
