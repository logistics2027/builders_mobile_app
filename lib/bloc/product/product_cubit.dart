import 'package:bloc/bloc.dart';
import 'package:avg_mart/models/product_detail_response.dart';
import 'package:avg_mart/models/product_response.dart';
import 'package:avg_mart/models/review_response.dart';
import 'package:avg_mart/service/api_service.dart';
import 'package:equatable/equatable.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ApiService _apiService;

  ProductCubit(this._apiService) : super(ProductInitial());

  static const int _pageSize = 25;

  List<ProductResponse> _parseProducts(dynamic raw) {
    final list = (raw is Map<String, dynamic>)
        ? (raw['products'] as List<dynamic>? ?? [])
        : (raw as List<dynamic>? ?? []);
    return list
        .map((e) => ProductResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // =======================================================================
  // PLAIN "ALL PRODUCTS" FLOW — used by HomeScreen, SubCategoryExploreScreen
  // =======================================================================

  Future<void> fetchProducts() async {
    emit(ProductLoading());
    try {
      final raw = await _apiService.getAllProducts();
      final products = raw
          .map((e) => ProductResponse.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> refreshProducts() => fetchProducts();

  // =======================================================================
  // FILTERED/SEARCH FLOW — used by SearchResultsScreen
  // =======================================================================

  /// Fetches page 1 with the given filters (used for initial load, search,
  /// category change, sort change, or "Apply" from the filter sheet).
  Future<void> fetchFilteredProducts({
    String category = 'All',
    String search = '',
    String? maxPrice,
    String sortBy = 'featured',
  }) async {
    emit(ProductFilterLoading());
    try {
      final response = await _apiService.getFilteredProducts(
        page: 1,
        limit: _pageSize,
        category: category,
        search: search,
        maxPrice: maxPrice,
        sortBy: sortBy,
      );
      emit(ProductFilterLoaded(
        products: _parseProducts(response),
        page: (response['page'] as num?)?.toInt() ?? 1,
        totalPages: (response['totalPages'] as num?)?.toInt() ?? 1,
        category: category,
        search: search,
        sortBy: sortBy,
        maxPrice: maxPrice,
      ));
    } catch (e) {
      emit(ProductFilterError(e.toString()));
    }
  }

  Future<void> refreshFilteredProducts() {
    final current = state;
    if (current is ProductFilterLoaded) {
      return fetchFilteredProducts(
        category: current.category,
        search: current.search,
        maxPrice: current.maxPrice,
        sortBy: current.sortBy,
      );
    }
    return fetchFilteredProducts();
  }

  /// Infinite-scroll pagination.
  Future<void> loadMoreFilteredProducts() async {
    final current = state;
    if (current is! ProductFilterLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.page + 1;
      final response = await _apiService.getFilteredProducts(
        page: nextPage,
        limit: _pageSize,
        category: current.category,
        search: current.search,
        maxPrice: current.maxPrice,
        sortBy: current.sortBy,
      );
      emit(current.copyWith(
        products: [...current.products, ..._parseProducts(response)],
        page: (response['page'] as num?)?.toInt() ?? nextPage,
        totalPages: (response['totalPages'] as num?)?.toInt() ?? current.totalPages,
        isLoadingMore: false,
      ));
    } catch (_) {
      // Keep existing list on failure, just stop the spinner.
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  // =======================================================================
  // DETAIL / REVIEWS
  // =======================================================================

  /// Fetches a single product by its id for the detail screen.
  Future<void> fetchProductById(String id) async {
    emit(ProductDetailLoading());
    try {
      final product = await _apiService.getProductsById(id: id);
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductDetailError(e.toString()));
    }
  }

  Future<void> fetchProductReviews(String productId) async {
    emit(ProductReviewsLoading());
    try {
      final reviewResponse = await _apiService.getProductReviews(productId);
      emit(ProductReviewsLoaded(reviewResponse));
    } catch (e) {
      emit(ProductReviewsError(e.toString()));
    }
  }
}