import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/services/api_client.dart';

class Fortune500Screen extends ConsumerStatefulWidget {
  const Fortune500Screen({super.key});

  @override
  ConsumerState<Fortune500Screen> createState() => _Fortune500ScreenState();
}

class _Fortune500ScreenState extends ConsumerState<Fortune500Screen> {
  List<dynamic> _rankings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    // Placeholder fetching logic
    setState(() {
      _rankings = List.generate(20, (index) => {
        'rank': index + 1,
        'username': 'TRAINER_${1000 + index}',
        'netWorth': 500000.0 - (index * 15000),
        'job': index == 0 ? 'CEO_SILPH_CO' : (index < 5 ? 'LEAD_PROGRAMMER' : 'DATA_ANALYST'),
      });
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Column(
      children: [
        _buildLeaderboardHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _rankings.length,
            itemBuilder: (context, index) => _buildRankCard(_rankings[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AEVORA_FORTUNE_500', style: AppTypography.textTheme.labelLarge),
          const SizedBox(height: 4),
          const Text('GLOBAL_NET_WORTH_RANKINGS', style: TextStyle(color: Colors.white24, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildRankCard(Map<String, dynamic> trainer) {
    final isTop3 = trainer['rank'] <= 3;
    final rankColor = isTop3 ? AppColors.tertiary : AppColors.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: isTop3 ? AppColors.tertiary.withOpacity(0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            alignment: Alignment.centerLeft,
            child: Text(
              '#${trainer['rank']}',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: rankColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            color: Colors.black,
            child: const Icon(Icons.person, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainer['username'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(trainer['job'].toString().replaceAll('_', ' '), style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 9)),
              ],
            ),
          ),
          Text(
            '${(trainer['netWorth'] as double).toStringAsFixed(0)} V',
            style: AppTypography.textTheme.labelLarge?.copyWith(color: AppColors.primary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
