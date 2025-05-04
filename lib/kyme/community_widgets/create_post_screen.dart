import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _mediaFiles = [];
  String? _selectedCommunityId;
  List<Map<String, dynamic>> _communities = [];

  @override
  void initState() {
    super.initState();
    fetchCommunities();
  }

  Future<void> fetchCommunities() async {
    try {
      final res = await Supabase.instance.client
        .schema('mahalaga_pca_comfor')
          .from('communities')
          .select('id, name');

      if (mounted) {
        setState(() {
          _communities = List<Map<String, dynamic>>.from(res);
        });
      }
    } catch (_) {
      // Optional: fallback
      if (mounted) {
        setState(() {
          _communities = [
            {'id': 'demo', 'name': 'Sample Group'}
          ];
        });
      }
    }
  }

  Future<void> pickMedia() async {
    final picked = await _picker.pickMultiImage(); // You can also support videos
    if (picked.isNotEmpty && mounted) {
      setState(() {
        _mediaFiles.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  Future<void> submitPost() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (_titleController.text.isEmpty ||
        _selectedCommunityId == null ||
        userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill all fields')),
        );
      }
      return;
    }

    final List<String> mediaUrls = [];
    for (var file in _mediaFiles) {
      final path =
          'posts/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      try {
        await Supabase.instance.client.storage.from('media').upload(path, file);
        final publicUrl =
            Supabase.instance.client.storage.from('media').getPublicUrl(path);
        mediaUrls.add(publicUrl);
      } catch (e) {
        // Show warning
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload media: $e')),
          );
        }
        return;
      }
    }

    await Supabase.instance.client.schema('mahalaga_pca_comfor').from('posts').insert({
      'user_id': userId,
      'content': _bodyController.text,
      'post_title': _titleController.text,
      'media_urls': mediaUrls,
      'community_id': _selectedCommunityId,
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        leading: BackButton(color: Colors.white),
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            iconEnabledColor: Colors.white,
            value: _selectedCommunityId,
            hint: const Text('Selected Group', style: TextStyle(color: Colors.white)),
            dropdownColor: const Color.fromARGB(255, 172, 170, 170),
            items: _communities.map((comm) {
              return DropdownMenuItem<String>(
                value: comm['id'],
                child: Text(comm['name'], style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCommunityId = value);
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 24, color: Colors.white),
              ),
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            Expanded(
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Write something',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Color(0xFF9B9982), size: 35,),
                  onPressed: pickMedia,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: submitPost,
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9B9982)),
                  child: const Text('Post'),
                ),
              ],
            ),
            if (_mediaFiles.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _mediaFiles.map((file) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(file, width: 100, fit: BoxFit.cover),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
