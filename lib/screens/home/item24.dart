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
  static const double radius = 10;
  static const double stubWidth = 88;
  static const double notch = 16;
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

class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.4;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 5), paint);
      y += 9;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "Deal Tickets": coupon-style cards with a perforated divider and
/// half-circle notches. The right stub shows the discount and an add button.
class Item24 extends StatelessWidget {
  const Item24({
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

    final sorted = [...products]
      ..sort((a, b) => discountPercentage(b).compareTo(discountPercentage(a)));
    final list = sorted.take(maxItems).toList();

    return HomeSectionContainer(
      title: 'Deal Tickets',
      child: Column(
        children: [
          for (int i = 0; i < list.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == list.length - 1 ? 0 : 12),
              child: _buildTicket(list[i]),
            ),
        ],
      ),
    );
  }

  Widget _notch({required bool top}) {
    return Positioned(
      right: _UI.stubWidth - _UI.notch / 2,
      top: top ? -_UI.notch / 2 : null,
      bottom: top ? null : -_UI.notch / 2,
      child: Container(
        width: _UI.notch,
        height: _UI.notch,
        decoration: const BoxDecoration(
          color: AppTheme.background,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildTicket(ProductResponse prod) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final originalPrice = parsePrice(prod.originalPrice);
    final discount = discountPercentage(prod);

    return GestureDetector(
      onTap: () => onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 108,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(color: _UI.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                // Left: product
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _money(price),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: _UI.ink,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (discount > 0 && originalPrice > price)
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 1,
                                        ),
                                        child: Text(
                                          _money(originalPrice),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: _UI.inkSoft,
                                            decoration:
                                                TextDecoration.lineThrough,
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
                ),
                // Right: stub
                SizedBox(
                  width: _UI.stubWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (discount > 0) ...[
                        Text(
                          '$discount%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            height: 1,
                          ),
                        ),
                        const Text(
                          'OFF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: _UI.inkSoft,
                          ),
                        ),
                      ] else
                        const Icon(
                          Icons.local_offer_outlined,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () => onAddToCart(prod),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Perforated divider
            Positioned(
              right: _UI.stubWidth,
              top: _UI.notch,
              bottom: _UI.notch,
              child: const SizedBox(
                width: 1,
                child: CustomPaint(painter: _DashPainter()),
              ),
            ),
            _notch(top: true),
            _notch(top: false),
          ],
        ),
      ),
    );
  }
}