import 'dart:async';
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

/// "Surprise Me": press the button, the tile shuffles through your products
/// for a moment and lands on a random pick with price and buttons.
class Item53 extends StatefulWidget {
  const Item53({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  State<Item53> createState() => _Item53State();
}

class _Item53State extends State<Item53> {
  final math.Random _rnd = math.Random();
  Timer? _timer;
  bool _shuffling = false;
  ProductResponse? _showing;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _shuffle() {
    final list = widget.products;
    if (_shuffling || list.isEmpty) return;

    setState(() => _shuffling = true);
    int ticks = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 90), (t) {
      ticks++;
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _showing = list[_rnd.nextInt(list.length)];
        if (ticks >= 14) {
          _shuffling = false;
          t.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    final prod = _showing;

    return HomeSectionContainer(
      title: 'Surprise Me',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _UI.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tile
            SizedBox(
              height: 190,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 90),
                child: prod == null ? _placeholder() : _imageTile(prod),
              ),
            ),
            const SizedBox(height: 12),
            // Result
            if (prod != null && !_shuffling) _buildResult(prod),
            if (prod == null)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "Can't decide? Let us pick something for you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: _UI.inkSoft),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _shuffling ? null : _shuffle,
                icon: const Icon(Icons.casino_outlined, size: 20),
                label: Text(
                  _shuffling
                      ? 'Picking...'
                      : (prod == null ? 'Surprise me' : 'Try again'),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.primary.withValues(
                    alpha: 0.5,
                  ),
                  disabledForegroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 14,
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
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      key: const ValueKey('placeholder'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.9),
            AppTheme.primary.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 84,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _imageTile(ProductResponse prod) {
    return Container(
      key: ValueKey('tile-${prod.id}-${_shuffling ? 's' : 'f'}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _shuffling ? _UI.border : AppTheme.primary,
          width: _shuffling ? 1 : 2,
        ),
      ),
      child: HomeNetworkImage(
        url: firstProductImage(prod),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildResult(ProductResponse prod) {
    final price = displayPrice(prod);
    final originalPrice = parsePrice(prod.originalPrice);
    final discount = discountPercentage(prod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          prod.name ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: _UI.ink,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _money(price),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _UI.ink,
              ),
            ),
            if (discount > 0 && originalPrice > price) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  _money(originalPrice),
                  style: const TextStyle(
                    fontSize: 12,
                    color: _UI.inkSoft,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
            if (discount > 0) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '$discount% off',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _UI.success,
                  ),
                ),
              ),
            ],
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 38,
                child: OutlinedButton(
                  onPressed: () => widget.onAddToCart(prod),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Add to cart',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}