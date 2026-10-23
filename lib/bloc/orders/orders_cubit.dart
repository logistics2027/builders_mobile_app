import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:avg_mart/service/api_service.dart';
import 'package:equatable/equatable.dart';
import '../../models/order_response.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final ApiService _apiService;

  // Kept locally so review-related states can carry the list forward
  // without needing another network round trip.
  List<OrderResponse> _cachedOrders = [];

  OrdersCubit(this._apiService) : super(OrdersInitial());

  Future<void> fetchOrders() async {
    emit(OrdersLoading());
    try {
      final orders = await _apiService.getUserOrders();
      _cachedOrders = orders;
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  /// Same as fetchOrders but intended for pull-to-refresh,
  /// kept separate in case you later want to avoid flashing
  /// the loading state on refresh.
  Future<void> refreshOrders() => fetchOrders();

  Future<void> submitReview({
    required String productId,
    required int rating,
    required String comment,
    List<File> images = const [],
  }) async {
    emit(ReviewSubmitting(_cachedOrders));
    try {
      await _apiService.addProductReview(
        productId: productId,
        rating: rating,
        comment: comment,
        images: images,
      );
      emit(ReviewSubmitSuccess(_cachedOrders));
      // Settle back into a normal loaded state so the orders list
      // stays interactive after the dialog closes.
      emit(OrdersLoaded(_cachedOrders));
    } catch (e) {
      emit(ReviewSubmitFailure(_cachedOrders, e.toString()));
      emit(OrdersLoaded(_cachedOrders));
    }
  }
}