import 'dart:math' as math;

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

  static const List<Color> tints = [
    Color(0xFFFEF3C7),
    Color(0xFFE0F2FE),
    Color(0xFFFCE7F3),
    Color(0xFFDCFCE7),
  ];
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

/// "Flip & Shop": tap a card and it flips in 3D to reveal price, savings
/// and the Add to cart / View buttons on the back.
class Item34 extends StatelessWidget {
  const Item34({
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
      title: 'Flip & Shop',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, i) => _FlipTile(
          prod: list[i],
          tint: _UI.tints[i % _UI.tints.length],
          onProductTap: onProductTap,
          onAddToCart: onAddToCart,
        ),
      ),
    );
  }
}

class _FlipTile extends StatefulWidget {
  const _FlipTile({
    required this.prod,
    required this.tint,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final ProductResponse prod;
  final Color tint;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  State<_FlipTile> createState() => _FlipTileState();
}

class _FlipTileState extends State<_FlipTile> {
  bool _flipped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _flipped = !_flipped),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: _flipped ? 1 : 0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        builder: (context, v, _) {
          final showBack = v > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(v * math.pi),
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _back(),
                  )
                : _front(),
          );
        },
      ),
    );
  }

  Widget _front() {
    final prod = widget.prod;
    return Container(
      decoration: BoxDecoration(
        color: widget.tint,
        borderRadius: BorderRadius.circular(_UI.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: HomeNetworkImage(
                url: firstProductImage(prod),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    prod.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: _UI.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flip,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _back() {
    final prod = widget.prod;
    final price = displayPrice(prod);
    final originalPrice = parsePrice(prod.originalPrice);
    final discount = discountPercentage(prod);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_UI.radius),
        border: Border.all(color: AppTheme.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            prod.name ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: _UI.ink,
            ),
          ),
          const Spacer(),
          Text(
            _money(price),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _UI.ink,
            ),
          ),
          if (discount > 0 && originalPrice > price)
            Row(
              children: [
                Text(
                  _money(originalPrice),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: _UI.inkSoft,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$discount% off',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _UI.success,
                  ),
                ),
              ],
            ),
          const Spacer(),
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: () => widget.onAddToCart(prod),
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
                'Add to cart',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 30,
            child: OutlinedButton(
              onPressed: () => widget.onProductTap(prod),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: _UI.ink,
                side: const BorderSide(color: _UI.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View details',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}