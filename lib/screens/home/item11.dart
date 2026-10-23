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

/// "In the Spotlight": auto-sliding promo carousel with dot indicators.
/// Each slide is a gradient banner with product text on the left and the
/// product image in a white circle on the right.
class Item11 extends StatefulWidget {
  const Item11({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.autoPlay = true,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;
  final bool autoPlay;

  @override
  State<Item11> createState() => _Item11State();
}

class _Item11State extends State<Item11> {
  final PageController _pc = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _page = 0;

  List<ProductResponse> _slides() {
    final featured = widget.products.where((p) => p.isFeatured ?? false);
    final list = featured.isNotEmpty ? featured.toList() : widget.products;
    return list.take(5).toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted || !_pc.hasClients) return;
        final n = _slides().length;
        if (n < 2) return;
        _pc.animateToPage(
          (_page + 1) % n,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides();
    if (slides.isEmpty) return const SizedBox.shrink();

    return HomeSectionContainer(
      title: 'In the Spotlight',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 196,
            child: PageView.builder(
              controller: _pc,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildSlide(slides[i]),
              ),
            ),
          ),
          if (slides.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: active ? 20 : 6,
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.primary
                        : AppTheme.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSlide(ProductResponse prod) {
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final originalPrice = parsePrice(prod.originalPrice);
    final discount = discountPercentage(prod);

    return GestureDetector(
      onTap: () => widget.onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_UI.radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              AppTheme.primary.withValues(alpha: 0.72),
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      discount > 0 ? 'SAVE $discount%' : 'FEATURED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  Text(
                    prod.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _money(price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (discount > 0 && originalPrice > price)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            _money(originalPrice),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.white70,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => widget.onAddToCart(prod),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Add to cart',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 118,
              height: 118,
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: HomeNetworkImage(
                url: image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}