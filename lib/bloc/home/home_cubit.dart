import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:avg_mart/models/banner_response.dart';
import 'package:avg_mart/service/api_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ApiService _apiService;
  HomeCubit({ApiService? apiService})
    : _apiService = apiService ?? ApiService(),
      super(HomeInitial());

  Future<void> fetchBanners() async {
    emit(HomeBannerLoading());

    try {
      final response = await _apiService.getBanners();
      emit(HomeBannerLoaded(response.banners ?? []));
    } catch (e) {
      emit(HomeBannerError(e.toString()));
    }
  }
}
