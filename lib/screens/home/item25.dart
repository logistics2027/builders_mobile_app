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

/// "Set Your Budget": a price range slider that live-filters a horizontal
/// list of matching products.
class Item25 extends StatefulWidget {
  const Item25({
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
  State<Item25> createState() => _Item25State();
}

class _Item25State extends State<Item25> {
  RangeValues? _range;

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    final prices = widget.products.map((p) => displayPrice(p)).toList();
    final minP = prices.reduce((a, b) => a < b ? a : b).floorToDouble();
    final maxP = prices.reduce((a, b) => a > b ? a : b).ceilToDouble();
    final canSlide = maxP > minP;

    final start = (_range?.start ?? minP).clamp(minP, maxP).toDouble();
    final end = (_range?.end ?? maxP).clamp(minP, maxP).toDouble();

    final matches = widget.products.where((p) {
      final price = displayPrice(p);
      return price >= start && price <= end;
    }).toList();

    return HomeSectionContainer(
      title: 'Set Your Budget',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_UI.radius),
              border: Border.all(color: _UI.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_money(start)}  -  ${_money(end)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _UI.ink,
                        ),
                      ),
                    ),
                    if (_range != null)
                      GestureDetector(
                        onTap: () => setState(() => _range = null),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                if (canSlide)
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primary,
                      inactiveTrackColor: AppTheme.primary.withValues(
                        alpha: 0.18,
                      ),
                      thumbColor: AppTheme.primary,
                      overlayColor: AppTheme.primary.withValues(alpha: 0.12),
                      trackHeight: 4,
                    ),
                    child: RangeSlider(
                      values: RangeValues(start, end),
                      min: minP,
                      max: maxP,
                      labels: RangeLabels(_money(start), _money(end)),
                      onChanged: (v) => setState(() => _range = v),
                    ),
                  ),
                Text(
                  '${matches.length} '
                  '${matches.length == 1 ? 'product' : 'products'} match',
                  style: const TextStyle(fontSize: 12, color: _UI.inkSoft),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (matches.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'Nothing in this range, try widening it',
                  style: TextStyle(fontSize: 13, color: _UI.inkSoft),
                ),
              ),
            )
          else
            SizedBox(
              height: 218,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: matches.length > widget.maxItems
                    ? widget.maxItems
                    : matches.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _buildCard(matches[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(ProductResponse prod) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final discount = discountPercentage(prod);

    return GestureDetector(
      onTap: () => widget.onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 136,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(color: _UI.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: HomeNetworkImage(
                  url: image,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _money(price),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _UI.ink,
                  ),
                ),
                if (discount > 0) ...[
                  const SizedBox(width: 5),
                  Text(
                    '$discount%',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _UI.success,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 26,
              child: OutlinedButton(
                onPressed: () => widget.onAddToCart(prod),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_UI.radius),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}