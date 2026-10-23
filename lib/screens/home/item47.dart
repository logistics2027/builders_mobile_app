import 'package:avg_mart/helper/helper.dart';
import 'package:avg_mart/widgets/network_image.dart';
import 'package:avg_mart/widgets/home_section_container.dart';
import 'package:flutter/material.dart';
import '../../models/product_response.dart';
import '../../theme/app_theme.dart';

class _UI {
  _UI._();

  static const List<List<Color>> gradients = [
    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    [Color(0xFFEC4899), Color(0xFFF97316)],
    [Color(0xFF059669), Color(0xFF10B981)],
    [Color(0xFF0EA5E9), Color(0xFF6366F1)],
  ];
}

String _money(double value) {
  final hasDecimals = value != value.roundToDouble();
  final fixed = value.toStringAsFixed(hasDecimals ? 2 : 0);
  final parts = fixed.split('.');
  final whole = parts[0];
  final decimals = parts.length > 1 ? '.${parts[1]}' : '';
  if (whole.length <= 3) return '₹$whole$decimals';
  final last3 = whole.substring(whole.length - 3);
  var rest = whole.substring(0, whole.length - 3);
  final groups = <String>[];
  while (rest.length > 2) {
    groups.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) groups.insert(0, rest);
  return '₹${groups.join(',')},$last3$decimals';
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// "Category Promos": one gradient promo tile per category showing
/// "Starting at ₹X" (cheapest product in that category) with a product
/// image peeking out of the corner. Tapping a tile calls [onCategoryTap].
class Item47 extends StatelessWidget {
  const Item47({
    super.key,
    required this.products,
    required this.onCategoryTap,
    this.maxCategories = 4,
  });

  final List<ProductResponse> products;
  final ValueChanged<String> onCategoryTap;
  final int maxCategories;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    // category -> cheapest product
    final cheapest = <String, ProductResponse>{};
    for (final p in products) {
      final c = (p.category ?? '').trim();
      if (c.isEmpty) continue;
      final current = cheapest[c];
      if (current == null || displayPrice(p) < displayPrice(current)) {
        cheapest[c] = p;
      }
    }
    final entries = cheapest.entries.take(maxCategories).toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return HomeSectionContainer(
      title: 'Category Promos',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, i) =>
            _buildTile(entries[i].key, entries[i].value, i),
      ),
    );
  }

  Widget _buildTile(String category, ProductResponse prod, int index) {
    final colors = _UI.gradients[index % _UI.gradients.length];
    final price = displayPrice(prod);
    final image = firstProductImage(prod);

    return GestureDetector(
      onTap: () => onCategoryTap(category),
      behavior: HitTestBehavior.opaque,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Stack(
          children: [
            // Peeking product image
            Positioned(
              right: -10,
              bottom: -10,
              child: Transform.rotate(
                angle: -0.12,
                child: Container(
                  width: 104,
                  height: 104,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: HomeNetworkImage(
                    url: image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Text
            Positioned(
              left: 14,
              top: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _capitalize(category),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Starting at',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  Text(
                    _money(price),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow chip
            Positioned(
              left: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}