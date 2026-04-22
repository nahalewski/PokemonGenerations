import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/audio_source_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../core/settings/visual_mode.dart';
import '../../core/services/global_audio_controller.dart';
import '../../data/services/api_client.dart';
import '../auth/auth_controller.dart';
import 'widgets/pokeball_visualizer.dart';

class MusicPlayerScreen extends ConsumerStatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  ConsumerState<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends ConsumerState<MusicPlayerScreen> with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  late final AnimationController _pulseController;
  late final AnimationController _rotationController;
  Timer? _ballThemeTimer;
  PokeballTheme _ballTheme = PokeballTheme.poke;
  
  Map<String, List<dynamic>> _library = {};
  String? _selectedAlbum;
  bool _showPlayer = false;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  List<dynamic> get _currentTracks => _selectedAlbum != null ? _library[_selectedAlbum] ?? [] : [];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    // Timer to cycle pokeball themes
    _ballThemeTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) {
        setState(() {
          final nextIndex = (_ballTheme.index + 1) % PokeballTheme.values.length;
          _ballTheme = PokeballTheme.values[nextIndex];
        });
      }
    });

    Future.microtask(() => ref.read(globalAudioControllerProvider).stopMenuMusic());
    _setupListeners();
    _fetchLibrary();
  }

  void _setupListeners() {
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (_isPlaying) {
            _pulseController.repeat(reverse: true);
            _rotationController.repeat();
          } else {
            _pulseController.stop();
            _rotationController.stop();
          }
        });
      }
    });
    _player.onPlayerComplete.listen((_) => _next());
  }

  Future<void> _fetchLibrary() async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    final lib = await ref.read(apiClientProvider.notifier).fetchOstLibrary(baseUrl);
    
    if (mounted) {
      setState(() {
        _library = lib;
        _isLoading = false;
      });

      // Pre-fetch album art for smoother scrolling
      for (final album in lib.keys) {
        final url = ref.read(audioSourceServiceProvider).getAlbumArtUrl(album);
        precacheImage(CachedNetworkImageProvider(url), context);
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _ballThemeTimer?.cancel();
    Future.microtask(() => ref.read(globalAudioControllerProvider).playMenuMusic());
    _reportStatus(isPlaying: false);
    super.dispose();
  }

  void _reportStatus({required bool isPlaying}) {
    final profile = ref.read(authControllerProvider).profile;
    if (profile == null || _selectedAlbum == null) return;
    
    final track = _currentTracks.isNotEmpty ? _currentTracks[_currentIndex] : null;
    if (track == null) return;

    final baseUrl = ref.read(backendBaseUrlProvider);
    ref.read(apiClientProvider.notifier).updateMusicStatus(
      baseUrl: baseUrl,
      username: profile.username,
      song: track['title'] ?? 'Unknown',
      album: _selectedAlbum!,
      isPlaying: isPlaying,
    );
  }

  Future<void> _play(int index) async {
    if (_currentTracks.isEmpty) return;
    
    await _player.stop();
    setState(() {
      _currentIndex = index;
      _isPlaying = true;
      _showPlayer = true;
    });
    
    final track = _currentTracks[index];
    final source = ref.read(audioSourceServiceProvider).resolveOstTrack(_selectedAlbum!, track['filename']);
    await _player.play(source);
    _reportStatus(isPlaying: true);
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_position == Duration.zero) {
        await _play(_currentIndex);
      } else {
        await _player.resume();
      }
    }
    _reportStatus(isPlaying: _isPlaying);
  }

  Future<void> _next() async {
    if (_currentTracks.isEmpty) return;
    final nextIndex = (_currentIndex + 1) % _currentTracks.length;
    await _play(nextIndex);
  }

  Future<void> _previous() async {
    if (_currentTracks.isEmpty) return;
    final prevIndex = (_currentIndex - 1 + _currentTracks.length) % _currentTracks.length;
    await _play(prevIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/battle/battle_bg.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
            colorFilter: ColorFilter.mode(
              AppColors.primary.withOpacity(0.1),
              BlendMode.srcATop,
            ),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _showPlayer && _selectedAlbum != null
                      ? _buildPlayerView()
                      : _buildAlbumGridView(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: Icon(_showPlayer ? Icons.grid_view_rounded : Icons.arrow_back_ios_new, color: Colors.white, size: 24),
              onPressed: () {
                if (_showPlayer) {
                  setState(() => _showPlayer = false);
                } else {
                  context.pop();
                }
              },
            ),
            const SizedBox(width: 8),
            Text(_showPlayer ? _selectedAlbum!.toUpperCase() : 'POKEMON SOUNDTRACKS', style: AppTypography.headlineSmall.copyWith(fontSize: 16, letterSpacing: 1.5)),
            const Spacer(),
            if (_showPlayer)
              IconButton(
                icon: const Icon(Icons.settings_suggest, color: AppColors.primary),
                onPressed: _showVisualizerSettings,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumGridView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 1200 ? 8 : (width > 800 ? 5 : 3);
        final double spacing = width > 800 ? 24 : 16;

        return GridView.builder(
          padding: EdgeInsets.all(spacing),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 0.85,
          ),
          itemCount: _library.keys.length,
          itemBuilder: (context, index) {
            final album = _library.keys.elementAt(index);
            final artUrl = ref.read(audioSourceServiceProvider).getAlbumArtUrl(album);
            
            return GestureDetector(
              onTap: () => setState(() {
                _selectedAlbum = album;
                _showPlayer = true;
                _currentIndex = 0;
              }),
              child: Hero(
                tag: 'album_$album',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(4, 4)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: artUrl,
                          fit: BoxFit.cover,
                          memCacheHeight: 400,
                          memCacheWidth: 400,
                          placeholder: (_, __) => Container(
                            color: Colors.white.withOpacity(0.05),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 1)),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.white.withOpacity(0.05),
                            child: const Icon(Icons.music_note, color: Colors.white30, size: 40),
                          ),
                        ),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                              ),
                            ),
                            child: Text(
                              album,
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlayerView() {
    final settings = ref.watch(appSettingsProvider);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildVisualizer(settings),
          const SizedBox(height: 40),
          _buildTrackInfo(),
          const SizedBox(height: 20),
          _buildProgressBar(),
          const SizedBox(height: 20),
          _buildControls(),
          const SizedBox(height: 48),
          _buildTrackList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildVisualizer(dynamic settings) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController]),
      builder: (context, _) {
        final double pulse = _isPlaying ? 1.0 + (_pulseController.value * 0.05) : 1.0;
        
        switch (settings.visualMode) {
          case PlayerVisualMode.vinyl:
          case PlayerVisualMode.pokeBallRecord:
          case PlayerVisualMode.pokeballSynthwave:
            final recordAsset = settings.visualMode == PlayerVisualMode.pokeballSynthwave
                ? 'assets/music/synthwave_masterball_record.png'
                : (settings.visualMode == PlayerVisualMode.pokeBallRecord
                    ? 'assets/icon/pokeball_record.png'
                    : 'assets/icon/vinyl_record.png');
            return Transform.scale(
              scale: pulse,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220, height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: settings.visualMode == PlayerVisualMode.pokeballSynthwave 
                            ? Colors.purpleAccent.withOpacity(0.3)
                            : AppColors.primary.withOpacity(0.15),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _rotationController,
                    child: Image.asset(recordAsset, width: 280, height: 280, fit: BoxFit.contain),
                  ),
                  // Center hole/reflection
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildTrackInfo() {
    if (_currentTracks.isEmpty) return const SizedBox.shrink();
    final track = _currentTracks[_currentIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            track['title'],
            style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(_selectedAlbum!, style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.outlineVariant,
              thumbColor: AppColors.primary,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: _position.inMilliseconds.toDouble(),
              max: max(1.0, _duration.inMilliseconds.toDouble()),
              onChanged: (value) async {
                await _player.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_position), style: AppTypography.labelSmall),
              Text(_formatDuration(_duration), style: AppTypography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.skip_previous_rounded, size: 48, color: Colors.white), onPressed: _previous),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 70, height: 70,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 42, color: Colors.white),
          ),
        ),
        const SizedBox(width: 24),
        IconButton(icon: const Icon(Icons.skip_next_rounded, size: 48, color: Colors.white), onPressed: _next),
      ],
    );
  }

  Widget _buildTrackList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text('ALBUM TRACKS', style: AppTypography.labelLarge.copyWith(letterSpacing: 2)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _currentTracks.length,
          itemBuilder: (context, index) {
            final track = _currentTracks[index];
            final isCurrent = _currentIndex == index;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              tileColor: isCurrent ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
              leading: Text('${index + 1}'.padLeft(2, '0'), style: TextStyle(color: isCurrent ? AppColors.primary : AppColors.outline, fontWeight: FontWeight.bold)),
              title: Text(track['title'], style: TextStyle(color: isCurrent ? Colors.white : Colors.white70, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
              trailing: isCurrent && _isPlaying
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : null,
              onTap: () => _play(index),
            );
          },
        ),
      ],
    );
  }

  void _showVisualizerSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final currentMode = ref.watch(appSettingsProvider).visualMode;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('PLAYER VISUALS', style: AppTypography.headlineSmall.copyWith(fontSize: 14)),
                const SizedBox(height: 24),
                ...PlayerVisualMode.values.map((mode) => ListTile(
                  title: Text(mode.displayName, style: TextStyle(color: currentMode == mode ? AppColors.primary : Colors.white)),
                  trailing: currentMode == mode ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                  onTap: () {
                    ref.read(appSettingsProvider.notifier).setVisualMode(mode);
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero) return '0:00';
    String minutes = d.inMinutes.toString();
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
