import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class WriteReviewPage extends StatefulWidget {
  final String placeId;
  final VoidCallback onReviewSubmitted;

  const WriteReviewPage({
    super.key,
    required this.placeId,
    required this.onReviewSubmitted,
  });

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  final List<File> _selectedImages = [];
  final int _maxImages = 3;

  double _rating = 0;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (_selectedImages.length < _maxImages) {
        if (!mounted) return;
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only upload up to 3 images.')),
        );
      }
    }
  }

  Future<String?> _uploadImage(File file) async {
    final imageSize = await file.length();
    if (imageSize > 10 * 1024 * 1024) {
      // 10MB size check
      if (!mounted) return null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image size exceeds 10MB.')));
      return null;
    }

    final supabase = Supabase.instance.client;
    final storage = supabase.storage.from('review-images');
    final filename = '${const Uuid().v4()}${path.extension(file.path)}';
    final filePath = 'reviews/$filename'; // organized inside "reviews/" folder

    try {
      await storage.upload(filePath, file);
      return storage.getPublicUrl(filePath);
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  Future<void> _submitReview() async {
    final reviewText = _reviewController.text.trim();

    if (reviewText.isEmpty || _rating == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a review and give a rating.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      List<String> imageUrls = [];

      for (var image in _selectedImages) {
        final url = await _uploadImage(image);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      await supabase.from('reviews_view').insert({
        'placeID': widget.placeId,
        'userID': userId,
        'reviewText': reviewText,
        'rating': _rating,
        'reviewImages': imageUrls.isNotEmpty ? imageUrls : null,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      widget.onReviewSubmitted();
      Navigator.of(context).pop();

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Review submission error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Write a Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your review here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Rate the place:'),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder:
                  (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            if (_selectedImages.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _selectedImages
                        .map(
                          (image) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              image,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                        .toList(),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Add Photo (Optional)'),
            ),
            const SizedBox(height: 10),
            Text(
              'You can upload up to $_maxImages images.',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          child:
              _isSubmitting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Submit'),
        ),
      ],
    );
  }
}
