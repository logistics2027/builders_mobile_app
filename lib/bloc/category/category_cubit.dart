// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';

// part 'category_state.dart';

// class CategoryCubit extends Cubit<CategoryState> {
//   CategoryCubit() : super(CategoryInitial());

//   /// Call this whenever products are (re)loaded — e.g. from the
//   /// app-root BlocListener<ProductCubit, ProductState> in main.dart.
//   void setCategories(List<String> categories) {
//     if (categories.isEmpty) {
//       emit(CategoryInitial());
//       return;
//     }

//     final current = state;
//     final selected = (current is CategoryLoaded &&
//             categories.contains(current.selectedCategory))
//         ? current.selectedCategory
//         : categories.first;

//     emit(CategoryLoaded(categories: categories, selectedCategory: selected));
//   }

//   void selectCategory(String category) {
//     final current = state;
//     if (current is CategoryLoaded) {
//       emit(current.copyWith(selectedCategory: category));
//     }
//   }
// }

import 'package:bloc/bloc.dart';
import 'package:avg_mart/models/category_response.dart';
import 'package:avg_mart/service/api_service.dart';
import 'package:equatable/equatable.dart';



part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final ApiService _apiService;

  CategoryCubit({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(CategoryInitial());

  /// Fetches categories directly from the API (id, name, imageUrl, etc.)
  /// instead of deriving them from loaded products.
  Future<void> fetchCategories() async {
    emit(CategoryLoading());
    try {
      await _apiService.addToken();

      // Confirm this matches your ApiService method name — it should
      // return List<CategoryiesResponse> (or raw JSON you parse here
      // with categoryiesResponseFromJson).
      final List<CategoryiesResponse> categories =
          await _apiService.getCategories();

      if (categories.isEmpty) {
        emit(CategoryInitial());
        return;
      }

      final current = state;
      final selected = (current is CategoryLoaded &&
              categories.any((c) => c.id == current.selectedCategory.id))
          ? categories.firstWhere((c) => c.id == current.selectedCategory.id)
          : categories.first;

      emit(CategoryLoaded(categories: categories, selectedCategory: selected));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void selectCategory(CategoryiesResponse category) {
    final current = state;
    if (current is CategoryLoaded) {
      emit(current.copyWith(selectedCategory: category));
    }
  }
}