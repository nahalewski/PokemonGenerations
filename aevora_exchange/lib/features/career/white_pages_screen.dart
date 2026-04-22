import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/services/api_client.dart';

class WhitePagesScreen extends ConsumerStatefulWidget {
  const WhitePagesScreen({super.key});

  @override
  ConsumerState<WhitePagesScreen> createState() => _WhitePagesScreenState();
}

class _WhitePagesScreenState extends ConsumerState<WhitePagesScreen> {
  List<dynamic> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final client = ref.read(apiClientProvider);
    try {
      final response = await client.fetchNewsData(); // Placeholder for career API
      // For now, using hardcoded high-fidelity goals as seen in backend
      setState(() {
        _jobs = [
          {
            'id': 'lead-debugger',
            'title': 'LEAD_DEBUGGER',
            'salary': 500,
            'desc': 'Audit terminal logs and report structural anomalies.',
            'sprite': 'scientist'
          },
          {
            'id': 'lead-programmer',
            'title': 'LEAD_PROGRAMMER',
            'salary': 1200,
            'desc': 'Architect high-fidelity systems for the Aevora region.',
            'sprite': 'clerk'
          },
          {
            'id': 'ceo',
            'title': 'CEO_SILPH_CO',
            'salary': 2740,
            'desc': 'Direct corporate strategy and regional innovation.',
            'sprite': 'businessman'
          }
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _jobs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildJobCard(_jobs[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('WHITE_PAGES_DIRECTORY', style: AppTypography.textTheme.labelLarge),
        const SizedBox(height: 8),
        const Text(
          'Select a professional path to begin earning daily Poké Dollars. Salaries are distributed at every terminal sync.',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Card(
      color: AppColors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  color: Colors.black,
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job['title'], style: AppTypography.textTheme.headlineSmall?.copyWith(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(job['desc'], style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DAILY: ${job['salary']} PD', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: const Text('APPLY_ROLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
