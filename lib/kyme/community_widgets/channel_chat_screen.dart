import 'package:flutter/material.dart';

class ChannelChatScreen extends StatelessWidget {
  final String channelName;

  const ChannelChatScreen({super.key, required this.channelName});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mockMessages = [
      {
        "username": "Bird lover789",
        "avatar": "🐦",
        "message":
            "Hey bird lovers! Just a reminder that our feathered friends aren’t just pretty faces—they’re smart, curious, and full of personality."
      },
      {
        "username": "Cat lover456",
        "avatar": "🐱",
        "message":
            "Hey fellow cat parents! Don’t forget to give your furballs some extra cuddles today (if they allow it 🎉)."
      },
      {
        "username": "Dog lover123",
        "avatar": "🐶",
        "message":
            "Hey Dog Squad! Morning zoomies are in full effect! 🐾 Make sure your pups get their walks and some extra playtime today! Don’t forget water breaks, belly rubs, and maybe a sneaky treat or two. 🍖\nShare your fluffballs’ pics—we love seeing those puppy eyes and wagging tails! 🐕‍🦺\n#PawsitivVibesOnly\n#BarkAndChill\n#TailWaggingTales"
      },
      {
        "username": "Petlover123",
        "avatar": "🦎",
        "message":
            "Hope everyone and their fur, feathered, and scaly friends are doing great today! 🐾🦜🐍"
      }
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        leading: BackButton(color: Colors.white),
        title: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.white, radius: 10),
            const SizedBox(width: 10),
            Text(channelName, style: const TextStyle(color: Colors.white)),
            const Spacer(),
            Text("1m members", style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: mockMessages.length,
              itemBuilder: (context, index) {
                final msg = mockMessages[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      child: Text(msg['avatar'] ?? '🐾'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msg['username']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg['message']!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade800,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Write a message',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    // Stub for send action
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sending message...')));
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
