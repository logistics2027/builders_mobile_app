
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product/product_cubit.dart';
import '../bloc/cart/cart_cubit.dart';
import '../models/product_response.dart';
import '../theme/app_theme.dart';
import '../widgets/avg_header.dart';
import 'product_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;
  final String? initialCategory;

  const SearchResultsScreen({
    super.key,
    required this.searchQuery,
    this.initialCategory,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  static const Map<String, String> _sortLabels = {
    'featured': 'Featured',
    'price_low_high': 'Price: Low to High',
    'price_high_low': 'Price: High to Low',
    'newest': 'Newest Arrivals',
  };

  static const Color _pageBg = Color(0xFFF5F6F8);
  static const Color _border = Color(0xFFE3E5E8);
  static const Color _textPrimary = Color(0xFF1F2328);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _success = Color(0xFF15803D);

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Everything search-related lives here — nothing reads/writes AppState.
  String _search = '';
  final List<String> _searchHistory = ['iphone', 'headphones', 'coffee press'];

  String _category = 'All';
  String _sortBy = 'featured';
  double? _maxPrice;

  // Tracks products with an add-to-cart request in flight, purely for the
  // brief spinner shown before CartCubit's new state (with the real
  // quantity) arrives and the button flips into the stepper.
  final Set<String> _addingProductIds = {};

  @override
  void initState() {
    super.initState();
    _search = widget.searchQuery;
    _searchController.text = widget.searchQuery;
    _category = widget.initialCategory ?? 'All';

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runFetch();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClientRange) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final state = context.read<ProductCubit>().state;
      if (state is ProductFilterLoaded &&
          state.hasMore &&
          !state.isLoadingMore) {
        context.read<ProductCubit>().loadMoreFilteredProducts();
      }
    }
  }

  void _runFetch() {
    context.read<ProductCubit>().fetchFilteredProducts(
      category: _category,
      search: _search,
      sortBy: _sortBy,
      maxPrice: _maxPrice != null ? _maxPrice!.toStringAsFixed(0) : null,
    );
  }

  void _addToHistory(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _searchHistory.remove(trimmed);
      _searchHistory.insert(0, trimmed);
      if (_searchHistory.length > 8) {
        _searchHistory.removeLast();
      }
    });
  }

  void _onSearchTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() => _search = value);
      _runFetch();
    });
  }

  void _onSearchSubmitted(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    setState(() => _search = trimmed);
    if (trimmed.isNotEmpty) {
      _addToHistory(trimmed);
    }
    _runFetch();
  }

  void _selectHistoryQuery(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    setState(() => _search = query);
    _addToHistory(query);
    _runFetch();
  }

  Future<void> _openFilterSheet() async {
    String tempSort = _sortBy;
    double tempMax = _maxPrice ?? 10000;
    bool useMaxPrice = _maxPrice != null;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sort & Filter',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sort by',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ..._sortLabels.entries.map(
                        (entry) => Material(
                          color: Colors.transparent,
                          child: RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            activeColor: AppTheme.primary,
                            title: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 14),
                            ),
                            value: entry.key,
                            groupValue: tempSort,
                            onChanged: (val) {
                              setSheetState(() => tempSort = val!);
                            },
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Max price',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: _textPrimary,
                            ),
                          ),
                          Switch(
                            activeColor: AppTheme.primary,
                            value: useMaxPrice,
                            onChanged: (val) {
                              setSheetState(() => useMaxPrice = val);
                            },
                          ),
                        ],
                      ),
                      if (useMaxPrice) ...[
                        Slider(
                          activeColor: AppTheme.primary,
                          min: 100,
                          max: 50000,
                          divisions: 499,
                          value: tempMax.clamp(100, 50000),
                          label: '₹${tempMax.toStringAsFixed(0)}',
                          onChanged: (val) {
                            setSheetState(() => tempMax = val);
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Up to ₹${tempMax.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _sortBy = tempSort;
                              _maxPrice = useMaxPrice ? tempMax : null;
                            });
                            Navigator.pop(sheetContext, true);
                          },
                          child: const Text(
                            'Apply',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == true) {
      _runFetch();
    }
  }

  // Finds the CartItem (if any) that corresponds to this product, matched
  // by productId. If your cart allows the same product in multiple sizes
  // as separate line items, this picks the first match — good enough for
  // a list-row quick-add control that always uses sizes.first.
  CartItem? _findCartItem(CartState cartState, ProductResponse product) {
    final productId = product.id.toString();
    for (final item in cartState.items) {
      final itemProductId = (item.productId ?? item.id).toString();
      if (itemProductId == productId) return item;
    }
    return null;
  }

  Future<void> _addToCart(BuildContext context, ProductResponse product) async {
    final productId = product.id.toString();
    if (_addingProductIds.contains(productId)) return;

    final sizes = product.sizes ?? [];
    final selectedSize = sizes.isNotEmpty ? sizes.first : null;
    final image = (product.images != null && product.images!.isNotEmpty)
        ? product.images!.first
        : '';
    final price = _parsePrice(product.offerPrice ?? product.originalPrice);

    setState(() => _addingProductIds.add(productId));

    try {
      await context.read<CartCubit>().addToCart(
        productId: productId,
        name: product.name ?? '',
        category: product.category ?? '',
        price: price,
        image: image,
        selectedSize: selectedSize,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name ?? 'Item'} added to cart'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not add "${product.name ?? 'item'}" to cart. Please try again.',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _addingProductIds.remove(productId));
      }
    }
  }

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

  String _formatPrice(double value) {
    return value == value.truncateToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AvgHeader(
        showBackButton: true,
        isReadOnly: false,
        searchController: _searchController,
        onSearchChanged: _onSearchTextChanged,
        onSearchSubmitted: _onSearchSubmitted,
      ),
      backgroundColor: _pageBg,
      body: Column(
        children: [
          _buildResultsHeader(),
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state is! ProductFilterLoading &&
                    state is! ProductFilterError &&
                    state is! ProductFilterLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductFilterLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductFilterError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: _textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: _textSecondary),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: _runFetch,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: BorderSide(color: AppTheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final loadedState = state as ProductFilterLoaded;

                if (loadedState.products.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 56,
                            color: Color(0xFF9CA3AF),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No results found',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Check your spelling or try more general terms.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () =>
                      context.read<ProductCubit>().refreshFilteredProducts(),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount:
                        loadedState.products.length +
                        (loadedState.hasMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index >= loadedState.products.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      return _buildProductRow(
                        context,
                        loadedState.products[index],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistoryView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ),
        Expanded(
          child: _searchHistory.isEmpty
              ? const Center(
                  child: Text(
                    'No recent searches',
                    style: TextStyle(color: _textSecondary),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchHistory.length,
                  itemBuilder: (context, index) {
                    final query = _searchHistory[index];
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: const Icon(
                          Icons.history,
                          color: _textSecondary,
                        ),
                        title: Text(query),
                        trailing: const Icon(
                          Icons.north_west,
                          color: _textSecondary,
                          size: 18,
                        ),
                        onTap: () => _selectHistoryQuery(query),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Slim header replacing the old chip bar. Delete this widget (and its
  /// call in build) if you want no sort/filter entry point at all.
  Widget _buildResultsHeader() {
    final hasFilters = _sortBy != 'featured' || _maxPrice != null;
    final query = _search.trim();

    // FIX: a Container can't have both `color` and `decoration`.
    // The color now lives only inside the BoxDecoration.
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              query.isEmpty ? 'All products' : 'Results for "$query"',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ),
          // TextButton.icon(
          //   onPressed: _openFilterSheet,
          //   style: TextButton.styleFrom(
          //     foregroundColor: AppTheme.primary,
          //     padding: const EdgeInsets.symmetric(horizontal: 10),
          //     minimumSize: const Size(0, 36),
          //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //   ),
          //   icon: Stack(
          //     clipBehavior: Clip.none,
          //     children: [
          //       const Icon(Icons.tune, size: 18),
          //       if (hasFilters)
          //         Positioned(
          //           right: -2,
          //           top: -2,
          //           child: Container(
          //             width: 8,
          //             height: 8,
          //             decoration: BoxDecoration(
          //               color: AppTheme.accent,
          //               shape: BoxShape.circle,
          //               border: Border.all(color: Colors.white, width: 1.5),
          //             ),
          //           ),
          //         ),
          //     ],
          //   ),
          //   label: const Text(
          //     'Sort & Filter',
          //     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildProductRow(BuildContext context, ProductResponse product) {
    final originalPrice = _parsePrice(product.originalPrice);
    final offerPrice = _parsePrice(product.offerPrice);
    final displayPrice = offerPrice > 0 ? offerPrice : originalPrice;
    final discount = _discountPercentage(product);
    final image = (product.images != null && product.images!.isNotEmpty)
        ? product.images!.first
        : null;

    final productId = product.id.toString();
    final inStock = product.count == null || product.count! > 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (routeContext) => BlocProvider.value(
                value: BlocProvider.of<CartCubit>(context),
                child: ProductDetailScreen(
                  productId: product.id.toString(),
                  title: product.name ?? '',
                ),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border),
                ),
                padding: const EdgeInsets.all(6),
                child: Center(
                  child: image != null
                      ? Image.network(
                          image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: Color(0xFF9CA3AF),
                          ),
                        )
                      : const Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFF9CA3AF),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        color: _textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        Text(
                          '₹${_formatPrice(displayPrice)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                        if (discount > 0) ...[
                          Text(
                            '₹${_formatPrice(originalPrice)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            '$discount% off',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (product.count != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        inStock ? '${product.count} in stock' : 'Out of stock',
                        style: TextStyle(
                          fontSize: 12,
                          color: inStock ? _textSecondary : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),

                    // --- Add to Cart / Quantity Stepper -------------------
                    // Reads live cart state from CartCubit — the same cubit
                    // the Cart screen watches — so this row and the Cart
                    // screen always agree on quantity in real time.
                    BlocBuilder<CartCubit, CartState>(
                      builder: (context, cartState) {
                        final isAdding = _addingProductIds.contains(productId);
                        final cartItem = _findCartItem(cartState, product);
                        final quantity = cartItem?.quantity ?? 0;

                        if (isAdding) {
                          return SizedBox(
                            height: 34,
                            width: 112,
                            child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                disabledBackgroundColor: AppTheme.primary
                                    .withOpacity(0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        if (cartItem == null || quantity <= 0) {
                          return SizedBox(
                            height: 34,
                            child: ElevatedButton(
                              onPressed: inStock
                                  ? () => _addToCart(context, product)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade300,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                              ),
                              child: const Text(
                                'Add to Cart',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          );
                        }

                        // In cart — compact outlined quantity stepper.
                        return Container(
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.primary),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _StepperButton(
                                icon: Icons.remove,
                                onTap: () {
                                  if (quantity <= 1) {
                                    context.read<CartCubit>().removeFromCart(
                                      cartItem,
                                    );
                                  } else {
                                    context.read<CartCubit>().updateQuantity(
                                      cartItem,
                                      quantity - 1,
                                    );
                                  }
                                },
                              ),
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '$quantity',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                ),
                              ),
                              _StepperButton(
                                icon: Icons.add,
                                onTap: () {
                                  final stock = product.count;
                                  if (stock != null && quantity >= stock) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Only $stock left in stock',
                                        ),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.red.shade600,
                                      ),
                                    );
                                    return;
                                  }
                                  context.read<CartCubit>().updateQuantity(
                                    cartItem,
                                    quantity + 1,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small tap target used inside the in-row quantity stepper.
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, size: 16, color: AppTheme.primary),
      ),
    );
  }
}

extension on ScrollController {
  bool get hasClientRange => hasClients && position.hasContentDimensions;
}
