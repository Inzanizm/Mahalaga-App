import 'package:flutter/material.dart';
import 'package:mahalaga_app/kyme/widgets/write_review_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ReviewSection extends StatefulWidget {
  final String placeId;

  const ReviewSection({super.key, required this.placeId});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final String tableName = 'reviews_view';

  Future<List<Map<String, dynamic>>> _fetchReviews() async {
    final response = await Supabase.instance.client
        .from(tableName)
        .select()
        .eq('placeID', widget.placeId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => e as Map<String, dynamic>).toList();
  }

  void _editReview(Map<String, dynamic> review) async {
    final newTextController = TextEditingController(text: review['reviewText']);
    double selectedRating = (review['rating'] ?? 0).toDouble();
    List<String> images = List<String>.from(review['reviewImages'] ?? []);

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Review'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: newTextController,
                      decoration: const InputDecoration(
                        labelText: 'Review Text',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text('Update Rating:'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            selectedRating >= index + 1
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setStateDialog(() {
                              selectedRating = (index + 1).toDouble();
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    const Text('Images:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          images.map((imageUrl) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setStateDialog(() {
                                        images.remove(imageUrl);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final imageUrl = await _pickImageAndUpload();
                        if (imageUrl != null) {
                          setStateDialog(() {
                            images.add(imageUrl);
                          });
                        }
                      },
                      child: const Text('Add Image'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedText = newTextController.text.trim();
                    if (updatedText.isEmpty) return;

                    _updateReview(
                      review['reviewID'],
                      updatedText,
                      selectedRating.toInt(),
                      images,
                    );

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateReview(
    String reviewId,
    String text,
    int rating,
    List<String> images,
  ) async {
    await Supabase.instance.client
        .from(tableName)
        .update({
          'reviewText': text,
          'rating': rating,
          'reviewImages': images, // <-- importante ito!
        })
        .eq('reviewID', reviewId);

    if (mounted) {
      setState(() {});
    }
  }

  void _deleteReview(Map<String, dynamic> review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Review'),
            content: const Text('Are you sure you want to delete this review?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await Supabase.instance.client
          .from(tableName)
          .delete()
          .eq('reviewID', review['reviewID']);

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _viewReviewInfo(Map<String, dynamic> review) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Review Info'),
            content: Text('Created at: ${review['created_at']}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<String?> _pickImageAndUpload() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';

      final storageResponse = await Supabase.instance.client.storage
          .from('review-images')
          .upload(fileName, file);

      if (storageResponse.isNotEmpty) {
        final imageUrl = Supabase.instance.client.storage
            .from('review-images')
            .getPublicUrl(fileName);
        return imageUrl;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchReviews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            children: [
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => WriteReviewPage(
                          placeId: widget.placeId,
                          onReviewSubmitted: () {
                            setState(() {});
                          },
                        ),
                  );
                },
                child: const Text('Write a Review'),
              ),
              const SizedBox(height: 20),
              const Text('No reviews yet.', style: TextStyle(fontSize: 16)),
            ],
          );
        }

        final reviews = snapshot.data!;
        return SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => WriteReviewPage(
                          placeId: widget.placeId,
                          onReviewSubmitted: () {
                            setState(() {});
                          },
                        ),
                  );
                },
                child: const Text('Write Another Review'),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  final double rating = (review['rating'] ?? 0).toDouble();
                  final String author = review['DisplayName'] ?? 'Anonymous';
                  final String text = review['reviewText'] ?? '';
                  final List<dynamic>? images = review['reviewImages'];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author and Options
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  author,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'Edit') {
                                  _editReview(review);
                                } else if (value == 'Delete') {
                                  _deleteReview(review);
                                } else if (value == 'Info') {
                                  _viewReviewInfo(review);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'Edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Delete',
                                      child: Text('Delete'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Info',
                                      child: Text('Info'),
                                    ),
                                  ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Rating Stars
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        // Review Text
                        Text(
                          text,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Images if any
                        if (images != null && images.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                images.map((imageUrl) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }).toList(),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
