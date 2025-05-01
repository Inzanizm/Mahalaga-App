import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final List<Map<String, String>> channels = [
    {
      'name': 'The Fur Squad',
      'members': '1m members',
      'description': 'A fluffy team united by paws, purrs, and pet adventures.',
      'avatarUrl': 'https://example.com/fur_squad.jpg',
    },
    {
      'name': 'Whisker Wonders',
      'members': '1m members',
      'description': 'Exploring the magic of pets, one whisker at a time.',
      'avatarUrl': 'https://example.com/whisker_wonders.jpg',
    },
    {
      'name': 'Tail Waggers United',
      'members': '1m members',
      'description': 'Where every tail wag means friendship and fun!',
      'avatarUrl': 'https://example.com/tail_waggers.jpg',
    },
  ];

  ChatScreen({super.key});

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9B9982),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B9982),
        leading: const BackButton(color: Colors.white),
        title: const Text('Chats', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://example.com/profile.jpg'), // Replace with user profile URL
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Discover Channels',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ...channels.map((channel) => GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/channel_chat', arguments: channel['name']);
                },
                child: Card(
                  color: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(channel['avatarUrl']!),
                    ),
                    title: Text(channel['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('${channel['members']} \n"${channel['description']}"',
                        style: const TextStyle(color: Colors.white70)),
                    isThreeLine: true,
                  ),
                ),
              )),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Chats with other about your favorite topics',
              style: TextStyle(color: Colors.white70),
            ),
          )
        ],
      ),
    );
  }
}
