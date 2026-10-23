import 'package:avg_mart/helper/helper.dart';
import 'package:avg_mart/widgets/network_image.dart';
import 'package:avg_mart/widgets/home_section_container.dart';
import 'package:flutter/material.dart';
import '../../models/product_response.dart';
import '../../theme/app_theme.dart';

class _UI {
  _UI._();

  static const Color ink = Color(0xFF111827);
  static const Color inkSoft = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF15803D);
  static const double radius = 6;
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

/// "Shop by Category": products grouped by category, each group is its own
/// titled row with a horizontal scroll and an optional "See all" link.
class Item15 extends StatelessWidget {
  const Item15({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.onSeeAll,
    this.maxCategories = 3,
    this.maxPerCategory = 8,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  /// Called with the category name when "See all" is tapped.
  final ValueChanged<String>? onSeeAll;
  final int maxCategories;
  final int maxPerCategory;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final groups = <String, List<ProductResponse>>{};
    for (final p in products) {
      final c = (p.category ?? '').trim();
      groups.putIfAbsent(c.isEmpty ? 'Other' : c, () => []).add(p);
    }
    final entries = groups.entries.take(maxCategories).toList();

    return HomeSectionContainer(
      title: 'Shop by Category',
      child: Column(
        children: [
          for (int i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            _buildGroup(entries[i].key, entries[i].value),
          ],
        ],
      ),
    );
  }

  Widget _buildGroup(String category, List<ProductResponse> items) {
    final list = items.take(maxPerCategory).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _capitalize(category),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _UI.ink,
                ),
              ),
            ),
            if (onSeeAll != null)
              GestureDetector(
                onTap: () => onSeeAll!(category),
                child: const Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 12,
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
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 214,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _buildCard(list[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(ProductResponse prod) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final discount = discountPercentage(prod);

    return GestureDetector(
      onTap: () => onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(color: _UI.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(6),
                child: HomeNetworkImage(
                  url: image,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              prod.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.25,
                color: _UI.ink,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _money(price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _UI.ink,
                  ),
                ),
                if (discount > 0) ...[
                  const SizedBox(width: 5),
                  Text(
                    '$discount%',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _UI.success,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 26,
              child: OutlinedButton(
                onPressed: () => onAddToCart(prod),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_UI.radius),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}