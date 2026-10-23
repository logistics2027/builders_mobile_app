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
  static const Color success = Color(0xFF15803D);
  static const Color accent = Color(0xFFF59E0B);
  static const double size = 72;
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

/// "Quick Picks": story-style round product bubbles with a gradient ring,
/// a discount tag and a tiny "+" button to add straight to the cart.
class Item12 extends StatelessWidget {
  const Item12({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.maxItems = 10,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final list = products.take(maxItems).toList();

    return HomeSectionContainer(
      title: 'Quick Picks',
      child: SizedBox(
        height: 134,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, i) => _buildBubble(list[i]),
        ),
      ),
    );
  }

  Widget _buildBubble(ProductResponse prod) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final discount = discountPercentage(prod);
    final featured = prod.isFeatured ?? false;

    return GestureDetector(
      onTap: () => onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            SizedBox(
              width: _UI.size + 8,
              height: _UI.size + 8,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Gradient ring + image
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: featured
                            ? [
                                AppTheme.primary,
                                _UI.accent,
                                AppTheme.primary,
                              ]
                            : [
                                AppTheme.primary.withValues(alpha: 0.35),
                                AppTheme.primary.withValues(alpha: 0.1),
                                AppTheme.primary.withValues(alpha: 0.35),
                              ],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: HomeNetworkImage(
                          url: image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Discount tag
                  if (discount > 0)
                    Positioned(
                      left: -2,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _UI.success,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          '$discount%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  // Add button
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: GestureDetector(
                      onTap: () => onAddToCart(prod),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              prod.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _UI.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _money(price),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _UI.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}