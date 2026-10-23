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

/// "Wholesale Club Tier Table": tiered volume discount widget with interactive
/// quantity selector dynamically recalculating unit pricing and bulk savings.
class Item73 extends StatefulWidget {
  const Item73({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  State<Item73> createState() => _Item73State();
}

class _Item73State extends State<Item73> {
  int _tier = 1;

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();
    final prod = widget.products.first;
    final basePrice = displayPrice(prod);

    double unitPrice = basePrice;
    int discountPct = 0;
    if (_tier == 3) {
      unitPrice = basePrice * 0.90;
      discountPct = 10;
    } else if (_tier == 6) {
      unitPrice = basePrice * 0.80;
      discountPct = 20;
    }

    final totalPrice = unitPrice * _tier;

    return HomeSectionContainer(
      title: 'Wholesale Club: Buy Bulk & Save',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: HomeNetworkImage(
                    url: firstProductImage(prod),
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prod.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Base: ${_money(basePrice)} each',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTierChip(1, 'Single (1x)', '0% Off'),
                _buildTierChip(3, 'Pack of 3', '10% Off'),
                _buildTierChip(6, 'Mega Pack (6x)', '20% Off'),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit: ${_money(unitPrice)} | Save $discountPct%',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total: ${_money(totalPrice)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => widget.onAddToCart(prod),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Add ${_tier}x to Cart', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierChip(int count, String label, String disc) {
    final isSel = _tier == count;
    return GestureDetector(
      onTap: () => setState(() => _tier = count),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSel ? const Color(0xFF1E3A8A) : const Color(0xFFCBD5E1)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isSel ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            Text(
              disc,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isSel ? const Color(0xFF93C5FD) : const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
