import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../../core/theme.dart';
import '../../../../services/admin_service.dart';
import '../../../../models/admin_models.dart';
import '../../../../services/admin_tab_logger.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

class CollectionInspectorTab extends StatefulWidget {
  const CollectionInspectorTab({super.key});

  @override
  State<CollectionInspectorTab> createState() => _CollectionInspectorTabState();
}

class _CollectionInspectorTabState extends State<CollectionInspectorTab> {
  List<AdminUser> _users = [];
  AdminUser? _selectedUser;
  Map<String, dynamic>? _fullUserProfile;
  Map<String, dynamic>? _selectedRoster; // null = Main Collection, else Preset
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    AdminTabLogger.log('collection_inspector', 'tab_initialized');
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await AdminService().fetchUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
      await AdminTabLogger.log(
        'collection_inspector',
        'users_loaded',
        details: {'count': users.length},
      );
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
      await AdminTabLogger.log('collection_inspector', 'users_load_failed');
    }
  }

  Future<void> _inspectUser(AdminUser user) async {
    setState(() {
      _selectedUser = user;
      _isLoading = true;
      _fullUserProfile = null;
      _selectedRoster = null; // Reset selection
    });

    try {
      final fullData = await AdminService().fetchFullUser(user.username);
      if (mounted) {
        setState(() {
          _fullUserProfile = fullData;
          _isLoading = false;
        });
      }
      await AdminTabLogger.log(
        'collection_inspector',
        'user_inspected',
        details: {'username': user.username},
      );
    } catch (e) {
      await AdminTabLogger.log(
        'collection_inspector',
        'user_inspection_failed',
        details: {'username': user.username},
        error: e,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _saveRoster(List<dynamic> newRoster) async {
    if (_selectedUser == null) return;
    
    setState(() => _isSaving = true);
    await AdminTabLogger.log(
      'collection_inspector',
      'roster_save_started',
      details: {
        'username': _selectedUser!.username,
        'entries': newRoster.length,
      },
    );
    try {
      final success = await AdminService().updatePlayerRoster(_selectedUser!.username, newRoster);
      if (mounted) {
        if (success) {
          await AdminTabLogger.log(
            'collection_inspector',
            'roster_save_completed',
            details: {
              'username': _selectedUser!.username,
              'entries': newRoster.length,
            },
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ROSTER UPDATED SUCCESSFULLY'), backgroundColor: AppColors.success),
          );
          _inspectUser(_selectedUser!); // Refresh
        } else {
          throw Exception('Backend rejection');
        }
      }
    } catch (e) {
      await AdminTabLogger.log(
        'collection_inspector',
        'roster_save_failed',
        details: {'username': _selectedUser!.username},
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 32),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trainer List
              SizedBox(
                width: 300,
                child: _buildTrainerList(),
              ),
              const VerticalDivider(width: 48, thickness: 0.5, color: Colors.white10),
              // Inspector View
              Expanded(
                child: _buildInspectorContent(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('COLLECTION INSPECTOR', style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 8),
        Text(
          'Trainer Registry Access — View and manage participant save files and Pokémon rosters.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textDim),
        ),
      ],
    );
  }

  Widget _buildTrainerList() {
    if (_isLoading && _users.isEmpty) return const Center(child: CircularProgressIndicator());

    return ListView.separated(
      itemCount: _users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = _users[index];
        final isSelected = _selectedUser?.username == user.username;
        return ListTile(
          onTap: () => _inspectUser(user),
          selected: isSelected,
          tileColor: AppColors.surface,
          selectedTileColor: AppColors.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05)),
          ),
          leading: CircleAvatar(
            backgroundColor: user.status == AdminUserStatus.online ? Colors.greenAccent : Colors.grey,
            radius: 4,
          ),
          title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text('@${user.username}', style: TextStyle(color: AppColors.textDim, fontSize: 10)),
          trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.textDim),
        );
      },
    );
  }

  Widget _buildInspectorContent() {
    if (_selectedUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: AppColors.textDim.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text('SELECT A TRAINER TO INSPECT', style: TextStyle(color: AppColors.textDim, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final roster = _selectedRoster != null 
        ? (_selectedRoster!['slots'] as List?) ?? []
        : (_fullUserProfile?['roster'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 32),
        if (_selectedRoster == null && _fullUserProfile != null && (_fullUserProfile!['presets'] as List?)?.isNotEmpty == true) ...[
           _buildRosterPicker(),
           const SizedBox(height: 32),
        ],
        Row(
          children: [
            if (_selectedRoster != null)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                onPressed: () => setState(() => _selectedRoster = null),
              ),
            Text(
              _selectedRoster != null 
                ? 'ROSTER: ${_selectedRoster!['name']?.toUpperCase()}' 
                : 'MAIN COLLECTION GRID', 
              style: const TextStyle(color: AppColors.textDim, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildRosterGrid(roster)),
      ],
    ).animate().fadeIn();
  }

  Widget _buildRosterPicker() {
    final presets = (_fullUserProfile!['presets'] as List?) ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AVAILABLE ROSTERS / PRESETS', style: TextStyle(color: AppColors.textDim, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: presets.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                 return _buildRosterCard('MAIN COLLECTION', null);
              }
              final preset = presets[index - 1];
              return _buildRosterCard(preset['name'] ?? 'PRESET $index', preset);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRosterCard(String title, Map<String, dynamic>? preset) {
    return InkWell(
      onTap: () => setState(() => _selectedRoster = preset),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            const Icon(Icons.grid_view_rounded, size: 16, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(_selectedUser!.displayName[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedUser!.displayName, style: Theme.of(context).textTheme.headlineSmall),
                Text('User ID: ${_selectedUser!.username}', style: TextStyle(color: AppColors.textDim, fontSize: 12)),
              ],
            ),
          ),
          _buildStatCard('WINS', _selectedUser!.wins.toString()),
          const SizedBox(width: 16),
          _buildStatCard('LOSSES', (_fullUserProfile?['losses'] ?? 0).toString()),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 8, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRosterGrid(List<dynamic> roster) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: 30, // Max slots
      itemBuilder: (context, index) {
        final hasPokemon = index < roster.length;
        final pokemon = hasPokemon ? roster[index] : null;

        return Container(
          decoration: BoxDecoration(
            color: hasPokemon ? AppColors.surface : Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: hasPokemon ? AppColors.primary.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
          ),
          child: InkWell(
            onHover: (_) {}, // For mouse interaction
            onTap: hasPokemon ? () => _openFullEditor(index, pokemon) : null,
            onLongPress: hasPokemon ? () => _confirmDelete(index) : null,
            child: Stack(
              children: [
                if (hasPokemon)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(pokemon['pokemonName'] ?? '#${pokemon['pokemonId'] ?? '???'}' , style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        Text('LVL ${pokemon['level'] ?? 50}', style: const TextStyle(color: AppColors.primary, fontSize: 8)),
                      ],
                    ),
                  )
                else
                  const Center(child: Icon(Icons.add, color: Colors.white10, size: 16)),
                Positioned(
                  top: 4,
                  left: 4,
                  child: Text('${index + 1}', style: TextStyle(color: AppColors.textDim.withOpacity(0.3), fontSize: 8)),
                ),
                if (hasPokemon)
                  const Positioned(
                    bottom: 4,
                    right: 4,
                    child: Icon(Icons.edit, size: 8, color: AppColors.textDim),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openFullEditor(int index, dynamic pokemon) async {
    final window = await DesktopMultiWindow.createWindow(jsonEncode({
      'args1': 'pokemon_editor',
      'username': _selectedUser?.username,
      'slotIndex': index,
      'pokemon': pokemon,
      'isPreset': _selectedRoster != null,
      'presetId': _selectedRoster?['id'],
    }));
    window
      ..setFrame(const Offset(100, 100) & const Size(600, 800))
      ..center()
      ..setTitle('Pokemon Editor - Admin')
      ..show();
      
    // Listen for refresh events
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
       if (call.method == 'refresh_collection') {
         _inspectUser(_selectedUser!);
       }
       return null;
    });
  }

  void _confirmDelete(int index) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('DELETE POKEMON?'),
         content: const Text('Are you sure you want to permanently remove this Pokemon from the roster? This action is irreversible on the server.'),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
           TextButton(
             onPressed: () {
               Navigator.pop(context);
               _deletePokemon(index);
             },
             child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
           ),
         ],
       ),
     );
  }

  Future<void> _deletePokemon(int index) async {
    final List<dynamic> oldRoster = _selectedRoster != null 
        ? List.from(_selectedRoster!['slots'] ?? [])
        : List.from(_fullUserProfile?['roster'] ?? []);
    
    if (index >= oldRoster.length) return;
    oldRoster.removeAt(index);

    if (_selectedRoster != null) {
      // Update preset
      final presets = List<dynamic>.from(_fullUserProfile?['presets'] ?? []);
      for (var p in presets) {
        if (p['id'] == _selectedRoster!['id']) {
          p['slots'] = oldRoster;
        }
      }
      // Since updatePlayerRoster only updates 'roster', we might need a general update endpont
      // But for now, let's just support main roster deletion as requested
      // Actually, let's update the full user if possible
      await AdminService().updatePlayerRoster(_selectedUser!.username, oldRoster); 
    } else {
      await _saveRoster(oldRoster);
    }
  }

  void _showEditDialog(int index, dynamic pokemon) {
    // Deprecated in favor of _openFullEditor
  }
}
