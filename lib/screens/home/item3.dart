import 'package:avg_mart/widgets/network_image.dart';
import 'package:avg_mart/widgets/home_section_container.dart';
import 'package:flutter/material.dart';
import '../../models/category_response.dart';

class _UI {
  _UI._();

  static const Color ink = Color(0xFF111827);
  static const Color border = Color(0xFFE5E7EB);
  static const double radius = 6;
}

/// "Shop by Category" 2x2 image grid (first 4 categories).
class Item3 extends StatelessWidget {
  const Item3({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  final List<CategoryiesResponse> categories;
  final ValueChanged<CategoryiesResponse> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return HomeSectionContainer(
      title: 'Shop by Category',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 0.95,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: categories.take(4).map((cat) {
          return GestureDetector(
            onTap: () => onCategoryTap(cat),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_UI.radius),
                      border: Border.all(color: _UI.border),
                    ),
                    child: HomeNetworkImage(
                      url: cat.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(_UI.radius - 1),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _UI.ink,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
