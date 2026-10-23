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
  static const double radius = 14;
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

/// "Budget - Mid-range - Premium": three price tiers side by side, like
/// pricing plans. Picks the cheapest, the median-priced and the most
/// expensive product. The middle card is raised and highlighted.
class Item55 extends StatelessWidget {
  const Item55({
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

    final sorted = [...products]
      ..sort((a, b) => displayPrice(a).compareTo(displayPrice(b)));

    final tiers = <MapEntry<String, ProductResponse>>[];
    if (sorted.length == 2) {
      tiers.add(MapEntry('BUDGET', sorted.first));
      tiers.add(MapEntry('PREMIUM', sorted.last));
    } else {
      tiers.add(MapEntry('BUDGET', sorted.first));
      tiers.add(MapEntry('MID-RANGE', sorted[sorted.length ~/ 2]));
      tiers.add(MapEntry('PREMIUM', sorted.last));
    }
    final hasMid = tiers.length == 3;

    return HomeSectionContainer(
      title: 'Pick Your Tier',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < tiers.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _buildCard(
                tiers[i].key,
                tiers[i].value,
                highlighted: hasMid && i == 1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(
    String tier,
    ProductResponse prod, {
    required bool highlighted,
  }) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final discount = discountPercentage(prod);

    return GestureDetector(
      onTap: () => onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.fromLTRB(8, highlighted ? 14 : 10, 8, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(
            color: highlighted ? AppTheme.primary : _UI.border,
            width: highlighted ? 2 : 1,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: highlighted ? AppTheme.primary : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tier,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: highlighted ? Colors.white : _UI.inkSoft,
                ),
              ),
            ),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 1,
              child: HomeNetworkImage(
                url: image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 6),
            Text(
              _money(price),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: highlighted ? 17 : 15,
                fontWeight: FontWeight.w900,
                color: _UI.ink,
              ),
            ),
            if (discount > 0)
              Text(
                '$discount% off',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: _UI.success,
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: 30,
              child: highlighted
                  ? ElevatedButton(
                      onPressed: () => onAddToCart(prod),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: () => onAddToCart(prod),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
    );
  }
}