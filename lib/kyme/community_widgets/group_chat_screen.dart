import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mahalaga_app/kyme/community_widgets/medias/group_photo.dart';
import 'package:mahalaga_app/kyme/community_widgets/medias/pfp_images.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Dummy data for fallback mode (offline or Supabase error)
final List<Map<String, dynamic>> dummyMessages = [
  {
    'id': 1,
    'group_id': 'group1',
    'sender_id': 'user1',
    'username': 'Bird lover789',
    'content': 'Don\'t forget to feed your birds today!',
    'created_at':
        DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
  },
  {
    'id': 2,
    'group_id': 'group1',
    'sender_id': 'user2',
    'username': 'Cat lover456',
    'content': 'Extra cuddles for all the cats tonight 😺',
    'created_at':
        DateTime.now().subtract(const Duration(minutes: 8)).toIso8601String(),
  },
  {
    'id': 3,
    'group_id': 'group1',
    'sender_id': 'user3',
    'username': 'Dog lover123',
    'content': 'My dog had the zoomies all morning!',
    'created_at':
        DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
  },
];

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final int memberCount;
  final String? avatarUrl;
  final String
  groupAvatarPath; // this is the path in storage like 'group123/photo.png'

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupAvatarPath,
    required this.groupName,
    required this.memberCount,
    this.avatarUrl,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _fallbackMode = false;
  final List<Map<String, dynamic>> _fallbackMessages = List.from(dummyMessages);

  String? _userId;
  String? _username;
  String? _avatarUrl;
  String? _error;
  String? _signedGroupPhotoUrl;

  @override
  void initState() {
    super.initState();
    _initUser();
    _loadGroupPhoto();
  }

  Future<void> _initUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');
      _userId = user.id;

      // Fetch username from profiles
      final profile =
          await supabase
              .schema('mahalaga_pca_comfor')
              .from('profiles')
              .select('username, avatar_url')
              .eq('id', _userId as Object)
              .maybeSingle();
      _username = profile?['username'] ?? 'Anonymous';
      _avatarUrl = profile?['avatar_url'];

      // Test Supabase connection
      await supabase.from('messages').select('id').limit(1);

      setState(() {
        _fallbackMode = false;
      });
    } catch (e) {
      setState(() {
        _fallbackMode = true;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadGroupPhoto() async {
    if (widget.groupAvatarPath.isNotEmpty) {
      debugPrint('Group Avatar Path: ${widget.groupAvatarPath}');
      final loader = GroupPhoto();
      final url = await loader.getSignedGroupPhotoUrl(widget.groupAvatarPath);
      debugPrint('Signed Group Photo URL: $url');
      if (mounted) {
        setState(() {
          _signedGroupPhotoUrl = url;
        });
      }
    } else {
      debugPrint('Group Avatar Path is empty.');
    }
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    final now = DateTime.now();

    if (_fallbackMode) {
      setState(() {
        _fallbackMessages.add({
          'id': DateTime.now().millisecondsSinceEpoch,
          'group_id': widget.groupId,
          'sender_id': _userId ?? 'offline_user',
          'username': _username ?? 'You',
          'avatar_url': _avatarUrl,
          'content': content,
          'created_at': now.toIso8601String(),
        });
      });
      _messageController.clear();
      _scrollToBottom();
      return;
    }

    try {
      await supabase.from('messages').insert({
        'group_id': widget.groupId,
        'avatar_url': _avatarUrl,
        'sender_id': _userId,
        'username': _username,
        'content': content,
        'created_at': now.toIso8601String(),
      });
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _error = 'Failed to send message: $e';
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageList() {
    if (_fallbackMode) {
      final messages =
          _fallbackMessages
              .where((msg) => msg['group_id'] == widget.groupId)
              .toList()
            ..sort(
              (a, b) => DateTime.parse(
                a['created_at'],
              ).compareTo(DateTime.parse(b['created_at'])),
            );
      return ListView.builder(
        controller: _scrollController,
        itemCount: messages.length,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        itemBuilder: (context, index) {
          final msg = messages[index];
          final isMe = msg['sender_id'] == _userId;
          return _ChatMessageBubble(
            username: msg['username'],
            content: msg['content'],
            isMe: isMe,
            timestamp: DateTime.parse(msg['created_at']),
            avatarUrl:
                msg['avatar_url'], // Use a placeholder or fetch if needed
          );
        },
      );
    }

    final messageStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('group_id', widget.groupId)
        .order('created_at', ascending: true);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          setState(() {
            _fallbackMode = true;
            _error = 'Supabase stream error: ${snapshot.error}';
          });
          return _buildMessageList();
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data!;
        if (messages.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }
        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg['sender_id'] == _userId;
            return _ChatMessageBubble(
              username: msg['username'] ?? 'Anonymous',
              content: msg['content'] ?? '',
              isMe: isMe,
              timestamp:
                  DateTime.tryParse(msg['created_at'] ?? '') ?? DateTime.now(),
              avatarUrl: msg['avatar_url'], // Optionally fetch avatar if needed
            );
          },
        );
      },
    );
  }

  Widget _buildInputBox() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        color: const Color(0xFF6B705C),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 69, 95, 90),
                      width: 1,
                    ),
                  ),
                  isCollapsed: false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  filled: true,
                  fillColor: Color(0xFFA5A58D),
                  hintText: 'Type a message...',
                ),
                onSubmitted: (val) => _sendMessage(val),
              ),
            ),
            IconButton(
              iconSize: 35,
              icon: const Icon(Icons.send_outlined, color: Colors.white),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9B9982),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B705C),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (_signedGroupPhotoUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(_signedGroupPhotoUrl!),
                radius: 16,
              )
            else
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                child: Icon(Icons.group, color: Colors.white, size: 16),
              ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groupName,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  '${widget.memberCount} members',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              color: Colors.red[100],
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(child: _buildMessageList()),
          _buildInputBox(),
        ],
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final String username;
  final String content;
  final bool isMe;
  final DateTime timestamp;
  final String? avatarUrl;

  const _ChatMessageBubble({
    required this.username,
    required this.content,
    required this.isMe,
    required this.timestamp,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe ? Color(0xFF6B705C) : Color(0xFFb7b7a4);
    final textColor = isMe ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) _AvatarCircle(avatarUrl: avatarUrl, username: username),
          Flexible(
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4, bottom: 2),
                  child: Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  child: Text(
                    content,
                    style: TextStyle(fontSize: 15, color: textColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 6, right: 6),
                  child: Text(
                    _formatTime(timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) _AvatarCircle(avatarUrl: avatarUrl, username: username),
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }
}

class _AvatarCircle extends StatefulWidget {
  final String? avatarUrl; // this is the path in Supabase Storage
  final String username;

  const _AvatarCircle({this.avatarUrl, required this.username});

  @override
  State<_AvatarCircle> createState() => _AvatarCircleState();
}

class _AvatarCircleState extends State<_AvatarCircle> {
  String? _signedUrl;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      String avatarPath = widget.avatarUrl!;
      if (!avatarPath.startsWith('http')) {
        // Prepend the base URL of your Supabase storage bucket
        avatarPath =
            'https://<your-supabase-project-id>.supabase.co/storage/v1/object/public/avatars/$avatarPath';
      }
      debugPrint('Avatar path: $avatarPath');
      final loader = PfpImage();
      try {
        final url = await loader.getSignedPfpUrl(avatarPath);
        debugPrint('Signed URL: $url');
        if (mounted) {
          setState(() {
            _signedUrl = url;
          });
        }
      } catch (e) {
        debugPrint('Error getting signed URL for avatar: $e');
      }
    } else {
      debugPrint('Avatar URL is null or empty.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials =
        widget.username.isNotEmpty
            ? widget.username
                .split(' ')
                .map((e) => e.isNotEmpty ? e[0] : '')
                .take(2)
                .join()
                .toUpperCase()
            : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Color(0xFFEFF8D6),
        backgroundImage: _signedUrl != null ? NetworkImage(_signedUrl!) : null,
        child:
            _signedUrl == null
                ? Text(
                  initials,
                  style: const TextStyle(color: Colors.black45, fontSize: 20),
                )
                : null,
      ),
    );
  }
}
