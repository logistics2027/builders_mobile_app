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
  static const Color gold = Color(0xFFFBBF24);
  static const Color silver = Color(0xFF9CA3AF);
  static const Color bronze = Color(0xFFD97706);
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

/// "Top 3 Podium": the three biggest discounts on a winners' podium.
/// Order on screen is 2nd - 1st - 3rd, with the 1st place taller and crowned.
class Item52 extends StatelessWidget {
  const Item52({
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

    final sorted = [...products]
      ..sort((a, b) => discountPercentage(b).compareTo(discountPercentage(a)));
    final top = sorted.take(3).toList();

    // Visual order: 2nd, 1st, 3rd (indexes into `top`).
    final order = <int>[1, 0, 2].where((i) => i < top.length).toList();

    return HomeSectionContainer(
      title: 'Top 3 Podium',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int k = 0; k < order.length; k++) ...[
            if (k > 0) const SizedBox(width: 8),
            Expanded(child: _buildPlace(top[order[k]], order[k])),
          ],
        ],
      ),
    );
  }

  Widget _buildPlace(ProductResponse prod, int rank) {
    final isFirst = rank == 0;
    final color = [_UI.gold, _UI.silver, _UI.bronze][rank];
    final pedestal = [92.0, 66.0, 48.0][rank];
    final imgSize = isFirst ? 96.0 : 78.0;
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final discount = discountPercentage(prod);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst)
          const Icon(Icons.emoji_events, color: _UI.gold, size: 26)
        else
          const SizedBox(height: 26),
        GestureDetector(
          onTap: () => onProductTap(prod),
          child: Container(
            width: imgSize,
            height: imgSize,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: HomeNetworkImage(
                url: image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
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
            fontWeight: FontWeight.w600,
            height: 1.25,
            color: _UI.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _money(price),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: _UI.ink,
          ),
        ),
        if (discount > 0)
          Text(
            '$discount% off',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15803D),
            ),
          ),
        const SizedBox(height: 6),
        SizedBox(
          height: 26,
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
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Pedestal
        Container(
          height: pedestal,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: Text(
            '${rank + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}