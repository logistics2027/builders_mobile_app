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

/// "Interactive Variant & Color Wheel": interactive card where tapping color swatches
/// updates the product preview border, color tag, and selected variant.
class Item71 extends StatefulWidget {
  const Item71({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  State<Item71> createState() => _Item71State();
}

class _Item71State extends State<Item71> {
  int _colorIndex = 0;
  final List<Map<String, dynamic>> _colors = [
    {'name': 'Ocean Navy', 'color': Color(0xFF1E3A8A)},
    {'name': 'Crimson Red', 'color': Color(0xFFDC2626)},
    {'name': 'Emerald Green', 'color': Color(0xFF059669)},
    {'name': 'Amber Gold', 'color': Color(0xFFD97706)},
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();
    final prod = widget.products.first;
    final activeColor = _colors[_colorIndex]['color'] as Color;
    final activeName = _colors[_colorIndex]['name'] as String;

    return HomeSectionContainer(
      title: 'Custom Shades & Variants',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: activeColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 85,
              height: 85,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: HomeNetworkImage(
                url: firstProductImage(prod),
                width: 85,
                height: 85,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Selected: $activeName',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: activeColor),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(_colors.length, (i) {
                      final c = _colors[i]['color'] as Color;
                      final isSel = i == _colorIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _colorIndex = i),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? Colors.black : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        _money(displayPrice(prod)),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => widget.onAddToCart(prod),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Add Shade', style: TextStyle(fontSize: 11)),
                      ),
                    ],
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
