import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class EditReviewPage extends StatefulWidget {
  final String reviewId;
  final String initialReviewText;
  final double initialRating;
  final List<String> initialImages;
  final VoidCallback onReviewUpdated;

  const EditReviewPage({
    super.key,
    required this.reviewId,
    required this.initialReviewText,
    required this.initialRating,
    required this.initialImages,
    required this.onReviewUpdated,
  });

  @override
  State<EditReviewPage> createState() => _EditReviewPageState();
}

class _EditReviewPageState extends State<EditReviewPage> {
  late TextEditingController _reviewController;
  late double _rating;
  final List<File> _newSelectedImages = [];
  late List<String> _existingImageUrls;
  final int _maxImages = 3;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController(text: widget.initialReviewText);
    _rating = widget.initialRating;
    _existingImageUrls = List<String>.from(widget.initialImages);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (_existingImageUrls.length + _newSelectedImages.length < _maxImages) {
        setState(() {
          _newSelectedImages.add(File(picked.path));
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
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image size exceeds 10MB.')),
      );
      return null;
    }

    final storage = Supabase.instance.client.storage;
    final bucket = storage.from('review-images');
    final filename = '${const Uuid().v4()}${path.extension(file.path)}';

    try {
      final filePath = 'reviews/$filename';
      await bucket.upload(filePath, file);
      return bucket.getPublicUrl(filePath);
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newSelectedImages.removeAt(index);
    });
  }

  void _submitUpdate() async {
    if (_reviewController.text.trim().isEmpty || _rating == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review and rate.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    List<String> finalImageUrls = List.from(_existingImageUrls);

    for (var file in _newSelectedImages) {
      final uploadedUrl = await _uploadImage(file);
      if (uploadedUrl != null) {
        finalImageUrls.add(uploadedUrl);
      }
    }

    try {
      await Supabase.instance.client
          .from('mahalaga_pca_schema.reviews')
          .update({
            'reviewText': _reviewController.text.trim(),
            'rating': _rating,
            'reviewImages': finalImageUrls.isNotEmpty ? finalImageUrls : null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('reviewID', widget.reviewId);

      if (!mounted) return;

      widget.onReviewUpdated();
      Navigator.of(context).pop();

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Update error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update review.')),
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
      title: const Text('Edit Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Update your review here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Update Rating:'),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Existing images
            if (_existingImageUrls.isNotEmpty)
              Wrap(
                children: _existingImageUrls
                    .asMap()
                    .entries
                    .map(
                      (entry) => Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.network(entry.value, height: 100, width: 100, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => _removeExistingImage(entry.key),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            // New selected images
            if (_newSelectedImages.isNotEmpty)
              Wrap(
                children: _newSelectedImages
                    .asMap()
                    .entries
                    .map(
                      (entry) => Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.file(entry.value, height: 100, width: 100, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => _removeNewImage(entry.key),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Add Photo'),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitUpdate,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
