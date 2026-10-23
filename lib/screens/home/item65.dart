// ignore_for_file: unused_import
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

/// "Time of Day Dynamic Mood Shelf": adapts greeting and curated products based on
/// current time (Morning breakfast, Afternoon energy, Evening snacks).
class Item65 extends StatelessWidget {
  const Item65({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.maxItems = 4,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final list = products.take(maxItems).toList();
    if (list.isEmpty) return const SizedBox.shrink();

    final hour = DateTime.now().hour;
    String title = 'Morning Sunrise Breakfast';
    String subtitle = 'Start your day fresh with oats, milk & fruits';
    IconData icon = Icons.wb_sunny;
    Color gradStart = const Color(0xFFF59E0B);
    Color gradEnd = const Color(0xFFEF4444);

    if (hour >= 12 && hour < 17) {
      title = 'Afternoon Lunch & Energy Recharge';
      subtitle = 'Wholesome snacks & refreshing beverages';
      icon = Icons.wb_cloudy;
      gradStart = const Color(0xFF0284C7);
      gradEnd = const Color(0xFF0D9488);
    } else if (hour >= 17) {
      title = 'Evening Chai & Crunch Time';
      subtitle = 'Crisp cookies, hot beverages & savory munchies';
      icon = Icons.nightlight_round;
      gradStart = const Color(0xFF7C3AED);
      gradEnd = const Color(0xFFBE185D);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [gradStart, gradEnd]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 10.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 165,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final prod = list[i];
                return GestureDetector(
                  onTap: () => onProductTap(prod),
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: HomeNetworkImage(
                              url: firstProductImage(prod),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prod.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            Text(
                              _money(displayPrice(prod)),
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () => onAddToCart(prod),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF111827),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, size: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
