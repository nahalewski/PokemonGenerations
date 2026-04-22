import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme.dart';
import '../../../../core/item_registry.dart';
import '../../../../services/admin_notifier.dart';
import '../../../../models/admin_models.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/admin_tab_logger.dart';

class GiftCenterTab extends ConsumerStatefulWidget {
  const GiftCenterTab({super.key});

  @override
  ConsumerState<GiftCenterTab> createState() => _GiftCenterTabState();
}

class _GiftCenterTabState extends ConsumerState<GiftCenterTab> {
  final _messageController = TextEditingController();
  final _itemSearchController = TextEditingController();
  
  AdminUser? _selectedPlayer;
  MasterItem? _selectedItem;
  int _quantity = 1;
  bool _isTransmitting = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _messageController.dispose();
    _itemSearchController.dispose();
    super.dispose();
  }

  Future<void> _transmitGift() async {
    if (_selectedPlayer == null || _selectedItem == null) return;
    
    setState(() => _isTransmitting = true);
    await AdminTabLogger.log(
      'gift_center',
      'gift_transmit_started',
      details: {
        'recipient': _selectedPlayer!.username,
        'itemId': _selectedItem!.id,
        'quantity': _quantity,
      },
    );
    
    try {
      final success = await AdminService().sendGift(
        senderUsername: 'POKEMON_CENTER',
        senderDisplayName: 'POKEMON CENTER',
        recipientUsername: _selectedPlayer!.username,
        itemId: _selectedItem!.id,
        quantity: _quantity,
        message: _messageController.text.trim().isEmpty 
            ? 'Access Granted. Enjoy your gift from the Pokemon Mart.' 
            : _messageController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        await AdminTabLogger.log(
          'gift_center',
          'gift_transmit_completed',
          details: {
            'recipient': _selectedPlayer!.username,
            'itemId': _selectedItem!.id,
            'quantity': _quantity,
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('TRANSMISSION SUCCESSFUL: ${_selectedItem!.name} x$_quantity SENT TO ${_selectedPlayer!.displayName}'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _selectedItem = null;
          _quantity = 1;
          _messageController.clear();
        });
      }
    } catch (e) {
      await AdminTabLogger.log(
        'gift_center',
        'gift_transmit_failed',
        error: e,
      );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
    } finally {
      if (mounted) setState(() => _isTransmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final filteredItems = pokemonItemRegistry.where((item) =>
      item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item.category.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 32),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Config
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlayerSelector(adminState.users),
                      const SizedBox(height: 32),
                      if (_selectedItem != null) _buildGiftConfig(),
                      const SizedBox(height: 32),
                      _buildTransmitButton(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 40),
              // Right: Registry
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildItemSearch(),
                    Expanded(child: _buildItemGrid(filteredItems)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GIFT CENTER', style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 8),
        Text(
          'Administrative Distribution Hub — Transmit berries, balls, and rare items to trainers.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textDim),
        ),
      ],
    );
  }

  Widget _buildPlayerSelector(List<AdminUser> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SELECT RECIPIENT', style: TextStyle(color: AppColors.textDim, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AdminUser>(
              value: _selectedPlayer,
              hint: const Text('Choose a trainer...'),
              isExpanded: true,
              dropdownColor: AppColors.surface,
              items: users.map((u) => DropdownMenuItem(
                value: u,
                child: Text('${u.displayName} (@${u.username})'),
              )).toList(),
              onChanged: (val) => setState(() => _selectedPlayer = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemSearch() {
    return TextField(
      controller: _itemSearchController,
      onChanged: (val) => setState(() => _searchQuery = val),
      decoration: InputDecoration(
        hintText: 'Search Pokemon Center Registry...',
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildItemGrid(List<MasterItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = _selectedItem?.id == item.id;
        
        return InkWell(
          onTap: () => setState(() => _selectedItem = item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
              border: Border.all(color: isSelected ? AppColors.primary : Colors.white10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Image.asset(
                    item.spritePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(item.icon, color: item.color, size: 28),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.category.toUpperCase(),
                  style: TextStyle(color: AppColors.textDim, fontSize: 8, letterSpacing: 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGiftConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Image.asset(
                _selectedItem!.spritePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(_selectedItem!.icon, color: _selectedItem!.color, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedItem!.name, style: Theme.of(context).textTheme.headlineSmall),
                  Text(_selectedItem!.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textDim)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text('QUANTITY:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            IconButton(
              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary, size: 20),
            ),
            Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: () => setState(() => _quantity++),
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _messageController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Add an administrative note...',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildTransmitButton() {
    final isReady = _selectedPlayer != null && _selectedItem != null && !_isTransmitting;
    
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isReady ? _transmitGift : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isTransmitting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : const Text('TRANSMIT GIFT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }
}
