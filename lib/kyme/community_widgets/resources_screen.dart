import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ResourcePost {
  final String tag;
  final String content;
  final String? mediaUrl;
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
      content:
          'How to Feed an Overweight Cat\nhttps://www.wikihow.pet/Feed-an-Overweight-Cat',
      mediaUrl:
          'https://www.wikihow.pet/images/thumb/4/40/Feed-an-Overweight-Cat-Step-8-Version-2.jpg/aid4644503-v4-728px-Feed-an-Overweight-Cat-Step-8-Version-2.jpg',
    ),
    ResourcePost(
      tag: '#ThePetArticle',
      content:
          'Look at the latest pet news\nhttps://www.philstar.com/lifestyle/pet-life/2025/04/29/2439216/rise-yoghurt-based-wet-food-cats-and-dogs',
      mediaUrl:
          'https://media.philstar.com/photos/2025/04/29/petmarra-lead_2025-04-29_11-20-40.jpg',
    ),
    ResourcePost(
      tag: '#YouTubePets',
      content: 'Check out this video about training dogs!',
      mediaUrl: 'https://youtu.be/jFMA5ggFsXU?si=xtak9zL375DF2dO6',
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
                Text(
                  post.tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(post.content, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                if (post.mediaUrl != null)
                  post.isYouTube
                      ? YoutubePlayer(
                        controller: YoutubePlayerController(
                          initialVideoId:
                              YoutubePlayer.convertUrlToId(post.mediaUrl!)!,
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
