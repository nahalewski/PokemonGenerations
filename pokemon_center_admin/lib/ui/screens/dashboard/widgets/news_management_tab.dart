import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/admin_tab_logger.dart';

class NewsManagementTab extends ConsumerStatefulWidget {
  const NewsManagementTab({super.key});

  @override
  ConsumerState<NewsManagementTab> createState() => _NewsManagementTabState();
}

class _NewsManagementTabState extends ConsumerState<NewsManagementTab> {
  final _versionController = TextEditingController();
  final _titleController = TextEditingController();
  final _changelogItemsController = TextEditingController();
  final _upcomingItemsController = TextEditingController();
  final _featuresItemsController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isBroadcasting = false;

  @override
  void initState() {
    super.initState();
    AdminTabLogger.log('news_management', 'tab_initialized');
    _loadNews();
  }

  @override
  void dispose() {
    _versionController.dispose();
    _titleController.dispose();
    _changelogItemsController.dispose();
    _upcomingItemsController.dispose();
    _featuresItemsController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    await AdminTabLogger.log('news_management', 'news_load_started');
    try {
      final news = await AdminService().fetchNews();
      final changelog = news['changelog'] ?? {};
      _versionController.text = changelog['version'] ?? '';
      _titleController.text = changelog['title'] ?? '';
      _changelogItemsController.text = ((changelog['items'] ?? []) as List).join('\n');
      _upcomingItemsController.text = ((news['upcoming'] ?? []) as List).join('\n');
      _featuresItemsController.text = ((news['features'] ?? []) as List).join('\n');
      await AdminTabLogger.log(
        'news_management',
        'news_load_completed',
        details: {
          'version': changelog['version']?.toString() ?? '',
          'title': changelog['title']?.toString() ?? '',
        },
      );
    } catch (e) {
      await AdminTabLogger.log(
        'news_management',
        'news_load_failed',
        error: e,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading news: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNews() async {
    setState(() => _isSaving = true);
    await AdminTabLogger.log(
      'news_management',
      'news_save_started',
      details: {'version': _versionController.text.trim()},
    );
    try {
      final news = {
        'changelog': {
          'version': _versionController.text.trim(),
          'title': _titleController.text.trim(),
          'items': _changelogItemsController.text.trim().split('\n').where((s) => s.isNotEmpty).toList(),
          'date': 'Apr 2026', // Static for now or we could add a field
        },
        'upcoming': _upcomingItemsController.text.trim().split('\n').where((s) => s.isNotEmpty).toList(),
        'features': _featuresItemsController.text.trim().split('\n').where((s) => s.isNotEmpty).toList(),
        'platforms': [
          {
            'name': 'Web',
            'status': 'Online',
            'details': ['Full feature parity', 'Global chat', 'PvP']
          },
          {
            'name': 'Android',
            'status': 'v1.0.9 Ready',
            'details': ['OTA updates', 'High-res assets']
          }
        ]
      };

      final success = await AdminService().updateNews(news);
      if (success) {
        await AdminTabLogger.log(
          'news_management',
          'news_save_completed',
          details: {'version': _versionController.text.trim()},
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NEWS UPDATED SUCCESSFULLY'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      await AdminTabLogger.log(
        'news_management',
        'news_save_failed',
        error: e,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving news: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _broadcastNews() async {
    if (_titleController.text.isEmpty) return;
    
    setState(() => _isBroadcasting = true);
    await AdminTabLogger.log(
      'news_management',
      'news_broadcast_started',
      details: {'title': _titleController.text.trim()},
    );
    try {
      final message = 'POKEMON CENTER BROADCAST: ${_titleController.text.trim()} is now LIVE! Check your News feed for details.';
      final success = await AdminService().broadcastNews(message);
      if (success) {
        await AdminTabLogger.log(
          'news_management',
          'news_broadcast_completed',
          details: {'title': _titleController.text.trim()},
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WORLD BROADCAST SENT'), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      await AdminTabLogger.log(
        'news_management',
        'news_broadcast_failed',
        error: e,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error broadcasting: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isBroadcasting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEWS MANAGEMENT', style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 8),
                Text(
                  'Global News Feed & Broadcast System — Control the narrative across all platforms.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textDim),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: _isBroadcasting ? null : _broadcastNews,
                  icon: const Icon(Icons.record_voice_over_rounded),
                  label: const Text('BROADCAST TO WORLD'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveNews,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('SAVE & UPDATE FEED'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('CHANGELOG HEADLINE', [
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Version (e.g. V1.0.9)', _versionController)),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _buildTextField('Title (e.g. THE DIVINE UPDATE)', _titleController)),
                    ],
                  ),
                ]),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildSection('CHANGELOG ITEMS (ONE PER LINE)', [
                        _buildTextField('• New feature 1\n• Bug fix 2...', _changelogItemsController, maxLines: 8),
                      ]),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildSection('UPCOMING FEATURES', [
                        _buildTextField('• Future feature 1\n• Research 2...', _upcomingItemsController, maxLines: 8),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSection('LIVE FEATURES HIGHLIGHT', [
                  _buildTextField('• Feature list...', _featuresItemsController, maxLines: 6),
                ]),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textDim, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }
}
