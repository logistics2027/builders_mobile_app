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
  static const double radius = 8;
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

/// "Quick Look": an accordion. Each product is a slim row; tapping it
/// expands a panel with a large image and the action buttons. Only one row
/// is open at a time.
class Item35 extends StatefulWidget {
  const Item35({
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
  State<Item35> createState() => _Item35State();
}

class _Item35State extends State<Item35> {
  int _open = 0; // -1 = all closed

  @override
  Widget build(BuildContext context) {
    final list = widget.products.take(widget.maxItems).toList();
    if (list.isEmpty) return const SizedBox.shrink();

    return HomeSectionContainer(
      title: 'Quick Look',
      child: Column(
        children: [
          for (int i = 0; i < list.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == list.length - 1 ? 0 : 10),
              child: _buildItem(list[i], i),
            ),
        ],
      ),
    );
  }

  Widget _buildItem(ProductResponse prod, int index) {
    final open = _open == index;
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final originalPrice = parsePrice(prod.originalPrice);
    final discount = discountPercentage(prod);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_UI.radius),
        border: Border.all(
          color: open ? AppTheme.primary : _UI.border,
          width: open ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          InkWell(
            onTap: () => setState(() => _open = open ? -1 : index),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(4),
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
                    child: Text(
                      prod.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _UI.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _money(price),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: _UI.ink,
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: _UI.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable panel
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 170,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: HomeNetworkImage(
                            url: image,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Text(
                              _money(price),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _UI.ink,
                              ),
                            ),
                            if (discount > 0 && originalPrice > price)
                              Text(
                                _money(originalPrice),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _UI.inkSoft,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            if (discount > 0)
                              Text(
                                '$discount% off',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _UI.success,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: OutlinedButton(
                                  onPressed: () => widget.onProductTap(prod),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _UI.ink,
                                    side: const BorderSide(color: _UI.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Details',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: () => widget.onAddToCart(prod),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Add to cart',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}