import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/auth_controller.dart';

class HomeSidebar extends ConsumerStatefulWidget {
  const HomeSidebar({super.key});

  @override
  ConsumerState<HomeSidebar> createState() => _HomeSidebarState();
}

class _HomeSidebarState extends ConsumerState<HomeSidebar> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final userProfile = ref.watch(authControllerProvider).profile;
    final pcName = '${(userProfile?.username ?? "TRAINER").toUpperCase()} PC';

    return MouseRegion(
      onEnter: (_) => setState(() => _isExpanded = true),
      onExit: (_) => setState(() => _isExpanded = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isExpanded ? 200 : 70,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Icon
            Icon(Icons.catching_pokemon, color: AppTheme.neonBlue, size: 32),
            const SizedBox(height: 40),
            
            _SidebarItem(
              icon: Icons.home_rounded,
              label: 'HOME',
              isSelected: currentPath == '/',
              isExpanded: _isExpanded,
              onTap: () => context.go('/'),
            ),
            _SidebarItem(
              icon: Icons.psychology_rounded,
              label: 'BATTLE CPU',
              isSelected: currentPath.startsWith('/battle/cpu'),
              isExpanded: _isExpanded,
              onTap: () => context.push('/battle/cpu'),
            ),
            _SidebarItem(
              icon: Icons.fort_rounded,
              label: 'BATTLE TOWER',
              isSelected: currentPath.startsWith('/battle-tower'),
              isExpanded: _isExpanded,
              onTap: () => context.push('/battle-tower'),
            ),
            _SidebarItem(
              icon: Icons.library_books_rounded,
              label: 'POKEDEX',
              isSelected: currentPath.startsWith('/pokedex'),
              isExpanded: _isExpanded,
              onTap: () => context.push('/pokedex'),
            ),
            _SidebarItem(
              icon: Icons.catching_pokemon_outlined,
              label: pcName,
              isSelected: currentPath.startsWith('/roster'),
              isExpanded: _isExpanded,
              onTap: () => context.push('/roster'),
            ),
            _SidebarItem(
              icon: Icons.analytics_rounded,
              label: 'ANALYTICS',
              isSelected: currentPath.startsWith('/analysis'),
              isExpanded: _isExpanded,
              onTap: () => context.push('/analysis'),
            ),
            _SidebarItem(
              icon: Icons.public_rounded,
              label: 'SOCIAL',
              isSelected: currentPath.startsWith('/social'),
              isExpanded: _isExpanded,
              onTap: () => context.push('/social'),
            ),
             _SidebarItem(
              icon: Icons.card_giftcard_rounded,
              label: 'GIFT ITEMS',
              isSelected: currentPath.startsWith('/gift'),
              isExpanded: _isExpanded,
              onTap: () => context.push('/gift'),
            ),
            _SidebarItem(
              icon: Icons.shopping_cart_rounded,
              label: 'POKE MART',
              isSelected: currentPath.startsWith('/mart'),
              isExpanded: _isExpanded,
              onTap: () => context.push('/mart'),
            ),
            _SidebarItem(
              icon: Icons.medical_services_rounded,
              label: 'POKEMON CENTER',
              isSelected: currentPath.startsWith('/center'),
              isExpanded: _isExpanded,
              onTap: () => context.push('/center'),
            ),
            _SidebarItem(
              icon: Icons.map_rounded,
              label: 'STORY MODE',
              isSelected: currentPath.startsWith('/story-mode'),
              isExpanded: _isExpanded,
              onTap: () => context.push('/story-mode'),
            ),
            
            const Spacer(),
            
            _SidebarItem(
              icon: Icons.settings_rounded,
              label: 'SETTINGS',
              isSelected: currentPath.startsWith('/settings'),
              isExpanded: _isExpanded,
              onTap: () => context.push('/settings'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.neonBlue : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 20),
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white38,
              size: 24,
            ),
            if (isExpanded) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
