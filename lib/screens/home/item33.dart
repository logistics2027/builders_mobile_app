import 'dart:async';

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

/// "Live Ticker": two lanes of product pills that glide sideways on their
/// own, in opposite directions. Touching a lane pauses it; it resumes after
/// two seconds.
class Item33 extends StatelessWidget {
  const Item33({
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

    final reversed = products.reversed.toList();

    return HomeSectionContainer(
      title: 'Live Ticker',
      child: Column(
        children: [
          _TickerLane(
            products: products,
            speed: 0.7,
            reverse: false,
            onProductTap: onProductTap,
            onAddToCart: onAddToCart,
          ),
          const SizedBox(height: 10),
          _TickerLane(
            products: reversed,
            speed: 0.5,
            reverse: true,
            onProductTap: onProductTap,
            onAddToCart: onAddToCart,
          ),
        ],
      ),
    );
  }
}

class _TickerLane extends StatefulWidget {
  const _TickerLane({
    required this.products,
    required this.speed,
    required this.reverse,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final double speed; // pixels per tick
  final bool reverse;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  State<_TickerLane> createState() => _TickerLaneState();
}

class _TickerLaneState extends State<_TickerLane> {
  final ScrollController _c = ScrollController();
  Timer? _ticker;
  Timer? _resume;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 32), (_) {
      if (_paused || !_c.hasClients) return;
      _c.jumpTo(_c.offset + widget.speed);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _resume?.cancel();
    _c.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n is ScrollStartNotification && n.dragDetails != null) {
      _paused = true;
      _resume?.cancel();
    } else if (n is ScrollEndNotification && _paused) {
      _resume?.cancel();
      _resume = Timer(const Duration(seconds: 2), () => _paused = false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.products;
    return SizedBox(
      height: 64,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: ListView.builder(
          controller: _c,
          scrollDirection: Axis.horizontal,
          reverse: widget.reverse,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _buildPill(list[i % list.length]),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(ProductResponse prod) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);

    return GestureDetector(
      onTap: () => widget.onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 220,
        padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: _UI.border),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
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
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    prod.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
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
                ],
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => widget.onAddToCart(prod),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}