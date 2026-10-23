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

/// "Pick & Add": tick several products, see the running total, and add them
/// all to the cart with one button.
class Item39 extends StatefulWidget {
  const Item39({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.maxItems = 5,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;

  /// Called once per ticked product when "Add selected" is pressed.
  final ValueChanged<ProductResponse> onAddToCart;
  final int maxItems;

  @override
  State<Item39> createState() => _Item39State();
}

class _Item39State extends State<Item39> {
  final Set<int> _picked = {};

  @override
  Widget build(BuildContext context) {
    final list = widget.products.take(widget.maxItems).toList();
    if (list.isEmpty) return const SizedBox.shrink();

    _picked.removeWhere((i) => i >= list.length);

    double total = 0;
    for (final i in _picked) {
      total += displayPrice(list[i]);
    }
    final allPicked = _picked.length == list.length;

    return HomeSectionContainer(
      title: 'Pick & Add',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(color: _UI.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tick the products you want',
                      style: TextStyle(fontSize: 12, color: _UI.inkSoft),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      if (allPicked) {
                        _picked.clear();
                      } else {
                        _picked
                          ..clear()
                          ..addAll(List.generate(list.length, (i) => i));
                      }
                    }),
                    child: Text(
                      allPicked ? 'Clear all' : 'Select all',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < list.length; i++) ...[
              const Divider(height: 1, color: _UI.border),
              _buildRow(list[i], i),
            ],
            // Bottom bar
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFF9FAFB),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _picked.isEmpty
                              ? 'Nothing selected'
                              : '${_picked.length} selected',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _UI.inkSoft,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _money(total),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _UI.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: _picked.isEmpty
                          ? null
                          : () {
                              final chosen = _picked.toList()..sort();
                              for (final i in chosen) {
                                widget.onAddToCart(list[i]);
                              }
                              setState(_picked.clear);
                            },
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text('Add selected'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE5E7EB),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_UI.radius),
                        ),
                      ),
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

  Widget _buildRow(ProductResponse prod, int index) {
    final picked = _picked.contains(index);
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final discount = discountPercentage(prod);

    return InkWell(
      onTap: () => setState(() {
        picked ? _picked.remove(index) : _picked.add(index);
      }),
      child: Container(
        color: picked ? AppTheme.primary.withValues(alpha: 0.05) : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: picked ? AppTheme.primary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: picked ? AppTheme.primary : const Color(0xFFD1D5DB),
                  width: 1.6,
                ),
              ),
              child: picked
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _UI.border),
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
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        _money(price),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: _UI.ink,
                        ),
                      ),
                      if (discount > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '$discount% off',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => widget.onProductTap(prod),
              icon: const Icon(Icons.chevron_right, color: _UI.inkSoft),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}