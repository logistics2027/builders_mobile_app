
import 'dart:async';
import 'package:avg_mart/service/api_service.dart';
import 'package:avg_mart/service/storege_service.dart';
import 'package:flutter/material.dart';
import '../models/product_response.dart';
import '../models/cart_response.dart';
import '../models/order_response.dart';
import '../models/address.dart';

class AppState extends ChangeNotifier {
  List<ProductResponse> _products = [];
  final List<CartResponse> _cart = [];
  final List<ProductResponse> _wishlist = [];
  final List<OrderResponse> _orders = [];

  final List<ShippingAddress> _addresses = [];
  ShippingAddress? _selectedAddress;

  String _userName = 'John Doe';
  String _userEmail = 'john.doe@avg.com';
  bool _isLoggedIn = true;

  AppState() {
    _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
  }

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  List<ProductResponse> get products => _products;
  List<CartResponse> get cart => _cart;
  List<ProductResponse> get wishlist => _wishlist;
  List<OrderResponse> get orders => _orders;
  List<ShippingAddress> get addresses => _addresses;
  ShippingAddress? get selectedAddress => _selectedAddress;
  String get userName => _userName;
  String get userEmail => _userEmail;

  void setProducts(List<ProductResponse> products) {
    _products = products;
    notifyListeners();
  }

  void setAddresses(List<ShippingAddress> addresses, {ShippingAddress? primaryAddress}) {
    _addresses
      ..clear()
      ..addAll(addresses);

    final currentStillValid =
        _selectedAddress != null && _addresses.any((a) => a.id == _selectedAddress!.id);

    if (!currentStillValid) {
      if (primaryAddress != null && _addresses.any((a) => a.id == primaryAddress.id)) {
        _selectedAddress = primaryAddress;
      } else {
        _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }
    }
    notifyListeners();
  }

  // =========================================================================
  // LEGACY LOCAL CART — kept only for backward compat. Use CartCubit instead.
  // =========================================================================

  double get cartSubtotal => _cart.fold(0.0, (sum, item) {
    final price = double.tryParse(item.price ?? '') ?? 0.0;
    final qty = item.quantity ?? 0;
    return sum + (price * qty);
  });

  int get cartCount => _cart.fold(0, (sum, item) => sum + (item.quantity ?? 0));

  @Deprecated('Use CartCubit.addToCart() instead — this local cart is not backed by the API.')
  void addToCart(
    ProductResponse product,
    Map<String, String> selectedVariants, {
    int qty = 1,
  }) {
    final selectedSize = selectedVariants['size'] ?? selectedVariants['Size'];
    final priceValue = product.offerPrice ?? product.originalPrice ?? '0';
    final imageValue = (product.images != null && product.images!.isNotEmpty)
        ? product.images!.first
        : null;

    int index = -1;
    for (int i = 0; i < _cart.length; i++) {
      if (_cart[i].productId == product.id && _cart[i].selectedSize == selectedSize) {
        index = i;
        break;
      }
    }

    if (index != -1) {
      _cart[index].quantity = (_cart[index].quantity ?? 0) + qty;
    } else {
      _cart.add(
        CartResponse(
          productId: product.id,
          name: product.name,
          category: product.category,
          price: priceValue,
          image: imageValue,
          quantity: qty,
          createdAt: DateTime.now(),
          selectedSize: selectedSize,
        ),
      );
    }
    notifyListeners();
  }

  @Deprecated('Use CartCubit.removeFromCart() instead — this local cart is not backed by the API.')
  void removeFromCart(CartResponse item) {
    _cart.removeWhere(
      (i) => i.productId == item.productId && i.selectedSize == item.selectedSize,
    );
    notifyListeners();
  }

  @Deprecated('Use CartCubit.updateQuantity() instead — this local cart is not backed by the API.')
  void updateCartQuantity(CartResponse item, int qty) {
    if (qty <= 0) {
      removeFromCart(item);
      return;
    }
    for (var i in _cart) {
      if (i.productId == item.productId && i.selectedSize == item.selectedSize) {
        i.quantity = qty;
        break;
      }
    }
    notifyListeners();
  }

  @Deprecated('Use CartCubit.clearLocalCart() instead — this local cart is not backed by the API.')
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // Address operations
  void addAddress(ShippingAddress address) {
    _addresses.add(address);
    _selectedAddress = address;
    notifyListeners();
  }

  void removeAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_selectedAddress?.id == id) {
      _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
    }
    notifyListeners();
  }

  void selectAddress(ShippingAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  // Wishlist operations
  void toggleWishlist(ProductResponse product) {
    final idx = _wishlist.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      _wishlist.removeAt(idx);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  bool isWishlisted(ProductResponse product) {
    return _wishlist.any((p) => p.id == product.id);
  }

  // Order operations
  String placeOrder(String paymentMethod) {
    if (_cart.isEmpty || _selectedAddress == null) return '';

    final orderId = 'OD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final orderItems = _cart.map((c) {
      final price = double.tryParse(c.price ?? '') ?? 0.0;
      return Item(
        productId: c.productId,
        name: c.name,
        price: price.round(),
        quantity: c.quantity,
        image: c.image,
        selectedSize: c.selectedSize,
      );
    }).toList();

    final deliveryFee = cartSubtotal >= 499.0 ? 0.0 : 49.0;
    final newOrder = OrderResponse(
      id: orderId,
      totalPrice: (cartSubtotal + deliveryFee).toStringAsFixed(2),
      status: 'processing',
      createdAt: DateTime.now(),
      items: orderItems,
    );

    _orders.insert(0, newOrder);
    clearCart();

    _startOrderStatusSimulation(newOrder);
    notifyListeners();
    return orderId;
  }

  void _startOrderStatusSimulation(OrderResponse order) {
    void updateStatus(String newStatus) {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index == -1) return;
      final current = _orders[index];
      _orders[index] = OrderResponse(
        id: current.id,
        totalPrice: current.totalPrice,
        status: newStatus,
        createdAt: current.createdAt,
        items: current.items,
      );
      notifyListeners();
    }

    Timer(const Duration(seconds: 15), () {
      updateStatus('shipped');

      Timer(const Duration(seconds: 15), () {
        updateStatus('outForDelivery');

        Timer(const Duration(seconds: 15), () {
          updateStatus('delivered');
        });
      });
    });
  }

  // Auth methods
  void login(String email, String name) {
    _isLoggedIn = true;
    _userEmail = email;
    _userName = name;
    notifyListeners();
  }

  void signup(String email, String name) {
    _isLoggedIn = true;
    _userEmail = email;
    _userName = name;
    notifyListeners();
  }

  void logout() async {
    _isLoggedIn = false;
    await StorageService().clearAll();
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await ApiService().deleteAccount();
    _isLoggedIn = false;
    await StorageService().clearAll();
    notifyListeners();
  }
}

// InheritedWidget wrapper for easy access
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }
}