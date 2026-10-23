part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeBannerLoading extends HomeState {}

class HomeBannerLoaded extends HomeState {
  final List<Banners> banners;

  const HomeBannerLoaded(this.banners);

  @override
  List<Object?> get props => [banners];
}

class HomeBannerError extends HomeState {
  final String message;

  const HomeBannerError(this.message);

  @override
  List<Object?> get props => [message];
}