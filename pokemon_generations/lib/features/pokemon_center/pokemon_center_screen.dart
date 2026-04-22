import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/futuristic_ui_utils.dart';
import '../social/social_controller.dart';
import '../../domain/models/social.dart';

class PokemonCenterScreen extends ConsumerStatefulWidget {
  const PokemonCenterScreen({super.key});

  @override
  ConsumerState<PokemonCenterScreen> createState() => _PokemonCenterScreenState();
}

class _PokemonCenterScreenState extends ConsumerState<PokemonCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Technical Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/battle/battle_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                
                // Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      dividerColor: Colors.transparent,
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.outline,
                      labelStyle: AppTypography.labelLarge.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: 'MEDICAL DIAGNOSTIC'),
                        Tab(text: 'MusicS TELEMETRY'),
                      ],
                    ),
                  ),
                ),
                
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMedicalTab(),
                      _buildMusicSTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.emergency_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text('POKÉMON CENTER / CORE HUB', style: AppTypography.labelLarge.copyWith(letterSpacing: 2)),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VITAL SIGNS',
                      style: AppTypography.displaySmall.copyWith(fontSize: 32),
                    ),
                    const Text(
                      'REAL-TIME BIOMETRICS // TERMINAL 01',
                      style: TextStyle(letterSpacing: 2, fontSize: 10, color: AppColors.outline),
                    ),
                    const SizedBox(height: 24),
                    FuturisticGlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const DiagnosticGauge(
                            label: 'Party Integrity',
                            value: 0.94,
                            secondaryLabel: '94%',
                          ),
                          const SizedBox(height: 24),
                          _buildAlertTile('Arcanine: Paralyzed', AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROCEDURES', style: AppTypography.headlineSmall),
                    const SizedBox(height: 16),
                    _buildProcedureCard('FULL HEAL PROTOCOL', 'Restore all party members to maximum health and status.', Icons.healing),
                    const SizedBox(height: 12),
                    _buildProcedureCard('ENERGY INJECTION', 'Restore all PP for selected move sets.', Icons.bolt),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMusicSTab() {
    final socialState = ref.watch(socialControllerProvider);
    final activeUsers = socialState.users.where((u) => u.status == 'online').toList();
    
    // Mock songs for telemetry flavor
    final mockSongs = [
      'Battle! Champion Cynthia',
      'Route 201 (Day)',
      'Eterna Forest',
      'Lake Theme',
      'Mt. Coronet',
      'Canalave City',
      'Underground Theme',
      'Wild Battle (Sinnoh)',
      'Jubilife City',
      'Oreburgh City',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Stats
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SERVER STATUS', style: AppTypography.displaySmall.copyWith(fontSize: 32)),
                    const Text('MusicS TELEMETRY // DATA FEED', style: TextStyle(letterSpacing: 2, fontSize: 10, color: AppColors.secondary)),
                    const SizedBox(height: 24),
                    
                    // Stats Row
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('LIVE LISTENERS', '${activeUsers.length + 8}', Icons.sensors, AppColors.primary)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('TRAFFIC LOAD', '2.4 GB/s', Icons.speed, AppColors.secondary)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('UPTIME', '99.9%', Icons.check_circle_outline, AppColors.tertiary)),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('GLOBAL STATISTICS', style: AppTypography.headlineSmall),
                        Text('UPDATED 1M AGO', style: TextStyle(color: AppColors.outline, fontSize: 8, letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTopSongTile('01', 'Cynthia\'s Battle Theme', 'Sinnoh League', '4,281 Hits'),
                    _buildTopSongTile('02', 'Lumiose City (Remastered)', 'Kalos High-Res', '3,912 Hits'),
                    _buildTopSongTile('03', 'Rocker Theme (Techno Mix)', 'Alola Remixes', '2,105 Hits'),
                    _buildTopSongTile('04', 'Wild Area Battle', 'Galar Wilds', '1,822 Hits'),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Side Panel: Most Active Users
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ACTIVE USERS', style: AppTypography.headlineSmall),
                    const SizedBox(height: 16),
                    FuturisticGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: activeUsers.isEmpty 
                          ? [const Padding(padding: EdgeInsets.all(16), child: Text('NO USERS ACTIVE', style: TextStyle(color: AppColors.outline, fontSize: 10)))]
                          : activeUsers.map((user) {
                              final songIndex = user.username.length % mockSongs.length;
                              return _buildUserListeningTile(user.displayName, 'Listening: ${mockSongs[songIndex]}');
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.secondary, size: 14),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Telemetrics are synced every 30s across the Generations network.',
                              style: TextStyle(color: AppColors.outline, fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return FuturisticGlassCard(
      borderColor: color.withOpacity(0.3),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTypography.displaySmall.copyWith(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildTopSongTile(String rank, String title, String album, String plays) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Text(rank, style: TextStyle(color: AppColors.primary.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'monospace')),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                Text(album, style: const TextStyle(color: AppColors.outline, fontSize: 10)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(plays, style: const TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (int.parse(rank) * 100).ms).slideX(begin: 0.1);
  }

  Widget _buildUserListeningTile(String username, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
          ).animate(onPlay: (controller) => controller.repeat()).scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(1.5, 1.5)).then().scale(duration: 1.seconds),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(status, style: const TextStyle(color: AppColors.outline, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcedureCard(String title, String desc, IconData icon) {
    return FuturisticGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text(desc, style: const TextStyle(color: AppColors.outline, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            child: const Text('EXECUTE'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 16),
          const SizedBox(width: 12),
          Text(
            text.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
