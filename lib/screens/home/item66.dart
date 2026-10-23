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

/// "Brand Flagship Showcase": official boutique layout with certified partner tick,
/// brand trust rating, and modern runway carousel.
class Item66 extends StatelessWidget {
  const Item66({
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.verified, color: Color(0xFF38BDF8), size: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OFFICIAL BRAND FLAGSHIP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '100% Genuine Direct from Brand • 4.9 ★ Rating',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final prod = list[i];
                return GestureDetector(
                  onTap: () => onProductTap(prod),
                  child: Container(
                    width: 135,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: HomeNetworkImage(
                              url: firstProductImage(prod),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          prod.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _money(displayPrice(prod)),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () => onAddToCart(prod),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF38BDF8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, size: 14, color: Colors.black),
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
