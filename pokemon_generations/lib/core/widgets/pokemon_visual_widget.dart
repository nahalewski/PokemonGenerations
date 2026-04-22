import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../services/graphics_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PokemonVisualWidget extends ConsumerWidget {
  final int pokemonId;
  final double size;
  final bool isBack;
  final bool isShiny;

  const PokemonVisualWidget({
    super.key,
    required this.pokemonId,
    this.size = 200,
    this.isBack = false,
    this.isShiny = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(graphicsSettingsProvider);
    final path = DynamicAssetMapper.getSpritePath(pokemonId, settings, isBack: isBack, isShiny: isShiny);

    if (settings.use3DModels) {
      return SizedBox(
        width: size,
        height: size,
        child: ModelViewer(
          src: path,
          alt: "A 3D model of a Pokemon",
          autoRotate: true,
          cameraControls: false, // Make it look like a sprite, not a viewer
          backgroundColor: Colors.transparent,
          loading: Loading.lazy,
          disableZoom: true,
          disablePan: true,
        ),
      );
    }
    
    // Network URL (e.g. back sprites or GIF fallbacks) → CachedNetworkImage
    if (path.startsWith('http')) {
      return _buildNetworkSprite(path, networkFallbackUrl: isBack
          ? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png'
          : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png');
    }

    // Local asset (front sprites)
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to PokeAPI network image when local asset is missing
        final networkUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png';
        return _buildNetworkSprite(networkUrl,
            networkFallbackUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png');
      },
    );
  }

  Widget _buildNetworkSprite(String url, {String? networkFallbackUrl}) {
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorWidget: (context, error, stackTrace) {
        if (networkFallbackUrl != null && networkFallbackUrl != url) {
          return CachedNetworkImage(
            imageUrl: networkFallbackUrl,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorWidget: (c, e, s) => _buildPlaceholder(),
          );
        }
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(Icons.catching_pokemon, color: Colors.white24, size: 40),
      ),
    );
  }
}
