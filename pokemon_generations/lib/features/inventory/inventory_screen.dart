import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/providers.dart';
import '../inventory/inventory_provider.dart';
import '../../core/constants/item_registry.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final ownedItems = inventory.entries.where((e) => e.value > 0).toList();

    final filteredItems = ownedItems.where((entry) {
      final item = pokemonItemRegistry.firstWhere(
        (i) => i.id == entry.key,
        orElse: () => MasterItem(id: entry.key, name: entry.key, description: '', category: 'Other', color: Colors.grey, icon: Icons.help_outline),
      );
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text('BAG INVENTORY', style: AppTypography.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildSearchBar(),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? _buildEmptyState()
                : _buildItemGrid(filteredItems),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: TextStyle(color: AppColors.outline.withValues(alpha: 0.5)),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Your bag is empty.' : 'No items found matching "$_searchQuery"',
            style: TextStyle(color: AppColors.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid(List<MapEntry<String, int>> items) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final entry = items[index];
        final item = pokemonItemRegistry.firstWhere(
          (i) => i.id == entry.key,
          orElse: () => MasterItem(id: entry.key, name: entry.key, description: '', category: 'Other', color: Colors.grey, icon: Icons.help_outline),
        );

        return _buildItemCard(item, entry.value);
      },
    );
  }

  Widget _buildItemCard(MasterItem item, int count) {
    final color = item.color ?? Colors.grey;
    return GestureDetector(
      onTap: () => _showItemActions(item),
      child: Column(
        children: [
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              color: color.withValues(alpha: 0.05),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (item.spritePath != null && item.spritePath!.isNotEmpty)
                    Image.asset(item.spritePath!, scale: 0.8)
                  else
                    Icon(item.icon ?? Icons.help_outline, color: color, size: 32),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'x$count',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showItemActions(MasterItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (item.spritePath != null && item.spritePath!.isNotEmpty)
                  Image.asset(item.spritePath!, width: 40)
                else
                  Icon(item.icon ?? Icons.help_outline, color: item.color, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name.toUpperCase(), style: AppTypography.headlineSmall),
                      Text(item.category, style: TextStyle(color: item.color, fontSize: 10, letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(item.description, style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
            const SizedBox(height: 24),
            _buildActionButton(
              'USE ITEM',
              Icons.bolt,
              AppColors.primary,
              () {
                ref.read(inventoryProvider.notifier).useItem(item.id);
                context.pop();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'GIFT',
                    Icons.card_giftcard,
                    Colors.purpleAccent,
                    () => context.pushReplacement('/gift'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'SELL',
                    Icons.attach_money,
                    Colors.amber,
                    () {
                      // Logic for selling (will integrate with currency system later)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item sold for 100 Poké Dollars!')),
                      );
                      ref.read(inventoryProvider.notifier).useItem(item.id);
                      context.pop();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.outline)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
      ),
    );
  }
}
