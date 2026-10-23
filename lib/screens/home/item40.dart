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
  static const double radius = 10;
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

/// "Free Delivery Booster": a progress bar towards the free-delivery limit
/// and quick add-ons, sorted by how well they close the gap.
///
/// Pass your real cart total in [cartTotal] and your limit in
/// [freeDeliveryAt].
class Item40 extends StatelessWidget {
  const Item40({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.cartTotal = 0,
    this.freeDeliveryAt = 999,
    this.maxItems = 6,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;
  final double cartTotal;
  final double freeDeliveryAt;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final remaining = (freeDeliveryAt - cartTotal).clamp(0, freeDeliveryAt);
    final unlocked = remaining <= 0;
    final progress = freeDeliveryAt <= 0
        ? 1.0
        : (cartTotal / freeDeliveryAt).clamp(0.0, 1.0).toDouble();

    final sorted = [...products];
    if (unlocked) {
      sorted.sort((a, b) => displayPrice(a).compareTo(displayPrice(b)));
    } else {
      sorted.sort(
        (a, b) => (displayPrice(a) - remaining)
            .abs()
            .compareTo((displayPrice(b) - remaining).abs()),
      );
    }
    final list = sorted.take(maxItems).toList();

    return HomeSectionContainer(
      title: 'Free Delivery Booster',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProgress(remaining.toDouble(), unlocked, progress),
          const SizedBox(height: 12),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) =>
                  _buildCard(list[i], remaining.toDouble()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(double remaining, bool unlocked, double progress) {
    final color = unlocked ? _UI.success : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(_UI.radius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                unlocked ? Icons.check_circle : Icons.local_shipping_outlined,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  unlocked
                      ? "You've unlocked FREE delivery!"
                      : 'Add ${_money(remaining)} more for FREE delivery',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cart ${_money(cartTotal)}',
                style: const TextStyle(fontSize: 11, color: _UI.inkSoft),
              ),
              Text(
                'Free at ${_money(freeDeliveryAt)}',
                style: const TextStyle(fontSize: 11, color: _UI.inkSoft),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(ProductResponse prod, double remaining) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final completes = remaining > 0 && price >= remaining;

    return GestureDetector(
      onTap: () => onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(
            color: completes ? _UI.success : _UI.border,
            width: completes ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 74,
              height: double.infinity,
              padding: const EdgeInsets.all(6),
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
            const SizedBox(width: 10),
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
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: _UI.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _money(price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _UI.ink,
                    ),
                  ),
                  if (completes)
                    const Text(
                      'Unlocks free delivery',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _UI.success,
                      ),
                    ),
                ],
              ),
            ),
            InkWell(
              onTap: () => onAddToCart(prod),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}