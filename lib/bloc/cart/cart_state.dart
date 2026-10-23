part of 'cart_cubit.dart';

enum CartStatus { initial, loading, loaded, error }

class CartItem extends Equatable {
  final int id; // cart row id — needed for update/delete calls
  final int? productId;
  final String name;
  final String category;
  final String price; // kept as string, matches API; parse with priceValue
  final String image;
  final int quantity;
  final String selectedSize;
  final DateTime? createdAt;

  const CartItem({
    required this.id,
    this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.quantity,
    required this.selectedSize,
    this.createdAt,
  });

  double get priceValue => double.tryParse(price) ?? 0.0;
  double get lineTotal => priceValue * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      productId: productId,
      name: name,
      category: category,
      price: price,
      image: image,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize,
      createdAt: createdAt,
    );
  }

  factory CartItem.fromCartResponse(CartResponse c) {
    return CartItem(
      id: c.id ?? 0,
      productId: c.productId,
      name: c.name ?? '',
      category: c.category ?? '',
      price: c.price ?? '0',
      image: c.image ?? '',
      quantity: c.quantity ?? 1,
      selectedSize: c.selectedSize ?? '',
      createdAt: c.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, productId, name, category, price, image, quantity, selectedSize];
}

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItem> items;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.lineTotal);

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}