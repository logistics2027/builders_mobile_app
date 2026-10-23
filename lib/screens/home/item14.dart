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

/// "Bundle & Save": 2-3 products shown side by side with "+" between them,
/// a combined price, the total savings and one "Add all" button.
class Item14 extends StatelessWidget {
  const Item14({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;

  /// Called once for every product in the bundle when "Add all" is pressed.
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  Widget build(BuildContext context) {
    if (products.length < 2) return const SizedBox.shrink();

    final items = products.take(3).toList();

    double total = 0;
    double originalTotal = 0;
    for (final p in items) {
      final price = displayPrice(p);
      final original = parsePrice(p.originalPrice);
      total += price;
      originalTotal += original > price ? original : price;
    }
    final savings = originalTotal - total;

    return HomeSectionContainer(
      title: 'Bundle & Save',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(color: _UI.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) _plus(),
                  Expanded(child: _buildTile(items[i])),
                ],
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: _UI.border),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bundle price',
                        style: TextStyle(fontSize: 11.5, color: _UI.inkSoft),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            _money(total),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _UI.ink,
                            ),
                          ),
                          if (savings > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                _money(originalTotal),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: _UI.inkSoft,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (savings > 0)
                        Text(
                          'You save ${_money(savings)}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _UI.success,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      for (final p in items) {
                        onAddToCart(p);
                      }
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: Text('Add all ${items.length}'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_UI.radius),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _plus() => Padding(
    padding: const EdgeInsets.only(top: 34, left: 4, right: 4),
    child: Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add, size: 14, color: AppTheme.primary),
    ),
  );

  Widget _buildTile(ProductResponse prod) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);

    return GestureDetector(
      onTap: () => onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(_UI.radius),
                border: Border.all(color: _UI.border),
              ),
              child: HomeNetworkImage(
                url: image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prod.name ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.25,
              color: _UI.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _money(price),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _UI.ink,
            ),
          ),
        ],
      ),
    );
  }
}