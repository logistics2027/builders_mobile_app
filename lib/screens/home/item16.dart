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
  static const double radius = 12;

  static const List<Color> tints = [
    Color(0xFFFEF3C7),
    Color(0xFFE0F2FE),
    Color(0xFFFCE7F3),
    Color(0xFFDCFCE7),
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

/// "Editor's Choice": big full-width feed-style cards, one product each,
/// with a large image, full details and two action buttons.
class Item16 extends StatelessWidget {
  const Item16({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.maxItems = 2,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final featured = products.where((p) => p.isFeatured ?? false).toList();
    final list = (featured.isNotEmpty ? featured : products)
        .take(maxItems)
        .toList();

    return HomeSectionContainer(
      title: "Editor's Choice",
      child: Column(
        children: [
          for (int i = 0; i < list.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == list.length - 1 ? 0 : 14),
              child: _buildCard(list[i], i),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(ProductResponse prod, int index) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final originalPrice = parsePrice(prod.originalPrice);
    final discount = discountPercentage(prod);

    return GestureDetector(
      onTap: () => onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(color: _UI.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.25,
                  child: ColoredBox(
                    color: _UI.tints[index % _UI.tints.length],
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: HomeNetworkImage(
                        url: image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _UI.ink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PICK #${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: _UI.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      Text(
                        _money(price),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _UI.ink,
                        ),
                      ),
                      if (discount > 0 && originalPrice > price)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            _money(originalPrice),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: _UI.inkSoft,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      if (discount > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '$discount% off',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _UI.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () => onProductTap(prod),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _UI.ink,
                              side: const BorderSide(color: _UI.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'View details',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => onAddToCart(prod),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Add to cart',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}