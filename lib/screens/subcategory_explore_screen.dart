import 'package:avg_mart/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product/product_cubit.dart';
import '../bloc/category/category_cubit.dart';
import '../bloc/cart/cart_cubit.dart';
import '../models/category_response.dart';
import '../models/product_response.dart';
import '../theme/app_theme.dart';
import '../widgets/avg_header.dart';
import '../widgets/shimmer.dart';
import 'product_detail_screen.dart';

class SubCategoryExploreScreen extends StatefulWidget {
  const SubCategoryExploreScreen({super.key});

  @override
  State<SubCategoryExploreScreen> createState() =>
      _SubCategoryExploreScreenState();
}

class _SubCategoryExploreScreenState extends State<SubCategoryExploreScreen> {
  int _selectedCategoryIndex = 0;
  String _selectedSubcategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BlocProvider.of<ProductCubit>(context).fetchProducts();
        BlocProvider.of<CategoryCubit>(context).fetchCategories();
      }
    });
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

  Future<void> _addToCart(BuildContext context, ProductResponse product) async {
    final sizes = product.sizes ?? [];
    final selectedSize = sizes.isNotEmpty ? sizes.first : null;
    final price = _parsePrice(product.offerPrice ?? product.originalPrice);
    final image = (product.images != null && product.images!.isNotEmpty)
        ? product.images!.first
        : '';

    try {
      await context.read<CartCubit>().addToCart(
        productId: product.id.toString(),
        name: product.name ?? '',
        category: product.category ?? '',
        price: price,
        image: image,
        selectedSize: selectedSize,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name ?? 'Item'} added to cart!'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not add "${product.name ?? 'item'}" to cart. Please try again.',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, categoryState) {
        // Full-page shimmer ONLY for the very first load (categories not ready yet)
        if (categoryState is CategoryLoading) {
          return const Scaffold(
            appBar: AvgHeader(isReadOnly: true),
            backgroundColor: Colors.white,
            body: ExploreShimmerSkeleton(),
          );
        }

        if (categoryState is CategoryError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${categoryState.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<ProductCubit>(context).fetchProducts();
                      BlocProvider.of<CategoryCubit>(context).fetchCategories();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final List<CategoryiesResponse> categoriesList =
            categoryState is CategoryLoaded ? categoryState.categories : [];

        if (categoriesList.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No categories available')),
          );
        }

        if (_selectedCategoryIndex >= categoriesList.length) {
          _selectedCategoryIndex = 0;
        }

        final currentCategory = categoriesList[_selectedCategoryIndex];
        final subcategoriesList = currentCategory.attributes ?? [];

        return Scaffold(
          appBar: const AvgHeader(isReadOnly: true),
          backgroundColor: Colors.white,
          body: Row(
            children: [
              // LEFT SIDEBAR — always rendered, never shimmered, always tappable
              Container(
                width: 100,
                color: Colors.grey.shade100,
                child: ListView.builder(
                  itemCount: categoriesList.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedCategoryIndex;
                    final cat = categoriesList[index];
                    return GestureDetector(
                      onTap: () {
                        if (index == _selectedCategoryIndex) return;
                        setState(() {
                          _selectedCategoryIndex = index;
                          _selectedSubcategory = 'All';
                        });
                        // ONLY the product API is called here — category API is untouched
                        BlocProvider.of<ProductCubit>(context).fetchProducts();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade100,
                          border: Border(
                            left: BorderSide(
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.transparent,
                              width: 4,
                            ),
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 0.5,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage:
                                  (cat.imageUrl != null &&
                                      cat.imageUrl!.isNotEmpty)
                                  ? NetworkImage(cat.imageUrl!)
                                  : null,
                              child:
                                  (cat.imageUrl == null ||
                                      cat.imageUrl!.isEmpty)
                                  ? const Icon(
                                      Icons.category,
                                      size: 16,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              toTitleCase(cat.name),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppTheme.primary
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              VerticalDivider(width: 1, color: Colors.grey.shade300),

              // RIGHT SIDE — header/subcategory row always shown, only the grid area shimmers
              Expanded(
                child: BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, productState) {
                    final List<ProductResponse> allProducts =
                        productState is ProductLoaded
                        ? productState.products
                        : [];

                    List<ProductResponse> filteredProducts = allProducts.where((
                      p,
                    ) {
                      final productCategory = (p.category ?? '').toLowerCase();
                      final matchesCategory =
                          productCategory ==
                          (currentCategory.name ?? '').toLowerCase();
                      if (_selectedSubcategory == 'All') {
                        return matchesCategory;
                      } else {
                        final name = (p.name ?? '').toLowerCase();
                        final description = (p.description ?? '').toLowerCase();
                        final sub = _selectedSubcategory.toLowerCase();
                        return matchesCategory &&
                            (name.contains(sub) || description.contains(sub));
                      }
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                toTitleCase(currentCategory.name),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                productState is ProductLoaded
                                    ? '${filteredProducts.length} items'
                                    : '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Container(
                        //   height: 38,
                        //   padding: const EdgeInsets.only(bottom: 6),
                        //   child: ListView.builder(
                        //     scrollDirection: Axis.horizontal,
                        //     padding: const EdgeInsets.symmetric(horizontal: 12),
                        //     itemCount: subcategoriesList.length + 1,
                        //     itemBuilder: (context, index) {
                        //       final isAll = index == 0;
                        //       final subName = isAll
                        //           ? 'All'
                        //           : subcategoriesList[index - 1];
                        //       final isSelected =
                        //           subName == _selectedSubcategory;

                        //       return GestureDetector(
                        //         onTap: () {
                        //           setState(() {
                        //             _selectedSubcategory = subName;
                        //           });
                        //         },
                        //         child: Container(
                        //           margin: const EdgeInsets.only(right: 8),
                        //           padding: const EdgeInsets.symmetric(
                        //             horizontal: 12,
                        //             vertical: 2,
                        //           ),
                        //           decoration: BoxDecoration(
                        //             color: isSelected
                        //                 ? AppTheme.primary.withOpacity(0.08)
                        //                 : Colors.white,
                        //             borderRadius: BorderRadius.circular(16),
                        //             border: Border.all(
                        //               color: isSelected
                        //                   ? AppTheme.primary
                        //                   : Colors.grey.shade300,
                        //               width: 1,
                        //             ),
                        //           ),
                        //           alignment: Alignment.center,
                        //           child: Text(
                        //             toTitleCase(subName),
                        //             style: TextStyle(
                        //               fontSize: 12,
                        //               fontWeight: isSelected
                        //                   ? FontWeight.bold
                        //                   : FontWeight.normal,
                        //               color: isSelected
                        //                   ? AppTheme.primary
                        //                   : Colors.black87,
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                        // Divider(height: 1, color: Colors.grey.shade200),
                        Expanded(
                          child: _buildProductArea(
                            context,
                            productState,
                            filteredProducts,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductArea(
    BuildContext context,
    ProductState productState,
    List<ProductResponse> filteredProducts,
  ) {
    if (productState is ProductLoading) {
      // ONLY this grid area shimmers — sidebar and header stay intact and tappable
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.65,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerProductCard(),
      );
    }

    if (productState is ProductError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${productState.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  BlocProvider.of<ProductCubit>(context).fetchProducts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'No items found in this section.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.65,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, ProductResponse product) {
    final offerPrice = _parsePrice(product.offerPrice);
    final originalPrice = _parsePrice(product.originalPrice);
    final displayPrice = offerPrice > 0 ? offerPrice : originalPrice;
    final discount = _discountPercentage(product);
    final firstImage = (product.images != null && product.images!.isNotEmpty)
        ? product.images!.first
        : null;
    final isFeatured = product.isFeatured ?? false;

    return GestureDetector(
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
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit
                      .expand, // makes Stack fill the full Expanded area
                  children: [
                    Center(
                      child: firstImage != null
                          ? Image.network(firstImage, fit: BoxFit.contain)
                          : Container(
                              color: Colors.grey.shade100,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    if (isFeatured)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                          child: const Text(
                            'FEATURED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                toTitleCase(product.name),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '₹',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    displayPrice.floor().toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    (displayPrice - displayPrice.floor())
                        .toStringAsFixed(2)
                        .substring(1),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (discount > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '-$discount%',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (product.count != null)
                    Text(
                      product.count! > 0
                          ? '${product.count} in stock'
                          : 'Out of stock',
                      style: TextStyle(
                        fontSize: 9,
                        color: (product.count ?? 0) > 0
                            ? Colors.grey.shade600
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    const SizedBox(),
                  GestureDetector(
                    onTap: () => _addToCart(context, product),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
