import 'package:avg_mart/models/product_response.dart';
import 'package:avg_mart/widgets/avg_mart_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart/cart_cubit.dart';
import '../bloc/orders/orders_cubit.dart';
import '../bloc/profile/profile_cubit.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';
import 'main_navigation_screen.dart';

const double _kFreeShippingThreshold = 499.0;
const double _kRadiusCard = 14;
const double _kRadiusControl = 10;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Kept for the (currently disabled) "save for later" feature.
  // ignore: unused_element
  ProductResponse _productFromCartItem(CartItem item) {
    return ProductResponse(
      id: item.productId ?? item.id,
      name: item.name,
      category: item.category,
      originalPrice: item.priceValue.toString(),
      offerPrice: item.priceValue.toString(),
      images: item.image.isNotEmpty ? [item.image] : const [],
      sizes: item.selectedSize.isNotEmpty ? [item.selectedSize] : const [],
    );
  }

  void _openCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeContext) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: BlocProvider.of<CartCubit>(context)),
            BlocProvider.value(value: BlocProvider.of<OrdersCubit>(context)),
            BlocProvider.value(value: BlocProvider.of<ProfileCubit>(context)),
          ],
          child: const CheckoutScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartCubit>().state;
    final cartItems = cartState.items;
    final isLoading =
        cartState.status == CartStatus.initial ||
        cartState.status == CartStatus.loading;

    return Scaffold(
      appBar: AvgMartAppBar(title: 'Shopping Cart', leading: false),
      backgroundColor: AppTheme.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const _EmptyCart()
          : Column(
              children: [
                _CheckoutHeader(
                  subtotal: cartState.totalPrice,
                  totalCount: cartState.totalItems,
                  onCheckout: () => _openCheckout(context),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 2, bottom: 10),
                        child: Text(
                          'Items in your cart (${cartItems.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: _cardDecoration,
                        child: Column(
                          children: [
                            for (int i = 0; i < cartItems.length; i++) ...[
                              _CartItemRow(
                                key: ValueKey(cartItems[i].id),
                                item: cartItems[i],
                              ),
                              if (i != cartItems.length - 1)
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  indent: 14,
                                  endIndent: 14,
                                  color: AppTheme.divider,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

final BoxDecoration _cardDecoration = BoxDecoration(
  color: AppTheme.surface,
  borderRadius: BorderRadius.circular(_kRadiusCard),
  border: Border.all(color: AppTheme.divider),
);

// -----------------------------------------------------------------------------
// Top header: total + checkout button, with a small free-delivery line below
// -----------------------------------------------------------------------------
class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({
    required this.subtotal,
    required this.totalCount,
    required this.onCheckout,
  });

  final double subtotal;
  final int totalCount;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(bottom: BorderSide(color: AppTheme.divider)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Subtotal ($totalCount ${totalCount == 1 ? 'item' : 'items'})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_kRadiusControl),
                      ),
                    ),
                    child: const Text(
                      'Continue to checkout',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 10),
          // _FreeDeliveryLine(subtotal: subtotal),
        ],
      ),
    );
  }
}

// Compact, low-emphasis free-delivery indicator.
class _FreeDeliveryLine extends StatelessWidget {
  const _FreeDeliveryLine({required this.subtotal});

  final double subtotal;

  @override
  Widget build(BuildContext context) {
    final unlocked = subtotal >= _kFreeShippingThreshold;
    final progress = (subtotal / _kFreeShippingThreshold).clamp(0.0, 1.0);
    final remaining = _kFreeShippingThreshold - subtotal;
    final color = unlocked ? AppTheme.success : AppTheme.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              unlocked
                  ? Icons.check_circle_rounded
                  : Icons.local_shipping_outlined,
              size: 13,
              color: color,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                unlocked
                    ? 'Free delivery unlocked'
                    : 'Add ₹${remaining.toStringAsFixed(2)} more for free delivery',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: AppTheme.divider,
            valueColor: AlwaysStoppedAnimation<Color>(
              unlocked ? AppTheme.success : AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Empty state
// -----------------------------------------------------------------------------
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppTheme.tint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 34,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add products to review them here before you check out.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MainNavigationScreen(initialTab: 0),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_kRadiusControl),
                  ),
                ),
                child: const Text(
                  'Start shopping',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Cart item row
// -----------------------------------------------------------------------------
class _CartItemRow extends StatelessWidget {
  const _CartItemRow({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (item.selectedSize.isNotEmpty) 'Size ${item.selectedSize}',
      '₹${item.priceValue.toStringAsFixed(2)} each',
    ].join('  |  ');

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ItemImage(url: item.image),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QuantityStepper(item: item),
                    const Spacer(),
                    Text(
                      '₹${item.lineTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => context.read<CartCubit>().removeFromCart(item),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: AppTheme.textMuted,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Remove',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.url});

  final String url;

  static const double _w = 80;
  static const double _h = 92;
  static const double _r = 10;

  @override
  Widget build(BuildContext context) {
    const placeholder = Icon(
      Icons.image_not_supported_outlined,
      color: AppTheme.textMuted,
    );
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return Container(
      width: _w,
      height: _h,
      decoration: BoxDecoration(
        color: AppTheme.tint,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: AppTheme.divider),
      ),
      child: url.isEmpty
          ? placeholder
          : ClipRRect(
              borderRadius: BorderRadius.circular(_r),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                // Decode at display size to save memory.
                cacheWidth: (_w * dpr).round(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  final total = progress.expectedTotalBytes;
                  return Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                        value: total != null
                            ? progress.cumulativeBytesLoaded / total
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
            ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(_kRadiusControl),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: () => cubit.updateQuantity(item, item.quantity - 1),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: () => cubit.updateQuantity(item, item.quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_kRadiusControl),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, size: 16, color: AppTheme.primary),
      ),
    );
  }
}
