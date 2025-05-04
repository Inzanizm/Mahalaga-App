import 'package:flutter/material.dart';
import 'package:mahalaga_app/kyme/community_widgets/channel_forum_screen.dart';
import 'package:mahalaga_app/kyme/community_widgets/chats_screen.dart';
import 'package:mahalaga_app/kyme/community_widgets/create_post_screen.dart';
import 'package:mahalaga_app/kyme/community_widgets/hotline_screen.dart';
import 'package:mahalaga_app/kyme/community_widgets/news_screen.dart';
import 'package:mahalaga_app/kyme/community_widgets/resources_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:marquee/marquee.dart';

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
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    await Future.wait([loadTags(), loadPosts(), loadNews(), loadCommunities()]);

    setState(() => isLoading = false);
  }

  Future<void> loadTags() async {
    try {
      final res = await supabase
          .schema('mahalaga_pca_comfor')
          .from('posts')
          .select('content');

      debugPrint('Tags response: $res'); // Log the response

      final tagSet = <String>{};
      for (var post in res) {
        final words = post['content'].toString().split(' ');
        for (var word in words) {
          if (word.startsWith('#')) {
            tagSet.add(word.replaceAll('#', ''));
          }
        }
      }

      setState(() {
        allTags = tagSet.toList();
      });
    } catch (e) {
      setState(() {
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
      });
    }
  }

  Future<void> loadPosts() async {
    try {
      final res = await supabase
          .schema('mahalaga_pca_comfor')
          .from('posts')
          .select(
            'id, content, created_at, user_id, media_urls, post_title, community_id(name), user_id(username)',
          )
          .order('created_at', ascending: false);
      debugPrint('haotdog from Supabase: $res');

      // Map username from nested user_id if available
      posts =
          res.map<Map<String, dynamic>>((post) {
            final username =
                post['user_id'] is Map && post['user_id'] != null
                    ? post['user_id']['username']
                    : null;
            return {...post, 'username': username};
          }).toList();
    } catch (_) {
      posts = List.generate(
        5,
        (i) => {
          'id': '$i',
          'content': 'Dummy post $i content with #Cat',
          'media_urls': [],
          'created_at': DateTime.now().toIso8601String(),
          'user_id': 'user_$i',
          'username': 'DummyUser$i',
          'post_title': 'Dummy Post Title $i',
        },
      );
    }
  }

  Future<void> loadNews() async {
    try {
      final res = await supabase
          .schema('mahalaga_pca_comfor')
          .from('featured_news')
          .select('title, image_url, writer, body, published_at');

      debugPrint('Raw Supabase news response: $res');

      if (res.isNotEmpty) {
        featuredNews = res;
      } else {
        debugPrint('News is empty, using fallback');
        featuredNews = [
          {
            'title': 'Sample News Title',
            'image_url': 'https://placedog.net/400/300',
            'body': 'Sample news body content.',
            'published_at': DateTime.now().toIso8601String(),
          },
          {
            'title': 'Another Sample News Title',
            'image_url': 'https://placedog.net/400/300',
            'body': 'Another sample news body content.',
            'published_at': DateTime.now().toIso8601String(),
          },
        ]; // fallback data
      }
    } catch (e, stack) {
      debugPrint('Error loading news: $e');
      debugPrint('Stack trace: $stack');
      featuredNews = [
        {
          'title': 'Sample News Title',
          'image_url': 'https://placedog.net/400/300',
          'body': 'Sample news body content.',
          'published_at': DateTime.now().toIso8601String(),
        },
        {
          'title': 'Another Sample News Title',
          'image_url': 'https://placedog.net/400/300',
          'body': 'Another sample news body content.',
          'published_at': DateTime.now().toIso8601String(),
        },
      ]; // fallback data
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
          .schema('mahalaga_pca_comfor')
          .from('post_reacts')
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
        .schema('mahalaga_pca_comfor')
        .from('post_reacts')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId!);

    if (res.isNotEmpty) {
      await supabase
          .schema('mahalaga_pca_comfor')
          .from('post_reacts')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
    } else {
      await supabase.schema('mahalaga_pca_comfor').from('post_reacts').insert({
        'post_id': postId,
        'user_id': userId,
      });
    }

    setState(() {}); // refresh count
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9B9982),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B705C),
        title: const Text('Community Forum'),
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
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewsScreen(news: news)),
              );
            },
            child: Card(
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
                      padding: const EdgeInsets.all(5),
                      color: Colors.black.withAlpha(120),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 30, // ← give it a fixed height
                        padding: const EdgeInsets.all(0),
                        color: Colors.transparent,
                        child: Marquee(
                          text: news['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          blankSpace: 50.0,
                          velocity: 30.0,
                          pauseAfterRound: Duration(seconds: 1),
                          startPadding: 35.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
              color: const Color(0xfFb7b7a4),
              child: ListTile(
                leading:
                    comm['chanIMG_Url'] != null
                        ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green.shade700,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(comm['chanIMG_Url']),
                            radius: 20,
                            backgroundColor: Colors.transparent,
                          ),
                        )
                        : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color.fromARGB(255, 144, 148, 133),
                              width: 2,
                            ),
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 199, 199, 192),
                            radius: 20,
                            child: Icon(Icons.group),
                          ),
                        ),
                onTap:
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

                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),

                title: Text(comm['name']),
                titleTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfFb7b7a4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
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
    final mediaUrl = post['media_urls'];
    final createdAt = DateTime.tryParse(post['created_at'] ?? '');
    final communityName = post['community_id']?['name'] ?? 'Unknown Community';

    return FutureBuilder<int>(
      future: getReactionCount(postId),
      builder: (context, snapshot) {
        final pawCount = snapshot.data ?? 0;
        return Card(
          color: const Color(0xfFb7b7a4),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "@${post['username'] ?? 'Unknown User'}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        timeago.format(createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black38,
                        ),
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    const Icon(Icons.pets, size: 12, color: Color(0xFF6B705C)),
                    Text(
                      communityName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B705C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      post['post_title'] ?? '',
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Post content
                Text(
                  post['content'] ?? '',
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),

                // Media preview (if any)
                if (mediaUrl != null &&
                    mediaUrl.isNotEmpty &&
                    mediaUrl[0].toString().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      mediaUrl[0].toString(),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Reactions and comments row
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
                  .schema('mahalaga_pca_comfor')
                  .from('post_comments')
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
                      .schema('mahalaga_pca_comfor')
                      .from('post_comments')
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
            backgroundColor: const Color.fromARGB(255, 128, 148, 129),
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
      backgroundColor: Color(0xFF9B9982),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      },
      child: Icon(icon),
    );
  }
}
