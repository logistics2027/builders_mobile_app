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
  static const double radius = 8;
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

/// "Swipe to Add": rows you swipe to the right to add to the cart. A green
/// "Add to cart" panel is revealed behind the row, then the row springs back.
class Item29 extends StatelessWidget {
  const Item29({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.maxItems = 4,
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
      title: 'Swipe to Add',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.swipe_right_alt, size: 18, color: _UI.inkSoft),
              SizedBox(width: 6),
              Text(
                'Swipe a product to the right to add it to your cart',
                style: TextStyle(fontSize: 11.5, color: _UI.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < list.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == list.length - 1 ? 0 : 10),
              child: _buildRow(list[i], i),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(ProductResponse prod, int index) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final originalPrice = parsePrice(prod.originalPrice);
    final discount = discountPercentage(prod);

    return ClipRRect(
      borderRadius: BorderRadius.circular(_UI.radius),
      child: Dismissible(
        key: ValueKey('swipe-${prod.id}-$index'),
        direction: DismissDirection.startToEnd,
        dismissThresholds: const {DismissDirection.startToEnd: 0.35},
        // Never actually remove the row: add to cart, then snap back.
        confirmDismiss: (_) async {
          onAddToCart(prod);
          return false;
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 18),
          color: _UI.success,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_shopping_cart, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Add to cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        child: GestureDetector(
          onTap: () => onProductTap(prod),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _UI.border),
              borderRadius: BorderRadius.circular(_UI.radius),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: HomeNetworkImage(
                    url: image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prod.name ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          color: _UI.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            _money(price),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: _UI.ink,
                            ),
                          ),
                          if (discount > 0 && originalPrice > price)
                            Text(
                              _money(originalPrice),
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: _UI.inkSoft,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          if (discount > 0)
                            Text(
                              '$discount% off',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: _UI.success,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_double_arrow_right, color: _UI.border),
              ],
            ),
          ),
        ),
      ),
    );
  }
}