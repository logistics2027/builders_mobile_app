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

/// "Recipe to Cart / Meal Kit Builder": Shows an appetizing meal card with prep time,
/// serving count, and a checklist of products needed to cook it with a 1-tap "Add All Ingredients".
class Item59 extends StatefulWidget {
  const Item59({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  @override
  State<Item59> createState() => _Item59State();
}

class _Item59State extends State<Item59> {
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    for (final p in widget.products.take(3)) {
      if (p.id != null) _selectedIds.add(p.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.products.take(3).toList();
    if (list.isEmpty) return const SizedBox.shrink();

    double totalCombo = 0.0;
    for (final p in list) {
      if (_selectedIds.contains(p.id)) {
        totalCombo += displayPrice(p);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECIPE KIT: ITALIAN DELIGHT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    Text(
                      '25 mins prep • Serves 3 • Chef Verified',
                      style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: const Text(
                  'Bundle & Save',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final prod in list) _buildIngredientRow(prod),
          const Divider(height: 20, color: Color(0xFFFDE68A)),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meal Kit Total',
                    style: TextStyle(fontSize: 11, color: Color(0xFF78350F)),
                  ),
                  Text(
                    _money(totalCombo),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () {
                        for (final prod in list) {
                          if (_selectedIds.contains(prod.id)) {
                            widget.onAddToCart(prod);
                          }
                        }
                      },
                icon: const Icon(Icons.add_shopping_cart, size: 16),
                label: Text('Add ${_selectedIds.length} to Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientRow(ProductResponse prod) {
    final isChecked = _selectedIds.contains(prod.id);
    final image = firstProductImage(prod);
    final price = displayPrice(prod);

    return InkWell(
      onTap: () {
        if (prod.id == null) return;
        setState(() {
          if (isChecked) {
            _selectedIds.remove(prod.id);
          } else {
            _selectedIds.add(prod.id!);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isChecked ? const Color(0xFFD97706) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isChecked ? const Color(0xFFD97706) : const Color(0xFF9CA3AF),
              size: 20,
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: HomeNetworkImage(
                url: image,
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                prod.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              _money(price),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB45309),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
