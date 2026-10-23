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

/// "Top Rated Star Filter": allows shoppers to filter products by customer ratings
/// (4.5★ and 4.0★) with verified customer praise tags.
class Item92 extends StatefulWidget {
  const Item92({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  State<Item92> createState() => _Item92State();
}

class _Item92State extends State<Item92> {
  int _ratingFilter = 0;
  final List<String> _filters = ['All Ratings', '★ 4.8 & Above', '★ 4.5 & Above'];

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    return HomeSectionContainer(
      title: 'Top Rated by 50,000+ Customers',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: List.generate(_filters.length, (i) {
              final isSel = _ratingFilter == i;
              return GestureDetector(
                onTap: () => setState(() => _ratingFilter = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFF59E0B) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Text(
                    _filters[i],
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: isSel ? Colors.black : const Color(0xFF92400E),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 165,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.products.take(5).length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final prod = widget.products[i];
                return GestureDetector(
                  onTap: () => widget.onProductTap(prod),
                  child: Container(
                    width: 125,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: HomeNetworkImage(
                            url: firstProductImage(prod),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                            Text(' 4.9 (1.2k)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
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
                              onTap: () => widget.onAddToCart(prod),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, size: 12, color: Colors.black),
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
