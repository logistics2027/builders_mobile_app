part of 'product_cubit.dart';

sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

final class ProductInitial extends ProductState {}

// ---- Plain "all products" states (Home, SubCategoryExplore, etc.) ----

final class ProductLoading extends ProductState {}

final class ProductLoaded extends ProductState {
  final List<ProductResponse> products;

  const ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

final class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

// ---- Filtered/search product list states (SearchResultsScreen) ----

final class ProductFilterLoading extends ProductState {}

final class ProductFilterLoaded extends ProductState {
  final List<ProductResponse> products;
  final int page;
  final int totalPages;
  final bool isLoadingMore;
  final String category;
  final String search;
  final String sortBy;
  final String? maxPrice;

  const ProductFilterLoaded({
    required this.products,
    required this.page,
    required this.totalPages,
    this.isLoadingMore = false,
    this.category = 'All',
    this.search = '',
    this.sortBy = 'featured',
    this.maxPrice,
  });

  bool get hasMore => page < totalPages;

  ProductFilterLoaded copyWith({
    List<ProductResponse>? products,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
    String? category,
    String? search,
    String? sortBy,
    String? maxPrice,
    bool clearMaxPrice = false,
  }) {
    return ProductFilterLoaded(
      products: products ?? this.products,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      category: category ?? this.category,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
    );
  }

  @override
  List<Object?> get props =>
      [products, page, totalPages, isLoadingMore, category, search, sortBy, maxPrice];
}

final class ProductFilterError extends ProductState {
  final String message;

  const ProductFilterError(this.message);

  @override
  List<Object?> get props => [message];
}

// ---- Single product (detail screen) states ----

final class ProductDetailLoading extends ProductState {}

final class ProductDetailLoaded extends ProductState {
  final ProductDetailResponse product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

final class ProductDetailError extends ProductState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// ---- Product reviews states ----

final class ProductReviewsLoading extends ProductState {}

final class ProductReviewsLoaded extends ProductState {
  final ReviewResponse reviews;

  const ProductReviewsLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

final class ProductReviewsError extends ProductState {
  final String message;

  const ProductReviewsError(this.message);

  @override
  List<Object?> get props => [message];
}