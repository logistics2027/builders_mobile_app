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

/// "Group Buy & Team Deals": collaborative shopping widget offering 30% discount
/// when purchasing together with a friend within a 15-minute window.
class Item85 extends StatefulWidget {
  const Item85({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  State<Item85> createState() => _Item85State();
}

class _Item85State extends State<Item85> {
  bool _teamJoined = false;

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();
    final prod = widget.products.first;
    final teamPrice = displayPrice(prod) * 0.7;

    return HomeSectionContainer(
      title: 'Group Buy: Team Up & Save 30%',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECDD3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(2),
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
                        'Solo Price: ${_money(displayPrice(prod))} | Team: ${_money(teamPrice)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFE11D48),
                  child: Text('A', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: _teamJoined ? const Color(0xFF059669) : const Color(0xFFCBD5E1),
                  child: Icon(
                    _teamJoined ? Icons.check : Icons.person_add,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _teamJoined ? 'Team Complete! (2/2)' : '1 spot open! 12 mins left',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _teamJoined = true);
                    widget.onAddToCart(prod);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: Text(_teamJoined ? 'Joined!' : 'Join Team', style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
