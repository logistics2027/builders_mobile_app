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
  static const Color inkSoft = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF15803D);
  static const Color hot = Color(0xFFDC2626);
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

/// "Deals of the Day": a live countdown to midnight and a horizontal
/// carousel of the highest-discount products.
class Item7 extends StatefulWidget {
  const Item7({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  State<Item7> createState() => _Item7State();
}

class _Item7State extends State<Item7> {
  Timer? _timer;
  late Duration _left;

  Duration _remaining() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day + 1);
    return end.difference(now);
  }

  @override
  void initState() {
    super.initState();
    _left = _remaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _left = _remaining());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    // Highest discount first; fall back to all products if none discounted.
    final discounted =
        widget.products.where((p) => discountPercentage(p) > 0).toList()
          ..sort((a, b) => discountPercentage(b).compareTo(discountPercentage(a)));
    final deals = (discounted.isNotEmpty ? discounted : widget.products)
        .take(8)
        .toList();

    return HomeSectionContainer(
      title: 'Deals of the Day',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCountdown(),
          const SizedBox(height: 12),
          SizedBox(
            height: 272,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: deals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) => _buildCard(deals[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return Row(
      children: [
        const Icon(Icons.timer_outlined, size: 18, color: _UI.hot),
        const SizedBox(width: 6),
        const Text(
          'Ends in',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: _UI.inkSoft,
          ),
        ),
        const SizedBox(width: 8),
        _timeBox(_two(_left.inHours)),
        _colon(),
        _timeBox(_two(_left.inMinutes.remainder(60))),
        _colon(),
        _timeBox(_two(_left.inSeconds.remainder(60))),
      ],
    );
  }

  Widget _colon() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 3),
    child: Text(
      ':',
      style: TextStyle(fontWeight: FontWeight.w700, color: _UI.ink),
    ),
  );

  Widget _timeBox(String v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: _UI.ink,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        v,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _buildCard(ProductResponse prod) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final originalPrice = parsePrice(prod.originalPrice);
    final discount = discountPercentage(prod);

    return GestureDetector(
      onTap: () => widget.onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 156,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(color: _UI.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: HomeNetworkImage(
                        url: image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (discount > 0)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: _UI.hot,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(_UI.radius),
                            bottomRight: Radius.circular(_UI.radius),
                          ),
                        ),
                        child: Text(
                          '-$discount%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
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
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: _UI.ink,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (discount > 0 && originalPrice > price)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: Text(
                              _money(originalPrice),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: _UI.inkSoft,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () => widget.onAddToCart(prod),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_UI.radius),
                        ),
                      ),
                      child: const Text(
                        'Grab deal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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