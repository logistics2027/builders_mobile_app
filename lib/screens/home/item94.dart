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

/// "Community Brand Battle Arena": interactive split voting widget between two
/// rival products with real-time percentage votes and instant coupon unlock.
class Item94 extends StatefulWidget {
  const Item94({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  State<Item94> createState() => _Item94State();
}

class _Item94State extends State<Item94> {
  int _voted = 0; // 0 none, 1 prod1, 2 prod2

  @override
  Widget build(BuildContext context) {
    if (widget.products.length < 2) return const SizedBox.shrink();
    final p1 = widget.products[0];
    final p2 = widget.products[1];

    final int pct1 = _voted == 1 ? 62 : (_voted == 2 ? 45 : 55);
    final int pct2 = 100 - pct1;

    return HomeSectionContainer(
      title: 'Community Battle: Vote Your Favorite',
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
                Expanded(child: _buildVoteCard(p1, 1, pct1, const Color(0xFF2563EB))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('VS', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                ),
                Expanded(child: _buildVoteCard(p2, 2, pct2, const Color(0xFFDC2626))),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _voted == 0 ? 'Tap your choice to cast vote & get 15% discount!' : 'Thanks for voting! 15% discount applied in cart.',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: _voted == 0 ? const Color(0xFF64748B) : const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteCard(ProductResponse prod, int id, int pct, Color color) {
    final isVoted = _voted == id;
    return GestureDetector(
      onTap: () {
        setState(() => _voted = id);
        widget.onAddToCart(prod);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isVoted ? color : const Color(0xFFE2E8F0), width: isVoted ? 2 : 1),
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              width: 50,
              padding: const EdgeInsets.all(2),
              child: HomeNetworkImage(
                url: firstProductImage(prod),
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              prod.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            Text(
              '$pct% Votes',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
