import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/futuristic_ui_utils.dart';
import '../../core/widgets/pokemon_sprite.dart';
import '../../data/services/api_client.dart';
import '../../domain/models/pokemon.dart';
import '../../core/widgets/stat_radar_chart.dart';

class PokedexDetailScreen extends ConsumerStatefulWidget {
  final String pokemonId;

  const PokedexDetailScreen({super.key, required this.pokemonId});

  @override
  ConsumerState<PokedexDetailScreen> createState() => _PokedexDetailScreenState();
}

class _PokedexDetailScreenState extends ConsumerState<PokedexDetailScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isPlayingCry = false;
  Future<Pokemon?>? _pokemonFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _tabController = TabController(length: 2, vsync: this);
    _pokemonFuture = ref.read(apiClientProvider.notifier).getPokemonDetail(widget.pokemonId);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _playCry(String? url) async {
    if (url == null || _isPlayingCry) return;
    setState(() => _isPlayingCry = true);
    try {
      await _audioPlayer.play(UrlSource(url));
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Error playing cry: $e');
    } finally {
      if (mounted) setState(() => _isPlayingCry = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FutureBuilder<Pokemon?>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorState();
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text('INITIALIZING TELEMETRY...', style: AppTypography.labelSmall.copyWith(letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 64),
          const SizedBox(height: 24),
          Text('CONNECTION TIMEOUT', style: AppTypography.headlineSmall.copyWith(color: AppColors.error)),
          const SizedBox(height: 8),
          TextButton(onPressed: () => context.pop(), child: const Text('RETURN TO BASE')),
        ],
      ),
    );
  }

  Widget _buildContent(Pokemon pokemon) {
    return Stack(
      children: [
        // Background glow
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _buildHeader(pokemon),
              ),
              const SizedBox(height: 32),
              // Sprite + side info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildVisualizerSection(pokemon),
              ),
              const SizedBox(height: 20),
              // Tab bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTypography.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white38,
                    tabs: const [
                      Tab(text: 'OVERVIEW'),
                      Tab(text: 'TCG CARDS'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(pokemon),
                    _buildTcgTab(pokemon),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Pokemon pokemon) {
    final rawId = pokemon.id;
    final numericId = int.tryParse(rawId);
    final displayId = numericId != null ? '#${numericId.toString().padLeft(3, '0')}' : '#${rawId.toUpperCase()}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayId,
                    style: AppTypography.labelLarge.copyWith(color: AppColors.primary, letterSpacing: 4)),
                Text(pokemon.name.toUpperCase(),
                    style: AppTypography.displayLarge.copyWith(height: 1)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVisualizerSection(Pokemon pokemon) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Center(
            child: Hero(
              tag: 'pokedex_${pokemon.id}',
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1),
                    ),
                  ).animate(onPlay: (c) => c.repeat()).rotate(duration: 10.seconds),
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.05), width: 4),
                    ),
                  ).animate(onPlay: (c) => c.repeat()).rotate(duration: 15.seconds, begin: 1, end: 0),
                  PokemonSprite(pokemonId: pokemon.id, width: 160, height: 160),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.primary, Colors.transparent],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                        .moveY(begin: -120, end: 120, duration: 3.seconds, curve: Curves.easeInOut)
                        .fadeOut(),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildControlTile(
                icon: Icons.volume_up,
                label: 'PLAY CRY',
                onTap: () => _playCry(pokemon.bestCryUrl),
                isLoading: _isPlayingCry,
              ),
              const SizedBox(height: 12),
              _buildTypeBadges(pokemon),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: FuturisticGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        borderColor: AppColors.primary.withValues(alpha: 0.3),
        child: Column(
          children: [
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
              )
            else
              Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(label,
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary, fontSize: 10, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadges(Pokemon pokemon) {
    return Column(
      children: pokemon.types.map((type) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
          ),
          child: Center(
            child: Text(type.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
      )).toList(),
    );
  }

  // ── Overview tab ──────────────────────────────────────────────────────────

  Widget _buildOverviewTab(Pokemon pokemon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDescriptionSection(pokemon),
          const SizedBox(height: 40),
          _buildStatsSection(pokemon),
          const SizedBox(height: 40),
          _buildMetadataSection(pokemon),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Pokemon pokemon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('BIOLOGICAL OVERVIEW'),
        const SizedBox(height: 16),
        Text(
          pokemon.description ?? 'NO DATA AVAILABLE IN REGISTRY.',
          style: TextStyle(
            color: AppColors.onSurface.withValues(alpha: 0.8),
            fontSize: 16,
            height: 1.6,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(Pokemon pokemon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('TELEMETRY STATUS'),
        const SizedBox(height: 24),
        Center(
          child: StatRadarChart(
            stats: pokemon.baseStats,
            maxValue: 255,
            size: 220,
          ),
        ),
        const SizedBox(height: 24),
        _buildStatGauge('HP',  pokemon.baseStats['hp']  ?? 0),
        const SizedBox(height: 16),
        _buildStatGauge('ATK', pokemon.baseStats['atk'] ?? 0),
        const SizedBox(height: 16),
        _buildStatGauge('DEF', pokemon.baseStats['def'] ?? 0),
        const SizedBox(height: 16),
        _buildStatGauge('SPA', pokemon.baseStats['spa'] ?? 0),
        const SizedBox(height: 16),
        _buildStatGauge('SPD', pokemon.baseStats['spd'] ?? 0),
        const SizedBox(height: 16),
        _buildStatGauge('SPE', pokemon.baseStats['spe'] ?? 0),
      ],
    );
  }

  Widget _buildStatGauge(String label, int value) {
    return DiagnosticGauge(
      label: label,
      value: value / 255.0,
      secondaryLabel: value.toString(),
      color: _getStatColor(label),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1);
  }

  Color _getStatColor(String label) {
    switch (label) {
      case 'HP':  return Colors.green;
      case 'ATK': return Colors.red;
      case 'DEF': return Colors.blue;
      case 'SPA': return Colors.orange;
      case 'SPD': return Colors.purple;
      case 'SPE': return Colors.cyan;
      default:    return AppColors.primary;
    }
  }

  Widget _buildMetadataSection(Pokemon pokemon) {
    if (pokemon.abilities.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ADDITIONAL DATA'),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: pokemon.abilities.map((a) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(a.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
          )).toList(),
        ),
      ],
    );
  }

  // ── TCG Cards tab ─────────────────────────────────────────────────────────

  Widget _buildTcgTab(Pokemon pokemon) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(apiClientProvider.notifier).getTcgCards(pokemon.name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final cards = snapshot.data ?? [];

        if (cards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.style_outlined, color: Colors.white24, size: 48),
                const SizedBox(height: 16),
                Text('NO CARDS IN DATABASE',
                    style: AppTypography.labelSmall.copyWith(color: Colors.white38, letterSpacing: 2)),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Text(
                '${cards.length} CARDS FOUND',
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary, fontSize: 10, letterSpacing: 2),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: cards.length,
                itemBuilder: (context, i) => _buildTcgCard(cards[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTcgCard(Map<String, dynamic> card) {
    final smallUrl = card['images']?['small'] as String?;
    final largeUrl = card['images']?['large'] as String?;
    final cardName = card['name'] as String? ?? '';
    final setName = card['set']?['name'] as String? ?? '';

    return GestureDetector(
      onTap: () => _showCardLightbox(largeUrl ?? smallUrl ?? '', cardName, setName),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: smallUrl != null
                    ? CachedNetworkImage(
                        imageUrl: smallUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          debugPrint('[TCG] Image Load Error: $error | URL: $url');
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.broken_image_outlined, color: Colors.white24, size: 24),
                          );
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image_not_supported_outlined, color: Colors.white24),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            cardName.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            setName,
            style: const TextStyle(color: AppColors.outline, fontSize: 8, letterSpacing: 0.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCardLightbox(String imageUrl, String cardName, String setName) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Hero(
                  tag: 'card_lightbox_$imageUrl',
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Container(
                          height: 400,
                          width: 300,
                          color: Colors.black26,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                              const SizedBox(height: 20),
                              Text('LOADING HI-RES DATA...', 
                                style: AppTypography.labelSmall.copyWith(color: AppColors.primary, letterSpacing: 1.5)),
                            ],
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          padding: const EdgeInsets.all(40),
                          color: Colors.black45,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                              SizedBox(height: 16),
                              Text('FAIL TO LOAD HI-RES IMAGE', style: TextStyle(color: Colors.white54, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cardName.toUpperCase(),
                      style: AppTypography.headlineSmall.copyWith(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      setName,
                      style: AppTypography.labelMedium.copyWith(color: AppColors.primary, letterSpacing: 1),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'TAP ANYWHERE TO DISMISS',
                style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 3, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(title, style: AppTypography.labelLarge.copyWith(letterSpacing: 2)),
      ],
    );
  }
}
