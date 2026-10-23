import 'package:flutter_bloc/flutter_bloc.dart';
import '../../service/storege_service.dart';

class SearchState {
  final List<String> searchHistory;
  final String currentSearchQuery;
  const SearchState({
    required this.searchHistory,
    required this.currentSearchQuery,
  });
}

class SearchCubit extends Cubit<SearchState> {
  final StorageService _storageService;
  static const String _storageKey = 'search_history';

  SearchCubit({StorageService? storageService})
      : _storageService = storageService ?? StorageService(),
        super(const SearchState(
          searchHistory: ['iphone', 'headphones', 'coffee press'],
          currentSearchQuery: '',
        )) {
    loadSearchHistory();
  }

  Future<void> loadSearchHistory() async {
    try {
      final data = await _storageService.getResponse(_storageKey);
      if (data != null && data['history'] is List) {
        final list = (data['history'] as List).map((e) => e.toString()).toList();
        emit(SearchState(
          searchHistory: list,
          currentSearchQuery: state.currentSearchQuery,
        ));
      }
    } catch (_) {
      // Ignore errors loading storage
    }
  }

  Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;
    final history = List<String>.from(state.searchHistory);
    history.remove(query);
    history.insert(0, query);
    if (history.length > 8) {
      history.removeLast();
    }
    emit(SearchState(
      searchHistory: history,
      currentSearchQuery: query,
    ));
    try {
      await _storageService.saveResponse(_storageKey, {
        'history': history,
      });
    } catch (_) {
      // Ignore errors saving storage
    }
  }

  void clearCurrentSearchQuery() {
    emit(SearchState(
      searchHistory: state.searchHistory,
      currentSearchQuery: '',
    ));
  }
}
