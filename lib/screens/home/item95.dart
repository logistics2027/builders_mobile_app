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

/// "Pre-Order Farm Harvest Bookings": allows reserving crops harvesting in 3 days
/// with direct dispatch dates and farmer signature assurance.
class Item95 extends StatelessWidget {
  const Item95({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    final prod = products.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FEE7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBEF264)),
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: HomeNetworkImage(
              url: firstProductImage(prod),
              width: 65,
              height: 65,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🌾 HARVESTING IN 2 DAYS: PRE-ORDER',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF3F6212)),
                ),
                Text(
                  prod.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Fresh Dispatch on Monday • ${_money(displayPrice(prod))}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4D7C0F)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => onAddToCart(prod),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF65A30D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: const Text('Book Batch', style: TextStyle(fontSize: 10.5)),
          ),
        ],
      ),
    );
  }
}
