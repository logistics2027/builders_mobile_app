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

/// "7-Day Habit Streak": gamified milestone tracker encouraging daily shopping
/// with an unlockable free reward on Day 7.
class Item88 extends StatefulWidget {
  const Item88({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  State<Item88> createState() => _Item88State();
}

class _Item88State extends State<Item88> {
  final int _currentStreak = 4;

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();
    final rewardProd = widget.products.first;

    return HomeSectionContainer(
      title: 'Daily Streak: 4 of 7 Days Active',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final dayNum = i + 1;
                final isDone = dayNum <= _currentStreak;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isDone ? const Color(0xFFF59E0B) : const Color(0xFFE5E7EB),
                      child: Icon(
                        isDone ? Icons.check : (dayNum == 7 ? Icons.card_giftcard : Icons.circle),
                        size: 14,
                        color: isDone ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Day $dayNum',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                        color: isDone ? const Color(0xFF92400E) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                );
              }),
            ),
            const Divider(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(2),
                  child: HomeNetworkImage(
                    url: firstProductImage(rewardProd),
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Day 7 Freebie Reward Preview',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                      ),
                      Text(
                        rewardProd.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => widget.onAddToCart(rewardProd),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Keep Streak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
