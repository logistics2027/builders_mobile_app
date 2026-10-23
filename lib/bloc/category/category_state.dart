// part of 'category_cubit.dart';

// sealed class CategoryState extends Equatable {
//   const CategoryState();

//   @override
//   List<Object> get props => [];
// }

// final class CategoryInitial extends CategoryState {}

// final class CategoryLoaded extends CategoryState {
//   final List<String> categories;
//   final String selectedCategory;

//   const CategoryLoaded({
//     required this.categories,
//     required this.selectedCategory,
//   });

//   CategoryLoaded copyWith({
//     List<String>? categories,
//     String? selectedCategory,
//   }) {
//     return CategoryLoaded(
//       categories: categories ?? this.categories,
//       selectedCategory: selectedCategory ?? this.selectedCategory,
//     );
//   }

//   @override
//   List<Object> get props => [categories, selectedCategory];
// }
part of 'category_cubit.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

final class CategoryInitial extends CategoryState {}

final class CategoryLoading extends CategoryState {}

final class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

final class CategoryLoaded extends CategoryState {
  final List<CategoryiesResponse> categories;
  final CategoryiesResponse selectedCategory;

  const CategoryLoaded({
    required this.categories,
    required this.selectedCategory,
  });

  CategoryLoaded copyWith({
    List<CategoryiesResponse>? categories,
    CategoryiesResponse? selectedCategory,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [categories, selectedCategory];
}