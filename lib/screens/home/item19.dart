import 'package:avg_mart/helper/helper.dart';
import 'package:avg_mart/widgets/network_image.dart';
import 'package:avg_mart/widgets/home_section_container.dart';
import 'package:flutter/material.dart';
import '../../models/product_response.dart';
import '../../theme/app_theme.dart';

class _UI {
  _UI._();

  static const Color bg = Color(0xFF111827);
  static const Color card = Color(0xFF1F2937);
  static const Color cardBorder = Color(0xFF374151);
  static const Color gold = Color(0xFFFBBF24);
  static const Color textSoft = Color(0xFF9CA3AF);
  static const double radius = 12;
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

/// "Premium Picks": a dark-themed panel with gold accents showing the
/// highest-priced products in a horizontal carousel.
class Item19 extends StatelessWidget {
  const Item19({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.maxItems = 6,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final sorted = [...products]
      ..sort((a, b) => displayPrice(b).compareTo(displayPrice(a)));
    final list = sorted.take(maxItems).toList();

    return HomeSectionContainer(
      title: 'Premium Picks',
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 0, 14),
        decoration: BoxDecoration(
          color: _UI.bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.workspace_premium, color: _UI.gold, size: 20),
                SizedBox(width: 6),
                Text(
                  'Handpicked, top-of-the-line',
                  style: TextStyle(
                    color: _UI.textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 268,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 14),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _buildCard(list[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(ProductResponse prod) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final originalPrice = parsePrice(prod.originalPrice);
    final discount = discountPercentage(prod);

    return GestureDetector(
      onTap: () => onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 156,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _UI.card,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(color: _UI.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: HomeNetworkImage(
                        url: image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _UI.bg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: _UI.gold,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _money(price),
                  style: const TextStyle(
                    color: _UI.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                if (discount > 0 && originalPrice > price)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Text(
                        _money(originalPrice),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _UI.textSoft,
                          fontSize: 10.5,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: _UI.textSoft,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                onPressed: () => onAddToCart(prod),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  backgroundColor: _UI.gold,
                  foregroundColor: _UI.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add to cart',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}