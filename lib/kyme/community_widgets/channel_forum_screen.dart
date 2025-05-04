import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mahalaga_app/kyme/community_widgets/create_post_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart ';

//----------START NG POST CLASS------------------
class Post {
  final String id;
  final String content;
  final String? mediaUrl;
  int pawCount;
  bool pawed;
  List<Comment> comments;
  final String? postTitle;

  final String? userName;

  // Community details
  final String communityName;
  final String communityDescription;
  final String? communityImage;

  Post({
    required this.id,
    required this.content,
    this.mediaUrl,
    this.pawCount = 0,
    this.pawed = false,
    this.comments = const [],
    this.communityName = 'Unknown Community',
    this.communityDescription = '',
    this.communityImage,
    this.postTitle,
    required this.userName,
  });
}
//----------END NG POST CLASS------------------

//----------START NG COMMENT CLASS------------------
class Comment {
  final String id;
  final String content;
  final List<Comment> replies;

  Comment({required this.id, required this.content, this.replies = const []});
}
//----------END NG COMMENT CLASS------------------

//----------START NG CHANNEL FORUM SCREEN------------------
class ChannelForumScreen extends StatefulWidget {
  final String communityName;
  final String description;
  final String? chanImgUrl;
  final String? postTitle;

  const ChannelForumScreen({
    super.key,
    required this.communityName,
    required this.description,
    this.chanImgUrl,
    this.postTitle,
  });

  @override
  State<ChannelForumScreen> createState() => _ChannelForumScreenState();
}
//----------END NG CHANNEL FORUM SCREEN------------------

//----------START NG CHANNEL FORUM SCREEN STATE------------------
class _ChannelForumScreenState extends State<ChannelForumScreen> {
  List<Post> posts = []; // Simulate empty DB table

  @override
  void initState() {
    super.initState();
    fetchPostsFromSupabase();
  }

