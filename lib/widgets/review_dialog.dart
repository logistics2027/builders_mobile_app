import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/orders/orders_cubit.dart';
import '../theme/app_theme.dart';

class ReviewDialog extends StatefulWidget {
  final String productId;
  final String productName;

  const ReviewDialog({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int _rating = 0;
  final List<File> _images = [];

  static const int _maxImages = 5;

  static const List<String> _ratingLabels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  int get _remainingSlots => _maxImages - _images.length;

  Future<void> _showImageSourceSheet() async {
    if (_remainingSlots <= 0) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ImageSourceSheet(),
    );

    if (source == null) return;

    if (source == ImageSource.camera) {
      await _pickFromCamera();
    } else {
      await _pickFromGallery();
    }
  }

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _images.add(File(picked.path));
    });
  }

  Future<void> _pickFromGallery() async {
    final remaining = _remainingSlots;
    if (remaining <= 0) return;

    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;

    setState(() {
      _images.addAll(picked.take(remaining).map((x) => File(x.path)));
    });
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _submit(BuildContext context) {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment')),
      );
      return;
    }

    context.read<OrdersCubit>().submitReview(
          productId: widget.productId,
          rating: _rating,
          comment: _commentController.text.trim(),
          images: _images,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersCubit, OrdersState>(
      listener: (context, state) {
        if (state is ReviewSubmitSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review submitted successfully'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ReviewSubmitFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: 460,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- Header ----------
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.rate_review_outlined, color: AppTheme.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Write a Review',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey.shade600, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    ),
                  ],
                ),
              ),

              // ---------- Body ----------
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Star rating
                      const Text(
                        'How would you rate this product?',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              final starIndex = index + 1;
                              final isFilled = starIndex <= _rating;
                              return GestureDetector(
                                onTap: () => setState(() => _rating = starIndex),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: Icon(
                                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: isFilled ? Colors.amber.shade600 : Colors.grey.shade400,
                                    size: 34,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 10),
                          if (_rating > 0)
                            Text(
                              _ratingLabels[_rating],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade800,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Comment
                      const Text(
                        'Your Review',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _commentController,
                          minLines: 3,
                          maxLines: 5,
                          maxLength: 500,
                          style: const TextStyle(fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: 'Share your experience with this product...',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                            counterStyle: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Images
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add Photos',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          Text(
                            '${_images.length}/$_maxImages',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ..._images.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: Image.file(
                                      file,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          if (_images.length < _maxImages)
                            GestureDetector(
                              onTap: _showImageSourceSheet,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined,
                                        size: 18, color: Colors.grey.shade600),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Add',
                                      style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // ---------- Footer ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: BlocBuilder<OrdersCubit, OrdersState>(
                  builder: (context, state) {
                    final isSubmitting = state is ReviewSubmitting;
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () => _submit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppTheme.accent.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit Review',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet asking whether to take a photo or pick from gallery.
/// Kept as a small stateless widget so it renders as a neat rounded card
/// instead of the default full-bleed sheet look.
class _ImageSourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Add a Photo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            _SourceOption(
              icon: Icons.photo_camera_outlined,
              label: 'Take Photo',
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            Divider(height: 1, color: Colors.grey.shade200, indent: 20, endIndent: 20),
            _SourceOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.grey.shade800),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}