import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/services/api_client.dart';

class SocialScreen extends ConsumerStatefulWidget {
  final String username;
  const SocialScreen({super.key, required this.username});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen> {
  List<dynamic> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInbox();
  }

  Future<void> _fetchInbox() async {
    final client = ref.read(apiClientProvider);
    try {
      final inbox = await client.fetchInbox(widget.username);
      if (mounted) {
        setState(() {
          _messages = inbox;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MAILBOX // INCOMING', style: AppTypography.textTheme.labelLarge?.copyWith(color: AppColors.primary)),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primary, size: 20),
                onPressed: _fetchInbox,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('NO_MESSAGES_DETECTED', style: TextStyle(color: Colors.white24, fontSize: 10)))
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageTile(_messages[index]);
                    },
                  ),
          ),
          const SizedBox(height: 16),
          _buildComposeAction(),
        ],
      ),
    );
  }

  Widget _buildMessageTile(dynamic msg) {
    final bool isUnread = !(msg['read'] ?? true);
    final String date = msg['sentAt'] != null 
        ? DateTime.parse(msg['sentAt']).toString().split('.')[0]
        : 'UNKNOWN_TIME';

    return InkWell(
      onTap: () => _viewMessage(msg),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.primary.withOpacity(0.05) : AppColors.surfaceContainerLow,
          border: Border(left: BorderSide(color: isUnread ? AppColors.primary : Colors.white24, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(msg['subject']?.toUpperCase() ?? 'NO_SUBJECT', 
                    style: TextStyle(
                      color: isUnread ? AppColors.primary : Colors.white,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12
                    )),
                Text(date, style: const TextStyle(color: Colors.white24, fontSize: 8)),
              ],
            ),
            const SizedBox(height: 4),
            Text('FROM: ${msg['fromDisplay'] ?? msg['from']}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _viewMessage(dynamic msg) async {
    final client = ref.read(apiClientProvider);
    // Mark as read
    if (!(msg['read'] ?? false)) {
      await client.markAsRead(widget.username, msg['id']);
      _fetchInbox();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final att = msg['attachment'];
          final bool canClaim = att != null && !(att['claimed'] ?? false);

          return AlertDialog(
            backgroundColor: Colors.black,
            shape: const RoundedRectangleBorder(side: BorderSide(color: AppColors.primary)),
            title: Text(msg['subject']?.toUpperCase() ?? 'MESSAGE_DATA', style: const TextStyle(color: AppColors.primary, fontSize: 14)),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('SENT_BY: ${msg['fromDisplay']} (@${msg['from']})', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  Text(msg['body'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  if (att != null) ...[
                    const SizedBox(height: 24),
                    _buildAttachmentInfo(att, canClaim),
                  ],
                ],
              ),
            ),
            actions: [
              if (canClaim)
                TextButton(
                  onPressed: () async {
                    final res = await client.claimAttachment(widget.username, msg['id']);
                    if (res['success'] == true) {
                      // Claimed! Now Archive
                      await client.archiveMessage(widget.username, msg['id']);
                      if (!mounted) return;
                      Navigator.pop(context);
                      _fetchInbox();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ASSETS_RECOVERED_&_LOG_ARCHIVED'))
                      );
                    }
                  },
                  child: const Text('CLAIM_ATTACHMENT', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                ),
              TextButton(
                child: const Text('CLOSE', style: TextStyle(color: AppColors.primary)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAttachmentInfo(dynamic attachment, bool canClaim) {
    final String type = (attachment['type'] as String).toUpperCase();
    final String value = attachment['type'] == 'pokedollars' 
        ? '${attachment['value']} V'
        : '${attachment['quantity']}x ${attachment['value']}';
    
    final bool claimed = attachment['claimed'] ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: claimed ? Colors.white.withOpacity(0.05) : AppColors.secondary.withOpacity(0.1),
        border: Border.all(color: claimed ? Colors.white24 : AppColors.secondary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(claimed ? Icons.check_circle_outline : Icons.card_giftcard, 
               color: claimed ? Colors.white24 : AppColors.secondary, size: 16),
          const SizedBox(width: 12),
          Text(claimed ? 'ATTACHMENT_RECOVERED: $value' : 'ATTACHMENT_AVAILABLE: $value', 
               style: TextStyle(color: claimed ? Colors.white24 : AppColors.secondary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildComposeAction() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.edit, size: 16),
        label: const Text('COMPOSE_NEW_COMMUNIQUE'),
        onPressed: () => _composeMessage(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }

  void _composeMessage() {
    // Basic implementation for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('COMPOSE_PROTOCOL_INITIALIZING...'))
    );
  }
}