  Future<void> fetchPostsFromSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      debugPrint('User not authenticated!');
      return;
    }

    try {
      // Get the community ID from its name
      final communityResponse =
          await Supabase.instance.client
              .schema('mahalaga_pca_comfor')
              .from('communities')
              .select('id')
              .eq('name', widget.communityName)
              .single();

      final communityId = communityResponse['id'];

      // Now fetch the posts for that community
      final response = await Supabase.instance.client
          .schema('mahalaga_pca_comfor')
          .from('posts')
          .select(
            '*, post_title, post_reacts(*), post_comments(*), communities(*), profiles(username)',
          )
          .eq('community_id', communityId)
          .order('created_at', ascending: false);

      debugPrint('HUUYYYYY Posts response: $response');

      final fetchedPosts =
          (response as List<dynamic>).map((data) {
            final reacts = data['post_reacts'] as List<dynamic>? ?? [];
            final pawCount = reacts.length;
            final hasReacted = reacts.any((r) => r['user_id'] == user.id);

            // Ensure community_id is a map or handle it gracefully
            final community = data['communities'] ?? {};
            final profile = data['profiles'] ?? {};
            final userName = profile['username'] ?? 'Unknown User';
            final postTitle = data['post_title'] ?? "Untitled";

            return Post(
              id: data['id'].toString(),
              content: data['content'] ?? '',
              mediaUrl:
                  data['media_urls'] != null &&
                          data['media_urls'] is List &&
                          data['media_urls'].isNotEmpty
                      ? data['media_urls'][0]
                      : null,

              pawCount: pawCount,
              pawed: hasReacted,
              comments:
                  (data['post_comments'] as List<dynamic>? ?? []).map((c) {
                    return Comment(
                      id: c['id'].toString(),
                      content: c['comment'] ?? '',
                    );
                  }).toList(),
              communityName:
                  community is Map<String, dynamic>
                      ? community['name'] ?? 'Unknown Community'
                      : 'Unknown Community',
              communityDescription:
                  community is Map<String, dynamic>
                      ? community['description'] ?? ''
                      : '',
              communityImage:
                  community is Map<String, dynamic>
                      ? community['chanIMG_Url']
                      : null,
              userName: userName,
              postTitle: postTitle,
            );
          }).toList();

      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    }
  }

  Future<void> _togglePaw(Post post, dynamic supabase) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final res = await supabase
          .schema('mahalaga_pca_comfor')
          .from('post_reacts')
          .select()
          .eq('post_id', post.id)
          .eq('user_id', userId);

      if (res.isNotEmpty) {
        // User has already pawed — remove the reaction
        await supabase
            .schema('mahalaga_pca_comfor')
            .from('post_reacts')
            .delete()
            .eq('post_id', post.id)
            .eq('user_id', userId);

        setState(() {
          post.pawCount--;
          post.pawed = false;
        });
      } else {
        // User has not pawed — add a reaction
        await supabase.schema('mahalaga_pca_comfor').from('post_reacts').insert(
          {'post_id': post.id, 'user_id': userId},
        );

        setState(() {
          post.pawCount++;
          post.pawed = true;
        });
      }
    } catch (e) {
      debugPrint('Error toggling paw: $e');
      // Optionally revert UI if needed
    }
  }

  void _showCommentsDialog(Post post) {
    String commentText = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            Widget buildComment(Comment comment, [int depth = 0]) {
              return Padding(
                padding: EdgeInsets.only(left: 16.0 * depth, top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.content),
                    ...comment.replies.map((r) => buildComment(r, depth + 1)),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Comments',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...post.comments.map((c) => buildComment(c)),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Add a comment',
                    ),
                    onChanged: (val) => commentText = val,
                    onSubmitted: (val) async {
                      if (val.trim().isNotEmpty) {
                        await _addCommentToSupabase(post.id, val);
                        setState(() {
                          post.comments = [
                            ...post.comments,
                            Comment(
                              id: DateTime.now().toString(),
                              content: val,
                            ),
                          ];
                        });
                        setStateSheet(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (commentText.trim().isNotEmpty) {
                        await _addCommentToSupabase(post.id, commentText);
                        setState(() {
                          post.comments = [
                            ...post.comments,
                            Comment(
                              id: DateTime.now().toString(),
                              content: commentText,
                            ),
                          ];
                        });
                        setStateSheet(() {});
                      }
                    },
                    child: const Text('Post Comment'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addCommentToSupabase(String postId, String comment) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await Supabase.instance.client
          .schema('mahalaga_pca_comfor')
          .from('post_comments')
          .insert({
            'post_id': postId,
            'user_id': userId,
            'comment': comment,
            'created_at': DateTime.now().toIso8601String(),
          });
      debugPrint('Comment added successfully');
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffa5a58d),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B705C),
        title: Text('${widget.communityName} Community'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          );
        },

        shape: const CircleBorder(),
        backgroundColor: const Color.fromARGB(255, 122, 155, 148),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.chanImgUrl != null
                    ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.chanImgUrl!,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    : const CircleAvatar(
                      radius: 25,
                      backgroundColor: Color.fromARGB(255, 54, 51, 51),
                      child: Icon(Icons.image, size: 30, color: Colors.white),
                    ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.communityName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.group, color: Colors.white),
                        Text(
                          '${posts.length} members',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${widget.description}"',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            const Divider(),
            Expanded(
              child:
                  posts.isEmpty
                      ? const Center(
                        child: Text(
                          'No posts yet. Be the first to post!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, idx) {
                          final post = posts[idx];
                          return Card(
                            color: const Color(0xfFb7b7a4),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.postTitle?.isNotEmpty == true
                                        ? post.postTitle!
                                        : 'Untitled',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color.fromARGB(255, 38, 38, 38),
                                      letterSpacing: 0.5,
                                    ),
                                  ),

                                  Text(
                                    post.userName != null
                                        ? 'Posted by ${post.userName}'
                                        : 'Anon User',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                    ),
                                  ),
                                  ...[
                                    if (post.mediaUrl != null &&
                                        post.mediaUrl!.isNotEmpty)
                                      Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ), // rounded edges
                                          border: Border.all(
                                            width: 3.0, // Border thickness
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child:
                                              (post.mediaUrl!.startsWith(
                                                        'http',
                                                      ) ||
                                                      post.mediaUrl!.startsWith(
                                                        'https',
                                                      ))
                                                  ? Image.network(
                                                    post.mediaUrl!,
                                                    height: 180,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Image.file(
                                                    File(post.mediaUrl!),
                                                    height: 180,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                        ),
                                      ),
                                  ],
                                  Text(post.content),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.pets,
                                          color:
                                              post.pawed
                                                  ? const Color.fromARGB(
                                                    255,
                                                    122,
                                                    26,
                                                    106,
                                                  )
                                                  : const Color.fromARGB(
                                                    255,
                                                    49,
                                                    46,
                                                    46,
                                                  ),
                                        ),
                                        onPressed:
                                            () => _togglePaw(
                                              post,
                                              Supabase.instance.client,
                                            ),
                                      ),

                                      Text('${post.pawCount}'),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: const Icon(Icons.comment),
                                        onPressed:
                                            () => _showCommentsDialog(post),
                                      ),
                                      Text('${post.comments.length}'),
                                    ],
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
      ),
    );
  }

  Future<void> savePostAndUploadMedia(
    String content,
    XFile? file,
    String communityName,
    String communityId,
    String postTile,
  ) async {
    String? uploadedUrl;

    // Upload media if provided
    if (file != null) {
      final bytes = await File(file.path).readAsBytes();
      final fileName =
          'media/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      try {
        final response = await Supabase.instance.client.storage
            .from('media')
            .uploadBinary(fileName, bytes);

        if (response.isNotEmpty) {
          uploadedUrl = Supabase.instance.client.storage
              .from('media')
              .getPublicUrl(fileName);
        } else {
          debugPrint('Failed to upload file.');
        }
      } catch (e) {
        debugPrint('Error uploading file: $e');
      }
    }

    // Always insert post — even without media

    // Fetch the community UUID by name
    final communityRes =
        await Supabase.instance.client
            .schema('mahalaga_pca_comfor')
            .from('communities')
            .select('id')
            .eq('name', communityName) // if 'communityId' is actually the name!
            .single();

    final communityUuid = communityRes['id'];

    final insert =
        await Supabase.instance.client
            .schema('mahalaga_pca_comfor')
            .from('posts')
            .insert({
              'content': content,
              'user_id': Supabase.instance.client.auth.currentUser?.id,
              'community_id': communityUuid, // ← Correct UUID now
              'media_urls': uploadedUrl != null ? [uploadedUrl] : [],
              'created_at': DateTime.now().toIso8601String(),
              'post_title': postTile,
            })
            .eq('community_id', 'community_id')
            .select(
              'id, content, media_urls, post_title, user_id, profiles(username)',
            )
            .single();

    final newPost = Post(
      id: insert['id'].toString(),
      userName: insert['profiles']['username'] ?? 'Unknown User',
      content: insert['content'],
      mediaUrl:
          insert['media_urls'].isNotEmpty ? insert['media_urls'][0] : null,
      postTitle: insert['post_title'],
    );

    setState(() {
      posts.insert(0, newPost);
    });
    await fetchPostsFromSupabase();
  }
}

Future<void> savePosttoSupabase(String content, String? mediaPath) async {
  String? uploadedUrl;
  String? postTitle;

  if (mediaPath != null) {
    uploadedUrl = await uploadMediaToSupabase(mediaPath);
  }

  final response = await Supabase.instance.client
      .schema('mahalaga_pca_comfor')
      .from('posts')
      .insert({
        'content': content,
        'media_urls': uploadedUrl,
        'created_at': DateTime.now().toIso8601String(),
        'post_title': postTitle,
      })
      .eq('community_id', 'community_id'); // Replace with actual community ID;

  debugPrint('Saved post: $response');
}

Future<String?> uploadMediaToSupabase(String filePath) async {
  try {
    final file = File(filePath);
    final fileBytes = await file.readAsBytes();
    final fileName =
        'media/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';

    final response = await Supabase.instance.client.storage
        .from('media')
        .uploadBinary(fileName, fileBytes);

    if (response.isNotEmpty) {
      final publicUrl = Supabase.instance.client.storage
          .from('media')
          .getPublicUrl(fileName);
      return publicUrl;
    } else {
      debugPrint('Failed to upload file.');
      return null;
    }
  } catch (e) {
    debugPrint('Upload error: $e');
    return null;
  }
}
