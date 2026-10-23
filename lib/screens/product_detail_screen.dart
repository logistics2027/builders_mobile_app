import 'package:avg_mart/models/product_response.dart';
import 'package:avg_mart/models/review_response.dart';
import 'package:avg_mart/service/api_service.dart';
import 'package:avg_mart/widgets/avg_mart_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../bloc/cart/cart_cubit.dart';
import '../bloc/product/product_cubit.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

// =====================================================================
// Design tokens for this screen. Brand colours come from AppTheme.
// =====================================================================
class _UI {
  _UI._();

  static const Color ink = Color(0xFF111827);
  static const Color inkSoft = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color canvas = Color(0xFFF5F6F8);
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFB45309);
  static const Color danger = Color(0xFFB91C1C);
  static const Color star = Color(0xFFF59E0B);

  static const double radius = 6;
  static const double pad = 16;
}

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  final String title;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductCubit>(
      create: (_) => ProductCubit(ApiService())..fetchProductById(productId),
      child: _ProductDetailView(productId: productId, title: title),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  final String productId;
  final String? title;
  const _ProductDetailView({required this.productId, this.title});

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  final PageController _imageController = PageController();

  // Separate cubit instance dedicated to reviews so it never overwrites
  // the product-detail state living in the ancestor BlocProvider.
  late final ProductCubit _reviewCubit = ProductCubit(ApiService());

  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor; // stores ColorOption.raw
  bool _isBuyingNow = false;
  bool _descExpanded = false;
  int _quantity = 1;

  // Anchor used to auto-scroll down to the reviews section.
  final GlobalKey _reviewsSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _reviewCubit.fetchProductReviews(widget.productId);
  }

  @override
  void dispose() {
    _imageController.dispose();
    _reviewCubit.close();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------
  double _parsePrice(String? value) {
    if (value == null) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }

  int _discountPercentage(ProductResponse product) {
    final original = _parsePrice(product.originalPrice);
    final offer = _parsePrice(product.offerPrice);
    if (original <= 0 || offer <= 0 || offer >= original) return 0;
    return (((original - offer) / original) * 100).round();
  }

  /// Indian digit grouping, e.g. 123456 -> ₹1,23,456
  String _money(num value) {
    final s = value.round().toString();
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '₹${parts.join(',')},$last3';
  }

  void _toast(String msg, {bool error = false, SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? _UI.danger : _UI.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_UI.radius),
          ),
          action: action,
        ),
      );
  }

  void _incrementQuantity(int stockCount) {
    if (_quantity < stockCount) {
      setState(() => _quantity++);
    } else {
      _toast('Only $stockCount left in stock', error: true);
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    } else {
      _toast('Minimum quantity is 1');
    }
  }

  void _selectColor(ColorOption color, int imageCount) {
    setState(() => _selectedColor = color.raw);

    final idx = color.imageIndex;
    if (idx != null &&
        idx >= 0 &&
        idx < imageCount &&
        _imageController.hasClients) {
      _imageController.animateToPage(
        idx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String? _selectedColorName(List<ColorOption> colors) {
    for (final c in colors) {
      if (c.raw == _selectedColor) return c.name;
    }
    return null;
  }

  Future<void> _shareProduct(
    BuildContext context, [
    ProductResponse? product,
  ]) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = (box != null)
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 1, 1);

    final productName = product?.name ?? widget.title ?? 'Product';
    final shareUrl = 'https://www.avgmart.com';

    await SharePlus.instance.share(
      ShareParams(
        text: 'Check out "$productName" on Avg Mart: $shareUrl',
        sharePositionOrigin: origin,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({
    String? title,
    bool interactive = true,
    ProductResponse? product,
  }) {
    return AvgMartAppBar(
      elevation: 0,
      title: title ?? widget.title ?? "",
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white),
          onPressed: interactive ? () => _shareProduct(context, product) : null,
        ),
      ],
    );
  }

  void _goToCart() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(initialTab: 2),
      ),
      (route) => false,
    );
  }

  void _retry() {
    context.read<ProductCubit>().fetchProductById(widget.productId);
    _reviewCubit.fetchProductReviews(widget.productId);
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductDetailLoading || state is ProductInitial) {
          return _buildLoadingSkeleton(context);
        }

        if (state is ProductDetailError) {
          return _buildMessageScaffold(
            icon: Icons.error_outline,
            title: 'Unable to load product',
            message: state.message,
          );
        }

        if (state is ProductDetailLoaded) {
          final product = state.product.product;
          if (product == null) {
            return _buildMessageScaffold(
              icon: Icons.inventory_2_outlined,
              title: 'Product not available',
              message: 'The details for this product could not be found.',
            );
          }

          // The API mixes colors and real sizes in one list; split them.
          final allOptions = product.sizes ?? [];
          final sizes = ProductVariantParser.sizes(allOptions);
          final colors = ProductVariantParser.colors(allOptions);

          if (_selectedSize == null && sizes.isNotEmpty) {
            _selectedSize = sizes.first;
          }
          if (_selectedColor == null && colors.isNotEmpty) {
            _selectedColor = colors.first.raw;
          }

          return _buildScreen(context, product);
        }

        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }

  Widget _buildMessageScaffold({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(interactive: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: _UI.inkSoft),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _UI.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _UI.inkSoft),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: _retry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_UI.radius),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Loading skeleton
  // ---------------------------------------------------------------------
  Widget _buildLoadingSkeleton(BuildContext context) {
    return Scaffold(
      backgroundColor: _UI.canvas,
      appBar: _buildAppBar(interactive: false),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(_UI.pad),
              child: const _ShimmerBox(height: 300),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(_UI.pad),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 90, height: 11),
                  SizedBox(height: 12),
                  _ShimmerBox(height: 16),
                  SizedBox(height: 8),
                  _ShimmerBox(width: 220, height: 16),
                  SizedBox(height: 14),
                  _ShimmerBox(width: 110, height: 22),
                  SizedBox(height: 18),
                  _ShimmerBox(width: 160, height: 28),
                  SizedBox(height: 8),
                  _ShimmerBox(width: 120, height: 12),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(_UI.pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ShimmerBox(width: 70, height: 13),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(
                      4,
                      (i) => const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: _ShimmerBox(width: 56, height: 38),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Main screen
  // ---------------------------------------------------------------------
  Widget _buildScreen(BuildContext context, ProductResponse product) {
    final images = product.images ?? [];
    final allOptions = product.sizes ?? [];
    final sizes = ProductVariantParser.sizes(allOptions);
    final colors = ProductVariantParser.colors(allOptions);
    final stockCount = product.count ?? 0;
    final title = product.name ?? '';
    final category = product.category ?? '';
    final inStock = stockCount > 0;

    final selectedColorName = _selectedColorName(colors);
    final variantLabel = [
      selectedColorName,
      _selectedSize,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' / ');

    final int effectiveQuantity = inStock ? _quantity.clamp(1, stockCount) : 0;

    final displayPrice = SizePriceCalculator.calculatePrice(
      sizes: sizes,
      selectedSize: _selectedSize,
      originalPrice: _parsePrice(product.originalPrice),
      offerPrice: _parsePrice(product.offerPrice),
    );
    final originalPrice = SizePriceCalculator.calculateOriginalPrice(
      sizes: sizes,
      selectedSize: _selectedSize,
      originalPrice: _parsePrice(product.originalPrice),
    );
    final discount = _discountPercentage(product);

    void addToCart() {
      context.read<CartCubit>().addToCart(
        productId: product.id?.toString() ?? '',
        name: title,
        category: category,
        price: displayPrice,
        image: images.isNotEmpty ? images.first : '',
        selectedSize: variantLabel.isEmpty ? null : variantLabel,
        quantity: effectiveQuantity,
      );
    }

    return Scaffold(
      backgroundColor: _UI.canvas,
      appBar: _buildAppBar(title: title, product: product),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Gallery ---------------------------------------------
            _buildGallery(images, colors),
            const SizedBox(height: 8),

            // ---- Summary: category, title, rating, price -------------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(_UI.pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.isNotEmpty)
                    Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: _UI.inkSoft,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: _UI.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildRatingRow(inStock: inStock, stockCount: stockCount),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: _UI.border),
                  const SizedBox(height: 16),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _money(displayPrice),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: _UI.ink,
                          height: 1.1,
                        ),
                      ),
                      if (discount > 0 && originalPrice > displayPrice) ...[
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            _money(originalPrice),
                            style: const TextStyle(
                              fontSize: 14,
                              color: _UI.inkSoft,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '$discount% off',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _UI.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Inclusive of all taxes',
                    style: TextStyle(fontSize: 12, color: _UI.inkSoft),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ---- Service assurances ---------------------------------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: const _AssuranceStrip(),
            ),
            const SizedBox(height: 8),

            // ---- Options: colour, size, quantity --------------------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(_UI.pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (colors.isNotEmpty) ...[
                    _OptionHeader(
                      label: 'Colour',
                      value: selectedColorName ?? '',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: colors.map((c) {
                        final imgIdx = c.imageIndex;
                        final thumb =
                            (imgIdx != null &&
                                imgIdx >= 0 &&
                                imgIdx < images.length)
                            ? images[imgIdx]
                            : null;
                        return _ColorSwatch(
                          option: c,
                          selected: _selectedColor == c.raw,
                          thumbUrl: thumb,
                          onTap: () => _selectColor(c, images.length),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                  ],
                  if (sizes.isNotEmpty) ...[
                    _OptionHeader(label: 'Size', value: _selectedSize ?? ''),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: sizes.map((opt) {
                        final isSelected = _selectedSize == opt;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSize = opt),
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 56,
                              minHeight: 40,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary.withOpacity(0.06)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(_UI.radius),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : _UI.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected ? AppTheme.primary : _UI.ink,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                  ],
                  _OptionHeader(label: 'Quantity', value: ''),
                  const SizedBox(height: 12),
                  _buildQuantityStepper(stockCount, effectiveQuantity),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ---- Product details ------------------------------------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(_UI.pad),
              child: _buildDetails(
                description: product.description,
                category: category,
                inStock: inStock,
                stockCount: stockCount,
                colorName: selectedColorName,
              ),
            ),
            const SizedBox(height: 8),

            // ---- Reviews --------------------------------------------
            Container(
              key: _reviewsSectionKey,
              color: Colors.white,
              padding: const EdgeInsets.all(_UI.pad),
              child: BlocBuilder<ProductCubit, ProductState>(
                bloc: _reviewCubit,
                builder: (context, reviewState) {
                  List<ProductReview> reviews = [];
                  final isLoading =
                      reviewState is ProductReviewsLoading ||
                      reviewState is ProductInitial;
                  final error = reviewState is ProductReviewsError
                      ? reviewState.message
                      : null;

                  if (reviewState is ProductReviewsLoaded) {
                    reviews = (reviewState.reviews.reviews ?? [])
                        .map((r) => r.toDisplay())
                        .toList();
                  }

                  final avgRating = reviews.isEmpty
                      ? 0.0
                      : reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                            reviews.length;

                  if (isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    );
                  }
                  if (error != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer reviews',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _UI.ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Failed to load reviews',
                          style: TextStyle(
                            color: _UI.danger,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          error,
                          style: const TextStyle(
                            color: _UI.inkSoft,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => _reviewCubit.fetchProductReviews(
                            widget.productId,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    );
                  }
                  return _ProductReviewsSection(
                    reviews: reviews,
                    averageRating: avgRating,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),

      // ---- Sticky action bar ------------------------------------------
      bottomNavigationBar: _buildBottomBar(
        inStock: inStock,
        total: displayPrice * (effectiveQuantity == 0 ? 1 : effectiveQuantity),
        quantity: effectiveQuantity,
        onAdd: () {
          addToCart();
          _toast(
            '$effectiveQuantity × $title added to cart',
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.amber,
              onPressed: _goToCart,
            ),
          );
        },
        onBuyNow: () async {
          setState(() => _isBuyingNow = true);
          try {
            addToCart();
            await context.read<CartCubit>().fetchCart();
          } finally {
            if (mounted) setState(() => _isBuyingNow = false);
          }
          if (!mounted) return;
          _goToCart();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Gallery
  // ---------------------------------------------------------------------
  Widget _buildGallery(List<String> images, List<ColorOption> colors) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 320,
            child: images.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                      size: 48,
                    ),
                  )
                : Stack(
                    children: [
                      PageView.builder(
                        controller: _imageController,
                        onPageChanged: (idx) {
                          setState(() {
                            _currentImageIndex = idx;
                            for (final c in colors) {
                              if (c.imageIndex == idx) {
                                _selectedColor = c.raw;
                                break;
                              }
                            }
                          });
                        },
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (images.length > 1)
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _UI.ink.withOpacity(0.72),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1} / ${images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          if (images.length > 1) ...[
            const Divider(height: 1, color: _UI.border),
            SizedBox(
              height: 72,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: _UI.pad,
                  vertical: 10,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final sel = i == _currentImageIndex;
                  return GestureDetector(
                    onTap: () {
                      if (_imageController.hasClients) {
                        _imageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: sel ? AppTheme.primary : _UI.border,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Image.network(
                        images[i],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Rating + availability row
  // ---------------------------------------------------------------------
  Widget _buildRatingRow({required bool inStock, required int stockCount}) {
    final availability = Text(
      !inStock
          ? 'Out of stock'
          : (stockCount <= 5 ? 'Only $stockCount left' : 'In stock'),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: !inStock
            ? _UI.danger
            : (stockCount <= 5 ? _UI.warning : _UI.success),
      ),
    );

    return BlocBuilder<ProductCubit, ProductState>(
      bloc: _reviewCubit,
      builder: (context, reviewState) {
        final reviews = reviewState is ProductReviewsLoaded
            ? (reviewState.reviews.reviews ?? [])
            : const [];

        if (reviews.isEmpty) return availability;

        final avgRating =
            reviews
                .map((r) => (r.rating ?? 0).toDouble())
                .reduce((a, b) => a + b) /
            reviews.length;

        return Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final ctx = _reviewsSectionKey.currentContext;
                if (ctx != null) {
                  Scrollable.ensureVisible(
                    ctx,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _UI.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.star, color: Colors.white, size: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${reviews.length} ${reviews.length == 1 ? 'rating' : 'ratings'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.linkBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 14, color: _UI.border),
            const SizedBox(width: 12),
            availability,
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Quantity stepper
  // ---------------------------------------------------------------------
  Widget _buildQuantityStepper(int stockCount, int effectiveQuantity) {
    final inStock = stockCount > 0;
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _UI.border),
            borderRadius: BorderRadius.circular(_UI.radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepperButton(
                icon: Icons.remove,
                onTap: inStock ? _decrementQuantity : null,
              ),
              Container(
                width: 48,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: _UI.border),
                  ),
                ),
                child: Text(
                  '$effectiveQuantity',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _UI.ink,
                  ),
                ),
              ),
              _StepperButton(
                icon: Icons.add,
                onTap: inStock ? () => _incrementQuantity(stockCount) : null,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            inStock ? '$stockCount units available' : 'Currently unavailable',
            style: TextStyle(
              fontSize: 12.5,
              color: inStock ? _UI.inkSoft : _UI.danger,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Product details: spec table + description
  // ---------------------------------------------------------------------
  Widget _buildDetails({
    required String? description,
    required String category,
    required bool inStock,
    required int stockCount,
    required String? colorName,
  }) {
    final text = (description ?? '').trim();
    final isLong = text.length > 220;

    final rows = <MapEntry<String, String>>[
      if (category.isNotEmpty) MapEntry('Category', category),
      if (colorName != null && colorName.isNotEmpty)
        MapEntry('Colour', colorName),
      if (_selectedSize != null && _selectedSize!.isNotEmpty)
        MapEntry('Size', _selectedSize!),
      MapEntry('Availability', inStock ? 'In stock' : 'Out of stock'),
      MapEntry('Sold by', 'Avg Mart retail merchant'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Product details'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _UI.border),
            borderRadius: BorderRadius.circular(_UI.radius),
          ),
          child: Column(
            children: List.generate(rows.length, (i) {
              final r = rows[i];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: i.isEven ? _UI.canvas : Colors.white,
                  border: i == rows.length - 1
                      ? null
                      : const Border(bottom: BorderSide(color: _UI.border)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        r.key,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _UI.inkSoft,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        r.value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _UI.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _UI.ink,
          ),
        ),
        const SizedBox(height: 8),
        if (text.isEmpty)
          const Text(
            'No description available.',
            style: TextStyle(fontSize: 13.5, color: _UI.inkSoft),
          )
        else ...[
          Text(
            text,
            maxLines: _descExpanded ? null : 5,
            overflow: _descExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: Color(0xFF374151),
            ),
          ),
          if (isLong)
            GestureDetector(
              onTap: () => setState(() => _descExpanded = !_descExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _descExpanded ? 'Show less' : 'Read more',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.linkBlue,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Sticky bottom bar
  // ---------------------------------------------------------------------
  Widget _buildBottomBar({
    required bool inStock,
    required double total,
    required int quantity,
    required VoidCallback onAdd,
    required Future<void> Function() onBuyNow,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        _UI.pad,
        12,
        _UI.pad,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _UI.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quantity > 1 ? 'Total ($quantity items)' : 'Total',
                style: const TextStyle(fontSize: 11.5, color: _UI.inkSoft),
              ),
              const SizedBox(height: 2),
              Text(
                _money(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _UI.ink,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: inStock ? onAdd : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(
                    color: inStock ? AppTheme.primary : _UI.border,
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_UI.radius),
                  ),
                ),
                child: const Text(
                  'Add to cart',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 46,
              child: FilledButton(
                onPressed: (inStock && !_isBuyingNow) ? onBuyNow : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  disabledBackgroundColor: _UI.border,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_UI.radius),
                  ),
                ),
                child: _isBuyingNow
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        inStock ? 'Buy now' : 'Unavailable',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: inStock ? Colors.white : _UI.inkSoft,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Small reusable widgets
// =====================================================================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _UI.ink,
      ),
    );
  }
}

class _OptionHeader extends StatelessWidget {
  final String label;
  final String value;
  const _OptionHeader({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _UI.ink,
          ),
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 13.5, color: _UI.inkSoft),
          ),
        ],
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 42,
        height: 40,
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? Colors.grey.shade400 : _UI.ink,
        ),
      ),
    );
  }
}

/// Square colour swatch. Falls back to a product thumbnail or an initial
/// when the colour name can't be mapped to a real colour.
class _ColorSwatch extends StatelessWidget {
  final ColorOption option;
  final bool selected;
  final String? thumbUrl;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.option,
    required this.selected,
    required this.thumbUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mapped = _colorFromName(option.name);
    Widget inner;
    if (mapped != null) {
      final isLight = mapped.computeLuminance() > 0.7;
      inner = Container(
        decoration: BoxDecoration(
          color: mapped,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _UI.border),
        ),
        child: selected
            ? Icon(
                Icons.check,
                size: 18,
                color: isLight ? _UI.ink : Colors.white,
              )
            : null,
      );
    } else if (thumbUrl != null) {
      inner = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          thumbUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: _UI.canvas),
        ),
      );
    } else {
      inner = Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _UI.canvas,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          option.name.isNotEmpty ? option.name[0] : '?',
          style: const TextStyle(fontWeight: FontWeight.w700, color: _UI.ink),
        ),
      );
    }

    return Tooltip(
      message: option.name,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_UI.radius),
            border: Border.all(
              color: selected ? AppTheme.primary : _UI.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: inner,
        ),
      ),
    );
  }
}

Color? _colorFromName(String name) {
  const map = <String, int>{
    'red': 0xFFD32F2F,
    'green': 0xFF388E3C,
    'blue': 0xFF1976D2,
    'black': 0xFF212121,
    'white': 0xFFFFFFFF,
    'yellow': 0xFFFBC02D,
    'orange': 0xFFF57C00,
    'pink': 0xFFE91E63,
    'purple': 0xFF7B1FA2,
    'violet': 0xFF673AB7,
    'grey': 0xFF9E9E9E,
    'gray': 0xFF9E9E9E,
    'brown': 0xFF6D4C41,
    'beige': 0xFFD7C4A3,
    'navy': 0xFF1A237E,
    'maroon': 0xFF800000,
    'gold': 0xFFC9A227,
    'silver': 0xFFBDBDBD,
    'cream': 0xFFFFF3D6,
    'teal': 0xFF00796B,
    'cyan': 0xFF00ACC1,
    'lavender': 0xFFB39DDB,
    'peach': 0xFFFFCCBC,
    'magenta': 0xFFC2185B,
    'olive': 0xFF808000,
    'mustard': 0xFFE1AD01,
    'khaki': 0xFFC3B091,
    'coral': 0xFFFF7F50,
    'turquoise': 0xFF40E0D0,
  };
  final key = name.toLowerCase().trim();
  if (map.containsKey(key)) return Color(map[key]!);
  final words = key.split(RegExp(r'\s+'));
  for (final w in words.reversed) {
    if (map.containsKey(w)) return Color(map[w]!);
  }
  return null;
}

/// Three-column service assurance strip with hairline separators.
class _AssuranceStrip extends StatelessWidget {
  const _AssuranceStrip();

  Widget _item(IconData icon, String title, String sub) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppTheme.primary),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _UI.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: _UI.inkSoft),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _item(
            Icons.local_shipping_outlined,
            'Free delivery',
            'On all orders',
          ),
          const VerticalDivider(width: 1, color: _UI.border),
          _item(
            Icons.assignment_return_outlined,
            'Easy returns',
            'Hassle free',
          ),
          const VerticalDivider(width: 1, color: _UI.border),
          _item(
            Icons.verified_user_outlined,
            'Secure payment',
            '100% protected',
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Reviews
// =====================================================================
extension _ReviewMapper on Review {
  ProductReview toDisplay() => ProductReview(
    id: id,
    userName: userName ?? 'Anonymous',
    rating: (rating ?? 0).toDouble(),
    comment: comment ?? '',
    date: createdAt != null
        ? '${createdAt!.day} ${_reviewMonthName(createdAt!.month)} ${createdAt!.year}'
        : '',
    images: images ?? const [],
    verifiedPurchase: false,
  );
}

String _reviewMonthName(int m) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][m - 1];

/// UI-facing review model consumed by `_ProductReviewsSection`/`_ReviewCard`.
class ProductReview {
  final int? id;
  final String userName;
  final double rating; // 0.0 - 5.0
  final String comment;
  final String date;
  final List<String> images;
  final bool verifiedPurchase;

  const ProductReview({
    this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    this.images = const [],
    this.verifiedPurchase = false,
  });
}

class _ProductReviewsSection extends StatefulWidget {
  final List<ProductReview> reviews;
  final double averageRating;

  const _ProductReviewsSection({
    required this.reviews,
    required this.averageRating,
  });

  @override
  State<_ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<_ProductReviewsSection> {
  final Set<String> _blockedUsers = <String>{};

  Map<int, int> _ratingCounts(List<ProductReview> list) {
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in list) {
      final bucket = r.rating.round().clamp(1, 5);
      counts[bucket] = (counts[bucket] ?? 0) + 1;
    }
    return counts;
  }

  void _blockUser(String userName) {
    setState(() {
      _blockedUsers.add(userName);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reviews from "$userName" are now blocked.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleReviews = widget.reviews
        .where((r) => !_blockedUsers.contains(r.userName))
        .toList();
    final counts = _ratingCounts(visibleReviews);
    final total = visibleReviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Customer reviews'),
        const SizedBox(height: 14),
        if (visibleReviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: _UI.canvas,
              borderRadius: BorderRadius.circular(_UI.radius),
            ),
            child: const Column(
              children: [
                Icon(Icons.rate_review_outlined, size: 28, color: _UI.inkSoft),
                SizedBox(height: 8),
                Text(
                  'No reviews yet',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _UI.ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Only verified buyers can review products after delivery.',
                  style: TextStyle(fontSize: 12.5, color: _UI.inkSoft),
                ),
              ],
            ),
          )
        else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 108,
                child: Column(
                  children: [
                    Text(
                      widget.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: _UI.ink,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StarRatingDisplay(rating: widget.averageRating, size: 15),
                    const SizedBox(height: 6),
                    Text(
                      '$total review${total == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 12, color: _UI.inkSoft),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 90,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: _UI.border,
              ),
              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    final star = 5 - i;
                    final count = counts[star] ?? 0;
                    final fraction = total == 0 ? 0.0 : count / total;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '$star ★',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: _UI.ink,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: fraction,
                                minHeight: 6,
                                backgroundColor: _UI.border,
                                valueColor: const AlwaysStoppedAnimation(
                                  _UI.success,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 28,
                            child: Text(
                              '$count',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: _UI.inkSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: _UI.border),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleReviews.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: _UI.border),
            itemBuilder: (context, index) => _ReviewCard(
              review: visibleReviews[index],
              onBlockUser: _blockUser,
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ProductReview review;
  final ValueChanged<String>? onBlockUser;

  const _ReviewCard({required this.review, this.onBlockUser});

  void _showReportDialog(BuildContext context) {
    String selectedReason = 'Inappropriate content or photos';
    final reasons = [
      'Inappropriate content or photos',
      'Spam, advertising, or promotional',
      'Harassment or offensive language',
      'Fake or misleading review',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Row(
            children: [
              Icon(Icons.flag_outlined, color: Colors.red, size: 22),
              SizedBox(width: 8),
              Text(
                'Report Review',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why are you reporting this review? Reports are reviewed by our moderation team within 24 hours.',
                  style: TextStyle(fontSize: 13, color: _UI.inkSoft),
                ),
                const SizedBox(height: 8),
                ...reasons.map(
                  (reason) => RadioListTile<String>(
                    dense: true,
                    activeColor: AppTheme.primary,
                    contentPadding: EdgeInsets.zero,
                    value: reason,
                    groupValue: selectedReason,
                    title: Text(reason, style: const TextStyle(fontSize: 13)),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedReason = val);
                      }
                    },
                  ),
                ),
                if (onBlockUser != null) ...[
                  const Divider(),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    icon: const Icon(Icons.block, size: 16),
                    label: Text(
                      'Block all reviews from "${review.userName}"',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogCtx);
                      onBlockUser!(review.userName);
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: _UI.inkSoft)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_UI.radius),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Thank you. Your report has been submitted and will be reviewed by our moderation team within 24 hours. For urgent issues, contact support@avgmart.com.',
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 4),
                  ),
                );
              },
              child: const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: _UI.canvas,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: _UI.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.userName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _UI.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StarRatingDisplay(rating: review.rating, size: 14),
              const SizedBox(width: 8),
              if (review.verifiedPurchase) ...[
                const Icon(Icons.check_circle, size: 13, color: _UI.success),
                const SizedBox(width: 3),
                const Text(
                  'Verified purchase',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _UI.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (review.date.isNotEmpty) ...[
                const Spacer(),
                Text(
                  review.date,
                  style: const TextStyle(fontSize: 11.5, color: _UI.inkSoft),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: Color(0xFF374151),
            ),
          ),
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final imageUrl = review.images[idx];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: GestureDetector(
                      onTap: () => _showFullScreenImage(context, imageUrl),
                      child: Image.network(
                        imageUrl,
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            width: 68,
                            height: 68,
                            color: _UI.canvas,
                            child: const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 68,
                          height: 68,
                          color: _UI.canvas,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders a row of 5 star icons (full / half / empty) for a given rating.
class _StarRatingDisplay extends StatelessWidget {
  final double rating; // 0.0 - 5.0
  final double size;
  final Color color;

  const _StarRatingDisplay({
    required this.rating,
    this.size = 14,
    this.color = _UI.star,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;
        if (rating >= starValue) {
          icon = Icons.star;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, size: size, color: color);
      }),
    );
  }
}

/// A single shimmering placeholder box. Self-contained — no external
/// `shimmer` package dependency required.
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const _ShimmerBox({
    this.width = double.infinity,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final slide = _controller.value * 2 - 1; // -1 .. 1
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-1 + slide * 2, 0),
              end: Alignment(1 + slide * 2, 0),
            ).createShader(bounds);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: widget.borderRadius,
            ),
          ),
        );
      },
    );
  }
}

// =====================================================================
// Variant parsing: the API stores colors inside the `sizes` list as
// strings like "Color: green__imgIdx:1". These helpers split them out.
// =====================================================================

/// A color variant parsed from strings like "Color: green__imgIdx:1".
class ColorOption {
  final String raw; // original string, used as a unique key
  final String name; // display text, e.g. "Green"
  final int? imageIndex; // which product image belongs to this color

  const ColorOption({required this.raw, required this.name, this.imageIndex});
}

class ProductVariantParser {
  ProductVariantParser._();

  static bool isColor(String value) =>
      value.trim().toLowerCase().startsWith('color:');

  static ColorOption? parseColor(String value) {
    if (!isColor(value)) return null;

    // Remove the "Color:" prefix
    var text = value.substring(value.indexOf(':') + 1).trim();

    // Split off the "__imgIdx:N" suffix
    int? imgIdx;
    final idxPos = text.toLowerCase().indexOf('__imgidx:');
    if (idxPos != -1) {
      imgIdx = int.tryParse(text.substring(idxPos + 9).trim());
      text = text.substring(0, idxPos).trim();
    }

    return ColorOption(raw: value, name: _capitalize(text), imageIndex: imgIdx);
  }

  /// "light blue" -> "Light Blue"
  static String _capitalize(String s) {
    return s
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  static List<ColorOption> colors(List<String> options) =>
      options.map(parseColor).whereType<ColorOption>().toList();

  static List<String> sizes(List<String> options) =>
      options.where((o) => !isColor(o)).toList();
}

/// Calculates a size-adjusted price from a single flat originalPrice/offerPrice.
///
/// ASSUMPTION (until backend supports true per-size pricing):
///   - The API's originalPrice/offerPrice correspond to the LARGEST parsable
///     size in the list (e.g. "1 litre" out of ["100ml","200ml","1 litre",
///     "1/2 litre","250ml"]) — NOT necessarily sizes.first, since size lists
///     aren't guaranteed to come sorted by volume.
///   - Smaller sizes are priced proportionally lower, larger sizes
///     proportionally higher, relative to that reference size.
///   - Supported units: ml, litre/liter/l, g, kg (and fractions like "1/2 litre").
///   - If a size string can't be parsed, it's excluded from the "find the
///     largest" comparison; if NO sizes can be parsed, all sizes fall back
///     to the flat price (no scaling).
class SizePriceCalculator {
  SizePriceCalculator._();

  static double? _parseSizeToBaseUnit(String size) {
    final normalized = size.toLowerCase().trim();

    final fractionMatch = RegExp(
      r'^(\d+)\s*/\s*(\d+)\s*(ml|litre|liter|l|kg|g)$',
    ).firstMatch(normalized);
    if (fractionMatch != null) {
      final numerator = double.tryParse(fractionMatch.group(1)!);
      final denominator = double.tryParse(fractionMatch.group(2)!);
      final unit = fractionMatch.group(3)!;
      if (numerator == null || denominator == null || denominator == 0) {
        return null;
      }
      return _convertToBaseUnit(numerator / denominator, unit);
    }

    final match = RegExp(
      r'^([\d.]+)\s*(ml|litre|liter|l|kg|g)$',
    ).firstMatch(normalized);
    if (match != null) {
      final value = double.tryParse(match.group(1)!);
      final unit = match.group(2)!;
      if (value == null) return null;
      return _convertToBaseUnit(value, unit);
    }

    return null;
  }

  static double _convertToBaseUnit(double value, String unit) {
    switch (unit) {
      case 'ml':
      case 'g':
        return value;
      case 'litre':
      case 'liter':
      case 'l':
      case 'kg':
        return value * 1000;
      default:
        return value;
    }
  }

  static String? _referenceSize(List<String> sizes) {
    String? best;
    double? bestUnits;

    for (final size in sizes) {
      final units = _parseSizeToBaseUnit(size);
      if (units == null) continue;
      if (bestUnits == null || units > bestUnits) {
        bestUnits = units;
        best = size;
      }
    }
    return best;
  }

  static double _sizeRatio({
    required List<String> sizes,
    required String selectedSize,
  }) {
    final reference = _referenceSize(sizes);
    if (reference == null || reference == selectedSize) return 1.0;

    final referenceUnits = _parseSizeToBaseUnit(reference);
    final selectedUnits = _parseSizeToBaseUnit(selectedSize);

    if (referenceUnits == null ||
        selectedUnits == null ||
        referenceUnits == 0) {
      return 1.0;
    }
    return selectedUnits / referenceUnits;
  }

  static double calculatePrice({
    required List<String> sizes,
    required String? selectedSize,
    required double originalPrice,
    required double offerPrice,
  }) {
    final basePrice = offerPrice > 0 ? offerPrice : originalPrice;
    if (selectedSize == null || sizes.isEmpty) return basePrice.roundToDouble();

    final ratio = _sizeRatio(sizes: sizes, selectedSize: selectedSize);
    return (basePrice * ratio).roundToDouble();
  }

  static double calculateOriginalPrice({
    required List<String> sizes,
    required String? selectedSize,
    required double originalPrice,
  }) {
    if (selectedSize == null || sizes.isEmpty) {
      return originalPrice.roundToDouble();
    }

    final ratio = _sizeRatio(sizes: sizes, selectedSize: selectedSize);
    return (originalPrice * ratio).roundToDouble();
  }
}
