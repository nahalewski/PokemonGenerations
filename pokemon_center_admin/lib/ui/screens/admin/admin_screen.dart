import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../services/admin_notifier.dart';
import '../../../models/admin_models.dart';
import '../../../core/theme.dart';
import '../../widgets/emoji_widgets.dart';

class SocialAdminScreen extends ConsumerWidget {
  const SocialAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, ref, state),
        const SizedBox(height: 32),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User List
              Expanded(
                flex: 3,
                child: _buildUserTable(context, ref, state),
              ),
              const SizedBox(width: 32),
              // Chat & Broadcast
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(child: _buildChatMonitor(context, state)),
                    const SizedBox(height: 32),
                    _buildBroadcastPanel(context, ref, state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AdminState state) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SOCIAL DASHBOARD', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text(
              'User Management, Chat Monitoring & Global Notifications',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textDim),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => ref.read(adminProvider.notifier).refresh(),
          icon: state.isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  Widget _buildUserTable(BuildContext context, WidgetRef ref, AdminState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.02)),
          columns: [
            DataColumn(label: Text('USER')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('SECURITY')),
            DataColumn(label: Text('RECORD')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: state.users.map((user) {
            return DataRow(cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('@${user.username}', style: TextStyle(color: AppColors.textDim, fontSize: 11)),
                  ],
                ),
              ),
              DataCell(_buildStatusBadge(user.status, user.suspended)),
              DataCell(
                user.forcePasscodeChange 
                  ? const Tooltip(
                      message: 'Passcode Reset Required',
                      child: Icon(Icons.security_update_warning_rounded, color: Colors.redAccent, size: 18),
                    )
                  : Icon(Icons.verified_user_rounded, color: AppColors.success.withOpacity(0.3), size: 18),
              ),
              DataCell(Text('${user.wins}W / ${user.losses}L', style: const TextStyle(fontSize: 12))),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: user.suspended ? 'Unsuspend' : 'Suspend',
                      icon: Icon(user.suspended ? Icons.lock_open_rounded : Icons.lock_person_rounded, size: 18),
                      onPressed: () => _confirmAction(context, 'Suspend User', 'Are you sure?', () {
                         ref.read(adminProvider.notifier).suspendUser(user.username, !user.suspended);
                      }),
                    ),
                    IconButton(
                      tooltip: 'Ban User',
                      icon: const Icon(Icons.block_flipped, size: 18, color: Colors.orange),
                      onPressed: () => _confirmAction(context, 'Ban User', 'Permanently ban this user?', () {
                         ref.read(adminProvider.notifier).banUser(user.username);
                      }),
                    ),
                    IconButton(
                      tooltip: 'Erase Data',
                      icon: const Icon(Icons.delete_forever_rounded, size: 18, color: Colors.redAccent),
                      onPressed: () => _confirmAction(context, 'Erase User', 'This will delete the user account and roster permanently.', () {
                         ref.read(adminProvider.notifier).deleteUser(user.username);
                      }, isDestructive: true),
                    ),
                    IconButton(
                      tooltip: 'Force Passcode Reset',
                      icon: const Icon(Icons.published_with_changes_rounded, size: 18, color: AppColors.primary),
                      onPressed: () => _confirmAction(context, 'Reset Passcode', 'Force this user to change their passcode on next login?', () {
                         ref.read(adminProvider.notifier).resetUserPasscode(user.username);
                      }),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AdminUserStatus status, bool suspended) {
    if (suspended) {
      return _Badge(label: 'SUSPENDED', color: Colors.redAccent);
    }
    switch (status) {
      case AdminUserStatus.online: return _Badge(label: 'ONLINE', color: AppColors.success);
      case AdminUserStatus.battling: return _Badge(label: 'BATTLING', color: AppColors.primary);
      case AdminUserStatus.offline: return _Badge(label: 'OFFLINE', color: AppColors.textDim);
    }
  }

  Widget _buildChatMonitor(BuildContext context, AdminState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.forum_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text('CHAT MONITOR', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.chat.length,
              itemBuilder: (context, index) {
                final msg = state.chat[index];
                final isAdminCmd = msg.text.startsWith('@Admin') || msg.recipient == 'admin';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: isAdminCmd ? const EdgeInsets.all(8) : null,
                    decoration: isAdminCmd ? BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ) : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(msg.sender, style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 13, 
                              color: isAdminCmd ? Colors.orangeAccent : AppColors.primary
                            )),
                            if (isAdminCmd) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.private_connectivity_rounded, size: 12, color: Colors.orangeAccent),
                              const SizedBox(width: 4),
                              const Text('PRIVATE', style: TextStyle(color: Colors.orangeAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                            const SizedBox(width: 8),
                            Text(DateFormat('HH:mm').format(msg.timestamp), style: TextStyle(color: AppColors.textDim, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        EmojiRichText(
                          text: msg.text,
                          style: TextStyle(
                            fontSize: 13, 
                            color: isAdminCmd ? Colors.white : Colors.white70,
                            fontWeight: isAdminCmd ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastPanel(BuildContext context, WidgetRef ref, AdminState state) {
    final controller = TextEditingController();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 12),
              Text('GLOBAL BROADCAST', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 20),
          if (state.activeBroadcast != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'ACTIVE: ${state.activeBroadcast!.text}',
                      style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: AppColors.warning),
                    onPressed: () => ref.read(adminProvider.notifier).clearBroadcast(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: controller,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Type global system message...',
              filled: true,
              fillColor: Colors.white.withOpacity(0.02),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref.read(adminProvider.notifier).sendBroadcast(controller.text);
                  controller.clear();
                }
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('SEND TO ALL USERS'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, String title, String message, VoidCallback onConfirm, {bool isDestructive = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            style: isDestructive ? FilledButton.styleFrom(backgroundColor: Colors.redAccent) : null,
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
