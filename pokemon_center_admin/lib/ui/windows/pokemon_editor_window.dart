import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

import '../../core/theme.dart';
import '../../services/admin_service.dart';
import '../../models/admin_models.dart';

class PokemonEditorWindow extends StatefulWidget {
  final WindowController windowController;
  final Map<String, dynamic> args;

  const PokemonEditorWindow({
    super.key,
    required this.windowController,
    required this.args,
  });

  @override
  State<PokemonEditorWindow> createState() => _PokemonEditorWindowState();
}

class _PokemonEditorWindowState extends State<PokemonEditorWindow> {
  late String _username;
  late int _slotIndex;
  late Map<String, dynamic> _pokemon;
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  
  List<String> _availableItems = ['None'];
  List<String> _availableMoves = [];
  List<String> _availableAbilities = [];
  List<String> _availablePokemons = [];

  @override
  void initState() {
    super.initState();
    _username = widget.args['username'] ?? '';
    _slotIndex = widget.args['slotIndex'] ?? -1;
    _pokemon = Map<String, dynamic>.from(widget.args['pokemon'] ?? {});
    
    _nameController.text = _pokemon['pokemonName'] ?? '';
    _levelController.text = (_pokemon['level'] ?? 50).toString();
    
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final service = AdminService();
      final items = await service.fetchItems();
      final moves = await service.fetchMoves();
      final abilities = await service.fetchAbilities();
      
      if (mounted) {
        setState(() {
          _availableItems = ['None', ...items..sort()];
          _availableMoves = ['None', ...moves..sort()];
          _availableAbilities = ['Unknown', ...abilities..sort()];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAndClose() async {
    setState(() => _isSaving = true);
    try {
      _pokemon['pokemonName'] = _nameController.text;
      _pokemon['level'] = int.tryParse(_levelController.text) ?? 50;
      
      // Notify the opener window that we saved
      // DesktopMultiWindow.setMethodHandler is a global setter, so we don't necessarily need to set it here
      // unless we want to handle incoming messages in this editor window.
      
      // We'll use a MethodChannel or just close and let the main window refresh via polling/notifier
      // But the user said: "automatically saves what the edits were, and then that gets synced to the server"
      
      // Save to server
      final fullData = await AdminService().fetchFullUser(_username);
      final List<dynamic> roster = List.from(fullData['roster'] ?? []);
      if (_slotIndex >= 0 && _slotIndex < roster.length) {
        roster[_slotIndex] = _pokemon;
      }
      
      await AdminService().updatePlayerRoster(_username, roster);
      
      await DesktopMultiWindow.invokeMethod(0, 'refresh_collection', _username);
      widget.windowController.close();
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('ADMIN EDITOR: ${_pokemon['pokemonName'] ?? 'POKEMON'}'),
        backgroundColor: AppColors.surface,
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2)))
          else
            TextButton.icon(
              onPressed: _saveAndClose,
              icon: const Icon(Icons.save_rounded),
              label: const Text('SAVE & CLOSE'),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('CORE IDENTITY'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: _inputDecoration('POKEMON NAME', Icons.badge),
                      ),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _levelController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('LEVEL', Icons.trending_up),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('STATS & TRAITS'),
                const SizedBox(height: 16),
                _buildTraitSelectors(),
                const SizedBox(height: 32),
                _buildSectionHeader('MOVESET'),
                const SizedBox(height: 16),
                _buildMoveSelectors(),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 2,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white.withOpacity(0.02),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      labelStyle: const TextStyle(color: AppColors.textDim, fontSize: 13),
    );
  }

  Widget _buildTraitSelectors() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _buildDropdown('ABILITY', _pokemon['ability'] ?? 'Unknown', _availableAbilities, (val) {
          setState(() => _pokemon['ability'] = val);
        }),
        _buildDropdown('NATURE', _pokemon['nature'] ?? 'Neutral', ['Adamant', 'Bashful', 'Bold', 'Brave', 'Calm', 'Careful', 'Docile', 'Gentle', 'Hardy', 'Hasty', 'Impish', 'Jolly', 'Lax', 'Lonely', 'Mild', 'Modest', 'Naive', 'Naughty', 'Quiet', 'Quirky', 'Rash', 'Relaxed', 'Sassy', 'Serious', 'Timid'], (val) {
          setState(() => _pokemon['nature'] = val);
        }),
        _buildDropdown('HELD ITEM', _pokemon['item'] ?? 'None', _availableItems, (val) {
          setState(() => _pokemon['item'] = val);
        }),
      ],
    );
  }

  Widget _buildMoveSelectors() {
    final List<dynamic> moves = List.from(_pokemon['moves'] ?? []);
    while (moves.length < 4) {
      moves.add('None');
    }

    return Column(
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildDropdown('MOVE #${index + 1}', moves[index], _availableMoves, (val) {
            setState(() {
              moves[index] = val;
              _pokemon['moves'] = moves.where((m) => m != 'None').toList();
            });
          }),
        );
      }),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String> onChanged) {
    if (!options.contains(value)) {
      options.add(value);
    }
    
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 9, fontWeight: FontWeight.bold)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: options.map((String opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
