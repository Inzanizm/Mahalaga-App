import 'package:flutter/material.dart';
import 'package:mahalaga_app/kyme/community_widgets/channel_forum_screen.dart';
import 'package:mahalaga_app/kyme/community_widgets/chat_screen.dart';
import 'package:mahalaga_app/kyme/community_widgets/create_post_screen.dart';
import 'package:mahalaga_app/kyme/community_widgets/hotline_screen.dart';
import 'package:mahalaga_app/kyme/community_widgets/resources_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  State<CommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> {
  List<String> allTags = [];
  String? selectedTag;
  bool isDropdownOpen = false;

  // Dummy implementation for picking and uploading an image
  Future<String?> _pickImageAndUpload() async {
    // TODO: Implement actual image picker and upload logic
    // For now, return a placeholder image URL
    return 'https://placedog.net/400/300';
  }

  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> featuredNews = [];
  List<Map<String, dynamic>> recommendedCommunities = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
    loadCommunities();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    await Future.wait([loadTags(), loadPosts(), loadNews(), loadCommunities()]);

    setState(() => isLoading = false);
  }

  Future<void> loadTags() async {
    try {
      final res = await supabase
          .from('mahalaga_pca_comfor.posts')
          .select('content');

      final tagSet = <String>{};
      for (var post in res) {
        final words = post['content'].toString().split(' ');
        for (var word in words) {
          if (word.startsWith('#')) {
            tagSet.add(word.replaceAll('#', ''));
          }
        }
      }

      allTags = tagSet.toList();
    } catch (_) {
      allTags = [
        "Cat",
        "Dogs",
        "Hamster",
        "Fish",
        "BullDog",
        "Birds",
        "Food",
        "Med",
      ];
    }
  }

  Future<void> loadPosts() async {
    try {
      final res = await supabase
          .from('mahalaga_pca_comfor.posts')
          .select('id, content, created_at, user_id, media_urls')
          .order('created_at', ascending: false);

      posts = res;
    } catch (_) {
      posts = List.generate(
        5,
        (i) => {
          'id': '$i',
          'content': 'Dummy post $i content with #Cat',
          'media_urls': [],
          'created_at': DateTime.now().toIso8601String(),
          'user_id': 'user_$i',
        },
      );
    }
  }

  Future<void> loadNews() async {
    try {
      final res = await supabase
          .from('mahalaga_pca_comfor.featured_news')
          .select('title, image_url, published_at');

      featuredNews = res;
    } catch (_) {
      featuredNews = [
        {
          'title': 'Pet Adoption Drive!',
          'image_url': 'https://placedog.net/640/480',
        },
        {
          'title': 'Healthy Pet Tips',
          'image_url': 'https://placedog.net/640/481',
        },
      ];
    }
  }

  Future<void> loadCommunities() async {
    try {
      final response = await Supabase.instance.client
          .schema('mahalaga_pca_comfor')
          .from('communities')
          .select('name, description, chanIMG_Url')
          .order('created_at', ascending: false)
          .limit(5);

      final List<Map<String, dynamic>> res = List<Map<String, dynamic>>.from(
        response,
      );

      debugPrint('Communities response: $res');

      if (res.isEmpty) {
        recommendedCommunities = [
          {
            'name': 'The Fur Squad',
            'description': 'A fluffy team united by paws and purrs',
            'chanIMG_Url': null,
          },
          {
            'name': 'Tail Waggers',
            'description': 'Where tail wags mean friendship!',
            'chanIMG_Url': null,
          },
          {
            'name': 'Mahalagang Gang',
            'description':
                'Yow, mga erp! Pet mo na, pagod ka pa. Welkam to da gengg, sheeshhh!',
            'chanIMG_Url': null,
          },
        ];
      } else {
        recommendedCommunities = res;
      }
    } catch (e) {
      debugPrint('Failed to load communities: $e');
      recommendedCommunities = [];
    }

    if (mounted) setState(() {});
  }

  Future<int> getReactionCount(String postId) async {
    try {
      final res = await supabase
          .from('mahalaga_pca_comfor.post_reacts')
          .select('id')
          .eq('post_id', postId)
          .count(CountOption.exact);

      return res.count;
    } catch (_) {
      return 0;
    }
  }

  Future<void> toggleReaction(String postId) async {
    final userId = supabase.auth.currentUser?.id;
    final res = await supabase
        .from('mahalaga_pca_comfor.post_reacts')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId!);

    if (res.isNotEmpty) {
      await supabase
          .from('mahalaga_pca_comfor.post_reacts')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
    } else {
      await supabase.from('mahalaga_pca_comfor.post_reacts').insert({
        'post_id': postId,
        'user_id': userId,
      });
    }

    setState(() {}); // refresh count
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFa7a28c),

      appBar: AppBar(
        title: const Text('Community Forum'),
        backgroundColor: Color(0xFF7d7b6c),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: loadData,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildTagChips(),
                        const SizedBox(height: 16),
                        _buildSectionTitle("Featured News"),
                        _buildNewsCarousel(),
                        const SizedBox(height: 16),
                        _buildSectionTitle("Recommended Communities"),
                        _buildCommunities(),
                        const SizedBox(height: 16),
                        _buildSectionTitle("Posts"),
                        ..._filteredPosts().map(_buildPostCard),
                      ],
                    ),
                  ),
                  buildFloatingDropdown(),
                ],
              ),
    );
  }

  Widget _buildTagChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allTags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final tag = allTags[index];
          final isSelected = selectedTag == tag;

          return ChoiceChip(
            label: Text(tag),
            selected: isSelected,
            onSelected:
                (_) => setState(() {
                  selectedTag = isSelected ? null : tag;
                }),
            selectedColor: const Color.fromARGB(255, 176, 206, 177),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filteredPosts() {
    if (selectedTag == null) return posts;
    return posts
        .where((p) => p['content'].toString().contains('#$selectedTag'))
        .toList();
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildNewsCarousel() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: featuredNews.length,
        itemBuilder: (_, index) {
          final news = featuredNews[index];
          return Card(
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Image.network(
                  news['image_url'],
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(12),
                    color: Colors.black.withAlpha(150),
                    child: Text(
                      news['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommunities() {
    return Column(
      children:
          recommendedCommunities.map((comm) {
            // Limit description to 60 chars
            final String desc = comm['description'] ?? '';
            final bool isLong = desc.length > 60;
            String shortDesc = isLong ? '${desc.substring(0, 60)}...' : desc;

            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                leading:
                    comm['chanIMG_Url'] != null
                        ? CircleAvatar(
                          backgroundImage: NetworkImage(comm['chanIMG_Url']),
                          radius: 24,
                        )
                        : const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.group),
                        ),
                title: Text(comm['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shortDesc),
                    if (isLong)
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50, 20),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: Text(comm['name']),
                                  content: Text(desc),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: const Text('See more'),
                      ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChannelForumScreen(
                                communityName: comm['name'],
                                description: desc,
                              ), // Replace with actual community screen
                        ),
                      ),
                  child: const Text("Join"),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final postId = post['id'];

    return FutureBuilder<int>(
      future: getReactionCount(postId),
      builder: (context, snapshot) {
        final pawCount = snapshot.data ?? 0;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['content'], style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.pets),
                      onPressed: () => toggleReaction(postId),
                    ),
                    Text('$pawCount'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => _buildCommentsSection(postId),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentsSection(String postId) {
    final commentController = TextEditingController();
    List<String> images = [];

    // Find the post by its ID
    final post = posts.firstWhere(
      (p) => p['id'] == postId,
      orElse: () => <String, dynamic>{},
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Display the post content at the top
          Text(
            "Post:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(post['content'] ?? '', style: const TextStyle(fontSize: 14)),
          const Divider(thickness: 1),

          const Text(
            "Comments",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),

          // Comments list
          Expanded(
            child: FutureBuilder<List>(
              future: supabase
                  .from('mahalaga_pca_comfor.post_comments')
                  .select()
                  .eq('post_id', postId)
                  .order('created_at'),
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children:
                      snapshot.data!
                          .map((c) => ListTile(title: Text(c['comment'])))
                          .toList(),
                );
              },
            ),
          ),

          // Comment input field and buttons
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  final imageUrl = await _pickImageAndUpload();
                  if (imageUrl != null) {
                    setState(() {
                      images.add(imageUrl);
                    });
                  }
                },
                icon: const Icon(Icons.add_a_photo),
              ),
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: "Write a comment...",
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  final userId = supabase.auth.currentUser?.id;
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("You must be logged in to comment."),
                      ),
                    );
                    return;
                  }

                  await supabase
                      .from('mahalaga_pca_comfor.post_comments')
                      .insert({
                        'post_id': postId,
                        'user_id': userId,
                        'comment': commentController.text,
                      });
                  commentController.clear();
                  setState(() {}); // Refresh comments
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildFloatingDropdown() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        children: [
          if (isDropdownOpen) ...[
            _buildDropdownNav(Icons.menu_book, "Resources", ResourcesScreen()),
            const SizedBox(height: 10),
            _buildDropdownNav(Icons.phone, "Hotline", HotlineScreen()),
            const SizedBox(height: 10),
            _buildDropdownNav(Icons.chat, "Chat", ChatScreen()),
            const SizedBox(height: 10),
            _buildDropdownNav(Icons.add, "Add Post", const CreatePostScreen()),
            const SizedBox(height: 10),
          ],
          FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: Colors.green,
            onPressed: () => setState(() => isDropdownOpen = !isDropdownOpen),
            child: Icon(isDropdownOpen ? Icons.close : Icons.menu),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownNav(IconData icon, String label, Widget screen) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      heroTag: label,
      mini: true,
      backgroundColor: Colors.green.shade700,
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      },
      child: Icon(icon),
    );
  }
}
