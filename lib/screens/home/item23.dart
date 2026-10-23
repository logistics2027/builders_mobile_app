import 'package:avg_mart/helper/helper.dart';
import 'package:avg_mart/widgets/network_image.dart';
import 'package:avg_mart/widgets/home_section_container.dart';
import 'package:flutter/material.dart';
import '../../models/product_response.dart';
import '../../theme/app_theme.dart';

class _UI {
  _UI._();

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

/// "Lookbook": image-first tiles. One wide hero tile on top, then pairs of
/// tiles. Name, price and add button sit on the image over a dark gradient.
class Item23 extends StatelessWidget {
  const Item23({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.maxItems = 5,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final list = products.take(maxItems).toList();
    final rows = <Widget>[];

    // Wide hero
    rows.add(
      AspectRatio(aspectRatio: 1.5, child: _buildTile(list.first, big: true)),
    );

    // Remaining tiles in pairs
    final rest = list.skip(1).toList();
    for (int i = 0; i < rest.length; i += 2) {
      rows.add(const SizedBox(height: 10));
      rows.add(
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 0.82,
                child: _buildTile(rest[i]),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: i + 1 < rest.length
                  ? AspectRatio(
                      aspectRatio: 0.82,
                      child: _buildTile(rest[i + 1]),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }

    return HomeSectionContainer(
      title: 'Lookbook',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }

  Widget _buildTile(ProductResponse prod, {bool big = false}) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final discount = discountPercentage(prod);

    return GestureDetector(
      onTap: () => onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_UI.radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFFF3F4F6)),
            HomeNetworkImage(
              url: image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            // Bottom gradient
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: big ? 110 : 96,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
            ),
            // Discount pill
            if (discount > 0)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$discount% off',
                    style: const TextStyle(
                      color: Color(0xFF15803D),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            // Add button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => onAddToCart(prod),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    size: 17,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
            // Text
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod.name ?? '',
                    maxLines: big ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: big ? 15 : 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _money(price),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: big ? 18 : 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}