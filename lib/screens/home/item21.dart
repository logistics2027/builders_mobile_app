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

/// "Face-Off": two products head to head with a VS badge, a mini
/// comparison table (price, discount, category) and the better price
/// highlighted. Uses the first two products of [products].
class Item21 extends StatelessWidget {
  const Item21({
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
    if (products.length < 2) return const SizedBox.shrink();

    final a = products[0];
    final b = products[1];
    final priceA = displayPrice(a);
    final priceB = displayPrice(b);
    final discA = discountPercentage(a);
    final discB = discountPercentage(b);
    final catA = (a.category ?? '').trim();
    final catB = (b.category ?? '').trim();

    // Which side has the lower price (null if equal).
    final bool? aCheaper = priceA == priceB ? null : priceA < priceB;

    return HomeSectionContainer(
      title: 'Face-Off',
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
            LayoutBuilder(
              builder: (context, c) {
                final sideW = (c.maxWidth - 36) / 2;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSide(a, aCheaper == true)),
                    SizedBox(
                      width: 36,
                      child: Padding(
                        padding: EdgeInsets.only(top: sideW / 2 - 14),
                        child: Center(
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: _UI.ink,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              'VS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: _buildSide(b, aCheaper == false)),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            _compareRow(
              'Price',
              _money(priceA),
              _money(priceB),
              highlightLeft: aCheaper == true,
              highlightRight: aCheaper == false,
            ),
            _compareRow(
              'Discount',
              discA > 0 ? '$discA% off' : '-',
              discB > 0 ? '$discB% off' : '-',
              highlightLeft: discA > discB,
              highlightRight: discB > discA,
            ),
            _compareRow(
              'Category',
              catA.isEmpty ? '-' : _capitalize(catA),
              catB.isEmpty ? '-' : _capitalize(catB),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _addButton(a)),
                const SizedBox(width: 36),
                Expanded(child: _addButton(b)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSide(ProductResponse prod, bool bestPrice) {
    final image = firstProductImage(prod);
    return GestureDetector(
      onTap: () => onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(_UI.radius),
                      border: Border.all(
                        color: bestPrice ? _UI.success : _UI.border,
                        width: bestPrice ? 1.6 : 1,
                      ),
                    ),
                    child: HomeNetworkImage(
                      url: image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if (bestPrice)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: const BoxDecoration(
                        color: _UI.success,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(_UI.radius),
                          bottomRight: Radius.circular(_UI.radius),
                        ),
                      ),
                      child: const Text(
                        'BEST PRICE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
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
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: _UI.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _compareRow(
    String label,
    String left,
    String right, {
    bool highlightLeft = false,
    bool highlightRight = false,
  }) {
    TextStyle style(bool hi) => TextStyle(
      fontSize: 12.5,
      fontWeight: hi ? FontWeight.w800 : FontWeight.w500,
      color: hi ? _UI.success : _UI.ink,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _UI.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style(highlightLeft),
            ),
          ),
          Container(
            width: 62,
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: _UI.inkSoft,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Expanded(
            child: Text(
              right,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style(highlightRight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addButton(ProductResponse prod) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: () => onAddToCart(prod),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_UI.radius),
          ),
        ),
        child: const Text(
          'Add to cart',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}