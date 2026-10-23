// ignore_for_file: unused_import, unused_element
import 'package:avg_mart/helper/helper.dart';
import 'package:avg_mart/widgets/network_image.dart';
import 'package:avg_mart/widgets/home_section_container.dart';
import 'package:flutter/material.dart';
import '../../models/product_response.dart';
import '../../theme/app_theme.dart';

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

/// "Daily Mystery Coupon Locker": interactive 3-door locker where tapping an unopened
/// locker swings it open to reveal secret promo codes.
class Item101 extends StatefulWidget {
  const Item101({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  State<Item101> createState() => _Item101State();
}

class _Item101State extends State<Item101> {
  int _unlockedDoor = -1;
  final List<String> _rewards = ['20% OFF', 'FREE SHIP', '₹100 OFF'];

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();
    final p = widget.products.first;

    return HomeSectionContainer(
      title: 'Daily Coupon Locker: Pick a Door',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (i) {
                final isOpened = _unlockedDoor == i;
                return GestureDetector(
                  onTap: () => setState(() => _unlockedDoor = i),
                  child: Container(
                    width: 90,
                    height: 70,
                    decoration: BoxDecoration(
                      color: isOpened ? const Color(0xFF10B981) : const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Color(0x1F000000), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Center(
                      child: isOpened
                          ? Text(
                              _rewards[i],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock, color: Colors.white70, size: 20),
                                const SizedBox(height: 2),
                                Text('Door ${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 10.5)),
                              ],
                            ),
                    ),
                  ),
                );
              }),
            ),
            if (_unlockedDoor >= 0) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(2),
                    child: HomeNetworkImage(
                      url: firstProductImage(p),
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Coupon ${_rewards[_unlockedDoor]} applied to ${p.name ?? 'item'}!',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => widget.onAddToCart(p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Apply & Buy', style: TextStyle(fontSize: 10.5)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
