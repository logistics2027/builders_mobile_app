// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../models/product_response.dart';
// import '../../service/storege_service.dart';

// class WishlistState {
//   final List<ProductResponse> items;
//   const WishlistState(this.items);
// }

// class WishlistCubit extends Cubit<WishlistState> {
//   final StorageService _storageService;
//   static const String _storageKey = 'wishlist_items';

//   WishlistCubit({StorageService? storageService})
//       : _storageService = storageService ?? StorageService(),
//         super(const WishlistState([])) {
//     loadWishlist();
//   }

//   Future<void> loadWishlist() async {
//     try {
//       final data = await _storageService.getResponse(_storageKey);
//       if (data != null && data['items'] is List) {
//         final list = (data['items'] as List)
//             .map((json) => ProductResponse.fromJson(json as Map<String, dynamic>))
//             .toList();
//         emit(WishlistState(list));
//       }
//     } catch (_) {
//       // Ignore errors loading storage
//     }
//   }

//   Future<void> toggleWishlist(ProductResponse product) async {
//     final list = List<ProductResponse>.from(state.items);
//     final idx = list.indexWhere((p) => p.id == product.id);
//     if (idx != -1) {
//       list.removeAt(idx);
//     } else {
//       list.add(product);
//     }
//     emit(WishlistState(list));
//     try {
//       await _storageService.saveResponse(_storageKey, {
//         'items': list.map((p) => p.toJson()).toList(),
//       });
//     } catch (_) {
//       // Ignore errors saving storage
//     }
//   }

//   bool isWishlisted(ProductResponse product) {
//     return state.items.any((p) => p.id == product.id);
//   }
// }
