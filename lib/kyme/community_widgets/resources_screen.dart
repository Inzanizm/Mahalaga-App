import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ResourcePost {
  final String tag;
  final String content;
  final String? mediaUrl; // Can be YouTube or image URL
  final bool isYouTube;

  ResourcePost({
    required this.tag,
    required this.content,
    this.mediaUrl,
    this.isYouTube = false,
  });
}

class ResourcesScreen extends StatelessWidget {
  final List<ResourcePost> posts = [
    ResourcePost(
      tag: '#TherianClub',
      content: 'Awwww this cat is realll really super duper cute i love this cat so much i want it.',
      mediaUrl: 'https://img.freepik.com/premium-photo/cat-grey-wooden-background_902049-17090.jpg',
    ),
    ResourcePost(
      tag: '#ThePetArticle',
      content: 'Look at the latest pet news\nwww://http//hdahdad/The nub pet??//.com',
      mediaUrl: 'https://i.ytimg.com/vi/YE7VzlLtp-4/maxresdefault.jpg',
    ),
    ResourcePost(
      tag: '#YouTubePets',
      content: 'Check out this video about training puppies!',
      mediaUrl: 'https://www.youtube.com/watch?v=YE7VzlLtp-4',
      isYouTube: true,
    ),
  ];

  ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFa7a28c),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7d7b6c),
        title: const Text("Resources", style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 12),
          CircleAvatar(radius: 15, backgroundImage: AssetImage('assets/profile.png')),
          SizedBox(width: 12),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.tag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(post.content, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                if (post.mediaUrl != null)
                  post.isYouTube
                      ? YoutubePlayer(
                          controller: YoutubePlayerController(
                            initialVideoId: YoutubePlayer.convertUrlToId(post.mediaUrl!)!,
                            flags: const YoutubePlayerFlags(autoPlay: false),
                          ),
                          showVideoProgressIndicator: true,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(post.mediaUrl!, fit: BoxFit.cover),
                        ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.favorite_border, color: Colors.white),
                    SizedBox(width: 8),
                    Icon(Icons.chat_bubble_outline, color: Colors.white),
                  ],
                ),
                const Divider(color: Colors.white54),
              ],
            ),
          );
        },
      ),
    );
  }
}
