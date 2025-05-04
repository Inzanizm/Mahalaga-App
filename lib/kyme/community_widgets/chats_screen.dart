// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mahalaga_app/kyme/community_widgets/group_chat_screen.dart';
import 'package:mahalaga_app/kyme/community_widgets/medias/group_photo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dummy fallback data for chat groups
final List<Map<String, dynamic>> dummyGroups = [
  {
    'id': 'dummy-1',
    'name': 'The Fur Squad',
    'description': 'A fluffy team united by paws, purrs, and pet adventures.',
    'avatar_url': 'https://placedog.net/400/300',
    'member_count': 1000000,
  },
  {
    'id': 'dummy-2',
    'name': 'Whisker Wonders',
    'description': 'Exploring the magic of pets, one whisker at a time.',
    'avatar_url': 'https://placedog.net/400/300',
    'member_count': 1000000,
  },
  {
    'id': 'dummy-3',
    'name': 'Tail Waggers United',
    'description': 'Where every tail wag means friendship and fun!',
    'avatar_url': 'https://placedog.net/400/300',
    'member_count': 1000000,
  },
];

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<List<Map<String, dynamic>>> _groupsFuture;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _fetchGroups();
  }

  Future<List<Map<String, dynamic>>> _fetchGroups() async {
    try {
      final groupsRes = await supabase
          .from('chat_groups')
          .select('id, name, description, avatar_url')
          .order('created_at', ascending: false);

      if (groupsRes.isEmpty) {
        // Fallback to dummy data if no groups found
        return dummyGroups;
      }

      // For each group, fetch member count
      List<Map<String, dynamic>> groups = [];
      for (final group in groupsRes) {
        final countRes = await supabase
            .from('chat_group_members')
            .select('id')
            .eq('group_id', group['id']);
        final memberCount = countRes.length;
        groups.add({...group, 'member_count': memberCount});
      }
      return groups;
    } catch (e) {
      // On error, fallback to dummy data
      return dummyGroups;
    }
  }

  /// Checks if the current user is a member of the group
  Future<bool> _isMember(String groupId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;
    final res =
        await supabase
            .from('chat_group_members')
            .select('id')
            .eq('group_id', groupId)
            .eq('user_id', userId)
            .maybeSingle();
    return res != null;
  }

  /// Adds the current user to the group in Supabase
  Future<bool> _joinGroup(String groupId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      await supabase.from('chat_group_members').insert({
        'group_id': groupId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Navigates to the group chat screen, passing group data
  void _goToGroupChat(Map<String, dynamic> group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => GroupChatScreen(
              groupId: group['id'],
              groupName: group['name'],
              memberCount: group['member_count'], // Pass member count
              // avatarUrl: group['avatar_url'],
              groupAvatarPath: group['avatar_url'] ?? '', // Pass avatar URL
            ),
      ),
    );
  }

  /// Handles tap on a group: checks membership, joins if needed, then navigates
  void _onGroupTap(Map<String, dynamic> group) async {
    final groupId = group['id'];
    // If dummy group, just navigate (no membership logic)
    if (groupId.toString().startsWith('dummy')) {
      _goToGroupChat(group);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final isMember = await _isMember(groupId);

    Navigator.pop(context); // Remove loading dialog

    if (isMember) {
      _goToGroupChat(group);
    } else {
      // Ask user to join
      final shouldJoin = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Join Group'),
              content: const Text('Do you want to join this group?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Yes'),
                ),
              ],
            ),
      );
      if (shouldJoin == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        final joined = await _joinGroup(groupId);
        Navigator.pop(context); // Remove loading dialog
        if (joined) {
          _goToGroupChat(group);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to join group. Please try again.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9B9982),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B705C),
        leading: const BackButton(color: Colors.white),
        title: const Text('Chats', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // TODO: Implement search or group chat navigation
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://placedog.net/400/300',
              ), // Replace with user profile URL
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Error state
            return const Center(
              child: Text(
                'Failed to load groups.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          final groups = snapshot.data ?? dummyGroups;
          if (groups.isEmpty) {
            return const Center(
              child: Text(
                'No groups available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Discover Channels',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ...groups.map(
                (group) => GestureDetector(
                  onTap: () => _onGroupTap(group),
                  child: Card(
                    color: Color(0xFF6B705C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: FutureBuilder<String?>(
                        future: GroupPhoto().getSignedGroupPhotoUrl(
                          group['avatar_url'] ?? '',
                        ),
                        builder: (context, snapshot) {
                          final hasUrl =
                              snapshot.hasData &&
                              snapshot.data != null &&
                              snapshot.data!.isNotEmpty;

                          return CircleAvatar(
                            backgroundImage:
                                hasUrl ? NetworkImage(snapshot.data!) : null,
                            child:
                                !hasUrl
                                    ? Text(
                                      group['name']?[0] ?? '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    )
                                    : null,
                          );
                        },
                      ),

                      title: Text(
                        group['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${group['member_count'] ?? 0} members\n"${group['description'] ?? ''}"',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Chats with others about your favorite topics',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
