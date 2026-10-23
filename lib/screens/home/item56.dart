import 'package:avg_mart/helper/helper.dart';
import 'package:avg_mart/widgets/network_image.dart';
import 'package:avg_mart/widgets/home_section_container.dart';
import 'package:flutter/material.dart';
import '../../models/product_response.dart';
import '../../theme/app_theme.dart';

class _UI {
  _UI._();

  static const Color ink = Color(0xFF111827);
  static const Color inkSoft = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color heart = Color(0xFFE11D48);
  static const double radius = 12;
}

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

/// "Favourites": a grid with a heart on every card and a "Saved" strip that
/// appears on top once something is hearted.
///
/// Hearts are kept only while the screen is alive. To keep them for real
/// (so they survive restarts), save/remove the product in
/// [onFavouriteToggle] using your own storage or API.
class Item56 extends StatefulWidget {
  const Item56({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.onFavouriteToggle,
    this.maxItems = 6,
  });

  final List<ProductResponse> products;
  final ValueChanged<ProductResponse> onProductTap;
  final ValueChanged<ProductResponse> onAddToCart;

  /// Called every time a heart is toggled (product, isNowFavourite).
  final void Function(ProductResponse product, bool isFavourite)?
  onFavouriteToggle;
  final int maxItems;

  @override
  State<Item56> createState() => _Item56State();
}

class _Item56State extends State<Item56> {
  final Set<String> _fav = {};

  String _key(ProductResponse p) => p.id.toString();

  void _toggle(ProductResponse p) {
    final k = _key(p);
    final nowFav = !_fav.contains(k);
    setState(() => nowFav ? _fav.add(k) : _fav.remove(k));
    widget.onFavouriteToggle?.call(p, nowFav);
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.products.take(widget.maxItems).toList();
    if (list.isEmpty) return const SizedBox.shrink();

    final saved = list.where((p) => _fav.contains(_key(p))).toList();

    return HomeSectionContainer(
      title: 'Favourites',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            alignment: Alignment.topCenter,
            child: saved.isEmpty
                ? const SizedBox(width: double.infinity)
                : _buildSavedStrip(saved),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.76,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, i) => _buildCard(list[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedStrip(List<ProductResponse> saved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _UI.heart.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(_UI.radius),
        border: Border.all(color: _UI.heart.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: _UI.heart, size: 18),
          const SizedBox(width: 6),
          Text(
            'Saved (${saved.length})',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _UI.ink,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: saved.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => widget.onProductTap(saved[i]),
                  child: Container(
                    width: 36,
                    height: 36,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: _UI.border),
                    ),
                    child: ClipOval(
                      child: HomeNetworkImage(
                        url: firstProductImage(saved[i]),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(ProductResponse prod) {
    final fav = _fav.contains(_key(prod));
    final image = firstProductImage(prod);
    final price = displayPrice(prod);
    final discount = discountPercentage(prod);

    return GestureDetector(
      onTap: () => widget.onProductTap(prod),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(color: _UI.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: HomeNetworkImage(
                        url: image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _toggle(prod),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x1F000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (c, a) =>
                              ScaleTransition(scale: a, child: c),
                          child: Icon(
                            fav ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(fav),
                            size: 18,
                            color: fav ? _UI.heart : _UI.inkSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              prod.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.25,
                color: _UI.ink,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _money(price),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _UI.ink,
                  ),
                ),
                if (discount > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$discount%',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ],
                const Spacer(),
                InkWell(
                  onTap: () => widget.onAddToCart(prod),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}