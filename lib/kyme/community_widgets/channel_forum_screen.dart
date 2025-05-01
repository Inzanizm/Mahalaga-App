import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Post {
  final String id;
  final String content;
  final String? mediaUrl;
  int pawCount;
  bool pawed;
  List<Comment> comments;

  Post({
    required this.id,
    required this.content,
    this.mediaUrl,
    this.pawCount = 0,
    this.pawed = false,
    this.comments = const [],
  });
}

class Comment {
  final String id;
  final String content;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.content,
    this.replies = const [],
  });
}

class ChannelForumScreen extends StatefulWidget {
  final String communityName;
  final String description;
  final String? chanImgUrl;

  const ChannelForumScreen({
    super.key,
    required this.communityName,
    required this.description,
    this.chanImgUrl,
  });

  @override
  State<ChannelForumScreen> createState() => _ChannelForumScreenState();
}

class _ChannelForumScreenState extends State<ChannelForumScreen> {
  List<Post> posts = []; // Simulate empty DB table

  void _showCreatePostDialog() async {
    String content = '';
    XFile? pickedFile;
    final picker = ImagePicker();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Create Post'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'What\'s on your mind?',
                    ),
                    onChanged: (val) => content = val,
                  ),
                  const SizedBox(height: 12),
                  if (pickedFile != null)
                    Image.file(
                      // ignore: deprecated_member_use
                      File(pickedFile!.path),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  TextButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Upload Media'),
                    onPressed: () async {
                      final file = await picker.pickImage(source: ImageSource.gallery);
                      if (file != null) {
                        setStateDialog(() {
                          pickedFile = file;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (content.trim().isNotEmpty) {
                    setState(() {
                      posts.insert(
                        0,
                        Post(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          content: content,
                          mediaUrl: pickedFile?.path,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Post'),
              ),
            ],
          );
        });
      },
    );
  }

  void _togglePaw(Post post) {
    setState(() {
      if (post.pawed) {
        post.pawCount--;
      } else {
        post.pawCount++;
      }
      post.pawed = !post.pawed;
    });
  }

  void _showCommentsDialog(Post post) {
    String commentText = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateSheet) {
          Widget buildComment(Comment comment, [int depth = 0]) {
            return Padding(
              padding: EdgeInsets.only(left: 16.0 * depth, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.content),
                  TextButton(
                    onPressed: () {
                      String replyText = '';
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Reply'),
                            content: TextField(
                              onChanged: (val) => replyText = val,
                              decoration: const InputDecoration(labelText: 'Reply'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (replyText.trim().isNotEmpty) {
                                    setState(() {
                                      comment.replies.add(
                                        Comment(
                                          id: DateTime.now().toString(),
                                          content: replyText,
                                        ),
                                      );
                                    });
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Reply'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Reply'),
                  ),
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
                const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
                ...post.comments.map((c) => buildComment(c)),
                TextField(
                  decoration: const InputDecoration(labelText: 'Add a comment'),
                  onChanged: (val) => commentText = val,
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      setState(() {
                        post.comments = [
                          ...post.comments,
                          Comment(id: DateTime.now().toString(), content: val),
                        ];
                      });
                      setStateSheet(() {});
                    }
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    if (commentText.trim().isNotEmpty) {
                      setState(() {
                        post.comments = [
                          ...post.comments,
                          Comment(id: DateTime.now().toString(), content: commentText),
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
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.communityName),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.chanImgUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.chanImgUrl!,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Divider(),
            Expanded(
              child: posts.isEmpty
                  ? const Center(
                      child: Text(
                        'No posts yet. Be the first to post!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, idx) {
                        final post = posts[idx];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (post.mediaUrl != null)
                                  Image.file(
                                    // ignore: deprecated_member_use
                                    File(post.mediaUrl!),
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                Text(post.content),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.pets,
                                        color: post.pawed ? Colors.orange : Colors.grey,
                                      ),
                                      onPressed: () => _togglePaw(post),
                                    ),
                                    Text('${post.pawCount}'),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(Icons.comment),
                                      onPressed: () => _showCommentsDialog(post),
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
}
