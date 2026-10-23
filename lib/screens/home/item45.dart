import 'package:avg_mart/helper/helper.dart';
import 'package:avg_mart/widgets/network_image.dart';
import 'package:avg_mart/widgets/home_section_container.dart';
import 'package:flutter/material.dart';
import '../../models/product_response.dart';
import '../../theme/app_theme.dart';

class _UI {
  _UI._();

  static const Color ink = Color(0xFF111827);
  static const Color success = Color(0xFF15803D);

  static const List<Color> tints = [
    Color(0xFFFEF3C7),
    Color(0xFFE0F2FE),
    Color(0xFFFCE7F3),
    Color(0xFFDCFCE7),
    Color(0xFFEDE9FE),
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

/// "Stories": a tall story-style card with segmented progress bars on top.
/// It advances by itself every 4 seconds. Tap the left/right half to go
/// back/forward, press and hold to pause.
class Item45 extends StatefulWidget {
  const Item45({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.maxItems = 5,
    this.height = 420,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;
  final int maxItems;
  final double height;

  @override
  State<Item45> createState() => _Item45State();
}

class _Item45State extends State<Item45> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  int _i = 0;

  List<ProductResponse> get _list =>
      widget.products.take(widget.maxItems).toList();

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) _go(_i + 1);
      });
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  void _go(int index) {
    final n = _list.length;
    if (n == 0 || !mounted) return;
    setState(() => _i = (index % n + n) % n);
    _ac.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final list = _list;
    if (list.isEmpty) return const SizedBox.shrink();
    if (_i >= list.length) _i = 0;

    final prod = list[_i];

    return HomeSectionContainer(
      title: 'Stories',
      child: SizedBox(
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background + image
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: ColoredBox(
                  key: ValueKey(_i),
                  color: _UI.tints[_i % _UI.tints.length],
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 70, 28, 190),
                    child: HomeNetworkImage(
                      url: firstProductImage(prod),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Tap zones (left = back, right = next, hold = pause)
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _go(_i - 1),
                        onLongPressStart: (_) => _ac.stop(),
                        onLongPressEnd: (_) => _ac.forward(),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _go(_i + 1),
                        onLongPressStart: (_) => _ac.stop(),
                        onLongPressEnd: (_) => _ac.forward(),
                      ),
                    ),
                  ],
                ),
              ),
              // Progress segments
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: IgnorePointer(
                  child: Row(
                    children: [
                      for (int j = 0; j < list.length; j++) _segment(j),
                    ],
                  ),
                ),
              ),
              // Info panel
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildInfo(prod),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segment(int j) {
    Widget bar;
    if (j < _i) {
      bar = const LinearProgressIndicator(
        value: 1,
        minHeight: 3.5,
        backgroundColor: Colors.black12,
        valueColor: AlwaysStoppedAnimation<Color>(_UI.ink),
      );
    } else if (j == _i) {
      bar = AnimatedBuilder(
        animation: _ac,
        builder: (context, _) => LinearProgressIndicator(
          value: _ac.value,
          minHeight: 3.5,
          backgroundColor: Colors.black12,
          valueColor: const AlwaysStoppedAnimation<Color>(_UI.ink),
        ),
      );
    } else {
      bar = const LinearProgressIndicator(
        value: 0,
        minHeight: 3.5,
        backgroundColor: Colors.black12,
        valueColor: AlwaysStoppedAnimation<Color>(_UI.ink),
      );
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ClipRRect(borderRadius: BorderRadius.circular(2), child: bar),
      ),
    );
  }

  Widget _buildInfo(ProductResponse prod) {
    final price = displayPrice(prod);
    final originalPrice = parsePrice(prod.originalPrice);
    final discount = discountPercentage(prod);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.82)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => widget.onProductTap(prod),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (discount > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
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
                Text(
                  prod.name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(price),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (discount > 0 && originalPrice > price)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          _money(originalPrice),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12.5,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.white60,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () => widget.onAddToCart(prod),
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Add to cart'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primary,
                textStyle: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}