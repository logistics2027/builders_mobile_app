import 'package:avg_mart/widgets/network_image.dart';
import 'package:flutter/material.dart';
import '../../models/category_response.dart';
import '../../theme/app_theme.dart';

class _UI {
  _UI._();

  static const Color ink = Color(0xFF111827);
  static const Color border = Color(0xFFE5E7EB);
  static const Color canvas = Color(0xFFF5F6F8);
  static const double radius = 6;
}
class Item1 extends StatelessWidget {
  const Item1({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.onSeeAllTap,
  });

  final List<CategoryiesResponse> categories;
  final ValueChanged<CategoryiesResponse> onCategoryTap;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Explore Categories",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (onSeeAllTap != null)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onSeeAllTap,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 116,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return _CategoryTile(
                  category: cat,
                  onTap: () => onCategoryTap(cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final CategoryiesResponse category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _UI.canvas,
                borderRadius: BorderRadius.circular(_UI.radius),
                border: Border.all(color: _UI.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_UI.radius - 1),
                child: HomeNetworkImage(
                  url: category.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name ?? '',
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.25,
                color: _UI.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
