import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../services/admin_tab_logger.dart';
import '../../../../services/update_monitor_service.dart';
import '../../../../services/github_automation_service.dart';

class UpdateManagementTab extends ConsumerWidget {
  const UpdateManagementTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(updateStatusProvider);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          statusAsync.when(
            data: (status) => _buildContent(context, ref, status),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPDATE MANAGEMENT',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'MANAGE SOURCE DATA LAKE AND PROJECT REPOSITORIES',
          style: TextStyle(
            color: AppColors.primary.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, UpdateStatus status) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Status & Action
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(status),
                const SizedBox(height: 24),
                _buildActionButtons(context, ref),
                const SizedBox(height: 24),
                _buildReleaseConsole(ref),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Right Side: List of Repos
          Expanded(
            flex: 3,
            child: _buildRepoList(status),
          ),
        ],
      ),
    );
  }

  // State to track release logs
  static final _logsProvider = StateProvider<List<String>>((ref) => []);

  Widget _buildReleaseConsole(WidgetRef ref) {
    final logs = ref.watch(_logsProvider);
    if (logs.isEmpty) return const SizedBox();

    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, i) => Text(
          logs[i],
          style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontFamily: 'monospace'),
        ),
      ),
    );
  }

  Widget _buildStatusCard(UpdateStatus status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status.totalUpdates > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: status.totalUpdates > 0 ? AppColors.primary : Colors.greenAccent,
              ),
              const SizedBox(width: 12),
              Text(
                status.totalUpdates > 0 ? 'UPDATES PENDING' : 'SYSTEM UP TO DATE',
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Last checked: ${status.lastCheck}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text('Total Repositories: ${status.reposChecked}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _runUpdateScript(context),
            icon: const Icon(Icons.sync_rounded, size: 18),
            label: const Text('SYNC SOURCE LAKE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _publishProductionRelease(ref),
            icon: const Icon(Icons.rocket_launch_rounded, size: 18),
            label: const Text('PUBLISH PRODUCTION RELEASE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _publishProductionRelease(WidgetRef ref) async {
    final automation = ref.read(githubAutomationProvider);
    ref.read(_logsProvider.notifier).state = []; // Clear logs
    
    final version = '2.0.1+2'; // Static for this phase
    await AdminTabLogger.log(
      'update_management',
      'production_release_started',
      details: {'version': version},
    );

    await for (final status in automation.publishRelease(version, '')) {
      ref.read(_logsProvider.notifier).update((state) => [...state, status]);
      await AdminTabLogger.log(
        'update_management',
        'production_release_progress',
        details: {'status': status},
      );
    }
    await AdminTabLogger.log(
      'update_management',
      'production_release_completed',
      details: {'version': version},
    );
  }

  Future<void> _runUpdateScript(BuildContext context) async {
    try {
      await AdminTabLogger.log('update_management', 'sync_source_lake_started');
      // In a real app, you'd use a more robust way to find the script path
      final scriptPath = './devops/sync_assets.command';
      await Process.run(scriptPath, ['--update']);
      await AdminTabLogger.log('update_management', 'sync_source_lake_completed');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repository update complete.')),
        );
      }
    } catch (e) {
      await AdminTabLogger.log(
        'update_management',
        'sync_source_lake_failed',
        error: e,
      );
       if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Widget _buildRepoList(UpdateStatus status) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: status.updates.length,
        separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05)),
        itemBuilder: (context, i) {
          final update = status.updates[i];
          return ListTile(
            leading: const Icon(Icons.folder_open, color: Colors.white24, size: 20),
            title: Text(update['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text('Origin: main', style: TextStyle(fontSize: 10, color: Colors.white38)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('PENDING', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}
