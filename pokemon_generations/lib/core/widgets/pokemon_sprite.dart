import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../settings/app_settings_controller.dart';

class PokemonSprite extends ConsumerWidget {
  final String pokemonId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;

  const PokemonSprite({
    super.key,
    required this.pokemonId,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backendImageUrl =
        '${ref.watch(backendBaseUrlProvider)}/pokemon-images/$pokemonId.png';
    final officialArtworkUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png';
    final fallbackSpriteUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png';
    final shinySpriteUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/$pokemonId.png';

    return SizedBox(
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: backendImageUrl,
        width: width,
        height: height,
        fit: fit,
        color: color,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, err) {
          // If backend fails, try network official artwork
          return CachedNetworkImage(
            imageUrl: officialArtworkUrl,
            width: width,
            height: height,
            fit: fit,
            color: color,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            errorWidget: (context, url, err2) {
              // If official artwork fails, try standard sprite
              return CachedNetworkImage(
                imageUrl: fallbackSpriteUrl,
                width: width,
                height: height,
                fit: fit,
                color: color,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, err3) {
                  // try shiny sprite
                  return CachedNetworkImage(
                    imageUrl: shinySpriteUrl,
                    width: width,
                    height: height,
                    fit: fit,
                    color: color,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, err4) => Icon(
                      Icons.catching_pokemon,
                      size: (width ?? 24) * 0.8,
                      color: AppColors.outline.withValues(alpha: 0.3),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
