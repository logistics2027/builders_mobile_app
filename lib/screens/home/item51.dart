import 'package:avg_mart/helper/helper.dart';
import 'package:avg_mart/widgets/network_image.dart';
import 'package:avg_mart/widgets/home_section_container.dart';
import 'package:flutter/material.dart';
import '../../models/product_response.dart';
import '../../theme/app_theme.dart';

class _UI {
  _UI._();

  static const Color ink = Color(0xFF111827);
  static const Color border = Color(0xFFE5E7EB);
  static const Color fire = Color(0xFFEA580C);
}

/// "Trending Searches": a cloud of text pills (like search suggestions).
/// Pills for heavily discounted products get a flame icon. Tapping a pill
/// opens that product.
class Item51 extends StatelessWidget {
  const Item51({
    super.key,
    required this.products,
    required this.onProductTap,
    this.maxItems = 10,
    this.hotDiscount = 20,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final int maxItems;

  /// Discount % at or above which a pill shows the flame icon.
  final int hotDiscount;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final list = products.take(maxItems).toList();

    return HomeSectionContainer(
      title: 'Trending Searches',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final p in list) _buildPill(context, p)],
      ),
    );
  }

  Widget _buildPill(BuildContext context, ProductResponse prod) {
    final hot = discountPercentage(prod) >= hotDiscount;
    final maxW = MediaQuery.of(context).size.width * 0.6;

    return GestureDetector(
      onTap: () => onProductTap(prod),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxW),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: hot ? _UI.fire : _UI.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hot ? Icons.local_fire_department : Icons.trending_up,
              size: 16,
              color: hot ? _UI.fire : AppTheme.primary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                prod.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: _UI.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}