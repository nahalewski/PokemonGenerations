import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/app_settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/services/api_client.dart';
import '../../domain/models/gift.dart';
import '../../domain/models/social.dart';
import '../auth/auth_controller.dart';
import '../inventory/inventory_provider.dart';
import '../social/social_controller.dart';

import '../../core/constants/item_registry.dart';

MasterItem? _findItem(String id) {
  try {
    return pokemonItemRegistry.firstWhere((i) => i.id == id);
  } catch (_) {
    return null;
  }
}

class GiftScreen extends ConsumerStatefulWidget {
  const GiftScreen({super.key});

  @override
  ConsumerState<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends ConsumerState<GiftScreen>
    with SingleTickerProviderStateMixin {
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text('GIFT ITEMS', style: AppTypography.headlineSmall),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'SEND GIFT'),
            Tab(text: 'INBOX'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.outline,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000), // Increased for row layout
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(), // Prevent accidental swipes
            controller: _tabController,
            children: const [
              _SendGiftTab(),
              _InboxTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Send Gift Tab ────────────────────────────────────────────────────────────

class _SendGiftTab extends ConsumerStatefulWidget {
  const _SendGiftTab();

  @override
  ConsumerState<_SendGiftTab> createState() => _SendGiftTabState();
}

class _SendGiftTabState extends ConsumerState<_SendGiftTab> {
  SocialUser? _selectedRecipient;
  String? _selectedItemId;
  int _quantity = 1;
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendGift() async {
    final profile = ref.read(authControllerProvider).profile;
    if (profile == null || _selectedRecipient == null || _selectedItemId == null) return;

    final inventory = ref.read(inventoryProvider);
    final available = inventory[_selectedItemId!] ?? 0;
    if (available < _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough items in your inventory.')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      for (var i = 0; i < _quantity; i++) {
        await ref.read(inventoryProvider.notifier).useItem(_selectedItemId!);
      }

      final success = await ref.read(socialControllerProvider.notifier).sendGift(
        recipientUsername: _selectedRecipient!.username,
        itemId: _selectedItemId!,
        quantity: _quantity,
        message: _messageController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gift sent to ${_selectedRecipient!.displayName}!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedRecipient = null;
          _selectedItemId = null;
          _quantity = 1;
          _messageController.clear();
        });
      } else {
        await ref.read(inventoryProvider.notifier).addItem(_selectedItemId!, _quantity);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send gift — server unreachable. Items returned.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final socialState = ref.watch(socialControllerProvider);
    final inventory = ref.watch(inventoryProvider);
    final profile = ref.watch(authControllerProvider).profile;

    final otherUsers = socialState.users
        .where((u) => u.username != profile?.username)
        .toList();

    final ownedItems = inventory.entries
        .where((e) => e.value > 0)
        .toList();

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. CHOOSE RECIPIENT', style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: ListView.separated(
                          itemCount: otherUsers.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
                          itemBuilder: (context, index) {
                            final user = otherUsers[index];
                            final isSelected = _selectedRecipient?.username == user.username;
                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.surfaceContainerHighest,
                                child: Text(user.displayName[0].toUpperCase()),
                              ),
                              title: Text(user.displayName, style: AppTypography.labelMedium),
                              subtitle: Text('@${user.username}', style: AppTypography.bodySmall),
                              onTap: () => setState(() => _selectedRecipient = user),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2. SELECT GIFT ITEM', style: AppTypography.labelLarge.copyWith(color: AppColors.secondary)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: 25,
                          itemBuilder: (context, index) {
                            if (index < ownedItems.length) {
                              final entry = ownedItems[index];
                              final itemId = entry.key;
                              final count = entry.value;
                              final isSelected = _selectedItemId == itemId;

                              return InkWell(
                                onTap: () => setState(() => _selectedItemId = itemId),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.secondary.withValues(alpha: 0.2) : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? AppColors.secondary : AppColors.outlineVariant,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Image.asset(
                                          'assets/items/$itemId.png',
                                          width: 32,
                                          height: 32,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2_outlined, size: 24),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: Text(
                                          'x$count',
                                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('3. ATTACH MESSAGE', style: AppTypography.labelLarge.copyWith(color: AppColors.tertiary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Enter a friendly message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: (_selectedRecipient == null || _selectedItemId == null || _isSending) 
                        ? null 
                        : _sendGift,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    icon: _isSending 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_outlined),
                    label: const Text('SEND GIFT'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Inbox Tab ────────────────────────────────────────────────────────────────

class _InboxTab extends ConsumerStatefulWidget {
  const _InboxTab();

  @override
  ConsumerState<_InboxTab> createState() => _InboxTabState();
}

class _InboxTabState extends ConsumerState<_InboxTab> {
  bool _isRefreshing = false;
  final Set<String> _accepting = {};

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await ref.read(socialControllerProvider.notifier).syncAll();
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _accept(Gift gift) async {
    setState(() => _accepting.add(gift.id));
    
    final ok = await ref.read(socialControllerProvider.notifier).acceptGift(
      gift.id,
      gift.itemId,
      gift.quantity,
    );

    if (!mounted) return;
    if (ok) {
      setState(() => _accepting.remove(gift.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claimed ${gift.quantity}× ${_findItem(gift.itemId)?.name ?? gift.itemId}!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _accepting.remove(gift.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to claim gift. Try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final socialState = ref.watch(socialControllerProvider);
    final gifts = socialState.pendingGifts;

    if (socialState.isLoading && gifts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (gifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.outline.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text('No pending gifts', style: AppTypography.bodyLarge.copyWith(color: AppColors.outline)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _refresh,
              child: _isRefreshing 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: gifts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final gift = gifts[i];
          final item = _findItem(gift.itemId);
          final isAccepting = _accepting.contains(gift.id);
          return GlassCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (item?.color ?? Colors.grey).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Image.asset(
                        item?.spritePath ?? '',
                        fit: BoxFit.contain,
                        errorBuilder: (context, _, __) => Icon(
                          item?.icon ?? Icons.card_giftcard,
                          color: item?.color ?? Colors.grey,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${gift.quantity}× ${item?.name ?? gift.itemId}',
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'From @${gift.senderUsername}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                      ),
                      if (gift.message.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '"${gift.message}"',
                            style: AppTypography.bodySmall.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: isAccepting ? null : () => _accept(gift),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: isAccepting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('CLAIM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String step;
  final String label;
  const _SectionLabel({required this.step, required this.label});

  Map<String, int> _calculateTeamStats(List<dynamic> roster) {
    return {'hp': 100, 'atk': 100, 'def': 100, 'spa': 100, 'spd': 100, 'spe': 100};
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(label, style: AppTypography.headlineSmall),
      ],
    );
  }
}

class _RecipientTile extends StatelessWidget {
  final SocialUser user;
  final bool isSelected;
  final VoidCallback onTap;
  const _RecipientTile({required this.user, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.12)
                : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  user.displayName[0].toUpperCase(),
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: AppTypography.bodyLarge),
                    Text('@${user.username}', style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: user.status == 'online'
                      ? Colors.green.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.status.toUpperCase(),
                  style: TextStyle(
                    color: user.status == 'online' ? Colors.greenAccent : Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  final String label;
  final String? spritePath;
  final IconData icon;
  final Color color;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  const _ItemChip({
    required this.label,
    this.spritePath,
    required this.icon,
    required this.color,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(
                spritePath ?? '',
                fit: BoxFit.contain,
                errorBuilder: (context, _, __) => Icon(icon, color: color, size: 28),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: AppTypography.labelMedium),
            Text(
              'x$count',
              style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }
}
