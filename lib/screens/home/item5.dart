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

/// Indian digit grouping. Decimals are shown only when the amount has them.
String _formatMoney(double value) {
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

/// "Recommended for You": the full product catalog as a 2-column grid
/// with a per-card Add to cart button.
class Item5 extends StatelessWidget {
  const Item5({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return HomeSectionContainer(
      title: 'Popular Picks',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.64,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final prod = products[index];
          final image = firstProductImage(prod);
          final price = displayPrice(prod);
          final originalPrice = parsePrice(prod.originalPrice);
          final discount = discountPercentage(prod);
          final isFeatured = prod.isFeatured ?? false;

          return GestureDetector(
            onTap: () => onProductTap(prod),
            behavior: HitTestBehavior.opaque,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_UI.radius),
                border: Border.all(color: _UI.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: HomeNetworkImage(
                              url: image,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        if (isFeatured)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text(
                                'Featured',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: _UI.border),
                  Padding(
                    padding: const EdgeInsets.all(10),
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
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Text(
                              _formatMoney(price),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _UI.ink,
                              ),
                            ),
                            if (discount > 0 && originalPrice > price)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 1),
                                child: Text(
                                  _formatMoney(originalPrice),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _UI.inkSoft,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            if (discount > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 1),
                                child: Text(
                                  '$discount% off',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _UI.success,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 34,
                          child: OutlinedButton(
                            onPressed: () => onAddToCart(prod),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              foregroundColor: AppTheme.primary,
                              side: const BorderSide(
                                color: AppTheme.primary,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(_UI.radius),
                              ),
                            ),
                            child: const Text(
                              'Add to cart',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
