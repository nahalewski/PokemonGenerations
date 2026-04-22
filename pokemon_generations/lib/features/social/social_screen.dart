import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/profanity_filter.dart';
import '../auth/auth_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/trainer_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'social_controller.dart';
import 'social_state.dart';
import '../../domain/models/social.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/android_apk_offer_dialog.dart';
import '../../core/widgets/futuristic_ui_utils.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/emoji_rich_text.dart';
import 'widgets/emoji_lookup_overlay.dart';
import 'widgets/pixel_chat_bubble.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String _emojiQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _chatController.addListener(_onChatChanged);

    // Mark all as read when entering social screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(socialControllerProvider.notifier).markAllRead();
      _checkAndOfferAndroidApk();
    });
  }

  void _onChatChanged() {
    final text = _chatController.text;
    final selection = _chatController.selection;
    
    if (selection.baseOffset <= 0) {
      _hideEmojiOverlay();
      return;
    }

    // Look for @ or # before the cursor
    final beforeCursor = text.substring(0, selection.baseOffset);
    final lastAt = beforeCursor.lastIndexOf('@');
    final lastHash = beforeCursor.lastIndexOf('#');
    final triggerIndex = lastAt > lastHash ? lastAt : lastHash;

    if (triggerIndex != -1) {
      final query = beforeCursor.substring(triggerIndex + 1);
      // Ensure no spaces in the query
      if (!query.contains(' ')) {
        _showEmojiOverlay(query);
        return;
      }
    }
    _hideEmojiOverlay();
  }

  void _showEmojiOverlay(String query) {
    _emojiQuery = query;
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _hideEmojiOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 250,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, -210), // Show above the text field
          child: EmojiLookupOverlay(
            query: _emojiQuery,
            onEmojiSelected: (emoji) {
              final text = _chatController.text;
              final selection = _chatController.selection;
              final beforeCursor = text.substring(0, selection.baseOffset);
              final afterCursor = text.substring(selection.baseOffset);
              
              final lastAt = beforeCursor.lastIndexOf('@');
              final lastHash = beforeCursor.lastIndexOf('#');
              final triggerIndex = lastAt > lastHash ? lastAt : lastHash;
              
              final newBefore = beforeCursor.substring(0, triggerIndex) + ':$emoji: ';
              _chatController.text = newBefore + afterCursor;
              _chatController.selection = TextSelection.collapsed(offset: newBefore.length);
              _hideEmojiOverlay();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _checkAndOfferAndroidApk() async {
    if (!kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final prefs = await SharedPreferences.getInstance();
    final hasBeenOffered = prefs.getBool('auth.android_apk_offered') ?? false;

    if (!hasBeenOffered && mounted) {
      await AndroidApkOfferDialog.show(context);
      await prefs.setBool('auth.android_apk_offered', true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(socialControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Online Battles & Social'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'FRIENDS', icon: Icon(Icons.star)),
            Tab(text: 'TRAINERS', icon: Icon(Icons.public)),
            Tab(text: 'CHAT', icon: Icon(Icons.chat_bubble)),
            Tab(text: 'THEATRE', icon: Icon(Icons.movie_filter)),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Deep immersive background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surfaceContainerLow,
                    AppColors.surfaceContainerLow.withValues(alpha: 0.9),
                    AppColors.surface.withValues(alpha: 1.0),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFriendsTab(state),
                    _buildTrainersTab(state),
                    _buildChatTab(state),
                    _buildTheatreTab(state),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainersTab(SocialState state) {
    final me = ref.read(authControllerProvider).profile?.username;
    final trainers = state.users.where((u) => u.username != me).toList()
      ..sort((a, b) {
        int getRank(String status) {
          if (status == 'battling') return 0;
          if (status == 'online') return 1;
          return 2;
        }
        return getRank(a.status).compareTo(getRank(b.status));
      });

    if (trainers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox.shrink(),
            SizedBox(height: 16),
            Text('No other trainers registered yet.', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trainers.length,
      itemBuilder: (context, index) {
        final user = trainers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  onTap: () => _showTrainerIDCard(user),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    backgroundImage: user.profileImageUrl != null
                        ? CachedNetworkImageProvider(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null
                        ? Text(user.username[0].toUpperCase())
                        : null,
                  ),
                  title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Level TBD • Wins: ${user.wins}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.person_add_outlined, color: AppColors.primary),
                        onPressed: () => _sendFriendRequest(user),
                        tooltip: 'Add Friend',
                      ),
                      if (user.status == 'battling' && user.currentBattleId != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/battle/online/${user.currentBattleId}'),
                            icon: const Icon(Icons.remove_red_eye, size: 16),
                            label: const Text('WATCH'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () => _challengeUser(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('vs'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatTab(SocialState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.chatMessages.length,
            itemBuilder: (context, index) {
              final msg = state.chatMessages[index];
              final isMe = msg.sender == ref.read(authControllerProvider).profile?.username;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isMe) ...[
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.secondary.withOpacity(0.2),
                            backgroundImage: msg.profileImageUrl != null
                                ? CachedNetworkImageProvider(msg.profileImageUrl!)
                                : null,
                            child: msg.profileImageUrl == null
                                ? Text(msg.sender[0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white))
                                : null,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: PixelChatBubble(
                            isMe: isMe,
                            borderColor: isMe ? AppColors.primary.withValues(alpha: 0.6) : AppColors.secondary.withValues(alpha: 0.6),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        msg.sender.toUpperCase(),
                                        style: GoogleFonts.vt323(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondary,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                                        ),
                                        child: Text(
                                          'RANK: TRAINER',
                                          style: GoogleFonts.vt323(fontSize: 12, color: AppColors.secondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (!isMe) const SizedBox(height: 8),
                                EmojiRichText(
                                  text: ProfanityFilter.filter(msg.text),
                                  style: GoogleFonts.vt323(fontSize: 18, color: Colors.white),
                                  emojiSize: 32,
                                ),
                                if (!isMe) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _challengeUser(SocialUser(username: msg.sender, displayName: msg.sender)),
                                        icon: const Icon(Icons.flash_on, size: 14, color: AppColors.secondary),
                                        label: Text(
                                          'CHALLENGE',
                                          style: GoogleFonts.vt323(color: AppColors.secondary, fontSize: 14),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            backgroundImage: ref.read(authControllerProvider).profile?.profileImageUrl != null
                                ? CachedNetworkImageProvider(ref.read(authControllerProvider).profile!.profileImageUrl!)
                                : null,
                            child: ref.read(authControllerProvider).profile?.profileImageUrl == null
                                ? Text(msg.sender[0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white))
                                : null,
                          ),
                        ],
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                      child: Text(
                        DateFormat('HH:mm').format(msg.timestamp),
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: GoogleFonts.vt323(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Type @ or # for Pokemon...',
                      hintStyle: GoogleFonts.vt323(color: Colors.white38, fontSize: 18),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsTab(SocialState state) {
    final me = ref.read(authControllerProvider).profile?.username;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.pendingRequests.isNotEmpty) ...[
          const Text('PENDING REQUESTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.outline)),
          const SizedBox(height: 8),
          ...state.pendingRequests.map((req) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: ListTile(
              title: Text(req['displayName'] ?? req['username']!),
              subtitle: const Text('Wants to be your friend', style: TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: ElevatedButton(
                onPressed: () => _acceptFriendRequest(req['username']!),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Accept'),
              ),
            ),
          )),
          const SizedBox(height: 24),
        ],
        
        const Text('MY FRIENDS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.outline)),
        const SizedBox(height: 8),
        if (state.friends.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('No friends yet. Add some trainers from the public list!')),
          )
        else
          ...state.friends.map((friend) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: ListTile(
                leading: Badge(
                  backgroundColor: friend.status == 'online' ? Colors.green : (friend.status == 'battling' ? Colors.orange : Colors.grey),
                  child: CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    backgroundImage: friend.profileImageUrl != null
                        ? CachedNetworkImageProvider(friend.profileImageUrl!)
                        : null,
                    child: friend.profileImageUrl == null
                        ? Text(friend.username[0].toUpperCase(), style: const TextStyle(color: Colors.white))
                        : null,
                  ),
                ),
                title: Text(friend.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(friend.status.toUpperCase(), style: TextStyle(fontSize: 10, color: friend.status == 'online' ? Colors.green : Colors.grey)),
                trailing: IconButton(
                  icon: const Icon(Icons.videogame_asset_outlined, color: AppColors.primary),
                  onPressed: () => _challengeUser(friend),
                  tooltip: 'Challenge',
                ),
              ),
            ),
          )),
      ],
    );
  }

  void _sendFriendRequest(SocialUser user) {
    ref.read(socialControllerProvider.notifier).sendFriendRequest(user.username);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request sent to ${user.displayName}!')),
    );
  }

  void _acceptFriendRequest(String username) {
    ref.read(socialControllerProvider.notifier).acceptFriendRequest(username);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request accepted!')),
    );
  }

  void _sendMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      ref.read(socialControllerProvider.notifier).sendMessage(_chatController.text.trim());
      _chatController.clear();
      _scrollToBottom();
    }
  }

  void _showUserRoster(SocialUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user.displayName}\'s Active Squad', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            if (user.roster.isEmpty)
              const Center(child: Text('This trainer has no active Pokémon in their roster.'))
            else
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: user.roster.length,
                  itemBuilder: (context, i) {
                    final pokemon = user.roster[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const SizedBox.shrink(), // Watermark removed for full-screen look
                          ),
                          const SizedBox(height: 4),
                          Text(pokemon['pokemonId']?.toString() ?? '???', style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _challengeUser(SocialUser user) async {
    final battleId = await ref.read(socialControllerProvider.notifier).challengeUser(user.username);
    if (battleId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Challenged ${user.displayName}! Waiting for response...')),
      );
      if (mounted) context.push('/battle/online/$battleId');
    }
  }

  void _showTrainerIDCard(SocialUser user) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TrainerCard(user: user),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _challengeUser(user),
                    icon: const Icon(Icons.flash_on),
                    label: const Text('CHALLENGE'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CLOSE', style: TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
            ],
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fade(),
        ),
      ),
    );
  }

  Widget _buildTheatreTab(SocialState state) {
    // Collect all unique replays from all online users
    final allReplays = state.users.expand((u) => u.recentReplays).toList()
      ..sort((a, b) => b['timestamp'].toString().compareTo(a['timestamp'].toString()));

    if (allReplays.isEmpty) {
      return const Center(child: Text('No historical battles recorded in the last 7 days.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allReplays.length,
      itemBuilder: (context, index) {
        final replay = allReplays[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: ListTile(
            leading: const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 40),
            title: Text('BATTLE: ${replay['battleId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('WINNER: ${replay['winner'].toString().toUpperCase()}\nSAVED: ${replay['timestamp']}'),
            isThreeLine: true,
            trailing: ElevatedButton(
              onPressed: () {
                 // Navigation to Replay Player
                 context.push('/replays/${replay['filename']}');
              },
              child: const Text('WATCH'),
            ),
          ),
        );
      },
    );
  }
}
