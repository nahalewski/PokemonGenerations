import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GraphicsProfile {
  static,
  highRes,
  animated,
  highFidelity3D,
}

class GraphicsSettings {
  final GraphicsProfile profile;
  final bool use3DModels;
  final bool useAnimatedGifs;
  final bool useHighResSprites;

  const GraphicsSettings({
    required this.profile,
    required this.use3DModels,
    required this.useAnimatedGifs,
    required this.useHighResSprites,
  });

  GraphicsSettings copyWith({
    GraphicsProfile? profile,
    bool? use3DModels,
    bool? useAnimatedGifs,
    bool? useHighResSprites,
  }) {
    return GraphicsSettings(
      profile: profile ?? this.profile,
      use3DModels: use3DModels ?? this.use3DModels,
      useAnimatedGifs: useAnimatedGifs ?? this.useAnimatedGifs,
      useHighResSprites: useHighResSprites ?? this.useHighResSprites,
    );
  }
}

final graphicsSettingsProvider = StateNotifierProvider<GraphicsSettingsNotifier, GraphicsSettings>((ref) {
  return GraphicsSettingsNotifier();
});

class GraphicsSettingsNotifier extends StateNotifier<GraphicsSettings> {
  GraphicsSettingsNotifier() : super(const GraphicsSettings(
    profile: GraphicsProfile.highRes,
    use3DModels: false,
    useAnimatedGifs: false,
    useHighResSprites: true,
  )) {
    _loadSettings();
  }

  static const _keyProfile = 'settings.graphics_profile';
  static const _key3D = 'settings.use_3d_models';
  static const _keyGifs = 'settings.use_animated_gifs';
  static const _keyHighRes = 'settings.use_high_res_sprites';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final profileName = prefs.getString(_keyProfile);
    final use3D = prefs.getBool(_key3D) ?? false;
    final useGifs = prefs.getBool(_keyGifs) ?? false;
    final useHighRes = prefs.getBool(_keyHighRes) ?? true; // Default true

    GraphicsProfile profile = GraphicsProfile.highRes;
    if (profileName != null) {
      profile = GraphicsProfile.values.firstWhere(
        (e) => e.name == profileName,
        orElse: () => GraphicsProfile.highRes,
      );
    }

    state = GraphicsSettings(
      profile: profile,
      use3DModels: use3D,
      useAnimatedGifs: useGifs,
      useHighResSprites: useHighRes,
    );
  }

  Future<void> setProfile(GraphicsProfile profile) async {
    state = state.copyWith(profile: profile);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, profile.name);
  }

  Future<void> setUse3DModels(bool value) async {
    final newState = value 
      ? state.copyWith(use3DModels: true, useAnimatedGifs: false, useHighResSprites: false)
      : state.copyWith(use3DModels: false);
    
    state = newState;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key3D, state.use3DModels);
    await prefs.setBool(_keyGifs, state.useAnimatedGifs);
    await prefs.setBool(_keyHighRes, state.useHighResSprites);
  }

  Future<void> setUseAnimatedGifs(bool value) async {
    final newState = value 
      ? state.copyWith(useAnimatedGifs: true, use3DModels: false, useHighResSprites: false)
      : state.copyWith(useAnimatedGifs: false);

    state = newState;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key3D, state.use3DModels);
    await prefs.setBool(_keyGifs, state.useAnimatedGifs);
    await prefs.setBool(_keyHighRes, state.useHighResSprites);
  }

  Future<void> setUseHighResSprites(bool value) async {
    final newState = value 
      ? state.copyWith(useHighResSprites: true, use3DModels: false, useAnimatedGifs: false)
      : state.copyWith(useHighResSprites: false);

    state = newState;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key3D, state.use3DModels);
    await prefs.setBool(_keyGifs, state.useAnimatedGifs);
    await prefs.setBool(_keyHighRes, state.useHighResSprites);
  }
}

class DynamicAssetMapper {
  static String getSpritePath(int id, GraphicsSettings settings, {bool isBack = false, bool isShiny = false}) {
    if (settings.use3DModels) {
      final type = isShiny ? 'shiny' : 'regular';
      return 'assets/community/pokemon_3d_api/models/opt/$type/$id.glb';
    }
    
    if (settings.useAnimatedGifs) {
      final smogonId = id * 32;
      final prefix = isBack ? '-b' : '';
      final shinySuffix = isShiny ? '-s' : '';
      return 'assets/community/smogon/src/models/s$smogonId$prefix$shinySuffix.gif';
    }

    // Back sprites have no local asset variants — use PokeAPI network URL
    if (isBack) {
      return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/$id.png';
    }

    if (settings.useHighResSprites) {
      final paddedId = id.toString().padLeft(3, '0');
      final shinySuffix = isShiny ? '_shiny' : '';
      return 'assets/community/pogo_assets/Images/Pokemon - 256x256/pokemon_icon_${paddedId}_00$shinySuffix.png';
    }

    // Standard static sprite
    return 'assets/community/pogo_assets/Images/Pokemon/Addressable Assets/pm$id.f.icon.png';
  }

  static String getMoveSound(String moveName) {
    // Normalize move name for cobblemon sounds folder
    final normalized = moveName.toLowerCase().replaceAll(' ', '');
    return 'assets/community/cobblemon/sounds/move/$normalized/${normalized}_target.ogg';
  }

  static String getMoveParticle(String moveType) {
    // Basic mapping of type to a representative particle texture
    final type = moveType.toLowerCase();
    switch (type) {
      case 'fire': return 'assets/community/cobblemon/particles/textures/generic/fire/flame.png';
      case 'water': return 'assets/community/cobblemon/particles/textures/generic/bubble/bubble.png';
      case 'electric': return 'assets/community/cobblemon/particles/textures/generic/electricity/electricity.png';
      case 'grass': return 'assets/community/cobblemon/particles/textures/generic/grass/leaf.png';
      default: return 'assets/community/cobblemon/particles/textures/generic/hit.png';
    }
  }
}
