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
  static const double radius = 16;
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

/// "Swipe Deck": a stack of cards with the next ones peeking from behind.
/// Swipe left/right (or use the arrows) to flip through products.
class Item22 extends StatefulWidget {
  const Item22({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.maxItems = 6,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;
  final int maxItems;

  @override
  State<Item22> createState() => _Item22State();
}

class _Item22State extends State<Item22> {
  int _index = 0;
  int _direction = 1; // 1 = next (slide from right), -1 = previous

  List<ProductResponse> get _list =>
      widget.products.take(widget.maxItems).toList();

  void _go(int delta) {
    final n = _list.length;
    if (n < 2) return;
    setState(() {
      _direction = delta;
      _index = (_index + delta + n) % n;
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = _list;
    if (list.isEmpty) return const SizedBox.shrink();
    if (_index >= list.length) _index = 0;

    final current = list[_index];

    return HomeSectionContainer(
      title: 'Swipe Deck',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onHorizontalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v < -200) _go(1);
              if (v > 200) _go(-1);
            },
            child: SizedBox(
              height: 340,
              child: Stack(
                children: [
                  if (list.length > 2) _backCard(2),
                  if (list.length > 1) _backCard(1),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 24,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0.18 * _direction, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(_index),
                        child: _buildTopCard(current),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _circleButton(Icons.chevron_left, () => _go(-1)),
              Expanded(
                child: Center(
                  child: Text(
                    '${_index + 1} / ${list.length}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _UI.inkSoft,
                    ),
                  ),
                ),
              ),
              _circleButton(Icons.chevron_right, () => _go(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _backCard(int depth) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 24,
      child: Transform.translate(
        offset: Offset(0, 11.0 * depth),
        child: Transform.scale(
          scale: 1 - 0.05 * depth,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_UI.radius),
              border: Border.all(color: _UI.border),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _UI.border),
          color: Colors.white,
        ),
        child: Icon(icon, size: 22, color: _UI.ink),
      ),
    );
  }

  Widget _buildTopCard(ProductResponse prod) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final originalPrice = parsePrice(prod.originalPrice);
    final discount = discountPercentage(prod);

    return GestureDetector(
      onTap: () => widget.onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(color: _UI.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(
                      color: const Color(0xFFF9FAFB),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: HomeNetworkImage(
                          url: image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  if (discount > 0)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _UI.success,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$discount% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _UI.ink,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (discount > 0 && originalPrice > price)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  _money(originalPrice),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: _UI.inkSoft,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => widget.onAddToCart(prod),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 13,
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
      ),
    );
  }
}