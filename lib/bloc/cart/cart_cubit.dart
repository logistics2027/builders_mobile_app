import 'package:bloc/bloc.dart';
import 'package:avg_mart/service/api_service.dart';
import 'package:equatable/equatable.dart';
import '../../models/cart_response.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final ApiService _apiService;
  CartCubit(this._apiService) : super(const CartState());

  /// Initial load — shows the loading indicator (used on page open).
  Future<void> fetchCart() async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      await _apiService.addToken();
      final rows = await _apiService.getCart();
      final items = rows.map(CartItem.fromCartResponse).toList();
      emit(state.copyWith(status: CartStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    }
  }

  /// Silent background refresh — fetches the latest cart from the server
  /// and updates items, but never touches `status`, so no loading spinner
  /// is ever shown. Used after every mutation (add/update/remove) to keep
  /// local state in sync with the server without any visible flicker.
  Future<void> _silentRefresh() async {
    try {
      await _apiService.addToken();
      final rows = await _apiService.getCart();
      final items = rows.map(CartItem.fromCartResponse).toList();
      emit(state.copyWith(status: CartStatus.loaded, items: items));
    } catch (e) {
      // Swallow silently — the optimistic local state stays as-is.
      // A visible fetchCart()/retry can still be triggered by the user
      // if something is actually broken.
    }
  }

  /// Public, silent refresh — call this from anywhere in the app (e.g.
  /// right after adding an item from the Home page) to bring `state`,
  /// and therefore `state.totalItems`, up to date without showing a
  /// loading indicator anywhere the cubit is watched (badges, etc).
  Future<void> refreshCart() => _silentRefresh();

  /// Adds a product to the cart with the given size and quantity, then
  /// silently refreshes so ids/quantities stay authoritative — no spinner.
  /// This is the ONLY path that should be used to add items anywhere
  /// in the app (Home, Search, Product Detail, etc).
  Future<void> addToCart({
    required String productId,
    required String name,
    required String category,
    required num price,
    required String image,
    String? selectedSize,
    int quantity = 1,
  }) async {
    if (quantity <= 0) return;

    final matches = state.items.where(
      (i) => i.productId?.toString() == productId && i.selectedSize == selectedSize,
    );
    final existingItem = matches.isNotEmpty ? matches.first : null;
    final existingQty = existingItem?.quantity;

    await _apiService.addToken();

    if (existingItem != null) {
      // Row already exists server-side — just bump its quantity up.
      final newQty = (existingQty ?? 0) + quantity;
      await _apiService.updateCartQuantity(
        id: existingItem.id.toString(),
        quantity: newQty,
      );
    } else {
      // Brand new row — create it (server defaults to qty 1),
      // then set it to the requested quantity if more than 1 was asked for.
      await _apiService.addToCart(
        productId: productId,
        name: name,
        category: category,
        price: price,
        image: image,
        selectedSize: selectedSize,
        existingQty: existingQty,
      );

      if (quantity > 1) {
        // Re-fetch to find the id the server just assigned to this row,
        // then bump it to the requested quantity.
        await _apiService.addToken();
        final rows = await _apiService.getCart();
        final items = rows.map(CartItem.fromCartResponse).toList();
        final created = items.where(
          (i) => i.productId?.toString() == productId && i.selectedSize == selectedSize,
        );
        if (created.isNotEmpty) {
          await _apiService.updateCartQuantity(
            id: created.first.id.toString(),
            quantity: quantity,
          );
        }
      }
    }

    await _silentRefresh();
  }

  /// Updates quantity for a cart row via PUT /auth/cart/:id, with an
  /// optimistic local update for instant feedback, then a silent refresh
  /// to confirm against the server — no loading indicator at any point.
  /// If the new quantity is 0 or less, this routes to removeFromCart()
  /// instead, which calls the DELETE endpoint.
  Future<void> updateQuantity(CartItem item, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(item);
      return;
    }

    // Optimistic local update — instant UI feedback.
    final optimistic = state.items
        .map((i) => i.id == item.id ? i.copyWith(quantity: quantity) : i)
        .toList();
    emit(state.copyWith(items: optimistic));

    try {
      await _apiService.addToken();
      await _apiService.updateCartQuantity(
        id: item.id.toString(),
        quantity: quantity,
      );
      await _silentRefresh();
    } catch (e) {
      // Revert to server truth on failure.
      await _silentRefresh();
      rethrow;
    }
  }

  /// Removes a cart row via DELETE /auth/cart/:id, with an optimistic
  /// local removal for instant feedback, then a silent refresh to confirm
  /// against the server.
  Future<void> removeFromCart(CartItem item) async {
    // Optimistic local removal.
    final optimistic = List<CartItem>.from(state.items)..removeWhere((i) => i.id == item.id);
    emit(state.copyWith(items: optimistic));

    try {
      await _apiService.addToken();
      await _apiService.removeFromCart(id: item.id.toString());
      await _silentRefresh();
    } catch (e) {
      await _silentRefresh();
      rethrow;
    }
  }

  /// Clears the cart locally without hitting the API — use right after a
  /// successful order placement, once the server has already emptied the cart.
  void clearLocalCart() {
    emit(state.copyWith(items: []));
  }
}