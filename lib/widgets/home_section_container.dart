import 'package:flutter/material.dart';

/// Common white card wrapper with a bold title used by most Home sections
/// (Deal of the Day, category grid, brand shelf, product shelves, etc).
class HomeSectionContainer extends StatelessWidget {
  const HomeSectionContainer({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
