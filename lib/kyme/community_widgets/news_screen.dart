import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// this screen shows full news article content
class NewsScreen extends StatelessWidget {
  final Map<String, dynamic> news;

  const NewsScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    // GET VALUES OR USE DEFAULTS — para hindi mag-crash kung may kulang sa data
    final String body = news['body'] ?? 'this is a test body';
    final String title = news['title'] ?? 'this is a test title: pogi ni kyme';
    final String imageUrl = news['image_url'] ?? '';
    final String publishedAt = news['published_at'] ?? '';
    final String writer = news['writer'] ?? 'The Mahalaga';

    // FORMAT DATE TO HUMAN-READABLE STRING
    String formattedDate = '';
    try {
      final date = DateTime.parse(publishedAt);
      formattedDate = DateFormat('MMMM d, y – h:mm a').format(date);
    } catch (_) {
      formattedDate = 'unknown date'; // fallback kung di ma-parse
    }

    // TEXTSTYLE PARA SA TITLE SA APPBAR
    final TextStyle te = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white, // ginagamit sa appbar title text
    );

    return Scaffold(
      backgroundColor: Colors.white70, // ginagamit sa buong background ng screen
      appBar: AppBar(
        title: Text("The PawPress Journal"),
        titleTextStyle: te,
        backgroundColor: const Color(0xFF6B705C), // ginagamit sa appbar background
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.all(0),
              child: Stack(
                children: [
                  // NEWS IMAGE DISPLAYED HERE
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                  // OVERLAY SA BOTTOM NG IMAGE — contains title, writer, date
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(12),
                      color: Colors.black.withAlpha(150), // ginagamit sa overlay background sa image
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white, // ginagamit sa news title sa image
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'By $writer',
                            style: const TextStyle(
                              color: Colors.white70, // ginagamit sa writer text
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.white70, // ginagamit sa date text
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                body,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  // default color (black) para readable ang article body
                ),
              ),
            ),
            const SizedBox(height: 16),
            // im gay — space lang to for spacing at maybe future widgets
          ],
        ),
      ),
    );
  }
}
