part of 'orders_cubit.dart';

sealed class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

final class OrdersInitial extends OrdersState {}

final class OrdersLoading extends OrdersState {}

final class OrdersLoaded extends OrdersState {
  final List<OrderResponse> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

final class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
final class ReviewSubmitting extends OrdersState {
  final List<OrderResponse> orders;

  const ReviewSubmitting(this.orders);

  @override
  List<Object?> get props => [orders];
}

final class ReviewSubmitSuccess extends OrdersState {
  final List<OrderResponse> orders;

  const ReviewSubmitSuccess(this.orders);

  @override
  List<Object?> get props => [orders];
}

final class ReviewSubmitFailure extends OrdersState {
  final List<OrderResponse> orders;
  final String message;

  const ReviewSubmitFailure(this.orders, this.message);

  @override
  List<Object?> get props => [orders, message];
}